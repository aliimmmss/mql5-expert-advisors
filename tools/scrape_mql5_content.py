#!/usr/bin/env python3
"""
MQL5 Article Content Scraper v3 - curl subprocess + parallel per-article fetching.
"""

import json
import time
import re
import random
import subprocess
import sys
from pathlib import Path
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

DATA_DIR = Path(__file__).parent.parent / "data"
ARTICLES_FILE = DATA_DIR / "mql5_articles_all.json"
PROGRESS_FILE = DATA_DIR / "scrape_progress.json"

SAVE_EVERY = 10
TIMEOUT = 8
DELAY = (0.3, 0.8)
MIN_PROXIES = 3
STALL_TIMEOUT = 120
PARALLEL_PER_ARTICLE = 3  # try 3 proxies simultaneously per article

PROXY_SOURCES = [
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt",
    "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/http.txt",
    "https://raw.githubusercontent.com/roosterkid/openproxylist/main/HTTPS_RAW.txt",
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/https.txt",
    "https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt",
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt",
    "https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/txt/proxies-http.txt",
]

BOILERPLATE = [
    "This article was written by a user", "Allow the use of cookies",
    "Please enable the necessary", "MetaQuotes Ltd is not responsible",
    "To write a comment", "Comments not found", "You are missing trading opportunities",
]


def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)


def fetch_proxy_lists():
    all_proxies = set()
    for url in PROXY_SOURCES:
        try:
            result = subprocess.run(
                ["curl", "-sL", "--max-time", "8", url],
                capture_output=True, text=True, timeout=12
            )
            for line in result.stdout.strip().split("\n"):
                line = line.strip()
                if re.match(r'^\d+\.\d+\.\d+\.\d+:\d+$', line):
                    all_proxies.add(line)
        except:
            pass
    return list(all_proxies)


def test_proxy_curl(proxy):
    """Test proxy with curl - much faster than urllib."""
    try:
        result = subprocess.run(
            ["curl", "-s", "--max-time", "6", "-x", f"http://{proxy}",
             "-H", "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
             "https://www.mql5.com/en/articles/19979"],
            capture_output=True, timeout=8
        )
        return result.returncode == 0 and len(result.stdout) > 5000
    except:
        return False


def test_proxies_parallel(proxies, max_workers=30):
    live = []
    with ThreadPoolExecutor(max_workers=max_workers) as ex:
        futs = {ex.submit(test_proxy_curl, p): p for p in proxies}
        for fut in as_completed(futs):
            try:
                if fut.result():
                    live.append(futs[fut])
            except:
                pass
    return live


def fetch_article_curl(url, proxy):
    """Fetch article with curl subprocess - fast and reliable."""
    result = subprocess.run(
        ["curl", "-s", "--max-time", str(TIMEOUT), "-x", f"http://{proxy}",
         "-H", "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
         "-H", "Accept: text/html,application/xhtml+xml",
         url],
        capture_output=True, timeout=TIMEOUT + 3
    )
    
    if result.returncode != 0:
        return None, 0
    
    html = result.stdout.decode("utf-8", errors="ignore")
    if len(html) < 1000:
        return None, 0
    
    # Title
    title = None
    m = re.search(r'<h1[^>]*>(.*?)</h1>', html, re.DOTALL)
    if m:
        title = re.sub(r'<[^>]+>', '', m.group(1)).strip()
    
    # Paragraphs
    paragraphs = re.findall(r'<p[^>]*>(.*?)</p>', html, re.DOTALL)
    texts = []
    for p_html in paragraphs:
        t = re.sub(r'<[^>]+>', ' ', p_html)
        t = re.sub(r'&nbsp;', ' ', t)
        t = re.sub(r'&amp;', '&', t)
        t = re.sub(r'&lt;', '<', t)
        t = re.sub(r'&gt;', '>', t)
        t = re.sub(r'&#\d+;', '', t)
        t = re.sub(r'\s+', ' ', t).strip()
        if len(t) > 20:
            texts.append(t)
    
    filtered = [t for t in texts if not any(b in t for b in BOILERPLATE)]
    content = "\n\n".join(filtered)
    
    if len(content) > 100:
        return {"title": title, "content": content, "para_count": len(filtered)}, 200
    return None, 200


def fetch_with_parallel_proxies(url, proxies, n=PARALLEL_PER_ARTICLE):
    """Try N proxies simultaneously, return first success."""
    chosen = random.sample(proxies, min(n, len(proxies)))
    
    with ThreadPoolExecutor(max_workers=n) as ex:
        futs = {ex.submit(fetch_article_curl, url, p): p for p in chosen}
        for fut in as_completed(futs):
            try:
                result, status = fut.result()
                if result:
                    return result, status, futs[fut]
            except:
                pass
    
    # All failed - check if any returned 200 (page loaded but no content)
    return None, 0, None


def recycle_proxies():
    log("Recycling proxies — fetching fresh lists...")
    all_proxies = fetch_proxy_lists()
    log(f"  Downloaded {len(all_proxies)} proxy candidates")
    
    if not all_proxies:
        return []
    
    sample = random.sample(all_proxies, min(400, len(all_proxies)))
    log(f"  Testing {len(sample)} proxies in parallel...")
    live = test_proxies_parallel(sample)
    log(f"  Found {len(live)} live proxies")
    return live


def main():
    log("=" * 50)
    log("MQL5 Content Scraper v3 - curl + parallel proxies")
    log("=" * 50)
    
    with open(ARTICLES_FILE) as f:
        data = json.load(f)
    articles = data["articles"]
    
    completed = set()
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE) as f:
            completed = set(json.load(f).get("completed", []))
    
    live_proxies = recycle_proxies()
    if not live_proxies:
        log("No live proxies found!")
        return
    
    to_fetch = [a for a in articles if a["id"] not in completed and not a.get("content")]
    log(f"Articles to fetch: {len(to_fetch)}")
    
    if not to_fetch:
        log("Nothing to fetch!")
        return
    
    success = 0
    no_content = 0
    proxy_failures = 0
    last_progress_time = time.time()
    
    for i, article in enumerate(to_fetch):
        # Stall detection
        if time.time() - last_progress_time > STALL_TIMEOUT:
            log(f"STALL detected. Recycling proxies...")
            save_state(completed, articles, data)
            new_proxies = recycle_proxies()
            if new_proxies:
                live_proxies = new_proxies
            last_progress_time = time.time()
        
        # Low proxy count
        if len(live_proxies) < MIN_PROXIES:
            log(f"Low proxies ({len(live_proxies)}). Recycling...")
            save_state(completed, articles, data)
            new_proxies = recycle_proxies()
            if new_proxies:
                live_proxies = list(set(live_proxies + new_proxies))
            elif not live_proxies:
                log("ALL PROXIES DEAD!")
                break
        
        url = article["url"]
        aid = article["id"]
        
        result, status, used_proxy = fetch_with_parallel_proxies(url, live_proxies)
        
        if result:
            for a in articles:
                if a["id"] == aid:
                    a["content"] = result["content"]
                    if result.get("title") and not a["title"]:
                        a["title"] = result["title"]
                    break
            completed.add(aid)
            success += 1
            last_progress_time = time.time()
        elif status == 200:
            completed.add(aid)
            no_content += 1
        else:
            proxy_failures += 1
        
        n = i + 1
        if n % 10 == 0:
            with_c = sum(1 for a in articles if a.get("content"))
            pct = (n / len(to_fetch)) * 100
            log(f"[{n}/{len(to_fetch)} ({pct:.0f}%)] ✓{success} ✗{no_content} 💀{proxy_failures} | {len(live_proxies)}px | {with_c} total")
        
        if n % SAVE_EVERY == 0:
            save_state(completed, articles, data)
        
        time.sleep(random.uniform(*DELAY))
    
    save_state(completed, articles, data)
    with_c = sum(1 for a in articles if a.get("content"))
    log("=" * 50)
    log(f"DONE: ✓{success} ✗{no_content} 💀{proxy_failures} | {with_c}/{len(articles)} total")
    log("=" * 50)


def save_state(completed, articles, data):
    with open(PROGRESS_FILE, "w") as f:
        json.dump({"completed": list(completed), "last_updated": datetime.now().isoformat()}, f, indent=2)
    data["articles"] = articles
    data["metadata"]["last_scraped"] = datetime.now().isoformat()
    with open(ARTICLES_FILE, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()

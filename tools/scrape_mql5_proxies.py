#!/usr/bin/env python3
"""
MQL5 Article Scraper with Free Proxy Rotation
Uses Scrapling + rotating free proxies to bypass IP blocks.
Fetches full content for all article URLs.
"""

import json
import time
import re
import random
import urllib.request
from pathlib import Path
from datetime import datetime

# Paths
DATA_DIR = Path(__file__).parent.parent / "data"
ARTICLES_FILE = DATA_DIR / "mql5_articles_all.json"
PROXIES_FILE = DATA_DIR / "proxies.json"
PROGRESS_FILE = DATA_DIR / "scrape_progress.json"

# Config
MAX_RETRIES = 3
DELAY_BETWEEN_REQUESTS = (2, 5)  # Random delay range in seconds
PROXY_TEST_TIMEOUT = 10
ARTICLE_FETCH_TIMEOUT = 15


def fetch_free_proxies():
    """Fetch free proxies from multiple sources."""
    proxies = set()
    
    # Source 1: free-proxy-list.net
    try:
        url = "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        resp = urllib.request.urlopen(req, timeout=15)
        for line in resp.read().decode().strip().split("\n"):
            line = line.strip()
            if line and ":" in line:
                proxies.add(f"http://{line}")
        print(f"  Fetched {len(proxies)} proxies from TheSpeedX")
    except Exception as e:
        print(f"  Failed to fetch from TheSpeedX: {e}")
    
    # Source 2: Another proxy list
    try:
        url = "https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        resp = urllib.request.urlopen(req, timeout=15)
        count = 0
        for line in resp.read().decode().strip().split("\n"):
            line = line.strip()
            if line and ":" in line and not line.startswith("#"):
                proxies.add(f"http://{line}")
                count += 1
        print(f"  Fetched {count} proxies from clarketm")
    except Exception as e:
        print(f"  Failed to fetch from clarketm: {e}")
    
    # Source 3: monosans proxy list
    try:
        url = "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/http.txt"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        resp = urllib.request.urlopen(req, timeout=15)
        count = 0
        for line in resp.read().decode().strip().split("\n"):
            line = line.strip()
            if line and ":" in line:
                proxies.add(f"http://{line}")
                count += 1
        print(f"  Fetched {count} proxies from monosans")
    except Exception as e:
        print(f"  Failed to fetch from monosans: {e}")
    
    print(f"\nTotal unique proxies: {len(proxies)}")
    return list(proxies)


def test_proxy(proxy, test_url="https://httpbin.org/ip"):
    """Test if a proxy works."""
    try:
        req = urllib.request.Request(test_url, headers={"User-Agent": "Mozilla/5.0"})
        proxy_handler = urllib.request.ProxyHandler({"http": proxy, "https": proxy})
        opener = urllib.request.build_opener(proxy_handler)
        resp = opener.open(req, timeout=PROXY_TEST_TIMEOUT)
        return resp.status == 200
    except:
        return False


def test_proxies_batch(proxies, batch_size=50):
    """Test a batch of proxies and return working ones."""
    print(f"\nTesting {min(batch_size, len(proxies))} proxies...")
    working = []
    
    sample = random.sample(proxies, min(batch_size, len(proxies)))
    for i, proxy in enumerate(sample):
        if test_proxy(proxy):
            working.append(proxy)
            print(f"  ✓ {proxy}")
            if len(working) >= 10:  # We have enough working proxies
                break
        if (i + 1) % 10 == 0:
            print(f"  Tested {i+1}/{len(sample)}, {len(working)} working...")
    
    print(f"Found {len(working)} working proxies")
    return working


def fetch_article_with_proxy(url, proxy):
    """Fetch a single article using Scrapling with a proxy."""
    from scrapling.fetchers import Fetcher
    
    try:
        p = Fetcher.get(url, stealthy_headers=True, proxy=proxy, timeout=ARTICLE_FETCH_TIMEOUT)
        
        if p.status != 200:
            return None
        
        html = p.text
        
        # Extract article content
        # Look for the main article content div
        content = ""
        
        # Try to find article body
        # MQL5 articles typically have content in specific divs
        body_match = re.search(r'<div[^>]*class="[^"]*article-body[^"]*"[^>]*>(.*?)</div>', html, re.DOTALL)
        if body_match:
            content = body_match.group(1)
        else:
            # Try other common patterns
            body_match = re.search(r'<div[^>]*class="[^"]*article__body[^"]*"[^>]*>(.*?)</div>', html, re.DOTALL)
            if body_match:
                content = body_match.group(1)
            else:
                # Try to find the main content area
                body_match = re.search(r'<article[^>]*>(.*?)</article>', html, re.DOTALL)
                if body_match:
                    content = body_match.group(1)
        
        if not content:
            return None
        
        # Clean HTML to text
        content = re.sub(r'<script[^>]*>.*?</script>', '', content, flags=re.DOTALL)
        content = re.sub(r'<style[^>]*>.*?</style>', '', content, flags=re.DOTALL)
        content = re.sub(r'<[^>]+>', ' ', content)
        content = re.sub(r'\s+', ' ', content).strip()
        
        # Also extract title if not already present
        title = ""
        title_match = re.search(r'<h1[^>]*>(.*?)</h1>', html, re.DOTALL)
        if title_match:
            title = re.sub(r'<[^>]+>', '', title_match.group(1)).strip()
        
        # Extract author
        author = ""
        author_match = re.search(r'<a[^>]*class="[^"]*author[^"]*"[^>]*>(.*?)</a>', html, re.DOTALL)
        if author_match:
            author = re.sub(r'<[^>]+>', '', author_match.group(1)).strip()
        
        return {
            "content": content,
            "title": title if title else None,
            "author": author if author else None,
            "fetched_at": datetime.now().isoformat(),
        }
        
    except Exception as e:
        return None


def main():
    """Main scraping function."""
    print("=" * 60)
    print("MQL5 Article Scraper with Free Proxy Rotation")
    print("=" * 60)
    
    # Load articles
    with open(ARTICLES_FILE) as f:
        data = json.load(f)
    
    articles = data["articles"]
    print(f"\nTotal articles: {len(articles)}")
    
    # Load progress if exists
    progress = {}
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE) as f:
            progress = json.load(f)
        print(f"Resuming from progress: {len(progress.get('completed', []))} completed")
    
    completed = set(progress.get("completed", []))
    failed = progress.get("failed", [])
    
    # Filter articles that need fetching
    to_fetch = [a for a in articles if a["id"] not in completed]
    print(f"Articles to fetch: {len(to_fetch)}")
    
    if not to_fetch:
        print("All articles already fetched!")
        return
    
    # Fetch and test proxies
    print("\n[1/4] Fetching free proxies...")
    all_proxies = fetch_free_proxies()
    
    if not all_proxies:
        print("ERROR: No proxies found!")
        return
    
    # Save proxies
    with open(PROXIES_FILE, "w") as f:
        json.dump(all_proxies, f, indent=2)
    
    # Test proxies
    print("\n[2/4] Testing proxies...")
    working_proxies = test_proxies_batch(all_proxies)
    
    if not working_proxies:
        print("ERROR: No working proxies found!")
        print("Trying direct connection as last resort...")
        working_proxies = [None]  # None = no proxy (direct)
    
    # Fetch articles
    print(f"\n[3/4] Fetching {len(to_fetch)} articles...")
    success_count = 0
    fail_count = 0
    proxy_fails = {}
    
    for i, article in enumerate(to_fetch):
        url = article["url"]
        article_id = article["id"]
        
        # Pick a proxy (rotate through working ones)
        proxy = working_proxies[i % len(working_proxies)]
        
        # Try to fetch
        result = None
        for retry in range(MAX_RETRIES):
            result = fetch_article_with_proxy(url, proxy)
            if result:
                break
            
            # If failed, try a different proxy
            proxy = working_proxies[(i + retry + 1) % len(working_proxies)]
            time.sleep(1)
        
        if result:
            # Update article with fetched content
            for a in articles:
                if a["id"] == article_id:
                    if result["content"]:
                        a["content"] = result["content"]
                    if result["title"] and not a["title"]:
                        a["title"] = result["title"]
                    if result["author"]:
                        a["author"] = result["author"]
                    break
            
            completed.add(article_id)
            success_count += 1
            
            if success_count % 10 == 0:
                print(f"  ✓ [{i+1}/{len(to_fetch)}] Fetched {success_count} articles...")
        else:
            fail_count += 1
            failed.append(article_id)
            
            # Track proxy failures
            if proxy:
                proxy_fails[proxy] = proxy_fails.get(proxy, 0) + 1
        
        # Save progress every 50 articles
        if (i + 1) % 50 == 0:
            save_progress(completed, failed, articles, data)
            print(f"  Progress saved ({len(completed)} completed)")
        
        # Random delay
        delay = random.uniform(*DELAY_BETWEEN_REQUESTS)
        time.sleep(delay)
    
    # Final save
    save_progress(completed, failed, articles, data)
    
    print(f"\n[4/4] Summary:")
    print(f"  ✓ Successfully fetched: {success_count}")
    print(f"  ✗ Failed: {fail_count}")
    print(f"  Total completed: {len(completed)}")
    print(f"  Remaining: {len(articles) - len(completed)}")


def save_progress(completed, failed, articles, data):
    """Save progress and updated articles."""
    # Save progress
    progress = {
        "completed": list(completed),
        "failed": failed,
        "last_updated": datetime.now().isoformat(),
    }
    with open(PROGRESS_FILE, "w") as f:
        json.dump(progress, f, indent=2)
    
    # Save updated articles
    data["articles"] = articles
    data["metadata"]["last_scraped"] = datetime.now().isoformat()
    with open(ARTICLES_FILE, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()

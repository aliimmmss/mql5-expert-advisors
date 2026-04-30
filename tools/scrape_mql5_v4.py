#!/usr/bin/env python3
"""
MQL5 Article Scraper v4 — Direct access, no proxies.
Uses proper headers + rate limiting to avoid 403s.
"""

import json
import time
import re
import sys
import requests
from pathlib import Path

# Config
DATA_DIR = Path(__file__).parent.parent / "data"
ARTICLES_FILE = DATA_DIR / "mql5_articles_all.json"
CHECKPOINT_EVERY = 50
DELAY_MIN = 3.0
DELAY_MAX = 6.0
MAX_RETRIES = 3

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
}


def extract_article_content(html: str) -> dict:
    result = {"title": None, "content": None}
    title_match = re.search(r'<h1[^>]*>(.*?)</h1>', html, re.DOTALL)
    if title_match:
        result["title"] = re.sub(r'<[^>]+>', '', title_match.group(1)).strip()
    article_match = re.search(r'<article[^>]*>(.*?)</article>', html, re.DOTALL)
    if article_match:
        body = article_match.group(1)
        body = re.sub(r'<script[^>]*>.*?</script>', '', body, flags=re.DOTALL)
        body = re.sub(r'<style[^>]*>.*?</style>', '', body, flags=re.DOTALL)
        body = re.sub(r'<br\s*/?>', '\n', body)
        body = re.sub(r'</p>', '\n\n', body)
        body = re.sub(r'</h[1-6]>', '\n\n', body)
        body = re.sub(r'<[^>]+>', '', body)
        body = re.sub(r'\n{3,}', '\n\n', body)
        body = re.sub(r'[ \t]+', ' ', body)
        body = body.strip()
        if len(body) > 100:
            result["content"] = body
    return result


def main():
    print("Loading articles...", flush=True)
    with open(ARTICLES_FILE) as f:
        data = json.load(f)

    articles = data["articles"]
    missing = [i for i, a in enumerate(articles) if not a.get("content")]
    total_missing = len(missing)

    print(f"📊 Total articles: {len(articles)}", flush=True)
    print(f"✅ Already scraped: {len(articles) - total_missing}", flush=True)
    print(f"📥 To scrape: {total_missing}", flush=True)
    print(f"⏱️  Estimated time: {total_missing * 5 / 60:.0f} minutes", flush=True)
    print(flush=True)

    if total_missing == 0:
        print("🎉 All articles already scraped!", flush=True)
        return

    session = requests.Session()
    scraped = 0
    failed = 0
    start_time = time.time()

    for idx in missing:
        article = articles[idx]
        url = article["url"]
        print(f"[{scraped+failed+1}/{total_missing}] {url}", flush=True)

        for attempt in range(MAX_RETRIES):
            try:
                resp = session.get(url, headers=HEADERS, timeout=30)
                if resp.status_code == 200:
                    result = extract_article_content(resp.text)
                    if result and result.get("content"):
                        articles[idx]["content"] = result["content"]
                        if result.get("title"):
                            articles[idx]["title"] = result["title"]
                        scraped += 1
                        print(f"  ✅ Scraped ({len(result['content'])} chars)", flush=True)
                    else:
                        failed += 1
                        print(f"  ❌ No content extracted", flush=True)
                    break
                elif resp.status_code == 429:
                    wait = 30 * (attempt + 1)
                    print(f"  ⚠️  Rate limited, waiting {wait}s...", flush=True)
                    time.sleep(wait)
                else:
                    print(f"  ❌ HTTP {resp.status_code}", flush=True)
                    failed += 1
                    break
            except Exception as e:
                print(f"  ❌ Error: {e}", flush=True)
                if attempt < MAX_RETRIES - 1:
                    time.sleep(5)
                else:
                    failed += 1

        # Checkpoint
        if (scraped + failed) % CHECKPOINT_EVERY == 0:
            with open(ARTICLES_FILE, "w") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            elapsed = time.time() - start_time
            rate = (scraped + failed) / elapsed * 60
            remaining = (total_missing - scraped - failed) / rate if rate > 0 else 0
            print(f"\n💾 Checkpoint: {scraped} scraped, {failed} failed, {rate:.1f}/min, ~{remaining:.0f} min left\n", flush=True)

        import random
        time.sleep(random.uniform(DELAY_MIN, DELAY_MAX))

    # Final save
    with open(ARTICLES_FILE, "w") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    elapsed = time.time() - start_time
    print(f"\n{'='*50}", flush=True)
    print(f"✅ Scraped: {scraped}", flush=True)
    print(f"❌ Failed: {failed}", flush=True)
    print(f"⏱️  Time: {elapsed/60:.1f} minutes", flush=True)
    print(f"📊 Total with content: {sum(1 for a in articles if a.get('content'))}/{len(articles)}", flush=True)


if __name__ == "__main__":
    main()

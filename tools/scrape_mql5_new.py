#!/usr/bin/env python3
"""
Scrape new MQL5 articles — finds articles not in existing dataset,
fetches their metadata + content, and merges into the main JSON.
"""

import json
import re
import time
import random
import requests
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"
ARTICLES_FILE = DATA_DIR / "mql5_articles_all.json"
CHECKPOINT_EVERY = 20
DELAY_MIN = 2.0
DELAY_MAX = 4.0
MAX_RETRIES = 3

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
}


def extract_article(html: str, article_id: int) -> dict:
    """Extract title, content, and date from article HTML."""
    result = {"title": None, "content": None, "date": None, "id": str(article_id)}

    # Title
    title_match = re.search(r'<h1[^>]*>(.*?)</h1>', html, re.DOTALL)
    if title_match:
        result["title"] = re.sub(r'<[^>]+>', '', title_match.group(1)).strip()

    # Published date
    date_match = re.search(r'article:published_time[^>]*content="([^"]*)"', html)
    if date_match:
        result["date"] = date_match.group(1)[:10]

    # Content from <article> tag
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


def discover_new_ids(existing_ids: set) -> list:
    """Scrape listing pages to find article IDs not in existing set."""
    all_ids = set()
    session = requests.Session()
    page = 1

    while True:
        url = f"https://www.mql5.com/en/articles/page{page}"
        try:
            resp = session.get(url, headers=HEADERS, timeout=30)
            if resp.status_code != 200:
                break
            ids = set(int(m) for m in re.findall(r'/en/articles/(\d+)', resp.text))
            if not ids:
                break
            all_ids.update(ids)
            print(f"  Page {page}: {len(ids)} articles (total: {len(all_ids)})")
            if max(ids) < min(existing_ids):
                break
            page += 1
            time.sleep(1)
        except Exception as e:
            print(f"  Page {page}: Error {e}")
            break

    new_ids = sorted(all_ids - existing_ids)
    return new_ids


def main():
    print("=== MQL5 New Article Scraper ===\n")

    # Load existing data
    print("Loading existing articles...")
    with open(ARTICLES_FILE) as f:
        data = json.load(f)

    articles = data["articles"]
    existing_ids = set()
    for a in articles:
        if a.get("id"):
            existing_ids.add(int(a["id"]))
        else:
            m = re.search(r'/(\d+)$', a["url"])
            if m:
                existing_ids.add(int(m.group(1)))

    print(f"Existing: {len(articles)} articles ({len(existing_ids)} unique IDs)\n")

    # Discover new articles
    print("Discovering new articles from listing pages...")
    new_ids = discover_new_ids(existing_ids)
    print(f"\nFound {len(new_ids)} new articles\n")

    if not new_ids:
        print("No new articles to scrape!")
        return

    # Scrape new articles
    session = requests.Session()
    scraped = 0
    failed = 0
    start_time = time.time()
    new_articles = []

    for i, aid in enumerate(new_ids):
        url = f"https://www.mql5.com/en/articles/{aid}"
        print(f"[{i+1}/{len(new_ids)}] #{aid}")

        for attempt in range(MAX_RETRIES):
            try:
                resp = session.get(url, headers=HEADERS, timeout=30)
                if resp.status_code == 200:
                    result = extract_article(resp.text, aid)
                    result["url"] = url
                    result["page"] = 0  # not from listing pagination
                    new_articles.append(result)
                    if result.get("content"):
                        scraped += 1
                        print(f"  ✅ {result.get('date', '?')} | {result.get('title', '?')[:70]} ({len(result['content'])} chars)")
                    else:
                        failed += 1
                        print(f"  ⚠️ Got metadata but no content")
                    break
                elif resp.status_code == 429:
                    wait = 30 * (attempt + 1)
                    print(f"  ⚠️ Rate limited, waiting {wait}s...")
                    time.sleep(wait)
                else:
                    print(f"  ❌ HTTP {resp.status_code}")
                    failed += 1
                    break
            except Exception as e:
                print(f"  ❌ Error: {e}")
                if attempt < MAX_RETRIES - 1:
                    time.sleep(5)
                else:
                    failed += 1

        # Checkpoint every N articles
        if (scraped + failed) % CHECKPOINT_EVERY == 0 and new_articles:
            elapsed = time.time() - start_time
            rate = (scraped + failed) / elapsed * 60
            remaining = (len(new_ids) - scraped - failed) / rate if rate > 0 else 0
            print(f"\n💾 Checkpoint: {scraped} scraped, {failed} failed, {rate:.1f}/min, ~{remaining:.0f} min left\n")

        time.sleep(random.uniform(DELAY_MIN, DELAY_MAX))

    # Merge new articles into existing data
    print(f"\n{'='*50}")
    print(f"Merging {len(new_articles)} new articles into dataset...")
    articles.extend(new_articles)
    data["articles"] = articles

    # Save
    with open(ARTICLES_FILE, "w") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    elapsed = time.time() - start_time
    total_with_content = sum(1 for a in articles if a.get("content"))
    print(f"\n{'='*50}")
    print(f"✅ New articles scraped: {scraped}")
    print(f"❌ Failed: {failed}")
    print(f"⏱️  Time: {elapsed/60:.1f} minutes")
    print(f"📊 Total articles: {len(articles)}")
    print(f"📊 Total with content: {total_with_content}/{len(articles)}")

    # Show latest by date
    dated = [a for a in new_articles if a.get("date")]
    dated.sort(key=lambda x: x["date"], reverse=True)
    print(f"\n📅 Latest new articles by date:")
    for a in dated[:20]:
        print(f"  {a['date']} | #{a['id']} | {a.get('title', '?')[:70]}")


if __name__ == "__main__":
    main()

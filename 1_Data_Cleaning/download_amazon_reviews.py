"""Download Amazon Reviews 2023 (McAuley Lab) into 0_Data/amazon_reviews_2023/.

Files are kept as gzipped JSON Lines (one JSON object per line):
    reviews/<Category>.jsonl.gz       user reviews
    meta/meta_<Category>.jsonl.gz     item metadata (title, price, ...)

Examples:
    python download_amazon_reviews.py                          # All_Beauty
    python download_amazon_reviews.py -c Software Video_Games
    python download_amazon_reviews.py -c All_Beauty --no-meta
    python download_amazon_reviews.py --list
"""

import argparse
import sys

import requests

import config
from download_utils import download_file


def download_category(category: str, meta: bool = True, overwrite: bool = False) -> None:
    print(f"\n== Amazon Reviews 2023: {category} ==")
    targets = [(
        config.AMAZON_REVIEW_URL.format(category=category),
        config.AMAZON_DIR / "reviews" / f"{category}.jsonl.gz",
    )]
    if meta:
        targets.append((
            config.AMAZON_META_URL.format(category=category),
            config.AMAZON_DIR / "meta" / f"meta_{category}.jsonl.gz",
        ))
    for url, dest in targets:
        download_file(url, dest, overwrite=overwrite)


def download_amazon(categories=None, meta: bool = True, overwrite: bool = False) -> bool:
    """Download the given categories. Returns True if all succeeded."""
    categories = categories or config.AMAZON_DEFAULT_CATEGORIES
    unknown = [c for c in categories if c not in config.AMAZON_CATEGORIES]
    if unknown:
        print(f"Unknown categories: {unknown}. Use --list to see valid names.")
        return False

    ok = True
    for cat in categories:
        try:
            download_category(cat, meta=meta, overwrite=overwrite)
        except requests.RequestException as e:
            print(f"  [error] {cat}: {e}")
            ok = False
    return ok


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-c", "--categories", nargs="+",
                   help=f"Categories to download (default: {config.AMAZON_DEFAULT_CATEGORIES}). Use 'all' for every category.")
    p.add_argument("--no-meta", action="store_true", help="Skip item metadata files.")
    p.add_argument("--overwrite", action="store_true", help="Re-download files that already exist.")
    p.add_argument("--list", action="store_true", help="List available categories and exit.")
    args = p.parse_args()

    if args.list:
        print("\n".join(config.AMAZON_CATEGORIES))
        return

    cats = args.categories
    if cats and [c.lower() for c in cats] == ["all"]:
        cats = config.AMAZON_CATEGORIES
    sys.exit(0 if download_amazon(cats, meta=not args.no_meta, overwrite=args.overwrite) else 1)


if __name__ == "__main__":
    main()

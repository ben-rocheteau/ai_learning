"""One-shot setup: download every dataset into 0_Data/ (git-ignored).

Run from anywhere:
    python 1_Data_Cleaning/setup_data.py
    python 1_Data_Cleaning/setup_data.py --amazon-categories All_Beauty Software
    python 1_Data_Cleaning/setup_data.py --skip-imdb
    python 1_Data_Cleaning/setup_data.py --skip-amazon
"""

import argparse
import sys

import config
from download_amazon_reviews import download_amazon
from download_imdb import download_imdb


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--amazon-categories", nargs="+",
                   help=f"Amazon categories (default: {config.AMAZON_DEFAULT_CATEGORIES}; 'all' for every one).")
    p.add_argument("--no-amazon-meta", action="store_true", help="Skip Amazon item metadata.")
    p.add_argument("--skip-amazon", action="store_true")
    p.add_argument("--skip-imdb", action="store_true")
    p.add_argument("--overwrite", action="store_true", help="Re-download existing files.")
    args = p.parse_args()

    config.DATA_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Data directory: {config.DATA_DIR}")

    results = {}
    if not args.skip_amazon:
        cats = args.amazon_categories
        if cats and [c.lower() for c in cats] == ["all"]:
            cats = config.AMAZON_CATEGORIES
        results["amazon"] = download_amazon(cats, meta=not args.no_amazon_meta, overwrite=args.overwrite)
    if not args.skip_imdb:
        results["imdb"] = download_imdb(overwrite=args.overwrite)

    print("\n== Summary ==")
    for name, ok in results.items():
        print(f"  {name:<8} {'OK' if ok else 'FAILED'}")
    sys.exit(0 if all(results.values()) else 1)


if __name__ == "__main__":
    main()

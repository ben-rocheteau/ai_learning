"""Download the IMDB 50K movie reviews dataset (Kaggle) into 0_Data/imdb_50k/.

Uses `kagglehub`. Public datasets usually download without login; if Kaggle
asks for credentials, either:
  - run `python -c "import kagglehub; kagglehub.login()"`, or
  - set KAGGLE_USERNAME and KAGGLE_KEY env vars, or
  - place kaggle.json in ~/.kaggle/ (from kaggle.com > Settings > API).

Result: 0_Data/imdb_50k/IMDB Dataset.csv  (columns: review, sentiment)
"""

import argparse
import shutil
import sys
from pathlib import Path

import config


def download_imdb(overwrite: bool = False) -> bool:
    print("\n== IMDB 50K movie reviews ==")
    dest = config.IMDB_DIR / config.IMDB_CSV_NAME
    if dest.exists() and not overwrite:
        print(f"  [skip] {dest.name} already exists")
        return True

    try:
        import kagglehub
    except ImportError:
        print("  [error] kagglehub not installed: pip install -r requirements.txt")
        return False

    try:
        # Downloads into kagglehub's cache (~/.cache/kagglehub) and returns that folder.
        cache_dir = Path(kagglehub.dataset_download(config.IMDB_KAGGLE_HANDLE))
    except Exception as e:  # kagglehub raises several error types
        print(f"  [error] Kaggle download failed: {e}")
        print("  See the docstring of download_imdb.py for how to set Kaggle credentials.")
        return False

    config.IMDB_DIR.mkdir(parents=True, exist_ok=True)
    csvs = list(cache_dir.rglob("*.csv"))
    if not csvs:
        print(f"  [error] No CSV found in {cache_dir}")
        return False
    for csv in csvs:
        shutil.copy2(csv, config.IMDB_DIR / csv.name)
        print(f"  [ok] {config.IMDB_DIR / csv.name}")
    return True


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--overwrite", action="store_true", help="Re-copy even if the CSV already exists.")
    args = p.parse_args()
    sys.exit(0 if download_imdb(overwrite=args.overwrite) else 1)


if __name__ == "__main__":
    main()

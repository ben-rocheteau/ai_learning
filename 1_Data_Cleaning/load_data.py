"""Helpers to load the downloaded datasets into pandas.

    from load_data import load_amazon_reviews, load_amazon_meta, load_imdb
    reviews = load_amazon_reviews("All_Beauty", nrows=10_000)
    imdb = load_imdb()
"""

import pandas as pd

import config


def _check(path):
    if not path.exists():
        raise FileNotFoundError(f"{path} not found. Run: python 1_Data_Cleaning/setup_data.py")
    return path


def load_amazon_reviews(category: str = "All_Beauty", nrows: int | None = None) -> pd.DataFrame:
    path = _check(config.AMAZON_DIR / "reviews" / f"{category}.jsonl.gz")
    return pd.read_json(path, lines=True, compression="gzip", nrows=nrows)


def load_amazon_meta(category: str = "All_Beauty", nrows: int | None = None) -> pd.DataFrame:
    path = _check(config.AMAZON_DIR / "meta" / f"meta_{category}.jsonl.gz")
    return pd.read_json(path, lines=True, compression="gzip", nrows=nrows)


def load_imdb() -> pd.DataFrame:
    return pd.read_csv(_check(config.IMDB_DIR / config.IMDB_CSV_NAME))


if __name__ == "__main__":
    for name, fn in [("Amazon reviews", lambda: load_amazon_reviews(nrows=5)), ("IMDB", load_imdb)]:
        try:
            df = fn()
            print(f"\n{name}: {df.shape}\n{df.head()}")
        except FileNotFoundError as e:
            print(f"\n{name}: {e}")

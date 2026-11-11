"""Shared paths and dataset settings for the data setup scripts."""

import os
from pathlib import Path

# Repo root = parent of this folder. Data lives in <root>/0_Data (git-ignored).
REPO_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = Path(os.environ.get("AI_LEARNING_DATA_DIR", REPO_ROOT / "0_Data"))

AMAZON_DIR = DATA_DIR / "amazon_reviews_2023"
IMDB_DIR = DATA_DIR / "imdb_50k"

# ---------------------------------------------------------------------------
# Amazon Reviews 2023 (https://amazon-reviews-2023.github.io/)
# ---------------------------------------------------------------------------
AMAZON_BASE_URL = os.environ.get(
    "AMAZON_2023_BASE_URL",
    "https://mcauleylab.ucsd.edu/public_datasets/data/amazon_2023/raw",
)
AMAZON_REVIEW_URL = AMAZON_BASE_URL + "/review_categories/{category}.jsonl.gz"
AMAZON_META_URL = AMAZON_BASE_URL + "/meta_categories/meta_{category}.jsonl.gz"

AMAZON_CATEGORIES = [
    "All_Beauty", "Amazon_Fashion", "Appliances", "Arts_Crafts_and_Sewing",
    "Automotive", "Baby_Products", "Beauty_and_Personal_Care", "Books",
    "CDs_and_Vinyl", "Cell_Phones_and_Accessories",
    "Clothing_Shoes_and_Jewelry", "Digital_Music", "Electronics",
    "Gift_Cards", "Grocery_and_Gourmet_Food", "Handmade_Products",
    "Health_and_Household", "Health_and_Personal_Care", "Home_and_Kitchen",
    "Industrial_and_Scientific", "Kindle_Store", "Magazine_Subscriptions",
    "Movies_and_TV", "Musical_Instruments", "Office_Products",
    "Patio_Lawn_and_Garden", "Pet_Supplies", "Software",
    "Sports_and_Outdoors", "Subscription_Boxes",
    "Tools_and_Home_Improvement", "Toys_and_Games", "Video_Games", "Unknown",
]

# Small categories by default; some (Books, Clothing, Home...) are many GB.
AMAZON_DEFAULT_CATEGORIES = ["All_Beauty"]

# ---------------------------------------------------------------------------
# IMDB 50K movie reviews (Kaggle)
# https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews
# ---------------------------------------------------------------------------
IMDB_KAGGLE_HANDLE = "lakshmi25npathi/imdb-dataset-of-50k-movie-reviews"
IMDB_CSV_NAME = "IMDB Dataset.csv"

# Shared paths and dataset settings for the data setup scripts.
# Sourced by the other scripts; not meant to be run on its own.

# Find the repo root: the first folder (going up) that contains 1_Data_Cleaning.
find_repo_root <- function(start = getwd()) {
  dir <- normalizePath(start, mustWork = FALSE)
  repeat {
    if (dir.exists(file.path(dir, "1_Data_Cleaning"))) return(dir)
    parent <- dirname(dir)
    if (parent == dir) stop("Could not find the repo root (a folder containing 1_Data_Cleaning). ",
                            "Run from inside the repo.")
    dir <- parent
  }
}

REPO_ROOT <- find_repo_root(if (exists("SCRIPT_DIR")) SCRIPT_DIR else getwd())
DATA_DIR <- Sys.getenv("AI_LEARNING_DATA_DIR", file.path(REPO_ROOT, "0_Data"))

AMAZON_DIR <- file.path(DATA_DIR, "amazon_reviews_2023")
IMDB_DIR <- file.path(DATA_DIR, "imdb_50k")

# ---------------------------------------------------------------------------
# Amazon Reviews 2023 (https://amazon-reviews-2023.github.io/)
# ---------------------------------------------------------------------------
AMAZON_BASE_URL <- Sys.getenv(
  "AMAZON_2023_BASE_URL",
  "https://mcauleylab.ucsd.edu/public_datasets/data/amazon_2023/raw"
)

AMAZON_CATEGORIES <- c(
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
  "Tools_and_Home_Improvement", "Toys_and_Games", "Video_Games", "Unknown"
)

# Small category used when no one can be asked (e.g. run from another script).
# Some categories (Books, Clothing, Home...) are many GB.
AMAZON_DEFAULT_CATEGORIES <- c("All_Beauty")

AMAZON_PARTS <- c("reviews", "meta")

amazon_url <- function(category, part) {
  if (part == "reviews") {
    sprintf("%s/review_categories/%s.jsonl.gz", AMAZON_BASE_URL, category)
  } else {
    sprintf("%s/meta_categories/meta_%s.jsonl.gz", AMAZON_BASE_URL, category)
  }
}

amazon_path <- function(category, part) {
  if (part == "reviews") {
    file.path(AMAZON_DIR, "reviews", paste0(category, ".jsonl.gz"))
  } else {
    file.path(AMAZON_DIR, "meta", paste0("meta_", category, ".jsonl.gz"))
  }
}

# ---------------------------------------------------------------------------
# IMDB 50K movie reviews (Kaggle)
# https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews
# ---------------------------------------------------------------------------
IMDB_KAGGLE_HANDLE <- "lakshmi25npathi/imdb-dataset-of-50k-movie-reviews"
IMDB_KAGGLE_URL <- Sys.getenv(
  "IMDB_KAGGLE_URL",
  paste0("https://www.kaggle.com/api/v1/datasets/download/", IMDB_KAGGLE_HANDLE)
)
IMDB_CSV_NAME <- "IMDB Dataset.csv"

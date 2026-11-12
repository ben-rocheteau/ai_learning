# `config.R`

Source: [`1_Data_Cleaning/1_Functions/config.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/config.R)

Paths, URLs and dataset settings shared by all other files.

## Settings

| Name | Value |
|---|---|
| `REPO_ROOT` | Repo folder, found from this file's location (two levels up). |
| `DATA_DIR` | `<repo>/0_Data`, or the `AI_LEARNING_DATA_DIR` environment variable. |
| `AMAZON_DIR` | `DATA_DIR/amazon_reviews_2023` |
| `IMDB_DIR` | `DATA_DIR/imdb_50k` |
| `AMAZON_BASE_URL` | `https://mcauleylab.ucsd.edu/public_datasets/data/amazon_2023/raw`, or the `AMAZON_2023_BASE_URL` environment variable. |
| `AMAZON_CATEGORIES` | The 34 Amazon Reviews 2023 categories, `All_Beauty` ... `Unknown`. |
| `AMAZON_DEFAULT_CATEGORIES` | `"All_Beauty"`: downloaded when no category is given and no one can answer the menu. |
| `AMAZON_PARTS` | `c("reviews", "meta")` |
| `IMDB_KAGGLE_HANDLE` | `lakshmi25npathi/imdb-dataset-of-50k-movie-reviews` |
| `IMDB_KAGGLE_URL` | Kaggle API download URL for the handle above, or the `IMDB_KAGGLE_URL` environment variable. |
| `IMDB_CSV_NAME` | `"IMDB Dataset.csv"` |

`config.R` must be loaded with `source()`: it uses the path `source()` records to find the repo.

## Functions

| Function | Description |
|---|---|
| [`amazon_url`](amazon_url) | Builds the download URL of one Amazon Reviews 2023 file. |
| [`amazon_path`](amazon_path) | Local path where one Amazon Reviews 2023 file is (or will be) stored. |

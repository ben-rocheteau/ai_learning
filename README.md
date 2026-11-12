# ai_learning

## Data setup

Datasets are **not** stored in git. They are downloaded locally into `0_Data/`,
which is listed in `.gitignore`.

| Dataset | Source | Local path |
|---|---|---|
| Amazon Reviews 2023 | https://amazon-reviews-2023.github.io/ | `0_Data/amazon_reviews_2023/{reviews,meta}/*.jsonl.gz` |
| IMDB 50K movie reviews | https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews | `0_Data/imdb_50k/IMDB Dataset.csv` |

### Requirements

R 4.1 or newer, plus two packages:

```r
install.packages(c("curl", "jsonlite"))
```

### Running the setup

In RStudio: open `ai_learning.Rproj` (this sets the working directory to the
repo), open `1_Data_Cleaning/setup_data.R` and click **Source**. Running it line
by line also works.

From a terminal (from any folder):

```bash
Rscript 1_Data_Cleaning/setup_data.R
```

The script finds the repo from its own location, so the working directory
doesn't matter. If it can't, it stops and tells you to open `ai_learning.Rproj`
or `setwd()` to the repo.

For Amazon, this opens an interactive menu that:

1. lists all 34 categories with the download size of the reviews and the item
   metadata files, and marks the ones you already have with `[have]`;
2. asks which categories you want (`1,3,5-7`, names like `All_Beauty Software`,
   or `all`) and which parts (reviews, metadata or both);
3. shows what will be downloaded vs. skipped and asks you to confirm the total size.

It then downloads the IMDB CSV. Re-running skips files that already exist.

To see the table without downloading anything:

```bash
Rscript 1_Data_Cleaning/setup_data.R --list-amazon
```

To skip the menu, pass categories directly:

```bash
Rscript 1_Data_Cleaning/setup_data.R --amazon-categories All_Beauty Software Video_Games
```

```bash
Rscript 1_Data_Cleaning/setup_data.R --skip-imdb --no-amazon-meta
```

or, after sourcing the script once in R:
`setup_data(amazon_categories = c("Software"), amazon_meta = FALSE, skip_imdb = TRUE)`.

Some Amazon categories (e.g. `Books`, `Clothing_Shoes_and_Jewelry`,
`Home_and_Kitchen`) are several GB each — `all` is very large. When run without a
terminal (e.g. by another program) and no categories are given, only
`All_Beauty` is downloaded.

### Kaggle credentials

The IMDB dataset comes from the Kaggle API. If the download is refused, create
an API token (Kaggle > Settings > API) and either put `kaggle.json` in
`~/.kaggle/`, or set `KAGGLE_USERNAME` and `KAGGLE_KEY` (e.g. in `~/.Renviron`).
You can also download the zip from the dataset page by hand and put
`IMDB Dataset.csv` in `0_Data/imdb_50k/`.

### Loading the data

All helper functions live in `1_Data_Cleaning/1_Functions/`. To use them in your
own scripts (working directory = repo root, e.g. with `ai_learning.Rproj` open):

```r
for (f in list.files("1_Data_Cleaning/1_Functions", pattern = "\\.R$", full.names = TRUE)) source(f)

reviews <- load_amazon_reviews("All_Beauty", n_max = 10000)
meta    <- load_amazon_meta("All_Beauty")   # nested fields become list-columns
imdb    <- load_imdb()
```

## Documentation

Detailed docs (code structure, dependencies, one page per script and function) are in
[`wiki/`](wiki/Home.md), formatted for the GitHub wiki. To publish or update the wiki:

1. Once only: on GitHub, open the repo's **Wiki** tab and create any first page
   (this creates the wiki).
2. Copy the pages over and push:

```bash
git clone https://github.com/ben-rocheteau/ai_learning.wiki.git ../ai_learning.wiki
```

```bash
cp wiki/*.md ../ai_learning.wiki/ && cd ../ai_learning.wiki && git add -A && git commit -m "Update wiki" && git push
```

## Layout

```
ai_learning.Rproj               # RStudio project (sets working directory to the repo)
0_Data/                         # local datasets (git-ignored, created by setup_data.R)
1_Data_Cleaning/
  setup_data.R                  # entry point: downloads everything
  1_Functions/                  # helper functions, loaded by setup_data.R
    config.R                    # paths, URLs, category list
    download_amazon_reviews.R   # Amazon Reviews 2023 downloader + interactive menu
    download_imdb.R             # IMDB 50K downloader (Kaggle)
    load_data.R                 # loaders into data frames
    utils.R                     # download, size lookup, prompt and argument helpers
wiki/                           # GitHub wiki pages (see Documentation)
```

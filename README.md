# ai_learning

## Data setup

Datasets are **not** stored in git. They are downloaded locally into `0_Data/`,
which is listed in `.gitignore`.

| Dataset | Source | Local path |
|---|---|---|
| Amazon Reviews 2023 | https://amazon-reviews-2023.github.io/ | `0_Data/amazon_reviews_2023/{reviews,meta}/*.jsonl.gz` |
| IMDB 50K movie reviews | https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews | `0_Data/imdb_50k/IMDB Dataset.csv` |

```bash
pip install -r requirements.txt
```

```bash
python 1_Data_Cleaning/setup_data.py
```

By default this downloads the small `All_Beauty` Amazon category (reviews + item
metadata) and the IMDB CSV. Re-running skips files that already exist.

Other options:

```bash
python 1_Data_Cleaning/download_amazon_reviews.py --list
```

```bash
python 1_Data_Cleaning/setup_data.py --amazon-categories All_Beauty Software Video_Games
```

```bash
python 1_Data_Cleaning/setup_data.py --skip-imdb --no-amazon-meta
```

Some Amazon categories (e.g. `Books`, `Clothing_Shoes_and_Jewelry`,
`Home_and_Kitchen`) are several GB each — `--amazon-categories all` is very large.

### Kaggle credentials

The IMDB dataset is fetched with `kagglehub`. If Kaggle asks you to log in, run
`python -c "import kagglehub; kagglehub.login()"` or put your `kaggle.json`
(Kaggle > Settings > API > Create New Token) in `~/.kaggle/`.

### Loading the data

```python
# from inside 1_Data_Cleaning/
from load_data import load_amazon_reviews, load_amazon_meta, load_imdb

reviews = load_amazon_reviews("All_Beauty", nrows=10_000)
meta = load_amazon_meta("All_Beauty")
imdb = load_imdb()
```

## Layout

```
0_Data/             # local datasets (git-ignored, created by setup script)
1_Data_Cleaning/
  config.py                   # paths, URLs, category list
  setup_data.py               # entry point: downloads everything
  download_amazon_reviews.py  # Amazon Reviews 2023 downloader
  download_imdb.py            # IMDB 50K downloader (Kaggle)
  download_utils.py           # streaming download helper
  load_data.py                # pandas loaders
```

# `download_imdb.R`

Source: [`1_Data_Cleaning/1_Functions/download_imdb.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_imdb.R)

Downloads the IMDB 50K movie reviews dataset from Kaggle.

## File produced

`0_Data/imdb_50k/IMDB Dataset.csv` with columns `review` and `sentiment`.

## Kaggle credentials

Public datasets sometimes download without a login. If Kaggle refuses, create a token
(kaggle.com > Settings > API) and either put `kaggle.json` in `~/.kaggle/`, or set
`KAGGLE_USERNAME` and `KAGGLE_KEY` (for example in `~/.Renviron`). You can also download the zip
by hand from the [dataset page](https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews)
and put `IMDB Dataset.csv` in `0_Data/imdb_50k/`.

## Functions

| Function | Description |
|---|---|
| [`kaggle_handle`](kaggle_handle) *(internal)* | Creates a `curl` handle carrying your Kaggle credentials, if any are set. |
| [`download_imdb`](download_imdb) | Downloads the IMDB 50K movie reviews from Kaggle into `0_Data/imdb_50k/`. |

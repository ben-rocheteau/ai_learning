# `load_data.R`

Source: [`1_Data_Cleaning/1_Functions/load_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/load_data.R)

Loads the downloaded datasets into data frames for cleaning and analysis.

## Using the loaders in your own scripts

With `ai_learning.Rproj` open (working directory = repo root):

```r
for (f in list.files("1_Data_Cleaning/1_Functions", pattern = "\\.R$", full.names = TRUE)) source(f)

reviews <- load_amazon_reviews("All_Beauty", n_max = 10000)
meta    <- load_amazon_meta("All_Beauty")
imdb    <- load_imdb()
```

## Functions

| Function | Description |
|---|---|
| [`.check_file`](check_file) *(internal)* | Stops with a helpful message if a data file is missing. |
| [`read_jsonl_gz`](read_jsonl_gz) *(internal)* | Reads a gzipped JSON Lines file into a data frame. |
| [`load_amazon_reviews`](load_amazon_reviews) | Loads one category's Amazon reviews. |
| [`load_amazon_meta`](load_amazon_meta) | Loads one category's Amazon item metadata. |
| [`load_imdb`](load_imdb) | Loads the IMDB 50K movie reviews. |

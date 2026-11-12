# `download_amazon_reviews.R`

Source: [`1_Data_Cleaning/1_Functions/download_amazon_reviews.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_amazon_reviews.R)

Downloads Amazon Reviews 2023 files and runs the interactive menu.

## Files produced

```
0_Data/amazon_reviews_2023/
  reviews/<Category>.jsonl.gz      user reviews
  meta/meta_<Category>.jsonl.gz    item metadata
```

Both are gzipped JSON Lines (one JSON object per line), as published by the dataset authors.

## Functions

| Function | Description |
|---|---|
| [`download_amazon`](download_amazon) | Downloads chosen parts of chosen Amazon categories, without prompts. |
| [`amazon_status`](amazon_status) | Builds a table of every Amazon file: where it comes from, where it goes, whether you have it and how big it is. |
| [`print_status_table`](print_status_table) | Prints the category table shown by the interactive menu. |
| [`parse_selection`](parse_selection) *(internal)* | Turns what the user typed in the menu into category names. |
| [`amazon_select`](amazon_select) *(internal)* | Runs the interactive menu and returns the choice, without downloading. |
| [`download_amazon_interactive`](download_amazon_interactive) | The interactive menu followed by the download. |

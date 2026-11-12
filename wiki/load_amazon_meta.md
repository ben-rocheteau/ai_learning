# `load_amazon_meta`

**Main function** · defined in [load_data.R](File-load_data) ([`1_Data_Cleaning/1_Functions/load_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/load_data.R#L34))

Loads one category's Amazon item metadata.

## Usage

```r
load_amazon_meta(category = "All_Beauty", n_max = NULL)
```

## Arguments

| Argument | Description |
|---|---|
| `category` | Category name (default `"All_Beauty"`). |
| `n_max` | Maximum number of rows, or `NULL` for all. |

## Value

Data frame with one row per item, e.g. `parent_asin`, `title`, `price`, `average_rating`, `rating_number`, `store`, `categories`, `features`, `details`. Nested fields are list-columns.

## Details

Join to reviews with `parent_asin`.

## Example

```r
meta <- load_amazon_meta("All_Beauty")
merged <- merge(reviews, meta[, c("parent_asin", "title", "price")],
                by = "parent_asin", suffixes = c("", "_item"))
```

## Related

- **Calls:** [`amazon_path`](amazon_path), [`read_jsonl_gz`](read_jsonl_gz)
- **Called by:** no other function (you call it directly)

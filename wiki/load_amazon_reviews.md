# `load_amazon_reviews`

**Main function** · defined in [load_data.R](File-load_data) ([`1_Data_Cleaning/1_Functions/load_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/load_data.R#L30))

Loads one category's Amazon reviews.

## Usage

```r
load_amazon_reviews(category = "All_Beauty", n_max = NULL)
```

## Arguments

| Argument | Description |
|---|---|
| `category` | Category name (default `"All_Beauty"`). |
| `n_max` | Maximum number of rows, or `NULL` for all. |

## Value

Data frame with one row per review. Columns follow the Amazon Reviews 2023 format, e.g. `rating`, `title`, `text`, `asin`, `parent_asin`, `user_id`, `timestamp`, `helpful_vote`, `verified_purchase`, `images`.

## Example

```r
reviews <- load_amazon_reviews("All_Beauty", n_max = 10000)
```

## Related

- **Calls:** [`amazon_path`](amazon_path), [`read_jsonl_gz`](read_jsonl_gz)
- **Called by:** no other function (you call it directly)

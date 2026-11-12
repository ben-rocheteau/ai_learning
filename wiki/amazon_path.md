# `amazon_path`

**Main function** · defined in [config.R](File-config) ([`1_Data_Cleaning/1_Functions/config.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/config.R#L52))

Local path where one Amazon Reviews 2023 file is (or will be) stored.

## Usage

```r
amazon_path(category, part)
```

## Arguments

| Argument | Description |
|---|---|
| `category` | Category name. |
| `part` | `"reviews"` or `"meta"`. |

## Value

A path under `AMAZON_DIR`: `reviews/<Category>.jsonl.gz` or `meta/meta_<Category>.jsonl.gz`.

## Example

```r
file.exists(amazon_path("Software", "reviews"))
```

## Related

- **Calls:** none
- **Called by:** [`download_amazon`](download_amazon), [`load_amazon_reviews`](load_amazon_reviews), [`load_amazon_meta`](load_amazon_meta)

# `amazon_url`

**Main function** · defined in [config.R](File-config) ([`1_Data_Cleaning/1_Functions/config.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/config.R#L44))

Builds the download URL of one Amazon Reviews 2023 file.

## Usage

```r
amazon_url(category, part)
```

## Arguments

| Argument | Description |
|---|---|
| `category` | Category name, e.g. `"All_Beauty"` (see `AMAZON_CATEGORIES`). |
| `part` | `"reviews"` or `"meta"`. |

## Value

A single URL string under `AMAZON_BASE_URL`.

## Example

```r
amazon_url("All_Beauty", "meta")
#> ".../raw/meta_categories/meta_All_Beauty.jsonl.gz"
```

## Related

- **Calls:** none
- **Called by:** [`download_amazon`](download_amazon)

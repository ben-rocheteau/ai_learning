# `amazon_status`

**Main function** · defined in [download_amazon_reviews.R](File-download_amazon_reviews) ([`1_Data_Cleaning/1_Functions/download_amazon_reviews.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_amazon_reviews.R#L42))

Builds a table of every Amazon file: where it comes from, where it goes, whether you have it and how big it is.

## Usage

```r
amazon_status(categories = AMAZON_CATEGORIES)
```

## Arguments

| Argument | Description |
|---|---|
| `categories` | Categories to include (default: all). |

## Value

Data frame with one row per category and part, and columns `category`, `part`, `url`, `path`, `have` (logical) and `size` (bytes, `NA` if unknown).

## Details

Sizes come from [`remote_sizes`](remote_sizes), so this needs network access.

## Example

```r
status <- amazon_status()
subset(status, have)
```

## Related

- **Calls:** [`check_packages`](check_packages), [`remote_sizes`](remote_sizes)
- **Called by:** [`amazon_select`](amazon_select)

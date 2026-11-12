# `download_amazon`

**Main function** · defined in [download_amazon_reviews.R](File-download_amazon_reviews) ([`1_Data_Cleaning/1_Functions/download_amazon_reviews.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_amazon_reviews.R#L18))

Downloads chosen parts of chosen Amazon categories, without prompts.

## Usage

```r
download_amazon(categories = AMAZON_DEFAULT_CATEGORIES, parts = AMAZON_PARTS, overwrite = FALSE)
```

## Arguments

| Argument | Description |
|---|---|
| `categories` | Category names (default `AMAZON_DEFAULT_CATEGORIES`). |
| `parts` | `"reviews"`, `"meta"` or both (default both). |
| `overwrite` | `TRUE` to re-download existing files. |

## Value

`TRUE` if every file succeeded (or was already there), `FALSE` otherwise. Unknown category names fail before anything is downloaded.

## Example

```r
download_amazon(c("Software", "Video_Games"), parts = "reviews")
```

## Related

- **Calls:** [`amazon_url`](amazon_url), [`amazon_path`](amazon_path), [`check_packages`](check_packages), [`download_file`](download_file)
- **Called by:** [`setup_data`](setup_data), [`download_amazon_interactive`](download_amazon_interactive)

# `download_amazon_interactive`

**Main function** · defined in [download_amazon_reviews.R](File-download_amazon_reviews) ([`1_Data_Cleaning/1_Functions/download_amazon_reviews.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_amazon_reviews.R#L151))

The interactive menu followed by the download.

## Usage

```r
download_amazon_interactive(overwrite = FALSE)
```

## Arguments

| Argument | Description |
|---|---|
| `overwrite` | `TRUE` to re-download files you already have. |

## Value

`TRUE` unless a download failed (cancelling counts as `TRUE`).

## Example

```r
download_amazon_interactive()
```

## Related

- **Calls:** [`download_amazon`](download_amazon), [`amazon_select`](amazon_select)
- **Called by:** [`setup_data`](setup_data)

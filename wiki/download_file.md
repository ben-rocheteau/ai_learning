# `download_file`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L63))

Downloads one file with a progress bar, safely.

## Usage

```r
download_file(url, dest, overwrite = FALSE, handle = curl::new_handle())
```

## Arguments

| Argument | Description |
|---|---|
| `url` | URL to download. |
| `dest` | Destination path. Parent folders are created. |
| `overwrite` | `FALSE` (default) skips the download if `dest` exists. |
| `handle` | A `curl` handle, e.g. one carrying credentials (see [`kaggle_handle`](kaggle_handle)). |

## Value

`TRUE` on success or skip, `FALSE` on error (the error is printed).

## Details

Writes to `<dest>.part` first and renames it when complete, so an interrupted download never looks finished. HTTP errors (404, 401, ...) count as failures, and the partial file is deleted.

## Example

```r
download_file("https://example.com/file.csv", "0_Data/example/file.csv")
```

## Related

- **Calls:** none
- **Called by:** [`download_amazon`](download_amazon), [`download_imdb`](download_imdb)

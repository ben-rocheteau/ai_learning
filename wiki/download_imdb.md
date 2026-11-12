# `download_imdb`

**Main function** · defined in [download_imdb.R](File-download_imdb) ([`1_Data_Cleaning/1_Functions/download_imdb.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_imdb.R#L41))

Downloads the IMDB 50K movie reviews from Kaggle into `0_Data/imdb_50k/`.

## Usage

```r
download_imdb(overwrite = FALSE)
```

## Arguments

| Argument | Description |
|---|---|
| `overwrite` | `TRUE` to download again even if the CSV exists. |

## Value

`TRUE` on success or if the CSV already exists, `FALSE` otherwise.

## Details

Downloads the dataset zip from the Kaggle API (with [`kaggle_handle`](kaggle_handle)), extracts `IMDB Dataset.csv` and deletes the zip. On failure it prints how to set credentials, or where to download the file by hand.

## Example

```r
download_imdb()
```

## Related

- **Calls:** [`check_packages`](check_packages), [`download_file`](download_file), [`kaggle_handle`](kaggle_handle)
- **Called by:** [`setup_data`](setup_data)

# `kaggle_handle`

**Internal helper** · defined in [download_imdb.R](File-download_imdb) ([`1_Data_Cleaning/1_Functions/download_imdb.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_imdb.R#L16))

Creates a `curl` handle carrying your Kaggle credentials, if any are set.

## Usage

```r
kaggle_handle()
```

## Arguments

None.

## Value

A `curl` handle for [`download_file`](download_file).

## Details

Credentials are looked up in this order:

1. `KAGGLE_API_TOKEN` environment variable, sent as `Authorization: Bearer`.
2. `KAGGLE_USERNAME` and `KAGGLE_KEY` environment variables (basic auth).
3. `kaggle.json` in `KAGGLE_CONFIG_DIR`, or `~/.kaggle/` by default.

With none of these, a message is printed and the download is tried without login.

## Example

```r
h <- kaggle_handle()
```

## Related

- **Calls:** [`%||%`](null-default-operator)
- **Called by:** [`download_imdb`](download_imdb)

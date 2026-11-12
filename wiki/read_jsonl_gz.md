# `read_jsonl_gz`

**Internal helper** · defined in [load_data.R](File-load_data) ([`1_Data_Cleaning/1_Functions/load_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/load_data.R#L18))

Reads a gzipped JSON Lines file into a data frame.

## Usage

```r
read_jsonl_gz(path, n_max = NULL)
```

## Arguments

| Argument | Description |
|---|---|
| `path` | Path to a `.jsonl.gz` file. |
| `n_max` | Maximum number of rows, or `NULL` (default) for all. |

## Value

Data frame; nested JSON fields become list-columns.

## Details

Uses `jsonlite::stream_in()`. With `n_max`, only the first `n_max` lines are read, which is much faster on large categories.

## Example

```r
read_jsonl_gz(amazon_path("All_Beauty", "reviews"), n_max = 100)
```

## Related

- **Calls:** [`check_packages`](check_packages), [`.check_file`](check_file)
- **Called by:** [`load_amazon_reviews`](load_amazon_reviews), [`load_amazon_meta`](load_amazon_meta)

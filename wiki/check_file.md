# `.check_file`

**Internal helper** · defined in [load_data.R](File-load_data) ([`1_Data_Cleaning/1_Functions/load_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/load_data.R#L10))

Stops with a helpful message if a data file is missing.

## Usage

```r
.check_file(path)
```

## Arguments

| Argument | Description |
|---|---|
| `path` | Path to check. |

## Value

`path`, unchanged, if the file exists.

## Details

The error tells you to run `setup_data.R` first.

## Example

```r
.check_file(file.path(IMDB_DIR, IMDB_CSV_NAME))
```

## Related

- **Calls:** none
- **Called by:** [`read_jsonl_gz`](read_jsonl_gz), [`load_imdb`](load_imdb)

# `check_packages`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L7))

Stops with a ready-to-paste `install.packages()` command if required packages are missing.

## Usage

```r
check_packages(pkgs = REQUIRED_PACKAGES)
```

## Arguments

| Argument | Description |
|---|---|
| `pkgs` | Package names to check. Defaults to `REQUIRED_PACKAGES` (`curl`, `jsonlite`). |

## Value

`NULL` invisibly when all packages are installed; otherwise an error.

## Example

```r
check_packages()
#> Error: Missing R packages. Install them with:
#>   install.packages(c("curl"))
```

## Related

- **Calls:** none
- **Called by:** [`setup_data`](setup_data), [`download_amazon`](download_amazon), [`amazon_status`](amazon_status), [`download_imdb`](download_imdb), [`read_jsonl_gz`](read_jsonl_gz)

# `parse_args`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L110))

Minimal command-line parser for `Rscript` options.

## Usage

```r
parse_args(args = commandArgs(trailingOnly = TRUE), aliases = character())
```

## Arguments

| Argument | Description |
|---|---|
| `args` | Arguments to parse (default: `commandArgs(trailingOnly = TRUE)`). |
| `aliases` | Named character vector renaming flags, e.g. `c(c = "categories")`. |

## Value

Named list: flags without values are `TRUE`; flags followed by values hold a character vector of those values.

## Example

```r
parse_args(c("--amazon-categories", "A", "B", "--skip-imdb"))
#> list(`amazon-categories` = c("A", "B"), `skip-imdb` = TRUE)
```

## Related

- **Calls:** none
- **Called by:** no other function (you call it directly)

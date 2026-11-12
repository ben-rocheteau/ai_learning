# `human_size`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L19))

Formats a byte count for display.

## Usage

```r
human_size(n)
```

## Arguments

| Argument | Description |
|---|---|
| `n` | Number of bytes, or `NA` / `NULL`. |

## Value

A string such as `"135 B"`, `"11.9 KB"` or `"2.3 GB"`; `"?"` when `n` is missing.

## Example

```r
human_size(12172)   #> "11.9 KB"
human_size(NA)      #> "?"
```

## Related

- **Calls:** none
- **Called by:** [`print_status_table`](print_status_table), [`amazon_select`](amazon_select)

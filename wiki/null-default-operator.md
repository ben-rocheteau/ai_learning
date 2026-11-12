# `%||%`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L5))

Returns `a`, or `b` when `a` is `NULL`. Base R only has this operator from 4.4, so it is defined here for older versions.

## Usage

```r
a %||% b
```

## Arguments

| Argument | Description |
|---|---|
| `a` | Any value. |
| `b` | Fallback used when `a` is `NULL`. |

## Value

`a` if not `NULL`, else `b`.

## Example

```r
NULL %||% "default"   #> "default"
"x" %||% "default"    #> "x"
```

## Related

- **Calls:** none
- **Called by:** [`setup_data`](setup_data), [`kaggle_handle`](kaggle_handle)

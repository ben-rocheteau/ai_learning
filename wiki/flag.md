# `flag`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L127))

Checks whether a value-less flag was given.

## Usage

```r
flag(args, name)
```

## Arguments

| Argument | Description |
|---|---|
| `args` | List returned by [`parse_args`](parse_args). |
| `name` | Flag name without dashes, e.g. `"overwrite"`. |

## Value

`TRUE` or `FALSE`.

## Example

```r
flag(parse_args(c("--overwrite")), "overwrite")   #> TRUE
```

## Related

- **Calls:** none
- **Called by:** no other function (you call it directly)

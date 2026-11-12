# `category_arg`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L130))

Turns a category option into a vector of category names.

## Usage

```r
category_arg(values, all_categories)
```

## Arguments

| Argument | Description |
|---|---|
| `values` | Value from [`parse_args`](parse_args) (character vector, `TRUE` or `NULL`). |
| `all_categories` | Vector returned when the value is `"all"`. |

## Value

`NULL` when no categories were given; all categories for `all`; otherwise `values` unchanged.

## Example

```r
category_arg("all", AMAZON_CATEGORIES)   # all 34 categories
```

## Related

- **Calls:** none
- **Called by:** no other function (you call it directly)

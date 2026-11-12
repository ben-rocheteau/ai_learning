# `amazon_select`

**Internal helper** · defined in [download_amazon_reviews.R](File-download_amazon_reviews) ([`1_Data_Cleaning/1_Functions/download_amazon_reviews.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_amazon_reviews.R#L104))

Runs the interactive menu and returns the choice, without downloading.

## Usage

```r
amazon_select(overwrite = FALSE)
```

## Arguments

| Argument | Description |
|---|---|
| `overwrite` | If `TRUE`, files you already have are listed as to download. |

## Value

`list(categories, parts)`, or `NULL` if the user cancels or already has everything selected.

## Details

Steps:

1. Shows the table from [`print_status_table`](print_status_table).
2. Asks for categories (Enter cancels); invalid input asks again.
3. Asks for parts: both (default), reviews only or metadata only.
4. Lists files to download (`[get]`, with sizes) and to skip (`[have]`).
5. Asks to confirm the total download size.

## Example

```r
choice <- amazon_select()
```

## Related

- **Calls:** [`human_size`](human_size), [`ask`](ask), [`amazon_status`](amazon_status), [`print_status_table`](print_status_table), [`parse_selection`](parse_selection)
- **Called by:** [`download_amazon_interactive`](download_amazon_interactive)

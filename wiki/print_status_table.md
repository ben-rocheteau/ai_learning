# `print_status_table`

**Main function** · defined in [download_amazon_reviews.R](File-download_amazon_reviews) ([`1_Data_Cleaning/1_Functions/download_amazon_reviews.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_amazon_reviews.R#L54))

Prints the category table shown by the interactive menu.

## Usage

```r
print_status_table(status)
```

## Arguments

| Argument | Description |
|---|---|
| `status` | Data frame from [`amazon_status`](amazon_status). |

## Value

`NULL`; called for its printed output.

## Details

One numbered row per category with the reviews and metadata sizes; files already on disk are marked `[have]`. Ends with the total size on disk.

## Example

```r
print_status_table(amazon_status())

#>   #  Category              Reviews          Metadata
#>   1  All_Beauty           x.x MB [have]    x.x MB [have]
#>   2  Amazon_Fashion       x.x MB           x.x MB
```

## Related

- **Calls:** [`human_size`](human_size)
- **Called by:** [`amazon_select`](amazon_select)

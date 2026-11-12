# `parse_selection`

**Internal helper** · defined in [download_amazon_reviews.R](File-download_amazon_reviews) ([`1_Data_Cleaning/1_Functions/download_amazon_reviews.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/download_amazon_reviews.R#L77))

Turns what the user typed in the menu into category names.

## Usage

```r
parse_selection(text, categories = AMAZON_CATEGORIES)
```

## Arguments

| Argument | Description |
|---|---|
| `text` | Input such as `"1,3,5-7"`, `"All_Beauty software"` or `"all"`. Numbers, ranges and names (any case) can be mixed. |
| `categories` | The numbered list (default `AMAZON_CATEGORIES`). |

## Value

Character vector of unique category names, in the order given.

## Details

Raises an error for unknown names or out-of-range numbers; the menu shows it and asks again.

## Example

```r
parse_selection("1, 28, video_games")
#> "All_Beauty" "Software" "Video_Games"
```

## Related

- **Calls:** none
- **Called by:** [`amazon_select`](amazon_select)

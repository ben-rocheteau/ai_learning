# `setup_data`

**Main function** · defined in [setup_data.R](Script-setup_data) ([`1_Data_Cleaning/setup_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/setup_data.R#L50))

Downloads every dataset into `0_Data/`. This is what runs when you source or `Rscript` the setup script.

## Usage

```r
setup_data(amazon_categories = NULL, amazon_meta = TRUE, skip_amazon = FALSE, skip_imdb = FALSE, overwrite = FALSE)
```

## Arguments

| Argument | Description |
|---|---|
| `amazon_categories` | Character vector of Amazon categories, or `NULL` (default). With `NULL`, the interactive menu is shown when someone can answer it, otherwise `AMAZON_DEFAULT_CATEGORIES` is downloaded. |
| `amazon_meta` | `TRUE` (default) to also download item metadata. Ignored by the menu, which asks. |
| `skip_amazon` | `TRUE` to skip the Amazon dataset. |
| `skip_imdb` | `TRUE` to skip the IMDB dataset. |
| `overwrite` | `TRUE` to re-download files that already exist. |

## Value

Invisibly, `TRUE` if every requested download succeeded.

## Details

Creates `DATA_DIR`, runs the Amazon step then the IMDB step, and prints a summary with `OK` / `FAILED` for each dataset. Cancelling the Amazon menu counts as `OK`.

## Example

```r
source("1_Data_Cleaning/setup_data.R")   # runs setup_data() once

# later, with options:
setup_data(amazon_categories = c("Software", "Video_Games"),
           amazon_meta = FALSE, skip_imdb = TRUE)
```

## Related

- **Calls:** [`%||%`](null-default-operator), [`check_packages`](check_packages), [`can_prompt`](can_prompt), [`download_amazon`](download_amazon), [`download_amazon_interactive`](download_amazon_interactive), [`download_imdb`](download_imdb)
- **Called by:** no other function (you call it directly)

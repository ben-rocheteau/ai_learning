# `can_prompt`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L93))

Tells whether a person can answer questions.

## Usage

```r
can_prompt()
```

## Arguments

None.

## Value

`TRUE` in an interactive R session (RStudio, R console) or when `Rscript` runs in a terminal; `FALSE` when run by another program with no terminal.

## Details

Used to decide between the interactive menu and the default download.

## Example

```r
if (can_prompt()) download_amazon_interactive()
```

## Related

- **Calls:** none
- **Called by:** [`setup_data`](setup_data)

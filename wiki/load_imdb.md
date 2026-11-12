# `load_imdb`

**Main function** · defined in [load_data.R](File-load_data) ([`1_Data_Cleaning/1_Functions/load_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/load_data.R#L38))

Loads the IMDB 50K movie reviews.

## Usage

```r
load_imdb()
```

## Arguments

None.

## Value

Data frame with 50,000 rows and columns `review` (text) and `sentiment` (`"positive"` / `"negative"`).

## Example

```r
imdb <- load_imdb()
table(imdb$sentiment)
```

## Related

- **Calls:** [`.check_file`](check_file)
- **Called by:** no other function (you call it directly)

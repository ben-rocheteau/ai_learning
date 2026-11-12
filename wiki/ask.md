# `ask`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L95))

Asks the user a question and returns the typed line.

## Usage

```r
ask(prompt)
```

## Arguments

| Argument | Description |
|---|---|
| `prompt` | Text shown before the input. |

## Value

The typed line, or `""` if nothing could be read.

## Details

Uses `readline()` in interactive sessions. Under `Rscript`, where `readline()` does not wait for input, it reads a line from standard input instead, keeping one connection open between calls.

## Example

```r
answer <- ask("Continue? [y/N]: ")
```

## Related

- **Calls:** none
- **Called by:** [`amazon_select`](amazon_select)

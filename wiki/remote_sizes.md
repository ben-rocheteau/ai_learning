# `remote_sizes`

**Internal helper** · defined in [utils.R](File-utils) ([`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R#L32))

Asks the server how big each file is, without downloading it.

## Usage

```r
remote_sizes(urls, timeout = 15)
```

## Arguments

| Argument | Description |
|---|---|
| `urls` | Character vector of URLs. |
| `timeout` | Seconds to wait per request (default 15). |

## Value

Numeric vector of sizes in bytes, same order as `urls`; `NA` where the server returned an error or no size.

## Details

Sends `HEAD` requests in parallel (up to 8 at a time per host) using the `curl` package's multi interface, follows redirects, and reads the last `Content-Length` header.

## Example

```r
remote_sizes(c(amazon_url("All_Beauty", "reviews"),
               amazon_url("All_Beauty", "meta")))
```

## Related

- **Calls:** none
- **Called by:** [`amazon_status`](amazon_status)

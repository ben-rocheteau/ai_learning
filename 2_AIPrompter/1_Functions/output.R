# Reading and writing prompter results.
#
# The run writes a .csv one row at a time (safe to interrupt). Each row has:
#   id, text, recommendation, response_1, response_2, finish_1, finish_2,
#   status ("ok", "truncated" or "error"), error, tokens_in, tokens_out,
#   provider, model, timestamp
# The priming message and the model's reply to it are saved next to it as
# <name>_priming.json.

AP_RESULT_COLUMNS <- c("id", "text", "recommendation", "response_1", "response_2",
                       "finish_1", "finish_2", "status", "error", "tokens_in", "tokens_out",
                       "provider", "model", "timestamp")

.ap_empty_results <- function() {
  df <- as.data.frame(setNames(replicate(length(AP_RESULT_COLUMNS), character(), simplify = FALSE),
                               AP_RESULT_COLUMNS), stringsAsFactors = FALSE)
  df$tokens_in <- df$tokens_out <- numeric()
  df
}

.ap_append_row <- function(row, file) {
  df <- as.data.frame(row[AP_RESULT_COLUMNS], stringsAsFactors = FALSE)
  utils::write.table(df, file, append = file.exists(file), col.names = !file.exists(file),
                     sep = ",", row.names = FALSE, qmethod = "double", na = "", fileEncoding = "UTF-8")
}

# Read a results .csv. Rows that were retried appear once (latest attempt).
read_results <- function(file) {
  df <- utils::read.csv(file, stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = "",
                        colClasses = c(id = "character"))
  df <- df[!duplicated(df$id, fromLast = TRUE), , drop = FALSE]
  rownames(df) <- NULL
  df
}

# Save results in another format, chosen by the file extension:
#   .csv      spreadsheet-friendly
#   .rds      R's own format (exact types)
#   .txt/.md  readable transcript, one block per row
#   .arrow / .feather / .parquet   needs install.packages("arrow")
write_results <- function(results, file) {
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  ext <- tolower(tools::file_ext(file))
  switch(ext,
    csv = utils::write.csv(results, file, row.names = FALSE, na = "", fileEncoding = "UTF-8"),
    rds = saveRDS(results, file),
    txt = , md = writeLines(.ap_transcript(results), file, useBytes = TRUE),
    arrow = , feather = , parquet = {
      if (!requireNamespace("arrow", quietly = TRUE)) stop('Install arrow first: install.packages("arrow")', call. = FALSE)
      if (ext == "parquet") arrow::write_parquet(results, file) else arrow::write_feather(results, file)
    },
    stop("Unsupported extension '.", ext, "'. Use csv, rds, txt, md, arrow, feather or parquet.", call. = FALSE)
  )
  invisible(file)
}

.ap_transcript <- function(results) {
  unlist(lapply(seq_len(nrow(results)), function(i) {
    r <- lapply(results[i, ], function(x) if (is.na(x)) "" else as.character(x))
    c(sprintf("==== id %s  [%s]  %s / %s ====", r$id, r$status, r$provider, r$model),
      "", "-- text --", r$text, "", "-- response 1 --", r$response_1,
      "", "-- recommendation --", r$recommendation, "", "-- response 2 --", r$response_2,
      if (nzchar(r$error)) c("", paste("-- error --", r$error)), "", "")
  }))
}

# ---- Priming sidecar: reuse the same priming reply when resuming ----

.ap_priming_file <- function(output_file) sub("(\\.csv)?$", "_priming.json", output_file)

.ap_save_priming <- function(output_file, priming, reply, provider) {
  jsonlite::write_json(list(priming = priming, reply = reply, provider = provider$name,
                            model = provider$model, timestamp = format(Sys.time())),
                       .ap_priming_file(output_file), auto_unbox = TRUE, pretty = TRUE)
}

# The saved reply, if it was for the same priming text and model; else NULL.
.ap_read_priming <- function(output_file, priming, provider) {
  f <- .ap_priming_file(output_file)
  if (!file.exists(f)) return(NULL)
  saved <- jsonlite::read_json(f)
  if (identical(saved$priming, priming) && identical(saved$model, provider$model)) saved$reply else NULL
}

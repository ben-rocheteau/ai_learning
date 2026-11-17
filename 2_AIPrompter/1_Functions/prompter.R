# The prompting workflow:
#   1. send the priming message (once)
#   2. for each row: send prompt_1 + text        -> collect response_1
#                    send prompt_2 + recommendation -> collect response_2
# Each row's result is written to the output file as soon as it is done, so a
# crash, Ctrl+C or exhausted quota loses nothing; rerun to resume.

# Bundle the three prompts.
#   priming   first message of every conversation (or the system prompt, see run_prompter)
#   prompt_1  sent with each text
#   prompt_2  sent with each recommendation
#   sep       joins a prompt and its value when the prompt has no placeholder
# Placeholders: write {text} in prompt_1 or {recommendation} in prompt_2 to put the
# value there instead of after the prompt.
prompter_prompts <- function(priming = NULL, prompt_1, prompt_2, sep = "\n\n") {
  structure(list(priming = priming, prompt_1 = prompt_1, prompt_2 = prompt_2, sep = sep),
            class = "prompter_prompts")
}

.ap_fill <- function(prompt, value, placeholder, sep) {
  token <- paste0("{", placeholder, "}")
  if (grepl(token, prompt, fixed = TRUE)) gsub(token, value, prompt, fixed = TRUE)
  else paste(prompt, value, sep = sep)
}

# Pick a column by name or number; NULL = guess.
.ap_pick_column <- function(data, col, guess, position, label) {
  if (is.null(col)) {
    hit <- which(tolower(names(data)) == guess)
    if (length(hit)) return(names(data)[hit[1]])
    if (ncol(data) == 2) return(names(data)[position])
    stop("Can't tell which column holds the ", label, ". Pass ", guess, "_col = <name or number>. ",
         "Columns: ", paste(names(data), collapse = ", "), call. = FALSE)
  }
  if (is.numeric(col)) {
    if (col < 1 || col > ncol(data)) stop(label, " column number ", col, " is out of range", call. = FALSE)
    return(names(data)[col])
  }
  if (!col %in% names(data)) {
    stop("No column '", col, "'. Columns: ", paste(names(data), collapse = ", "), call. = FALSE)
  }
  col
}

# Run the workflow over a data frame.
#
#   data                data frame; any size, any column names
#   prompts             from prompter_prompts()
#   provider            from llm_provider()
#   text_col, recommendation_col
#                       column names or numbers. NULL = a column called "text" /
#                       "recommendation" (any case), or the 1st / 2nd of two columns.
#   id_col              column identifying rows (used to resume). NULL = row number.
#   output_file         .csv file written row by row. NULL = a new timestamped file in
#                       0_Data/ai_prompter/. FALSE = don't write a file.
#   resume              if output_file exists, skip rows already done successfully
#                       (rows that failed are tried again). FALSE = start a new file
#                       (the old one is renamed, not deleted).
#   priming_as          "message": priming is sent once as a user message, and it plus the
#                       model's answer start every conversation. "system": priming is the
#                       system prompt (cheaper; no reply to it).
#   conversation        "per_row": each row is a fresh conversation (priming, then that
#                       row's two prompts). "continuous": one conversation through all rows;
#                       when it gets too long for the model, the oldest rows are dropped.
#   max_continuations   how many times to ask the model to continue a reply cut off by
#                       provider$max_tokens.
#   max_consecutive_failures
#                       stop after this many rows in a row fail (e.g. the service is down).
#   delay               seconds to pause between requests (to stay under rate limits).
#
# Returns a data frame of all results in output_file (or of this run, if no file).
run_prompter <- function(data, prompts, provider,
                         text_col = NULL, recommendation_col = NULL, id_col = NULL,
                         output_file = NULL, resume = TRUE,
                         priming_as = c("message", "system"),
                         conversation = c("per_row", "continuous"),
                         max_continuations = 1, max_consecutive_failures = 3,
                         max_retries = AP_MAX_RETRIES, delay = 0, verbose = TRUE) {
  priming_as <- match.arg(priming_as)
  conversation <- match.arg(conversation)
  stopifnot(inherits(prompts, "prompter_prompts"), inherits(provider, "llm_provider"))
  for (p in AP_REQUIRED_PACKAGES) {
    if (!requireNamespace(p, quietly = TRUE)) stop("Install the ", p, " package: install.packages(\"", p, "\")", call. = FALSE)
  }
  say <- function(...) if (verbose) message(...)

  # ---- Inputs ----
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  text_col <- .ap_pick_column(data, text_col, "text", 1, "text")
  rec_col <- .ap_pick_column(data, recommendation_col, "recommendation", 2, "recommendation")
  ids <- if (is.null(id_col)) seq_len(nrow(data)) else data[[.ap_pick_column(data, id_col, "id", 0, "id")]]
  ids <- as.character(ids)
  if (anyDuplicated(ids)) stop("id_col values must be unique", call. = FALSE)
  as_text <- function(x) ifelse(is.na(x), "", as.character(x))
  texts <- as_text(data[[text_col]])
  recs <- as_text(data[[rec_col]])

  # ---- Output file and resume ----
  if (is.null(output_file)) {
    output_file <- file.path(AP_OUTPUT_DIR, sprintf("responses_%s_%s.csv", provider$name,
                                                     format(Sys.time(), "%Y%m%d_%H%M%S")))
  }
  write_file <- !isFALSE(output_file)
  done <- character()
  if (write_file) {
    dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
    if (file.exists(output_file) && !resume) {
      backup <- sub("(\\.csv)?$", sprintf("_old_%s.csv", format(Sys.time(), "%Y%m%d_%H%M%S")), output_file)
      file.rename(output_file, backup)
      file.rename(.ap_priming_file(output_file), .ap_priming_file(backup))
      say("Existing results moved to ", backup)
    }
    if (file.exists(output_file)) {
      previous <- read_results(output_file)
      done <- previous$id[previous$status %in% c("ok", "truncated")]
    }
  }
  todo <- which(!ids %in% done)
  say(sprintf("%s (%s) | %d rows: %d to do, %d already done%s", provider$name, provider$model, nrow(data),
              length(todo), length(done), if (write_file) paste0("\nOutput: ", output_file) else ""))
  if (!length(todo)) return(invisible(if (write_file) read_results(output_file) else .ap_empty_results()))

  # ---- Priming ----
  system <- NULL
  base <- list()
  priming <- prompts$priming
  if (!is.null(priming) && nzchar(priming)) {
    if (priming_as == "system") {
      system <- priming
    } else {
      priming_reply <- if (write_file) .ap_read_priming(output_file, priming, provider) else NULL
      if (is.null(priming_reply)) {
        say("Sending priming message...")
        r <- tryCatch(llm_chat(provider, list(list(role = "user", content = priming)), NULL,
                               max_retries, max_continuations, verbose),
                      error = function(e) e)
        if (inherits(r, "error")) {
          message("Priming failed, nothing was run: ", conditionMessage(r))
          return(invisible(structure(
            if (write_file && file.exists(output_file)) read_results(output_file) else .ap_empty_results(),
            stopped = conditionMessage(r))))
        }
        priming_reply <- r$text
        if (write_file) .ap_save_priming(output_file, priming, priming_reply, provider)
      }
      base <- list(list(role = "user", content = priming),
                   list(role = "assistant", content = priming_reply))
    }
  }

  # ---- Rows ----
  history <- list()          # only used when conversation = "continuous"
  results <- list()
  failures <- 0
  stopped <- NULL
  t_start <- Sys.time()

  ask_model <- function(msgs) {
    repeat {
      r <- tryCatch(llm_chat(provider, c(base, history, msgs), system, max_retries,
                             max_continuations, verbose),
                    llm_context = function(e) e)
      if (!inherits(r, "llm_context")) return(r)
      # Too long: in a continuous conversation, forget the oldest row and try again.
      if (conversation == "continuous" && length(history) >= 4) {
        history <<- history[-(1:4)]
        say("    Conversation too long for the model; dropped the oldest row from it.")
      } else {
        stop(r)
      }
    }
  }

  for (k in seq_along(todo)) {
    i <- todo[k]
    row <- list(id = ids[i], text = texts[i], recommendation = recs[i],
                response_1 = NA_character_, response_2 = NA_character_,
                finish_1 = NA_character_, finish_2 = NA_character_,
                status = "error", error = NA_character_, tokens_in = 0, tokens_out = 0,
                provider = provider$name, model = provider$model,
                timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
    t0 <- Sys.time()

    outcome <- tryCatch({
      msg1 <- list(role = "user", content = .ap_fill(prompts$prompt_1, texts[i], "text", prompts$sep))
      r1 <- ask_model(list(msg1))
      row$response_1 <- r1$text
      row$finish_1 <- r1$finish
      if (delay > 0) Sys.sleep(delay)

      msg2 <- list(role = "user", content = .ap_fill(prompts$prompt_2, recs[i], "recommendation", prompts$sep))
      r2 <- ask_model(list(msg1, list(role = "assistant", content = r1$text), msg2))
      row$response_2 <- r2$text
      row$finish_2 <- r2$finish
      row$tokens_in <- r1$tokens_in + r2$tokens_in
      row$tokens_out <- r1$tokens_out + r2$tokens_out
      row$status <- if (r1$truncated || r2$truncated) "truncated" else "ok"
      if (conversation == "continuous") {
        history <- c(history, list(msg1, list(role = "assistant", content = r1$text),
                                   msg2, list(role = "assistant", content = r2$text)))
      }
      "ok"
    },
    llm_fatal = function(e) e,
    error = function(e) {
      row$error <<- conditionMessage(e)
      "failed"
    })

    if (inherits(outcome, "llm_fatal")) {
      stopped <- outcome
      break
    }

    if (write_file) .ap_append_row(row, output_file)
    results[[length(results) + 1]] <- row
    failures <- if (identical(outcome, "failed")) failures + 1 else 0
    say(sprintf("[%d/%d] id %s: %s (%s in / %s out tokens, %.1f s)%s", k, length(todo), ids[i],
                row$status, row$tokens_in, row$tokens_out,
                as.numeric(difftime(Sys.time(), t0, units = "secs")),
                if (is.na(row$error)) "" else paste0("\n    ", row$error)))

    if (failures >= max_consecutive_failures) {
      stopped <- simpleCondition(sprintf("%d rows failed in a row; the last error was: %s",
                                         failures, row$error))
      break
    }
    if (delay > 0 && k < length(todo)) Sys.sleep(delay)
  }

  # ---- Summary ----
  this_run <- if (length(results)) do.call(rbind, lapply(results, as.data.frame, stringsAsFactors = FALSE)) else NULL
  if (verbose) {
    n <- function(s) if (is.null(this_run)) 0 else sum(this_run$status == s)
    message(sprintf("\nDone %d of %d rows in %.0f s: %d ok, %d truncated, %d errors. Tokens: %s in / %s out.",
                    length(results), length(todo), as.numeric(difftime(Sys.time(), t_start, units = "secs")),
                    n("ok"), n("truncated"), n("error"),
                    if (is.null(this_run)) 0 else sum(this_run$tokens_in),
                    if (is.null(this_run)) 0 else sum(this_run$tokens_out)))
  }
  if (!is.null(stopped)) {
    message("\nSTOPPED: ", conditionMessage(stopped))
    if (identical(stopped$type, "quota")) message("You may be out of credits or over your usage limit.")
    if (write_file) {
      message("Results so far are saved. Run the same run_prompter() call again (same output_file) ",
              "to continue where it stopped.")
    }
  }

  out <- if (write_file && file.exists(output_file)) read_results(output_file) else this_run %||% .ap_empty_results()
  invisible(structure(out, stopped = if (!is.null(stopped)) conditionMessage(stopped)))
}

# Run the workflow for one text + recommendation (or two equal-length vectors).
# Doesn't write a file unless you give output_file. Returns a data frame.
prompt_one <- function(text, recommendation, prompts, provider, output_file = FALSE, ...) {
  run_prompter(data.frame(text = text, recommendation = recommendation, stringsAsFactors = FALSE),
               prompts, provider, text_col = "text", recommendation_col = "recommendation",
               output_file = output_file, ...)
}

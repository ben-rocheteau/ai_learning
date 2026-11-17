# Send one conversation to an LLM and get the reply, with retries, back-off and
# automatic continuation of replies cut off by the token limit.

# Conditions raised (catch them with tryCatch):
#   llm_fatal    the run cannot continue: out of credits/quota, bad key, unknown
#                model, or still rate-limited after every retry
#   llm_context  the conversation is too long for the model
#   llm_failed   this request failed (bad request, or server errors after every retry)
.ap_condition <- function(class, message, type) {
  structure(class = c(class, "error", "condition"),
            list(message = message, call = NULL, type = type))
}

# One HTTP call with retries. Returns the parsed reply (see .ap_parse_response).
.ap_request <- function(provider, messages, system = NULL, max_retries = AP_MAX_RETRIES,
                        verbose = TRUE) {
  if (provider$name == "mock") return(.ap_mock_reply(provider, messages, system))

  req <- .ap_build_request(provider, messages, system)
  body <- jsonlite::toJSON(req$body, auto_unbox = TRUE, null = "null")

  for (attempt in 0:max_retries) {
    h <- curl::new_handle(post = TRUE, postfields = body, timeout = AP_TIMEOUT_SECONDS)
    curl::handle_setheaders(h, .list = c(as.list(req$headers), `content-type` = "application/json"))

    res <- tryCatch(curl::curl_fetch_memory(req$url, handle = h), error = function(e) e)
    if (inherits(res, "error")) {
      err <- list(type = "retry", message = paste("Network error:", conditionMessage(res)), wait = NA)
    } else {
      text <- rawToChar(res$content)
      Encoding(text) <- "UTF-8"
      if (res$status_code < 300) {
        json <- tryCatch(jsonlite::fromJSON(text, simplifyVector = FALSE), error = function(e) NULL)
        if (!is.null(json)) return(.ap_parse_response(provider, json))
        err <- list(type = "retry", message = "Reply was not valid JSON", wait = NA)
      } else {
        err <- .ap_classify_error(res$status_code, text, curl::parse_headers_list(res$headers))
      }
    }

    if (err$type == "context") stop(.ap_condition("llm_context", err$message, err$type))
    if (err$type %in% c("quota", "auth", "model")) stop(.ap_condition("llm_fatal", err$message, err$type))
    if (err$type == "request") stop(.ap_condition("llm_failed", err$message, err$type))

    # Temporary problem: wait (server's suggestion, else exponential back-off) and retry.
    if (attempt == max_retries) break
    wait <- if (!is.na(err$wait)) err$wait else 2^attempt * 2 + stats::runif(1)
    wait <- min(wait, AP_MAX_WAIT_SECONDS)
    if (verbose) message(sprintf("    %s. Retrying in %.0f s (%d/%d)", err$message, wait,
                                 attempt + 1, max_retries))
    Sys.sleep(wait)
  }

  # Rate limits that never clear mean the quota is used up for now: stop the run.
  if (grepl("HTTP 429", err$message)) {
    stop(.ap_condition("llm_fatal", paste("Still rate-limited after retries.", err$message), "quota"))
  }
  stop(.ap_condition("llm_failed", paste("Failed after retries.", err$message), "retry"))
}

# Send `messages` (and optional `system` prompt) and return:
#   list(text, finish, truncated, tokens_in, tokens_out, continuations)
# If the reply hits max_tokens, asks the model to continue up to
# `max_continuations` times and joins the parts.
llm_chat <- function(provider, messages, system = NULL, max_retries = AP_MAX_RETRIES,
                     max_continuations = 1, verbose = TRUE) {
  if (is.character(messages)) messages <- list(list(role = "user", content = paste(messages, collapse = "\n")))
  reply <- .ap_request(provider, messages, system, max_retries, verbose)
  n_cont <- 0
  while (reply$finish == "length" && n_cont < max_continuations) {
    n_cont <- n_cont + 1
    if (verbose) message("    Reply hit the token limit; asking the model to continue (", n_cont, ")")
    messages <- c(messages, list(list(role = "assistant", content = reply$text),
                                 list(role = "user", content = AP_CONTINUE_PROMPT)))
    more <- .ap_request(provider, messages, system, max_retries, verbose)
    reply <- list(text = paste0(reply$text, more$text), finish = more$finish,
                  tokens_in = reply$tokens_in + more$tokens_in,
                  tokens_out = reply$tokens_out + more$tokens_out)
  }
  c(reply, list(truncated = reply$finish == "length", continuations = n_cont))
}

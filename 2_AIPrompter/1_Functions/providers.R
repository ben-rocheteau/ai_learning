# One small adapter per LLM API: build the HTTP request, read the reply, and
# classify errors. Everything else in the prompter is provider-neutral.
#
# Messages are passed around as a list of list(role = "user"|"assistant", content = "...").

`%||%` <- function(a, b) if (is.null(a)) b else a

# Create a provider: which API, which model, and how long replies may be.
#   name        "claude", "chatgpt" or "gemini" (also "anthropic", "openai", "google"),
#               or "mock" for a free offline dry run.
#   model       model ID; NULL = the default in config.R.
#   api_key     NULL = read from the environment variable in config.R
#               (ANTHROPIC_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY).
#   max_tokens  maximum length of each reply, in tokens.
#   temperature NULL = the provider's default.
#   base_url    NULL = the official API. Set it for proxies or OpenAI-compatible
#               servers (e.g. Ollama: "http://localhost:11434/v1" with name = "chatgpt").
llm_provider <- function(name = "claude", model = NULL, api_key = NULL, max_tokens = 1024,
                         temperature = NULL, base_url = NULL) {
  key <- tolower(name)
  key <- if (key %in% names(AP_PROVIDER_ALIASES)) AP_PROVIDER_ALIASES[[key]] else key
  if (!key %in% names(AP_PROVIDERS)) {
    stop("Unknown provider '", name, "'. Use one of: ",
         paste(c(names(AP_PROVIDERS), names(AP_PROVIDER_ALIASES)), collapse = ", "), call. = FALSE)
  }
  cfg <- AP_PROVIDERS[[key]]

  if (is.null(api_key) && length(cfg$key_env)) {
    found <- Filter(nzchar, Sys.getenv(cfg$key_env))
    if (!length(found)) {
      stop("No API key for ", key, ". Set ", paste(cfg$key_env, collapse = " or "),
           " (e.g. in ~/.Renviron, then restart R), or pass api_key = ...", call. = FALSE)
    }
    api_key <- found[[1]]
  }

  structure(list(
    name = key, model = model %||% cfg$model, api_key = api_key,
    max_tokens = as.integer(max_tokens), temperature = temperature,
    base_url = sub("/+$", "", base_url %||% cfg$base_url)
  ), class = "llm_provider")
}

print.llm_provider <- function(x, ...) {
  cat(sprintf("<llm_provider> %s, model %s, max_tokens %d%s\n", x$name, x$model, x$max_tokens,
              if (is.null(x$temperature)) "" else sprintf(", temperature %s", x$temperature)))
  invisible(x)
}

# Drop NULL entries so they are not sent as {} in JSON.
.ap_compact <- function(x) x[!vapply(x, is.null, logical(1))]

# ---------------------------------------------------------------------------
# Requests: list(url, headers, body)
# ---------------------------------------------------------------------------

.ap_build_request <- function(p, messages, system = NULL) {
  switch(p$name,
    claude = list(
      url = paste0(p$base_url, "/messages"),
      headers = c(`x-api-key` = p$api_key, `anthropic-version` = "2023-06-01"),
      body = .ap_compact(list(
        model = p$model, max_tokens = p$max_tokens, system = system,
        temperature = p$temperature, messages = messages
      ))
    ),
    chatgpt = list(
      url = paste0(p$base_url, "/chat/completions"),
      headers = c(Authorization = paste("Bearer", p$api_key)),
      body = .ap_compact(list(
        model = p$model,
        messages = c(if (!is.null(system)) list(list(role = "system", content = system)), messages),
        max_completion_tokens = p$max_tokens, temperature = p$temperature
      ))
    ),
    gemini = list(
      url = sprintf("%s/models/%s:generateContent", p$base_url, p$model),
      headers = c(`x-goog-api-key` = p$api_key),
      body = .ap_compact(list(
        systemInstruction = if (!is.null(system)) list(parts = list(list(text = system))),
        contents = lapply(messages, function(m) list(
          role = if (m$role == "assistant") "model" else "user",
          parts = list(list(text = m$content))
        )),
        generationConfig = .ap_compact(list(maxOutputTokens = p$max_tokens,
                                            temperature = p$temperature))
      ))
    ),
    stop("No request builder for provider ", p$name)
  )
}

# ---------------------------------------------------------------------------
# Replies: list(text, finish, tokens_in, tokens_out)
#   finish is "stop" (complete), "length" (hit max_tokens), or the provider's own
#   reason (e.g. "refusal", "SAFETY", "blocked").
# ---------------------------------------------------------------------------

.ap_parse_response <- function(p, json) {
  num <- function(x) if (is.null(x)) 0 else as.numeric(x)
  switch(p$name,
    claude = {
      texts <- vapply(Filter(function(b) identical(b$type, "text"), json$content %||% list()),
                      function(b) b$text, character(1))
      reason <- json$stop_reason %||% "unknown"
      list(text = paste(texts, collapse = ""),
           finish = switch(reason, end_turn = , stop_sequence = "stop", max_tokens = "length", reason),
           tokens_in = num(json$usage$input_tokens), tokens_out = num(json$usage$output_tokens))
    },
    chatgpt = {
      choice <- json$choices[[1]] %||% list()
      msg <- choice$message %||% list()
      reason <- choice$finish_reason %||% "unknown"
      text <- msg$content %||% ""
      if (!nzchar(text) && !is.null(msg$refusal)) {
        text <- msg$refusal
        reason <- "refusal"
      }
      list(text = text, finish = if (reason == "stop") "stop" else reason,
           tokens_in = num(json$usage$prompt_tokens), tokens_out = num(json$usage$completion_tokens))
    },
    gemini = {
      usage <- json$usageMetadata %||% list()
      tokens <- list(tokens_in = num(usage$promptTokenCount),
                     tokens_out = num(usage$candidatesTokenCount) + num(usage$thoughtsTokenCount))
      cand <- json$candidates[[1]]
      if (is.null(cand)) {
        return(c(list(text = "", finish = paste0("blocked:", json$promptFeedback$blockReason %||% "unknown")),
                 tokens))
      }
      parts <- Filter(function(x) !isTRUE(x$thought) && !is.null(x$text), cand$content$parts %||% list())
      reason <- cand$finishReason %||% "unknown"
      c(list(text = paste(vapply(parts, function(x) x$text, character(1)), collapse = ""),
             finish = switch(reason, STOP = "stop", MAX_TOKENS = "length", reason)),
        tokens)
    },
    stop("No response parser for provider ", p$name)
  )
}

# Offline stand-in: replies with a short echo of the last message.
.ap_mock_reply <- function(p, messages, system = NULL) {
  last <- messages[[length(messages)]]$content
  text <- sprintf("[mock reply to: %s]", substr(gsub("\\s+", " ", last), 1, 80))
  list(text = text, finish = "stop",
       tokens_in = sum(nchar(vapply(messages, `[[`, "", "content"))) %/% 4,
       tokens_out = nchar(text) %/% 4)
}

# ---------------------------------------------------------------------------
# Errors
# ---------------------------------------------------------------------------
# Returns list(type, message, wait):
#   retry    temporary (rate limit, overload, server error): wait and try again
#   quota    out of credits / quota: stop the run, resume later
#   auth     bad or missing API key: stop the run
#   model    unknown model or endpoint: stop the run
#   context  conversation longer than the model's context window
#   request  anything else wrong with this request: skip the row

.ap_classify_error <- function(status, body, headers = list()) {
  msg <- tryCatch({
    j <- jsonlite::fromJSON(body, simplifyVector = FALSE)
    e <- j$error %||% j
    if (is.list(e)) paste(c(e$type, e$code, e$status, e$message), collapse = ": ") else as.character(e)
  }, error = function(e) substr(body, 1, 500))
  low <- tolower(paste(msg, body))

  # Wait time suggested by the server: Retry-After header, or Gemini's RetryInfo.
  wait <- suppressWarnings(as.numeric(headers[["retry-after"]]))
  if (is.null(wait) || !length(wait) || is.na(wait)) {
    m <- regmatches(body, regexpr('"retryDelay"\\s*:\\s*"[0-9.]+s"', body))
    wait <- if (length(m)) as.numeric(gsub("[^0-9.]", "", m)) else NA_real_
  }

  type <-
    # OpenAI "insufficient_quota", Anthropic "credit balance is too low", Gemini daily quotas.
    # (Per-minute limits share wording with these but are "retry".)
    if (grepl("insufficient_quota|credit balance|perday|per_day|requests per day", low)) "quota"
    else if (status %in% c(401, 403) || grepl("api key not valid|invalid x-api-key|incorrect api key", low)) "auth"
    else if (status == 413 || grepl("prompt is too long|context_length_exceeded|context window|maximum context length|input token count.*exceeds|too many tokens", low)) "context"
    else if (status == 404) "model"
    else if (status %in% c(408, 409, 425, 429, 500, 502, 503, 504, 529) || status >= 500) "retry"
    else "request"

  list(type = type, message = sprintf("HTTP %s: %s", status, msg), wait = wait)
}

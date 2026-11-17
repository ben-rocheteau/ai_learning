# Settings for the AI prompter. Loaded with source() by 2_AIPrompter/run_prompter.R.
# Names start with AP_ so they don't clash with 1_Data_Cleaning's helpers.

# This file lives in <repo>/2_AIPrompter/1_Functions/, so the repo root is two folders up.
AP_REPO_ROOT <- local({
  files <- Filter(Negate(is.null), lapply(rev(sys.frames()), function(f) f$ofile))
  if (!length(files)) stop("config.R must be loaded with source(), not run line by line.", call. = FALSE)
  normalizePath(file.path(dirname(files[[1]]), "..", ".."), winslash = "/")
})

# Results go next to the datasets, in the git-ignored 0_Data folder.
AP_OUTPUT_DIR <- file.path(Sys.getenv("AI_LEARNING_DATA_DIR", file.path(AP_REPO_ROOT, "0_Data")),
                           "ai_prompter")

AP_REQUIRED_PACKAGES <- c("curl", "jsonlite")

# ---------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------
# Default models change often: check each provider's model list and edit here,
# or pass `model =` to llm_provider().
#   Claude:  https://docs.anthropic.com/en/docs/about-claude/models
#   OpenAI:  https://platform.openai.com/docs/models
#   Gemini:  https://ai.google.dev/gemini-api/docs/models
AP_PROVIDERS <- list(
  claude = list(
    model    = "claude-sonnet-5-5",
    key_env  = "ANTHROPIC_API_KEY",
    base_url = "https://api.anthropic.com/v1"
  ),
  chatgpt = list(
    model    = "gpt-5-mini",
    key_env  = "OPENAI_API_KEY",
    base_url = "https://api.openai.com/v1"
  ),
  gemini = list(
    model    = "gemini-flash-latest",          # Google's alias for the latest Flash model
    key_env  = c("GEMINI_API_KEY", "GOOGLE_API_KEY"),
    base_url = "https://generativelanguage.googleapis.com/v1beta"
  ),
  mock = list(                                 # free, offline: echoes the prompt
    model    = "mock",
    key_env  = character(),
    base_url = NA_character_
  )
)

# Other names accepted by llm_provider().
AP_PROVIDER_ALIASES <- c(
  anthropic = "claude", openai = "chatgpt", gpt = "chatgpt", chat = "chatgpt",
  google = "gemini"
)

# ---------------------------------------------------------------------------
# Robustness
# ---------------------------------------------------------------------------
AP_MAX_RETRIES <- 5          # retries for rate limits, overload and network errors
AP_MAX_WAIT_SECONDS <- 120   # longest single wait between retries
AP_TIMEOUT_SECONDS <- 300    # per request

# Sent when a reply was cut off by the output-token limit.
AP_CONTINUE_PROMPT <- paste(
  "Your previous reply was cut off.",
  "Continue exactly where you stopped, without repeating anything."
)

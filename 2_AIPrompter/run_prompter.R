# AI prompter: send a priming message, then for each row
#   prompt 1 + text           -> response 1
#   prompt 2 + recommendation -> response 2
# and save every response to a .csv in 0_Data/ai_prompter/.
#
# Edit sections 1-3, then click "Source" in RStudio, or run from a terminal:
#   Rscript 2_AIPrompter/run_prompter.R
#
# API keys are read from environment variables. Put them in ~/.Renviron (never in
# this repo), then restart R:
#   ANTHROPIC_API_KEY=...   (Claude)
#   OPENAI_API_KEY=...      (ChatGPT)
#   GEMINI_API_KEY=...      (Gemini)
# Open ~/.Renviron with: usethis::edit_r_environ()  or  file.edit("~/.Renviron")

# ---- Find this repo and load the helper functions ---------------------------
local({
  this_file <- c(
    sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)),          # Rscript
    unlist(lapply(rev(sys.frames()), function(f) f$ofile)),                           # source()
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())  # RStudio, line by line
      tryCatch(rstudioapi::getSourceEditorContext()$path, error = function(e) NULL)
  )
  starts <- c(dirname(this_file[nzchar(this_file)]), getwd())
  for (dir in normalizePath(starts, winslash = "/", mustWork = FALSE)) {
    repeat {
      fn_dir <- file.path(dir, "2_AIPrompter", "1_Functions")
      if (dir.exists(fn_dir)) {
        for (f in list.files(fn_dir, pattern = "\\.R$", full.names = TRUE)) source(f)
        return(invisible())
      }
      if (dirname(dir) == dir) break
      dir <- dirname(dir)
    }
  }
  stop("Could not find the ai_learning repo (looked from: ", paste(unique(starts), collapse = ", "),
       ").\nOpen ai_learning.Rproj in RStudio, or setwd() to the repo folder.", call. = FALSE)
})

# ---- 1. Model ------------------------------------------------------------------
# "mock" is a free offline dry run. Switch to "claude", "chatgpt" or "gemini".
provider <- llm_provider("mock", max_tokens = 1024)
# provider <- llm_provider("claude")
# provider <- llm_provider("chatgpt", model = "gpt-5-mini")
# provider <- llm_provider("gemini", temperature = 0)

# ---- 2. Prompts ----------------------------------------------------------------
# Use {text} / {recommendation} to place the value inside a prompt; otherwise it is
# added after the prompt.
prompts <- prompter_prompts(
  priming  = paste("You will read product reviews. For each one, first summarise it,",
                   "then judge whether a given recommendation matches it. Be concise."),
  prompt_1 = "Summarise this review in one sentence:",
  prompt_2 = "The reviewer's recommendation was: {recommendation}\nDoes it match the review? Answer yes or no, then explain in one sentence."
)

# ---- 3. Data -------------------------------------------------------------------
# Any data frame works; say which columns to use in run_prompter() below.
data <- data.frame(
  review    = c("Arrived quickly and works great, the battery lasts all day.",
                "Broke after two uses. The seller never answered my emails."),
  recommend = c("Would buy again", "Would buy again")
)
# For example, Amazon reviews downloaded by 1_Data_Cleaning/setup_data.R:
# for (f in list.files("1_Data_Cleaning/1_Functions", "\\.R$", full.names = TRUE)) source(f)
# reviews <- load_amazon_reviews("All_Beauty", n_max = 50)
# data <- data.frame(review = reviews$text,
#                    recommend = ifelse(reviews$rating >= 4, "Recommended", "Not recommended"))

# ---- 4. Run --------------------------------------------------------------------
# Results are saved row by row. If the run stops (out of credits, rate limits,
# Ctrl+C), run this again with the same output_file and it picks up where it left off.
results <- run_prompter(
  data, prompts, provider,
  text_col = "review", recommendation_col = "recommend",
  output_file = file.path(AP_OUTPUT_DIR, paste0("example_", provider$name, ".csv"))
)

# Single text + recommendation, nothing saved:
# one <- prompt_one("Great value for money.", "Would recommend", prompts, provider)

# Other formats: .txt (readable transcript), .rds, .arrow/.parquet (needs the arrow package)
# write_results(results, file.path(AP_OUTPUT_DIR, "example_transcript.txt"))

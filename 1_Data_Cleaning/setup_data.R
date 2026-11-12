# One-shot setup: download every dataset into 0_Data/ (git-ignored).
#
# In RStudio: open this file and click "Source" (or run it line by line).
#
# From a terminal (any folder):
#   Rscript 1_Data_Cleaning/setup_data.R                        # menu for Amazon
#   Rscript 1_Data_Cleaning/setup_data.R --amazon-categories All_Beauty Software
#   Rscript 1_Data_Cleaning/setup_data.R --list-amazon          # sizes + what you have
#   Options: --no-amazon-meta  --skip-amazon  --skip-imdb  --overwrite
#
# The functions live in 1_Data_Cleaning/1_Functions/.

# ---- Find this repo and load the helper functions ---------------------------
local({
  # Where is this script? Try, in order:
  this_file <- c(
    # 1. Rscript 1_Data_Cleaning/setup_data.R
    sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)),
    # 2. source("1_Data_Cleaning/setup_data.R") or RStudio's Source button
    unlist(lapply(rev(sys.frames()), function(f) f$ofile)),
    # 3. RStudio, running lines from the editor: the file open in the editor
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
      tryCatch(rstudioapi::getSourceEditorContext()$path, error = function(e) NULL)
  )
  # 4. Otherwise start from the working directory.
  starts <- c(dirname(this_file[nzchar(this_file)]), getwd())

  # From each start, walk up until a folder contains 1_Data_Cleaning/1_Functions.
  for (dir in normalizePath(starts, winslash = "/", mustWork = FALSE)) {
    repeat {
      fn_dir <- file.path(dir, "1_Data_Cleaning", "1_Functions")
      if (dir.exists(fn_dir)) {
        for (f in list.files(fn_dir, pattern = "\\.R$", full.names = TRUE)) source(f)
        return(invisible())
      }
      if (dirname(dir) == dir) break
      dir <- dirname(dir)
    }
  }
  stop("Could not find the ai_learning repo (looked from: ",
       paste(unique(starts), collapse = ", "), ").\n",
       "Open ai_learning.Rproj in RStudio, or setwd() to the repo folder, then try again.",
       call. = FALSE)
})

# ---- Setup -------------------------------------------------------------------

# amazon_categories = NULL shows the interactive menu when someone can answer it,
# otherwise downloads AMAZON_DEFAULT_CATEGORIES.
setup_data <- function(amazon_categories = NULL, amazon_meta = TRUE,
                       skip_amazon = FALSE, skip_imdb = FALSE, overwrite = FALSE) {
  check_packages()
  dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)
  message("Data directory: ", normalizePath(DATA_DIR, winslash = "/"))

  results <- c()
  if (!skip_amazon) {
    if (is.null(amazon_categories) && can_prompt()) {
      results["amazon"] <- download_amazon_interactive(overwrite)
    } else {
      cats <- amazon_categories %||% AMAZON_DEFAULT_CATEGORIES
      parts <- if (amazon_meta) AMAZON_PARTS else "reviews"
      results["amazon"] <- download_amazon(cats, parts, overwrite = overwrite)
    }
  }
  if (!skip_imdb) results["imdb"] <- download_imdb(overwrite)

  message("\n== Summary ==")
  for (name in names(results)) {
    message(sprintf("  %-8s %s", name, if (results[[name]]) "OK" else "FAILED"))
  }
  invisible(all(results))
}

# ---- Run ---------------------------------------------------------------------
# In RStudio there are no command-line arguments, so this runs setup_data().

local({
  args <- parse_args(commandArgs(trailingOnly = TRUE))
  if (flag(args, "help") || flag(args, "h")) {
    cat("Usage: Rscript 1_Data_Cleaning/setup_data.R [--amazon-categories CAT ... | all]\n",
        "       [--no-amazon-meta] [--skip-amazon] [--skip-imdb] [--overwrite] [--list-amazon]\n", sep = "")
    return(invisible())
  }
  if (flag(args, "list-amazon")) {
    print_status_table(amazon_status())
    return(invisible())
  }
  ok <- setup_data(
    amazon_categories = category_arg(args[["amazon-categories"]], AMAZON_CATEGORIES),
    amazon_meta = !flag(args, "no-amazon-meta"),
    skip_amazon = flag(args, "skip-amazon"),
    skip_imdb = flag(args, "skip-imdb"),
    overwrite = flag(args, "overwrite")
  )
  if (!interactive()) quit(status = if (ok) 0 else 1)
})

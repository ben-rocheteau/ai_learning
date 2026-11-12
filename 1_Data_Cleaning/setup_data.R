# One-shot setup: download every dataset into 0_Data/ (git-ignored).
#
# From a terminal (run from the repo root):
#   Rscript 1_Data_Cleaning/setup_data.R                       # menu for Amazon
#   Rscript 1_Data_Cleaning/setup_data.R --amazon-categories All_Beauty Software
#   Rscript 1_Data_Cleaning/setup_data.R --skip-imdb
#   Rscript 1_Data_Cleaning/setup_data.R --skip-amazon
#   Options: --no-amazon-meta  --overwrite
#
# From R / RStudio:
#   source("1_Data_Cleaning/setup_data.R")
#   setup_data()

if (!exists("SCRIPT_DIR")) {
  SCRIPT_DIR <- local({
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (!length(f)) f <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
    if (length(f)) dirname(normalizePath(f[1]))
    else if (dir.exists("1_Data_Cleaning")) normalizePath("1_Data_Cleaning")
    else getwd()
  })
}
source(file.path(SCRIPT_DIR, "download_amazon_reviews.R"))
source(file.path(SCRIPT_DIR, "download_imdb.R"))

# amazon_categories = NULL shows the interactive menu when someone can answer it,
# otherwise downloads AMAZON_DEFAULT_CATEGORIES.
setup_data <- function(amazon_categories = NULL, amazon_meta = TRUE,
                       skip_amazon = FALSE, skip_imdb = FALSE, overwrite = FALSE) {
  check_packages()
  dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)
  message("Data directory: ", normalizePath(DATA_DIR))

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

if (sys.nframe() == 0L) {
  args <- parse_args()
  ok <- setup_data(
    amazon_categories = category_arg(args[["amazon-categories"]], AMAZON_CATEGORIES),
    amazon_meta = !flag(args, "no-amazon-meta"),
    skip_amazon = flag(args, "skip-amazon"),
    skip_imdb = flag(args, "skip-imdb"),
    overwrite = flag(args, "overwrite")
  )
  quit(status = if (ok) 0 else 1)
}

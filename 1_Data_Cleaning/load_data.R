# Helpers to load the downloaded datasets into data frames.
#
#   source("1_Data_Cleaning/load_data.R")
#   reviews <- load_amazon_reviews("All_Beauty", n_max = 10000)
#   meta    <- load_amazon_meta("All_Beauty")
#   imdb    <- load_imdb()
#
# Amazon metadata has nested fields (lists such as images or categories); they
# come back as list-columns.

if (!exists("SCRIPT_DIR")) {
  SCRIPT_DIR <- local({
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (!length(f)) f <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
    if (length(f)) dirname(normalizePath(f[1]))
    else if (dir.exists("1_Data_Cleaning")) normalizePath("1_Data_Cleaning")
    else getwd()
  })
}
source(file.path(SCRIPT_DIR, "config.R"))
source(file.path(SCRIPT_DIR, "utils.R"))

.check_file <- function(path) {
  if (!file.exists(path)) {
    stop(path, " not found. Run: Rscript 1_Data_Cleaning/setup_data.R", call. = FALSE)
  }
  path
}

# Read a .jsonl.gz file; n_max limits the number of rows (NULL = all).
read_jsonl_gz <- function(path, n_max = NULL) {
  check_packages("jsonlite")
  con <- gzfile(.check_file(path), "r")
  on.exit(close(con))
  if (is.null(n_max)) {
    jsonlite::stream_in(con, verbose = FALSE)
  } else {
    lines <- readLines(con, n = n_max, warn = FALSE)
    jsonlite::stream_in(textConnection(lines), verbose = FALSE)
  }
}

load_amazon_reviews <- function(category = "All_Beauty", n_max = NULL) {
  read_jsonl_gz(amazon_path(category, "reviews"), n_max)
}

load_amazon_meta <- function(category = "All_Beauty", n_max = NULL) {
  read_jsonl_gz(amazon_path(category, "meta"), n_max)
}

load_imdb <- function() {
  path <- .check_file(file.path(IMDB_DIR, IMDB_CSV_NAME))
  utils::read.csv(path, stringsAsFactors = FALSE, encoding = "UTF-8")
}

if (sys.nframe() == 0L) {
  for (name in c("Amazon reviews", "IMDB")) {
    tryCatch({
      df <- if (name == "IMDB") load_imdb() else load_amazon_reviews(n_max = 5)
      cat(sprintf("\n%s: %d rows x %d cols\n", name, nrow(df), ncol(df)))
      print(utils::head(df))
    }, error = function(e) cat(sprintf("\n%s: %s\n", name, conditionMessage(e))))
  }
}

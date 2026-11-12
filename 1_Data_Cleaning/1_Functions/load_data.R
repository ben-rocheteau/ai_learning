# Helpers to load the downloaded datasets into data frames.
#
#   reviews <- load_amazon_reviews("All_Beauty", n_max = 10000)
#   meta    <- load_amazon_meta("All_Beauty")
#   imdb    <- load_imdb()
#
# Amazon metadata has nested fields (lists such as images or categories); they
# come back as list-columns.

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

# Download the IMDB 50K movie reviews dataset (Kaggle) into 0_Data/imdb_50k/.
#
# Result: 0_Data/imdb_50k/IMDB Dataset.csv  (columns: review, sentiment)
#
# Uses the Kaggle API. If Kaggle asks for credentials (HTTP 401/403), set them in
# one of these ways (create a token at kaggle.com > Settings > API):
#   - put kaggle.json in ~/.kaggle/  (contains "username" and "key")
#   - or set KAGGLE_USERNAME and KAGGLE_KEY, e.g. in ~/.Renviron
#   - or set KAGGLE_API_TOKEN to a Kaggle API token
# If all else fails, download the zip manually from the dataset page and put
# "IMDB Dataset.csv" in 0_Data/imdb_50k/.
#
# Main function: download_imdb(overwrite = FALSE)

# curl handle carrying Kaggle credentials, if any are configured.
kaggle_handle <- function() {
  h <- curl::new_handle()
  token <- Sys.getenv("KAGGLE_API_TOKEN")
  user <- Sys.getenv("KAGGLE_USERNAME")
  key <- Sys.getenv("KAGGLE_KEY")
  if (!nzchar(user) || !nzchar(key)) {
    cfg_dir <- Sys.getenv("KAGGLE_CONFIG_DIR", file.path(path.expand("~"), ".kaggle"))
    json <- file.path(cfg_dir, "kaggle.json")
    if (file.exists(json)) {
      creds <- jsonlite::read_json(json)
      user <- creds$username %||% ""
      key <- creds$key %||% ""
    }
  }
  if (nzchar(token)) {
    curl::handle_setheaders(h, Authorization = paste("Bearer", token))
  } else if (nzchar(user) && nzchar(key)) {
    curl::handle_setopt(h, httpauth = 1L, userpwd = paste0(user, ":", key))
  } else {
    message("  No Kaggle credentials found; trying without login.")
  }
  h
}

# Returns TRUE on success.
download_imdb <- function(overwrite = FALSE) {
  check_packages()
  message("\n== IMDB 50K movie reviews ==")
  dest <- file.path(IMDB_DIR, IMDB_CSV_NAME)
  if (file.exists(dest) && !overwrite) {
    message("  [skip] ", IMDB_CSV_NAME, " already exists")
    return(TRUE)
  }

  zip <- file.path(IMDB_DIR, "imdb-dataset.zip")
  handle <- kaggle_handle()
  if (!download_file(IMDB_KAGGLE_URL, zip, overwrite = TRUE, handle = handle)) {
    message("  Kaggle download failed. See the top of download_imdb.R for how to set\n",
            "  Kaggle credentials, or download the file manually from:\n",
            "  https://www.kaggle.com/datasets/", IMDB_KAGGLE_HANDLE)
    return(FALSE)
  }

  on.exit(unlink(zip))
  files <- tryCatch(utils::unzip(zip, exdir = IMDB_DIR), error = function(e) character())
  if (!file.exists(dest)) {
    message("  [error] '", IMDB_CSV_NAME, "' not found in the downloaded archive (got: ",
            paste(basename(files), collapse = ", "), ")")
    return(FALSE)
  }
  message("  [ok]   ", dest)
  TRUE
}

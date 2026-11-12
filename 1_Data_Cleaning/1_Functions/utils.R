# Helpers shared by the data setup scripts: packages, downloads, prompts, CLI args.

REQUIRED_PACKAGES <- c("curl", "jsonlite")

`%||%` <- function(a, b) if (is.null(a)) b else a

check_packages <- function(pkgs = REQUIRED_PACKAGES) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Missing R packages. Install them with:\n  install.packages(c(",
         paste0('"', missing, '"', collapse = ", "), "))", call. = FALSE)
  }
}

# ---------------------------------------------------------------------------
# Sizes
# ---------------------------------------------------------------------------

human_size <- function(n) {
  if (is.null(n) || is.na(n)) return("?")
  units <- c("B", "KB", "MB", "GB", "TB")
  i <- 1
  while (n >= 1024 && i < length(units)) {
    n <- n / 1024
    i <- i + 1
  }
  if (i == 1) sprintf("%.0f %s", n, units[i]) else sprintf("%.1f %s", n, units[i])
}

# Download sizes (bytes) reported by the server for each URL, NA if unknown.
# Requests run in parallel.
remote_sizes <- function(urls, timeout = 15) {
  sizes <- rep(NA_real_, length(urls))
  pool <- curl::new_pool(host_con = 8)
  for (i in seq_along(urls)) {
    local({
      idx <- i
      h <- curl::new_handle(url = urls[idx], nobody = TRUE, followlocation = TRUE, timeout = timeout)
      curl::multi_add(h, pool = pool,
        done = function(res) {
          if (res$status_code >= 400) return()
          headers <- rawToChar(res$headers)
          m <- regmatches(headers, gregexpr("(?i)content-length:\\s*\\d+", headers, perl = TRUE))[[1]]
          if (length(m)) {
            n <- as.numeric(sub("^\\D*", "", m[length(m)]))  # last one = after redirects
            if (n > 0) sizes[idx] <<- n
          }
        },
        fail = function(msg) NULL)
    })
  }
  curl::multi_run(pool = pool)
  sizes
}

# ---------------------------------------------------------------------------
# Download
# ---------------------------------------------------------------------------

# Download `url` to `dest` with a progress bar. Writes to `<dest>.part` first and
# renames on success, so an interrupted download never looks complete.
# Returns TRUE on success, FALSE on error.
download_file <- function(url, dest, overwrite = FALSE, handle = curl::new_handle()) {
  if (file.exists(dest) && !overwrite) {
    message("  [skip] ", basename(dest), " already exists")
    return(TRUE)
  }
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  tmp <- paste0(dest, ".part")
  message("  [get]  ", basename(dest))
  ok <- tryCatch({
    curl::handle_setopt(handle, failonerror = TRUE, followlocation = TRUE)
    curl::curl_download(url, tmp, quiet = FALSE, handle = handle)
    TRUE
  }, error = function(e) {
    message("  [error] ", basename(dest), ": ", conditionMessage(e))
    FALSE
  })
  if (!ok) {
    unlink(tmp)
    return(FALSE)
  }
  file.rename(tmp, dest)
}

# ---------------------------------------------------------------------------
# Prompts
# ---------------------------------------------------------------------------

.io <- new.env()

# TRUE when a person can answer prompts (RStudio/R console, or Rscript in a terminal).
can_prompt <- function() interactive() || isatty(stdin())

ask <- function(prompt) {
  if (interactive()) return(readline(prompt))
  cat(prompt)
  flush(stdout())
  if (is.null(.io$stdin)) .io$stdin <- file("stdin", open = "r")
  line <- readLines(.io$stdin, n = 1, warn = FALSE)
  if (length(line)) line else ""
}

# ---------------------------------------------------------------------------
# Command-line arguments
# ---------------------------------------------------------------------------

# Parse e.g. `-c A B --no-meta` into list(categories = c("A", "B"), `no-meta` = TRUE).
# `aliases` renames short flags, e.g. c(c = "categories").
parse_args <- function(args = commandArgs(trailingOnly = TRUE), aliases = character()) {
  out <- list()
  key <- NULL
  for (a in args) {
    if (grepl("^-", a)) {
      key <- sub("^-+", "", a)
      if (key %in% names(aliases)) key <- aliases[[key]]
      out[[key]] <- TRUE
    } else if (!is.null(key)) {
      out[[key]] <- if (isTRUE(out[[key]])) a else c(out[[key]], a)
    } else {
      stop("Unexpected argument: ", a, call. = FALSE)
    }
  }
  out
}

flag <- function(args, name) isTRUE(args[[name]])

# Values of a multi-value option, with 'all' expanded to every category.
category_arg <- function(values, all_categories) {
  if (is.null(values) || isTRUE(values)) return(NULL)
  if (length(values) == 1 && tolower(values) == "all") return(all_categories)
  values
}

# Amazon Reviews 2023 (McAuley Lab): download functions and interactive menu.
#
# Files go to 0_Data/amazon_reviews_2023/ as gzipped JSON Lines:
#   reviews/<Category>.jsonl.gz       user reviews
#   meta/meta_<Category>.jsonl.gz     item metadata (title, price, ...)
#
# Main functions:
#   download_amazon_interactive()                        menu with sizes + what you have
#   download_amazon(c("Software"), parts = "reviews")    no prompts
#   print_status_table(amazon_status())                  table only

# ---------------------------------------------------------------------------
# Download
# ---------------------------------------------------------------------------

# Download `parts` ("reviews" and/or "meta") of each category.
# Returns TRUE if every file succeeded.
download_amazon <- function(categories = AMAZON_DEFAULT_CATEGORIES,
                            parts = AMAZON_PARTS, overwrite = FALSE) {
  check_packages()
  unknown <- setdiff(categories, AMAZON_CATEGORIES)
  if (length(unknown)) {
    message("Unknown categories: ", paste(unknown, collapse = ", "),
            ". Use --list to see valid names.")
    return(FALSE)
  }
  ok <- TRUE
  for (cat in categories) {
    message("\n== Amazon Reviews 2023: ", cat, " ==")
    for (part in parts) {
      ok <- download_file(amazon_url(cat, part), amazon_path(cat, part), overwrite) && ok
    }
  }
  ok
}

# ---------------------------------------------------------------------------
# Status table (what you have + remote sizes)
# ---------------------------------------------------------------------------

# Data frame with one row per (category, part): url, local path, size, have.
amazon_status <- function(categories = AMAZON_CATEGORIES) {
  check_packages()
  df <- expand.grid(part = AMAZON_PARTS, category = categories, stringsAsFactors = FALSE)
  df <- df[, c("category", "part")]
  df$url <- mapply(amazon_url, df$category, df$part, USE.NAMES = FALSE)
  df$path <- mapply(amazon_path, df$category, df$part, USE.NAMES = FALSE)
  df$have <- file.exists(df$path)
  message("Checking download sizes for ", nrow(df), " files...")
  df$size <- remote_sizes(df$url)
  df
}

print_status_table <- function(status) {
  cats <- unique(status$category)
  width <- max(nchar(cats))
  cell <- function(cat, part) {
    row <- status[status$category == cat & status$part == part, ]
    sprintf("%9s %s", human_size(row$size), if (row$have) "[have]" else "      ")
  }
  cat(sprintf("\n  #  %-*s  %16s  %16s\n", width, "Category", "Reviews", "Metadata"))
  cat("  ", strrep("-", width + 40), "\n", sep = "")
  for (i in seq_along(cats)) {
    cat(sprintf("%3d  %-*s  %s  %s\n", i, width, cats[i],
                cell(cats[i], "reviews"), cell(cats[i], "meta")))
  }
  on_disk <- sum(file.size(status$path[status$have]))
  cat(sprintf("\n  [have] = already in %s  (total on disk: %s)\n", AMAZON_DIR, human_size(on_disk)))
  cat("  Sizes are compressed (.jsonl.gz) download sizes; '?' = server did not report one.\n")
}

# ---------------------------------------------------------------------------
# Interactive menu
# ---------------------------------------------------------------------------

# Parse "1,3,5-7", "all", or category names (any case) into category names.
parse_selection <- function(text, categories = AMAZON_CATEGORIES) {
  text <- trimws(text)
  if (tolower(text) == "all") return(categories)
  tokens <- strsplit(gsub(",", " ", text), "\\s+")[[1]]
  tokens <- tokens[nzchar(tokens)]
  chosen <- character()
  for (tok in tokens) {
    if (grepl("^[0-9]+-[0-9]+$", tok)) {
      ends <- as.integer(strsplit(tok, "-")[[1]])
      idx <- seq(min(ends), max(ends))
    } else if (grepl("^[0-9]+$", tok)) {
      idx <- as.integer(tok)
    } else if (tolower(tok) %in% tolower(categories)) {
      chosen <- c(chosen, categories[tolower(categories) == tolower(tok)])
      next
    } else {
      stop(sprintf("'%s' is not a number, range or category name", tok), call. = FALSE)
    }
    bad <- idx[idx < 1 | idx > length(categories)]
    if (length(bad)) stop(sprintf("%d is out of range (1-%d)", bad[1], length(categories)), call. = FALSE)
    chosen <- c(chosen, categories[idx])
  }
  unique(chosen)
}

# Show the status table and ask what to download.
# Returns list(categories, parts), or NULL if the user cancels.
amazon_select <- function(overwrite = FALSE) {
  status <- amazon_status()
  print_status_table(status)

  repeat {
    text <- ask("\nWhich categories? (e.g. 1,3,5-7 | All_Beauty Software | all | Enter to cancel): ")
    if (!nzchar(trimws(text))) return(NULL)
    chosen <- tryCatch(parse_selection(text), error = function(e) {
      cat("  ", conditionMessage(e), "\n", sep = "")
      NULL
    })
    if (length(chosen)) break
  }

  choice <- tolower(substr(trimws(ask(
    "Which parts? [b]oth reviews + metadata, [r]eviews only, [m]etadata only (default b): ")), 1, 1))
  parts <- switch(choice, r = "reviews", m = "meta", AMAZON_PARTS)

  sel <- status[status$category %in% chosen & status$part %in% parts, ]
  sel <- sel[order(match(sel$category, chosen), match(sel$part, AMAZON_PARTS)), ]
  todo <- if (overwrite) rep(TRUE, nrow(sel)) else !sel$have

  labels <- paste(sel$category, sel$part)
  width <- max(nchar(labels))
  cat("\n")
  for (i in which(!todo)) cat(sprintf("  [have] %s\n", labels[i]))
  for (i in which(todo)) cat(sprintf("  [get]  %-*s  %9s\n", width, labels[i], human_size(sel$size[i])))
  if (!any(todo)) {
    cat("\nYou already have everything selected. Nothing to download.\n")
    return(NULL)
  }

  sizes <- sel$size[todo]
  n_unknown <- sum(is.na(sizes))
  total <- if (n_unknown == length(sizes)) "size unknown" else {
    paste0(human_size(sum(sizes, na.rm = TRUE)),
           if (n_unknown) sprintf(" + %d file(s) of unknown size", n_unknown) else "")
  }
  answer <- tolower(trimws(ask(sprintf("\nDownload %d file(s), %s? [y/N]: ", sum(todo), total))))
  if (!answer %in% c("y", "yes")) {
    cat("Cancelled.\n")
    return(NULL)
  }
  list(categories = chosen, parts = parts)
}

# Menu + download. Returns TRUE unless a download failed (cancelling counts as OK).
download_amazon_interactive <- function(overwrite = FALSE) {
  selection <- amazon_select(overwrite = overwrite)
  if (is.null(selection)) return(TRUE)
  download_amazon(selection$categories, selection$parts, overwrite = overwrite)
}

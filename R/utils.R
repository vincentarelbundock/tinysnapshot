snapshot_label <- function(label) {
  regex <- "[^[:alnum:]|_|-]"
  regexdot <- "[^[:alnum:]_|\\-|\\.]"
  out <- gsub(regexdot, "_", label, perl = TRUE)
  return(out)
}

ts_assert_package <- function(package) {
  flag <- requireNamespace(package, quietly = TRUE)
  if (isFALSE(flag)) {
    msg <- sprintf("Please install the `%s` package.", package)
    stop(msg, call. = FALSE)
  }
}

ts_assert_choice <- function(x, choices) {
  flag <- is.character(x) &&
    length(x) == 1 &&
    x %in% choices
  if (!flag) {
    msg <- sprintf(
      "Invalid value. Must be one of: %s",
      paste(sprintf('"%s"', choices), collapse = ", ")
    )
    stop(msg, call. = FALSE)
  }
}

ts_assert_number <- function(x, lower = -Inf, upper = Inf) {
  flag <- is.numeric(x) &&
    length(x) == 1 &&
    x >= lower &&
    x <= upper
  if (!flag) {
    msg <- sprintf(
      "Invalid value. Must be a single number between %s and %s.",
      lower,
      upper
    )
    stop(msg, call. = FALSE)
  }
}

ts_assert_file_exists <- function(x) {
  if (!is.character(x) || length(x) != 1) {
    stop("Invalid file name.", call. = FALSE)
  }
  if (!file.exists(x)) {
    msg <- sprintf("Missing file: %s", x)
    stop(msg, call. = FALSE)
  }
}

ts_assert_named_list <- function(x, null.ok = FALSE) {
  if (is.null(x) && null.ok) {
    return(invisible(NULL))
  }
  if (!is.list(x) || is.null(names(x))) {
    stop("Must be a named list.", call. = FALSE)
  }
}

ts_check_file_exists <- function(x) {
  if (!is.character(x) || length(x) != 1 || !file.exists(x)) {
    FALSE
  } else {
    TRUE
  }
}

ts_assert_path_for_output <- function(x) {
  if (!is.character(x) || length(x) != 1) {
    stop("Invalid path.", call. = FALSE)
  }
  #    # This doesn't work
  #    if (file.access(x, mode = 2) != 0) {
  #        msg <- sprintf("Path not writeable: %s", x)
  #        stop(msg, call. = FALSE)
  #    }
}

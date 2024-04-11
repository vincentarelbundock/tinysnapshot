#' Test if printed output matches a target printout
#'
#' @description
#' This expectation can be used with `tinytest` to check if the new plot matches
#' a target plot. 
#' 
#' When the expectation is checked for the first time, the expectation fails and
#' a reference text file is saved to the `inst/tinytest/_tinysnapshot` folder.
#' 
#' To update a snapshot, delete the reference file from the `_tinysnapshot`
#' folder and run the test suite again.
#' 
#' See the package README file or website for detailed examples.
#' 
#' @param current an object which returns text to the console when calling `print(x`)`
#' @param mode "unified", "sidebyside", "context", or "auto". See `?diffobj::diffPrint`
#' @param format "raw", "ansi8", "ansi256", "html", or "auto". See `?diffobj::diffPrint`
#' @inheritParams expect_snapshot_plot
#' @param ... Additional arguments are passed to `diffobj::diffPrint()`
#' @return A `tinytest` object. A `tinytest` object is a `logical` with attributes holding information about the test that was run
#' @export
expect_snapshot_print <- function(current,
                                  label,
                                  mode = getOption("tinysnapshot_mode", default = "unified"),
                                  format = getOption("tinysnapshot_format", default = "ansi256"),
                                  ...) {

    # defaults
    snapshot <- snapshot_label(label)
    snapshot_fn <- file.path("_tinysnapshot", paste0(snapshot, ".txt"))
    cal <- sys.call(sys.parent(1))
    diff <- info <- NA_character_
    fail <- FALSE

    # if snapshot missing, copy current to snapshot, and return failure immediately
    if (!isTRUE(ts_check_file_exists(snapshot_fn))) {
        if (isTRUE(tinytest::at_home())) {
            dir.create(dirname(snapshot_fn), showWarnings = FALSE, recursive = TRUE)
            sink(snapshot_fn)
            print(current)
            sink()
            info <- paste("Creating snapshot:", snapshot_fn)
        } else {
             # stop() otherwise source("test-file.R") fails silently
            info <- 'Snapshot missing: %s. Make sure you execute commands in the right directory, or use one of the `tinytest` runners to generate new snapshots: `run_test_dir()` or `run_test_file()`.'
            info <- sprintf(info, snapshot_fn)
            stop(info, call. = FALSE)
        }
        return(tinytest::tinytest(FALSE, call = cal, info = info))
    }

    # snapshot exists -> diff
    print.tinysnapshotprint <- function(x) cat(x)
    target <- readLines(snapshot_fn, warn = FALSE)
    target <- paste(target, collapse = "\n")
    class(target) <- c("tinysnapshotprint", class(target))

    do <- suppressWarnings(diffobj::diffPrint(
        current,
        target,
        mode = mode,
        format = format,
        guides = FALSE,
        sgr.supported = TRUE,
        strip.sgr = FALSE,
        ...))

    if (suppressWarnings(any(do))) {
        fail <- TRUE
        diff <- paste(as.character(do), collapse = "\n")
        info <- paste("Snapshot:", snapshot_fn)
    }

    tinytest::tinytest(
        result = !fail,
        call = cal,
        info = info,
        diff = diff)
}

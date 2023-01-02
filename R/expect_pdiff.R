#' Test if printed output matches a target printout
#'
#' This expectation can be used with `tinytest` to check if the new plot matches
#' a target plot. 
#' 
#' When the expectation is checked for the first time, the expectation fails and
#' a reference text file is saved to the `inst/tinytest/_tinyviztest` folder.
#' 
#' To update a snapshot, delete the reference file from the `_tinyviztest`
#' folder and run the test suite again.
#' 
#' @param x an object which returns text to the console when calling `print(x`)`
#' @inheritParams expect_vdiff
#' @inheritParams diffobj::diffPrint
#' @return A `tinytest` object. A tinytest object is a
#' \code{logical} with attributes holding information about the test that was
#' run
#' @export
expect_pdiff <- function(x,
                         label,
                         mode = "unified",
                         format = "raw") {

    fn <- snapshot_file(label, extension = "txt")
    info <- diff <- NA_character_
    fail <- FALSE

    # snapshot missing -> generate (only "at home")
    if (!file.exists(fn)) {
        fail <- TRUE
        info <- write_snapshot_print(x, fn = fn)

    # snapshot exists -> diff
    } else {
        ref <- readChar(fn, file.info(fn)$size)
        print.tinyvizstring <- function(x) cat(x)
        class(ref) <- c("tinyvizstring", class(ref))

        do <- diffobj::diffPrint(
            ref,
            x,
            mode = mode,
            format = format,
            ...)

        if (suppressWarnings(any(do))) {
            fail <- TRUE
            diff <- paste(as.character(do), collapse = "\n")
        }
    }

    tinytest::tinytest(
        result = !fail,
        call = sys.call(sys.parent(1)),
        info = info,
        diff = diff)
}
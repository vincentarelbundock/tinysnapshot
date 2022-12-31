# method to print the custom class object we feed to `diffobj::diffPrint()`
print.tinyvizstring <- function(x) cat(x)


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
expect_pdiff <- function(x, label, disp.width = 200) {

    label <- portable_label(label) 

    fn <- file.path("_tinyviztest", paste0(label, ".txt"))

    # if there is no reference file (first run), we create it
    if (!file.exists(fn)) {
        msg <- sprintf("Creating reference file: %s", fn)
        warning(msg, call. = FALSE)
        dir.create(dirname(fn), showWarnings = FALSE, recursive = TRUE)
        sink(fn)
        print(x)
        sink()
        flag <- FALSE
        di <- "blah"

    } else {
        ref <- readChar(fn, file.info(fn)$size)
        class(ref) <- c("tinyvizstring", class(ref))
        di <- diffobj::diffPrint(ref, x, disp.width = disp.width)
        flag <- suppressWarnings(!any(di))
        di <- paste(as.character(di), collapse = "\n")
    }

    tinytest::tinytest(
        result = flag,
        call = sys.call(sys.parent(1)),
        diff = di,
        info = "diffobj::printDiff()")
}

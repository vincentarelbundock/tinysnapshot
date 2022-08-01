#' Test if the current plot matches a target plot
#'
#' This expectation can be used with `tinytest` to check if the current plot matches a target plot. When the expectation is checked for the first time, the expectation fails and a target plot is saved in a folder called `_tinyviztest`. If the expectation fails after the first run, the current plot and a comparison object are saved in `tinyviztest_current` and `tinyviztest_compare`.
#' @param current an object of class `ggplot` or a function which returns a base R plot. See Examples below.
#' @param name a string to identify the test. Each plot in the test suite must have a unique name.
#' @param tolerance integer the number of different pixels that are acceptable before triggering a failure.
#' @param device Graphics device to generate output. See ?[gdiff::gdiffDevice]
#' @param clean TRUE cleans the test directory. FALSE keeps the current plot and a visual diff file.
#' @param overwrite `TRUE` if the target plot should be overwritten; `FALSE`
#' otherwise.
#' @return A \code{\link{tinytest}} object. A tinytest object is a
#' \code{logical} with attributes holding information about the test that was
#' run
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(tinytest)
#' using(tinyviztest)
#'
#' # ggplot2: run once to save a snapshot
#' expect_vdiff(
#'   ggplot(mtcars, aes(mpg, hp)) + geom_point(),
#'   name = "ggplot2 example")
#'
#' # ggplot2: run a second time -> PASS
#' expect_vdiff(
#'   ggplot(mtcars, aes(mpg, hp)) + geom_point(),
#'   name = "ggplot2 example")
#'
#' # ggplot2: run with the wrong plot -> FAIL
#' expect_vdiff(
#'   ggplot(mtcars, aes(mpg, wt)) + geom_point(),
#'   name = "ggplot2 example")
#'
#' # Base R graphics: Function which returns a plot
#' expect_vdiff(
#'   function() plot(mtcars$mpg, mtcars$wt),
#'   name = "base R example")
#'
#' expect_vdiff(
#'   function() plot(mtcars$mpg, mtcars$wt),
#'   name = "base R example")
#' }
#' @export
expect_vdiff <- function(current,
                         name,
                         tolerance = 0,
                         overwrite = FALSE,
                         clean = FALSE,
                         device = gdiff::pngDevice()) {

    # portable test names
    name <- gsub(" ", "_", name)

    # support both types
    if (inherits(current, "ggplot")) {
        fun <- function() print(current)
    } else if (is.function(current)) {
        fun <- current
    } else {
        stop("Must be an object of class `ggplot` or a function which prints a plot.")
    }

    tmp <- tempfile()
    tmp_current <- file.path(tmp, "current")
    tmp_diff <- file.path(tmp, "diff")

    dir.create("_tinyviztest", showWarnings = FALSE)
    dir.create(tmp_current, showWarnings = FALSE, recursive = TRUE)
    dir.create(tmp_diff, showWarnings = FALSE, recursive = TRUE)

    fn_current <- gdiff::gdiffOutput(
        fun,
        name = name,
        dir = tmp_current,
        device = device,
        clean = FALSE)

    fn_target <- file.path("_tinyviztest", basename(fn_current))

    if (!file.exists(fn_target) || isTRUE(overwrite)) {
        # void <- file.rename(fn_current, fn_target)
        fs::file_move(fn_current, fn_target)
        msg <- "new plot was saved to: %s"
        msg <- sprintf(msg, fn_target)
        flag <- FALSE
        pixels <- 0

    } else {
        results <- gdiff::gdiffCompare(
            controlDir = "_tinyviztest",
            testDir = tmp_current,
            compareDir = tmp_diff,
            clean = FALSE)
        msg <- "pixels"
        pixels <- results$diffs[fn_target][1]
        flag <- isTRUE(pixels <= tolerance)

        if (!isTRUE(clean) && !isTRUE(flag)) {
            bn <- basename(fn_target)
            dir.create("_tinyviztest_fail/current", showWarnings = FALSE, recursive = TRUE)
            dir.create("_tinyviztest_fail/diff", showWarnings = FALSE, recursive = TRUE)
            void <- file.copy(file.path(tmp, "current", bn), "_tinyviztest_fail/current/", recursive = TRUE)
            # gdiff renames diff file, doubling the extension
            fn_diff <- file.path(tmp, "diff", list.files(file.path(tmp, "diff"))[1])
            void <- file.copy(fn_diff, "_tinyviztest_fail/diff/", recursive = TRUE)
        }
    }

    # if (!isTRUE(flag)) {
    #     flag <- "The current image does not match the target image."
    # }

    tinytest::tinytest(
        result = flag,
        call = sys.call(sys.parent(1)),
        diff = as.character(pixels),
        info = msg)
}


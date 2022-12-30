#' Test if the new plot matches a target plot
#'
#' This expectation can be used with `tinytest` to check if the new plot matches
#' a target plot. 
#' 
#' When the expectation is checked for the first time, the expectation fails and
#' a reference plot is saved to the `inst/tinytest/_tinyviztest` folder.
#' 
#' When the expectation fails, the reference plot, the new plot, and a diff are
#' saved to the `inst/tinytest/label` folder. Call the `review()` function to compare.
#' 
#' To update a snapshot, delete the reference file from the `_tinyviztest`
#' folder and run the test suite again.
#' 
#' @param x an object of class `ggplot` or a function which returns a base R plot. See Examples below.
#' @param label a string to identify the test. Each plot in the test suite must have a unique label.
#' @param tolerance distance estimates larger than this threshold will trigger a test failure. Scale depends on the `metric` argument. With the default `metric="AE"` (absolute error), the `tolerance` corresponds roughly to the number of pixels of difference between the plot and the reference image. See also `?distance_plot`
#' @inheritParams magick::image_compare
#' @return A `tinytest` object. A tinytest object is a
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
#'   label = "ggplot2 example")
#'
#' # ggplot2: run a second time -> PASS
#' expect_vdiff(
#'   ggplot(mtcars, aes(mpg, hp)) + geom_point(),
#'   label = "ggplot2 example")
#'
#' # ggplot2: run with the wrong plot -> FAIL
#' expect_vdiff(
#'   ggplot(mtcars, aes(mpg, wt)) + geom_point(),
#'   label = "ggplot2 example")
#'
#' # Base R graphics: Function which returns a plot
#' expect_vdiff(
#'   function() plot(mtcars$mpg, mtcars$wt),
#'   label = "base R example")
#'
#' expect_vdiff(
#'   function() plot(mtcars$mpg, mtcars$wt),
#'   label = "base R example")
#' }
#' @export
expect_vdiff <- function(x,
                         label,
                         tolerance = 0,
                         metric = "AE",
                         fuzz = 0) {

    # Graphics device to generate output. See ?[gdiff::gdiffDevice]
    # we could eventually add support for other devices
    device <- gdiff::pngDevice()

    # sanity
    if (!is.character(metric) || length(metric) != 1 || !metric %in% magick::metric_types()) {
        msg <- sprintf(
            "The `metric` argument must be a single string, element of: %s",
            paste(magick::metric_types(), collapse = ", "))
        stop(msg, call. = FALSE)
    }

    fn_ref <- file.path("_tinyviztest", paste0(label, ".png"))

    # if there is no reference file, this is the first arwe need to create it
    if (!file.exists(fn_ref)) {
        msg <- sprintf("Creating reference file: %s", fn_ref)
        warning(msg, call. = FALSE)
        render(x, path = fn_ref, device = device)
        flag <- FALSE
        pixels <- 0

    } else {
        cmp <- distance_plot(
            x,
            label = label,
            path = fn_ref,
            tolerance = tolerance,
            device = device,
            clean = FALSE)
        flag <- compare(x = cmp, label = label, tolerance = tolerance)
        pixels <- cmp$distance
    }

    tinytest::tinytest(
        result = flag,
        call = sys.call(sys.parent(1)),
        diff = as.character(pixels),
        info = "pixels")
}
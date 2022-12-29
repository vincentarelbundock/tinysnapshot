#' Review the plots rendered by the `tinyviztest` suite
#'
#' @param label a string to identify the test. Each plot in the test suite must have a unique label. When `label` is `NULL`, the function returns a list of images ready for review.
#' @param path Path to the `_tinyviztest_review` folder. This folder is created when expectations fail while using `tinytest`.
#' @param width Width of the graphics device window
#' @param height Height of the graphics device window
#' @return A plot with 3 panels: old, new, and diff pictures.
#' @export
tinyvizreview <- function(
    label = NULL,
    path = "inst/tinytest/_tinyviztest_review",
    width = 12,
    height = width / 3) {

    if (is.null(label)) {
        return(list.files(path))
    }

    dir_name <- file.path(path, label)
    fn_new <- file.path(dir_name, "new.png")
    fn_old <- file.path(dir_name, "old.png")
    fn_diff <- file.path(dir_name, "diff.png")
    for (fn in c(fn_new, fn_old, fn_diff)) {
        if (!file.exists(fn)) {
            msg <- sprintf("Missing file: %s. Check the `label` and `path` arguments, or try running the `tinytest` suite again.", fn)
            stop(msg, call. = FALSE)
        }
    }

    fn_old <- grDevices::as.raster(png::readPNG(fn_old))
    fn_new <- grDevices::as.raster(png::readPNG(fn_new))
    fn_diff <- grDevices::as.raster(png::readPNG(fn_diff))

    # reset graphics parameters
    def.par <- par(no.readonly = TRUE)

    # plot grid
    par(mfrow = c(1, 3), mar = rep(0, 4))
    plot(fn_old)
    plot(fn_new)
    plot(fn_diff)

    # reset graphics parameters
    par(def.par)

    return(invisible(NULL))
}

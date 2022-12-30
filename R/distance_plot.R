#' Measure the distance between an `R` plot and a plot saved as a PNG file.
#' 
#' @inheritParams expect_vdiff
#' @param x a `ggplot2` object or a function which returns a base `R` plot when executed.
#' @param path Path to the saved plot in PNG format.
#' @param clean `TRUE` deletes temporary files.
#' @export
distance_plot <- function(x,
                          path,
                          tolerance = 0,
                          metric = "AE",
                          fuzz = 0,
                          clean = TRUE,
                          ...) {

    if (!file.exists(path)) {
        msg <- sprintf("This file does not exist: %s", path)
        stop(msg, call. = FALSE)
    }

    # `gdiff` requires a directory structure
    randdir <- sample(c(0:9, letters), 20, replace = TRUE)
    randdir <- paste0("tinyviztest_compare_", paste(randdir, collapse = ""))
    randfn <- file.path(randdir, paste0("new", ".png"))

    render(x, randfn)

    old <- magick::image_read(path)
    new <- magick::image_read(randfn)
    imgdist <- magick::image_compare_dist(old, new, metric = metric, fuzz = fuzz)$distortion
    imgdiff <- magick::image_compare(old, new, metric = metric, fuzz = fuzz)
    fn_diff <- file.path(randdir, "diff.png")
    magick::image_write(imgdiff, path = fn_diff)

    out <- list(
        new = randfn,
        old = path,
        diff = fn_diff,
        tmp_dir = randdir,
        distance = imgdist)

    if (isTRUE(clean)) {
        unlink(out$tmp_dir, recursive = TRUE, force = TRUE)
    }

    return(out)
}
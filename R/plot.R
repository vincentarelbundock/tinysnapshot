render <- function(x, path, width = 480, height = 480) {
    if (!identical(tools::file_ext(path), "png")) {
        msg <- "Plots can only be rendered to files with .png extension."
        stop(msg, call. = FALSE)
    }

    dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)

    # support both types
    ragg::agg_png(path, width = width, height = height)

    if (inherits(x, "ggplot")) {
        print(x)
    } else if (is.function(x)) {
        x()
    } else {
        msg <- "Must be an object of class `ggplot` or a function which prints a plot."
        stop(msg, call. = FALSE)
    }

    invisible(grDevices::dev.off())
}


#' Measure the distance between an `R` plot and a plot saved as a PNG file.
#' 
#' @inheritParams expect_vdiff
#' @param x a `ggplot2` object or a function which returns a base `R` plot when executed.
#' @param path Path to the saved plot in PNG format.
#' @export
distance <- function(x,
                     path,
                     tolerance = 0,
                     metric = "AE",
                     fuzz = 0,
                     ...) {

    if (!file.exists(path)) {
        msg <- sprintf("This file does not exist: %s", path)
        stop(msg, call. = FALSE)
    }

    # render new plot to temp file
    fn_tmp <- paste0(tempfile(), ".png")
    render(x, fn_tmp)

    # compare new and old
    old <- magick::image_read(path)
    new <- magick::image_read(fn_tmp)
    dif <- magick::image_compare(old, new, metric = metric, fuzz = fuzz)
    dis <- magick::image_compare_dist(
        old,
        new,
        metric = metric,
        fuzz = fuzz)
    dis <- unname(dis$distortion)

    review <- function(...) {
        # reset graphics parameters
        def.par <- graphics::par(no.readonly = TRUE)

        # plot grid
        graphics::par(mfrow = c(1, 3), mar = rep(0, 4))
        plot(grDevices::as.raster(old))
        plot(grDevices::as.raster(new))
        plot(grDevices::as.raster(dif))

        # reset graphics parameters
        graphics::par(def.par)
    }

    fn <- paste0(tempfile(), ".png")

    render(
        review,
        path = fn,
        width = 640 * 3,
        height = 640)

    out <- list(
        review = fn,
        distance = dis)

    return(out)
}
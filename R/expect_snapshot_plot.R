#' Test if the new plot matches a target (snapshot) plot
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
#' @param current an object of class `ggplot` or a function which returns a base R plot. See Examples below.
#' @param label a string to identify the snapshot (alpha-numeric, hypohens, or underscores). Each plot in the test suite must have a unique label.
#' @param width of snapshot in pixel (not supported for svg)
#' @param height of snapshot in pixels (not supported for svg)
#' @param device "svg", "png", "ragg" or "svglite"
#' @param tol distance estimates larger than this threshold will trigger a test failure. Scale depends on the `metric` argument. With the default `metric="AE"` (absolute error), the `tolerance` corresponds roughly to the number of pixels of difference between the plot and the reference image.
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
#' expect_snapshot_plot(
#'   ggplot(mtcars, aes(mpg, hp)) + geom_point(),
#'   label = "ggplot2 example")
#'
#' # ggplot2: run a second time -> PASS
#' expect_snapshot_plot(
#'   ggplot(mtcars, aes(mpg, hp)) + geom_point(),
#'   label = "ggplot2 example")
#'
#' # ggplot2: run with the wrong plot -> FAIL
#' expect_snapshot_plot(
#'   ggplot(mtcars, aes(mpg, wt)) + geom_point(),
#'   label = "ggplot2 example")
#'
#' # Base R graphics: Function which returns a plot
#' expect_snapshot_plot(
#'   function() plot(mtcars$mpg, mtcars$wt),
#'   label = "base R example")
#'
#' expect_snapshot_plot(
#'   function() plot(mtcars$mpg, mtcars$wt),
#'   label = "base R example")
#' }
#' @export
expect_snapshot_plot <- function(current,
                                 label,
                                 width = 480,
                                 height = 480,
                                 tol = width * height * 0.001,
                                 metric = "AE",
                                 fuzz = 0,
                                 device = getOption("tinyviztest_device", default = "ragg")
                                 ) {

    ts_assert_choice(device, c("ragg", "png", "svg", "svglite"))

    # defaults
    snapshot <- snapshot_label(label)
    cal <- sys.call(sys.parent(1))
    if (device %in% c("png", "ragg")) {
        ext <- ".png"
    } else if (device %in% c("svg", "svglite")) {
        ext <- ".svg"
    }
    current_fn <- paste0(tempfile(), ext)
    snapshot_fn <- file.path("_tinyviztest", paste0(snapshot, ext))

    if (!is.function(current) && !inherits(current, "ggplot")) {
        info <- "`current` must be a `ggplot2` object or a function which returns a base `R` plot."
        return(tinytest::tinytest(FALSE, call = cal, info = info))
    }

    # write current plot to file
    if (device == "ragg") {
        ts_assert_package("ragg")
        ragg::agg_png(current_fn, width = width, height = height)
    } else if (device == "png") {
        grDevices::png(current_fn, width = width, height = height)
    } else if (device == "svglite") {
        ts_assert_package("svglite")
        svglite::svglite(current_fn, width = 7, height = 7)
    } else if (device == "svg") {
        grDevices::svg(current_fn, width = 7, height = 7)
    }
    if (inherits(current, "ggplot")) {
        print(current)
    } else {
        current()
    }
    invisible(grDevices::dev.off())

    # if snapshot missing, copy current to snapshot, and return failure immediately
    if (!isTRUE(ts_check_file_exists(snapshot_fn))) {
        if (isTRUE(tinytest::at_home())) {
            dir.create(dirname(snapshot_fn), recursive = TRUE, showWarnings = FALSE)
            file.copy(from = current_fn, to = snapshot_fn)
            info <- paste("Creating snapshot:", snapshot_fn)
        } else {
            # stop() otherwise source("test-file.R") fails silently
            info <- "Snapshot missing: %s. Make sure you execute commands in the right directory, or use one of the `tinytest` runners to generate new snapshots: `run_test_dir()` or `run_test_file()`."
            info <- sprintf(info, snapshot_fn)
            stop(info, call. = FALSE)
        }
        return(tinytest::tinytest(FALSE, call = cal, info = info))
    }

    # if snapshot present -> compare images and save diff plot
    dir.create("_tinyviztest_review", recursive = TRUE, showWarnings = FALSE)
    out <- expect_equivalent_images(
        current_fn,
        snapshot_fn,
        tol = tol,
        metric = metric,
        fuzz = fuzz,
        diffpath = file.path("_tinyviztest_review", paste0(basename(snapshot), ".png")) 
    )
    attr(out, "call") <- cal
    return(out)
}



#' Test if two image files are equivalent
#' 
#' @param current path to an image file
#' @param target path to an image file
#' @param diffpath path where to save an image which shows the differences between `current` and `target`. `NULL` means that the diff image is not saved.
#' @inheritParams expect_snapshot_plot
#' @export
expect_equivalent_images <- function(current,
                                     target,
                                     tol = sqrt(.Machine$double.eps),
                                     metric = "AE",
                                     fuzz = 0,
                                     diffpath = NULL) {
                                
    # default values
    cal <- sys.call(sys.parent(1))
    info <- diff <- NA_character_
    fail <- FALSE

    # input sanity checks
    ts_assert_choice(metric, choices = magick::metric_types())
    ts_assert_number(tol, lower = 0)
    ts_assert_number(fuzz, lower = 0)
    ts_assert_file_exists(current)
    ts_assert_file_exists(target)
    if (!is.null(diffpath)) {
        ts_assert_path_for_output(diffpath)
    }

    # distance > tol
    # warnings: ImageMagick wants us to install `rsvg` for better quality rendering
    target <- suppressWarnings(magick::image_read(target))
    current <- suppressWarnings(magick::image_read(current))
    dis <- magick::image_compare_dist(
        target,
        current,
        metric = metric,
        fuzz = fuzz)
    dis <- unname(dis$distortion)
    info <- paste("Distance metric:", metric)
    diff <- as.character(dis)
    if (dis > tol) fail <- TRUE

    # diff plot
    if (isTRUE(fail) && !is.null(diffpath)) {
        diffplot <- magick::image_compare(current, target, metric = metric, fuzz = fuzz)

        current <- grDevices::as.raster(current)
        target <- grDevices::as.raster(target)
        diffplot <- grDevices::as.raster(diffplot)

        width <- nrow(current) + nrow(target) + nrow(diffplot)
        height <- max(c(ncol(current), ncol(target), ncol(diffplot)))

        grDevices::png(diffpath, width = width, height = height)
        def_par <- graphics::par(no.readonly = TRUE) # save graphics params
        graphics::par(mfrow = c(1, 3), mar = rep(0, 4))
        plot(target)
        plot(current)
        plot(diffplot)
        invisible(grDevices::dev.off())
        graphics::par(def_par) # reset graphics parameters

        info <- paste("Diff plot saved to:", diffpath)
    }

    # test results
    tinytest::tinytest(
        result = !fail,
        call = cal,
        info = info,
        diff = diff)
}
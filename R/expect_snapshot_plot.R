#' Test if the new plot matches a target (snapshot) plot
#'
#' @description
#' This expectation can be used with `tinytest` to check if the new plot matches
#' a target plot. 
#' 
#' When the expectation is checked for the first time, the expectation fails and
#' a reference plot is saved to the `inst/tinytest/_tinysnapshot` folder.
#' 
#' When the expectation fails, the reference plot, the new plot, and a diff are
#' saved to the `inst/tinytest/label` folder. Call the `review()` function to compare.
#' 
#' To update a snapshot, delete the reference file from the `_tinysnapshot`
#' folder and run the test suite again.
#'
#' See the package README file or website for detailed examples.
#' 
#' @param current an object of class `ggplot` or a function which returns a base R plot.
#' @param label a string to identify the snapshot (alpha-numeric, hyphens, or underscores). Each plot in the test suite must have a unique label.
#' @param width of the snapshot. PNG default: 480 pixels. SVG default: 7 inches.
#' @param height of the snapshot. PNG default: 480 pixels. SVG default: 7 inches.
#' @param device "svg", "png", "ragg" or "svglite"
#' @param tol distance estimates larger than this threshold will trigger a test failure. Scale depends on the `metric` argument. With the default `metric="AE"` (absolute error), the `tolerance` corresponds roughly to the number of pixels of difference between the plot and the reference image.
#' @param metric string with a metric from `magick::metric_types()` such as `"AE"` or `"phash"`.
#' @param fuzz relative color distance between 0 and 100 to be considered similar.
#' @param os character vector of operating systems on which the test should be run (e.g., "Windows", "Linux", "Darwin"). Tests are skipped when no element of the vector matches the output of: `Sys.info()["sysname"]`
#' @return A `tinytest` object. A `tinytest` object is a `logical` with attributes holding information about the test that was run
#'
#' @export
expect_snapshot_plot <- function(current,
                                 label,
                                 width = getOption("tinysnapshot_width", default = NULL),
                                 height = getOption("tinysnapshot_height", default = NULL),
                                 tol = getOption("tinysnapshot_tol", default = 0),
                                 metric = getOption("tinysnapshot_metric", default = "AE"),
                                 fuzz = getOption("tinysnapshot_fuzz", default = 0),
                                 device = getOption("tinysnapshot_device", default = "svg"),
                                 os = getOption("tinysnapshot_os", default = Sys.info()["sysname"])
                                 ) {

    ts_assert_choice(device, c("ragg", "png", "svg", "svglite"))
    
    if (!isTRUE(is.vector(os)) || !isTRUE(is.character(os))) {
        stop("`os` must be a character vector.")
    }
    
    if (!Sys.info()["sysname"] %in% os) {
        return(invisible(NULL))
    }

    # defaults
    snapshot <- snapshot_label(label)
    cal <- sys.call(sys.parent(1))
    if (device %in% c("png", "ragg")) {
        ext <- ".png"
        if (is.null(width)) width <- 480
        if (is.null(height)) height <- width
    } else if (device %in% c("svg", "svglite")) {
        ext <- ".svg"
        if (is.null(width)) width <- 7
        if (is.null(height)) height <- width
    }
    current_fn <- paste0(tempfile(), ext)
    snapshot_fn <- file.path("_tinysnapshot", paste0(snapshot, ext))


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
        # need rsvg otherwise magick returns all white images
        ts_assert_package("rsvg")
        ts_assert_package("svglite")
        svglite::svglite(current_fn, width = 7, height = 7)
    } else if (device == "svg") {
        # need rsvg otherwise magick returns all white images
        ts_assert_package("rsvg")
        grDevices::svg(current_fn, width = 7, height = 7)
    }
    if (inherits(current, "ggplot")) {
        ts_assert_package("ggplot2")
        print(current + ggplot2::theme_test())
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
    dir.create("_tinysnapshot_review", recursive = TRUE, showWarnings = FALSE)
    out <- expect_equivalent_images(
        current_fn,
        snapshot_fn,
        tol = tol,
        metric = metric,
        fuzz = fuzz,
        diffpath = file.path("_tinysnapshot_review", paste0(basename(snapshot), ".png")) 
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
#' @return A `tinytest` object. A `tinytest` object is a `logical` with attributes holding information about the test that was run
#' @export
expect_equivalent_images <- function(current,
                                     target,
                                     tol = getOption("tinysnapshot_tol", default = 0),
                                     metric = getOption("tinysnapshot_metric", default = "AE"),
                                     fuzz = getOption("tinysnapshot_fuzz", default = 0),
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
    if (tools::file_ext(target) == "svg") {
        file_target <- magick::image_read_svg(target)
        file_current <- magick::image_read_svg(current)
    } else {
        file_target <- suppressWarnings(magick::image_read(target))
        file_current <- suppressWarnings(magick::image_read(current))
    }
    dis <- magick::image_compare_dist(
        file_target,
        file_current,
        metric = metric,
        fuzz = fuzz)
    dis <- unname(dis$distortion)
    info <- paste("Distance metric:", metric)
    diff <- as.character(dis)
    if (dis > tol) fail <- TRUE

    # diff plot
    if (isTRUE(fail) && !is.null(diffpath)) {
        diffplot <- magick::image_compare(file_current, file_target, metric = metric, fuzz = fuzz)

        file_current <- grDevices::as.raster(file_current)
        file_target <- grDevices::as.raster(file_target)
        diffplot <- grDevices::as.raster(diffplot)

        width <- nrow(file_current) + nrow(file_target) + nrow(diffplot)
        height <- max(c(ncol(file_current), ncol(file_target), ncol(diffplot)))

        grDevices::png(diffpath, width = width, height = height)
        def_par <- graphics::par(no.readonly = TRUE) # save graphics params
        graphics::par(mfrow = c(1, 3), mar = rep(0, 4))
        plot(file_target)
        plot(file_current)
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
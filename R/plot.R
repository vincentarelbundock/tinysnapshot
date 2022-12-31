render <- function(x, path) {
    if (!identical(tools::file_ext(path), "png")) {
        msg <- "Plots can only be rendered to files with .png extension."
        stop(msg, call. = FALSE)
    }

    dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)

    # support both types
    ragg::agg_png(path)

    if (inherits(x, "ggplot")) {
        print(x)
    } else if (is.function(x)) {
        x()
    } else {
        msg <- "Must be an object of class `ggplot` or a function which prints a plot."
        stop(msg, call. = FALSE)
    }

    invisible(grDevices::dev.off())

    ##### old code works with `gdiff`

    # # `gdiff` requires directory structure
    # randdir <- sample(c(0:9, letters), 20, replace = TRUE)
    # randdir <- paste0("tinyviztest_render_", paste(randdir, collapse = ""))

    # unlink(".gdiffSession")

    # fn <- suppressWarnings(gdiff::gdiffOutput(
    #     obj,
    #     dir = randdir,
    #     device = device,
    #     clean = TRUE))

    # pathdir <- dirname(path)
    # dir.create(pathdir, showWarnings = FALSE, recursive = TRUE)
    # file.rename(fn[1], path)

    # unlink(".gdiffSession")
    # unlink(randdir, recursive = TRUE, force = TRUE)
}
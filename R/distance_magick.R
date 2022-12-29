distance_magick <- function(x,
                            label,
                            path,
                            tolerance = 0,
                            metric = "AE",
                            device = gdiff::pngDevice(),
                            ...) {
    flag <- suppressPackageStartupMessages(require("magick"))
    if (!isTRUE(flag)) {
        msg <- "Please install the `magick` package."
        stop(msg, call. = FALSE)
    }

    # `gdiff` requires a directory structure
    randdir <- sample(c(0:9, letters), 20, replace = TRUE)
    randdir <- paste0("tinyviztest_compare_", paste(randdir, collapse = ""))
    randfn <- paste0(file.path(randdir), ".png")

    render(x, randfn, device = device)

    old <- magick::image_read(path)
    new <- magick::image_read(randfn)
    dist <- magick::image_compare_dist(old, new, metric = metric)$distortion

    out <- list(
        old = randfn,
        new = path,
        dir = randdir,
        distance = dist)
    return(out)
}
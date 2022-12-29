distance_magick <- function(x,
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
    randfn <- file.path(randdir, paste0("new", ".png"))

    render(x, randfn, device = device)

    old <- magick::image_read(path)
    new <- magick::image_read(randfn)
    imgdist <- magick::image_compare_dist(old, new, metric = metric)$distortion
    imgdiff <- magick::image_compare(old, new, metric = metric)
    fn_diff <- file.path(randdir, "diff.png")
    magick::image_write(imgdiff, path = fn_diff)

    out <- list(
        new = randfn,
        old = path,
        diff = fn_diff,
        tmp_dir = randdir,
        distance = imgdist)
    return(out)
}
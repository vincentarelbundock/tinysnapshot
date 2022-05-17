#' @export
write_vdiff <- function(object,
                        name,
                        dir = "_tinyviztest_target",
                        device = gdiff::pngDevice(),
                        overwrite = FALSE) {
    dir <- file.path(dir, name)
    if (!dir.exists(dir)) {
        void <- dir.create(dir, recursive = TRUE)
    }
    if (inherits(object, "ggplot")) {
        fun <- function() print(object)
    } else if (is.function(object)) {
        fun <- object
    } else {
        stop("Must be an object of class `ggplot` or a function which prints a plot.")
    }
    void <- tryCatch(
        gdiff::gdiffOutput(fun,
                           name = name,
                           dir = dir,
                           device = device,
                           clean = overwrite),
        error = function(e) e)
    if (inherits(void, "error")) {
        msg <- "Directory already contains 'gdiff' output"
        if (identical(void$message, msg)) {
            msg <- sprintf(
                "The target plot already exists. Use `overwrite=TRUE` to overwrite the files located here: %s",
                dir)
            stop(msg, call. = FALSE)
        } else {
            stop(msg$error, call. = FALSE)
        }
    }
}


#' @export
expect_vdiff <- function(x,
                         name,
                         dir_current = "_tinyviztest_current",
                         dir_target = "_tinyviztest_target",
                         dir_compare = "_tinyviztest_compare",
                         device = gdiff::pngDevice()) {
    # deeply nested because gdiffOutput overwrites all files in directory
    # even if they have different names
    dir_target <- file.path(dir_target, name)
    dir_compare <- file.path(dir_compare, name)
    if (!dir.exists(dir_compare)) dir.create(dir_compare, recursive = TRUE)
    write_vdiff(
        x,
        name = name,
        dir = dir_current,
        device = device,
        overwrite = TRUE)
    # dir_current is only combined now because `write_vdiff` handled it before
    dir_current <- file.path(dir_current, name)
    results <- gdiff::gdiffCompare(dir_target, dir_current, dir_compare)
    identical_images <- isTRUE(results[["diffs"]][1] == 0)
    tinytest::tinytest(
        result = identical_images,
        call = sys.call(sys.parent(1)),
        diff = results[["diffs"]][1],
        info = "pixels")
}


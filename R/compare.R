compare <- function(x, label, tolerance = 0) {
    if (x$distance > tolerance) {
        revdir <- file.path("_tinyviztest_review", label)
        dir.create(revdir, showWarnings = FALSE, recursive = TRUE)
        file.rename(x$new, file.path(revdir, "new.png"))
        file.rename(x$old, file.path(revdir, "old.png"))
        file.rename(x$diff, file.path(revdir, "diff.png"))
        flag <- FALSE
    } else {
        flag <- TRUE
    }
    unlink(x$tmp_dir, recursive = TRUE, force = TRUE)
    return(flag)
}
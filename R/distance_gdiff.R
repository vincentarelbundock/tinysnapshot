distance_gdiff <- function(x, label, path, tolerance = 0, device = gdiff::pngDevice(), ...) {
    # `gdiff` requires a directory structure
    randdir <- sample(c(0:9, letters), 20, replace = TRUE)
    randdir <- paste0("tinyviztest_compare_", paste(randdir, collapse = ""))
    controlDir <- file.path(randdir, "control")
    testDir <- file.path(randdir, "test")
    compareDir <- file.path(randdir, "compare")
    dir.create(controlDir, recursive = TRUE, showWarnings = FALSE)
    dir.create(testDir, recursive = TRUE, showWarnings = FALSE)
    dir.create(compareDir, recursive = TRUE, showWarnings = FALSE)

    file.copy(path, controlDir, recursive = TRUE)
    render(x, file.path(testDir, basename(path)), device = device)

    results <- gdiff::gdiffCompare(
        controlDir = controlDir,
        testDir = testDir,
        compareDir = compareDir,
        clean = FALSE)

    if (results$diffs[1] > tolerance) {
        revdir <- file.path("_tinyviztest_review", label)
        dir.create(revdir, showWarnings = FALSE, recursive = TRUE)
        file.rename(results$testFiles[1], file.path(revdir, "new.png"))
        file.rename(results$controlFiles[1], file.path(revdir, "old.png"))
        file.rename(results$diffFiles[1], file.path(revdir, "diff.png"))
    }

    # cleanup temp files
    unlink(randdir, recursive = TRUE, force = TRUE)

    return(results$diffs[1])
}


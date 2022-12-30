# We do not need this because it yields exactly the same results as "Absolute Error":
# magick::image_compare(metric = "AE") 





# distance_gdiff <- function(x,
#                            path,
#                            tolerance = 0,
#                            clean = TRUE,
#                            ...) {

#     device = gdiff::pngDevice()

#     # `gdiff` requires a directory structure
#     randdir <- sample(c(0:9, letters), 20, replace = TRUE)
#     randdir <- paste0("tinyviztest_compare_", paste(randdir, collapse = ""))
#     controlDir <- file.path(randdir, "control")
#     testDir <- file.path(randdir, "test")
#     compareDir <- file.path(randdir, "compare")
#     dir.create(controlDir, recursive = TRUE, showWarnings = FALSE)
#     dir.create(testDir, recursive = TRUE, showWarnings = FALSE)
#     dir.create(compareDir, recursive = TRUE, showWarnings = FALSE)

#     file.copy(path, controlDir, recursive = TRUE)
#     render(x, file.path(testDir, basename(path)), device = device)

#     results <- gdiff::gdiffCompare(
#         controlDir = controlDir,
#         testDir = testDir,
#         compareDir = compareDir,
#         clean = FALSE)

#     out <- list(
#         new = results$testFiles[1],
#         old = results$controlFiles[1],
#         diff = results$diffFiles[1],
#         tmp_dir = randdir,
#         distance = unname(results$diffs[1]))

#     if (isTRUE(clean)) {
#         unlink(out$tmp_dir, recursive = TRUE, force = TRUE)
#     }

#     return(out)
# }
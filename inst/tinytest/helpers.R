rm(list = ls())
OSes <- c("Darwin")
options(width = 10000)
options(tinysnapshot_os = OSes)
# Small tolerance to absorb antialiasing drift across macOS versions: the
# Quartz `png` device renders slightly differently on macOS 15 vs 26. Genuine
# plot differences are ~1e-2, two orders of magnitude above this threshold.
options(tinysnapshot_tol = 1e-4)

ON_CRAN <- !identical(Sys.getenv("NOT_CRAN"), "true")
BAD_OS <- !Sys.info()[["sysname"]] %in% OSes
SKIP <- ON_CRAN || BAD_OS

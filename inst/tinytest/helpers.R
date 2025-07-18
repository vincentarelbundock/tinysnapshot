rm(list = ls())
OSes <- c("Linux", "Darwin")
options(width = 10000)
options(tinysnapshot_os = OSes)

ON_CRAN <- !identical(Sys.getenv("NOT_CRAN"), "true")
SKIP <- ON_CRAN

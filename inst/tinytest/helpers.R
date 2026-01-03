rm(list = ls())
OSes <- c("Darwin")
options(width = 10000)
options(tinysnapshot_os = OSes)
options(tinysnapshot_tol = 0.00)

ON_CRAN <- !identical(Sys.getenv("NOT_CRAN"), "true")
BAD_OS <- !Sys.info()[["sysname"]] %in% OSes
SKIP <- ON_CRAN || BAD_OS

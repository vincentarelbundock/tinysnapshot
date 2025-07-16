rm(list = ls())
options(width = 10000)
options(tinysnapshot_os = c("Linux")) # , "Darwin"))

SKIP = !identical(Sys.getenv("NOT_CRAN"), "true") ||
  !Sys.info()[["sysname"]] %in% c("Linux")

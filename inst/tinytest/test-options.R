source("helpers.R")
using("tinysnapshot")

options(tinysnapshot_device = "svglite")

p1 <- function() plot(mtcars$hp, mtcars$mpg)
flag <- expect_snapshot_plot(p1, "svglite-base")

if (Sys.info()["sysname"] == "Linux") {
  expect_inherits(flag, "tinytest")
} else {
  expect_null(flag)
}

options(tinysnapshot_device = NULL)
options(tinysnapshot_os = NULL)

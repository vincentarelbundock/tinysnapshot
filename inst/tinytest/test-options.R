source("helpers.R")
using("tinysnapshot")

options(tinysnapshot_device = "svglite")

if (!SKIP) {
  p1 <- function() plot(mtcars$hp, mtcars$mpg)
  flag <- expect_snapshot_plot(p1, "svglite-base")
  expect_inherits(flag, "tinytest")
}

options(tinysnapshot_device = NULL)
options(tinysnapshot_os = NULL)

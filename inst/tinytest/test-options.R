source("helpers.R")
using("tinysnapshot")
if (SKIP) exit_file("skip")

options(tinysnapshot_device = "svglite")

p1 <- function() plot(mtcars$hp, mtcars$mpg)
flag <- expect_snapshot_plot(p1, "svglite-base")
expect_inherits(flag, "tinytest")

options(tinysnapshot_device = NULL)
options(tinysnapshot_os = NULL)

library("tinytest")
using("tinysnapshot")

p <- function() with(mtcars, plot(hp, mpg))
expect_snapshot_plot(p, "svg-basic", device = "svg")

options(tinysnapshot_device = "svg")
expect_snapshot_plot(p, "svg-basic", device = "svg")
options(tinysnapshot_device = NULL)
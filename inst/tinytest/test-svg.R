library("tinytest")
using("tinysnapshot")

p <- function() with(mtcars, plot(hp, mpg))
expect_snapshot_plot(p, "svg-basic", device = "svglite")

options(tinysnapshot_device = "svglite")
expect_snapshot_plot(p, "svg-basic")
options(tinysnapshot_device = NULL)
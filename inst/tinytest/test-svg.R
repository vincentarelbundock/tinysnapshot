library("tinytest")
using("tinyviztest")

p <- function() with(mtcars, plot(hp, mpg))
expect_snapshot_plot(p, "svg-basic", device = "svg")
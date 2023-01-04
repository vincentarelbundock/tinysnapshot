# 1st run: These tests fail 6 times and generate 3 reference plots
# 2nd run: These tests fail 3 times

library("tinytest")
using("tinyviztest")


###### base R
p1 <- function() plot(mtcars$hp, mtcars$mpg)
p2 <- function() plot(mtcars$hp, mtcars$wt)

# good plot
# Run once to create the reference plot
# Run twice to pass the test
expect_snapshot_plot(p1, "plot-base")

# bad plot always fails
expect_snapshot_plot(p2, "plot-base")


###### ggplot2
suppressPackageStartupMessages(library("ggplot2"))

p1 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()
expect_snapshot_plot(p1, "plot-ggplot2_variable")

p2 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
expect_snapshot_plot(p2, "plot-ggplot2_variable")

p3 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()
expect_snapshot_plot(p3, "plot-ggplot2_theme")

p4 <- ggplot(mtcars, aes(mpg, hp)) + geom_point() + theme_minimal()
expect_snapshot_plot(p4, "plot-ggplot2_theme")
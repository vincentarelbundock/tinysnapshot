# 1st run: These tests fail 6 times and generate 3 reference plots
# 2nd run: These tests fail 3 times
library("tinytest")
using("tinysnapshot")
options(tinysnapshot_device = "png")

###### base R
p1 <- function() plot(mtcars$hp, mtcars$mpg)
p2 <- function() plot(mtcars$hp, mtcars$wt)

# good plot
# Run once to create the reference plot
# Run twice to pass the test
expect_snapshot_plot(p1, "png-base")

# bad plot always fails
flag <- tinysnapshot::expect_snapshot_plot(p2, "png-base")
expect_false(flag)

###### ggplot2
suppressPackageStartupMessages(library("ggplot2"))

p1 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()
expect_snapshot_plot(p1, "png-ggplot2_variable")

p2 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
flag <- tinysnapshot::expect_snapshot_plot(p2, "png-ggplot2_variable")
expect_false(flag)

p3 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()
expect_snapshot_plot(p3, "png-ggplot2_theme")

p4 <- ggplot(mtcars, aes(mpg, hp)) + geom_point() + theme_minimal()
flag <- tinysnapshot::expect_snapshot_plot(p4, "png-ggplot2_theme")
expect_false(flag)



options(tinysnapshot_device = NULL)
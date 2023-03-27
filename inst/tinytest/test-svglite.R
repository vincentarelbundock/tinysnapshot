source("helpers.R")

# 1st run: These tests fail 6 times and generate 3 reference plots
# 2nd run: These tests fail 3 times
library("tinytest")
using("tinysnapshot")
options(tinysnapshot_device = "svglite")

###### base R
p1 <- function() plot(mtcars$hp, mtcars$mpg)
p2 <- function() plot(mtcars$hp, mtcars$wt)

# good plot
# Run once to create the reference plot
# Run twice to pass the test
if (!ON_CRAN) {
    expect_snapshot_plot(p1, "svglite-base")
}

# bad plot always fails
expect_false(ignore(expect_snapshot_plot)(p2, "svglite-base"))

###### ggplot2
suppressPackageStartupMessages(library("ggplot2"))

if (!ON_CRAN) {
    p1 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()
    expect_snapshot_plot(p1, "svglite-ggplot2_variable")
}

p2 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
expect_false(ignore(expect_snapshot_plot)(p2, "svglite-ggplot2_variable"))



options(tinysnapshot_device = NULL)
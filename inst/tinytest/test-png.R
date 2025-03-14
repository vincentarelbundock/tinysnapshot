source("helpers.R")
if (ON_CI) exit_file("CI") # works locally but not on Github actions

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
expect_false(ignore(expect_snapshot_plot)(p2, "png-base", review = FALSE))

###### ggplot2
suppressPackageStartupMessages(library("ggplot2"))

p1 <- ggplot(mtcars, aes(mpg, hp)) +
    geom_point()
expect_snapshot_plot(p1, "png-ggplot2_variable")

p2 <- ggplot(mtcars, aes(mpg, wt)) +
    geom_point()
expect_false(ignore(expect_snapshot_plot)(p2, "png-ggplot2_variable", review = FALSE))

# test expect_equivalent_images ever so briefly
pf1 <- tempfile(fileext = ".png")
pf2 <- tempfile(fileext = ".png")
pf3 <- tempfile(fileext = ".png")
set.seed(123)
D <- data.frame(x = 1:100, y = cumsum(rnorm(100)))

png(pf1)
with(D, plot(x, y, type = "l", main = "Plot One"))
dev.off()

png(pf2)
with(D, plot(x, y, type = "l", main = "Plot Two", xlab = "Foo"))
dev.off()

# plots differ so expect false result
expect_false(ignore(expect_equivalent_images)(pf1, pf2, diffpath = pf3, review = FALSE))
expect_false(ignore(expect_equivalent_images)(pf1, pf2, diffpath = pf3, style = "diff", review = FALSE))
expect_false(ignore(expect_equivalent_images)(pf1, pf2, diffpath = pf3, style = c("old", "new", "diff"), review = FALSE))

# wrong arguments
expect_error(expect_equivalent_images(pf1, pf2, diffpath = pf3, style = "multiple"))
options(tinysnapshot_plot_diff_style = "wrong argument")
expect_error(expect_equivalent_images(pf1, pf2, diffpath = pf3))

options(tinysnapshot_device = NULL)
options(tinysnapshot_plot_diff_style = "three")

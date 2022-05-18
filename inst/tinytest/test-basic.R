library("tinytest")
using("tinyviztest")

p1 <- function() plot(mtcars$hp, mtcars$mpg)
p2 <- function() plot(mtcars$hp, mtcars$wt)

# 1st run fails but writes the target to file
expect_vdiff(p1, "base simple")

# 2nd run succeeds
expect_vdiff(p1, "base simple")

# bad plot fails (clean to avoid CI artefacts)
expect_vdiff(p2, "base simple")

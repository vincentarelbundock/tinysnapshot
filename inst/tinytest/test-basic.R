library(tinytest)
library(tinyviztest)
tinytest::using(tinyviztest)

p1 <- function() plot(mtcars$hp, mtcars$mpg)
p2 <- function() plot(mtcars$hp, mtcars$wt)

# 1st run fails but writes the target to file
flag <- expect_vdiff(p1, "base simple")
expect_true(!isTRUE(flag))

# 2nd run succeeds
flag <- expect_vdiff(p1, "base simple")
expect_true(isTRUE(flag))

# bad plot fails (clean to avoid CI artefacts)
flag <- expect_vdiff(p2, "base simple", clean = FALSE)
expect_true(!isTRUE(flag))

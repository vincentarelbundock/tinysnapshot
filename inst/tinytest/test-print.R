# 1st run: These tests fail 2 times and generate 1 reference text file
# 2nd run: These tests fail 1 time
library("tinytest")
using("tinysnapshot")

mod1 <- lm(mpg ~ hp + factor(gear), mtcars)
mod2 <- lm(mpg ~ factor(gear), mtcars)

# First run fails
# Second run passes
expect_snapshot_print(summary(mod1), "print-lm_summary")

# Always fails
expect_false(ignore(expect_snapshot_print)(summary(mod2), "print-lm_summary"))
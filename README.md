
# Visual regression testing in the `tinytest` framework for `R`

<!-- badges: start -->

[![R-CMD-check](https://github.com/vincentarelbundock/tinyviztest/workflows/R-CMD-check/badge.svg)](https://github.com/vincentarelbundock/tinyviztest/actions)
<!-- badges: end -->

[`tinytest` is a wonderful package for
`R`](https://cran.r-project.org/package=tinytest) created by Mark van
der Loo. It is a “lightweight, no-dependency, but full-featured package
for unit testing in `R`.”

`tinyviztest` extends `tinytest` with an expectation function called
`expect_vdiff()`. This function can be used to:

1.  Take snapshots of known “target” plots.
2.  Test if the “current” plot matches the target.

`tinyviztest` supports both `ggplot2` and base `R` plots.

Under the hood, `tinyviztest` uses [the `gdiff` package by Paul
Murrell](https://cran.r-project.org/package=gdiff) to compare plots.

## Installation

`tinyviztest` is not yet available on CRAN. It can be installed from
Github:

``` r
library(remotes)
install_github("vincentarelbundock/tinyviztest")
```

It is useful to add this `.gitignore`:

``` git
/inst/tinytest/_tinytest_compare
/inst/tinytest/_tinytest_current
```

And this to `.Rbuildignore`:

``` git
inst/tinytest/_tinytest_compare
inst/tinytest/_tinytest_current
```

### `ggplot2` example

The first time we run `expect_vdiff()`, the test fails, and a target
plot is saved in a folder called `_tinyviztest`

``` r
library(ggplot2)
library(tinytest)
using(tinyviztest)

p1 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
p2 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()

expect_vdiff(p1, name = "ggplot2 example")
```

    ## ----- FAILED[]: <-->
    ##  call| expect_vdiff(p1, name = "ggplot2 example")
    ##  diff| 33536
    ##  info| pixels

The second time we run `expect_vdiff()` the test passes:

``` r
expect_vdiff(p1, name = "ggplot2 example")
```

    ## ----- FAILED[]: <-->
    ##  call| expect_vdiff(p1, name = "ggplot2 example")
    ##  diff| 33536
    ##  info| pixels

If we use a different plot, the test fails:

``` r
expect_vdiff(p2, name = "ggplot2 example")
```

    ## ----- PASSED      : <-->
    ##  call| expect_vdiff(p2, name = "ggplot2 example")
    ##  info| pixels

We can overwrite the target plot with an argument:

``` r
expect_vdiff(p2, name = "ggplot2 example", overwrite = TRUE)
```

    ## ----- FAILED[]: <-->
    ##  call| expect_vdiff(p2, name = "ggplot2 example", overwrite = TRUE)
    ## 
    ##  info| Target missing. A new plot was saved to: _tinyviztest

``` r
expect_vdiff(p2, name = "ggplot2 example")
```

    ## ----- PASSED      : <-->
    ##  call| expect_vdiff(p2, name = "ggplot2 example")
    ##  info| pixels

### Base `R` plot example

To test a Base `R` plot, we supply a function which prints the plot:

``` r
p1 <- function() plot(mtcars$hp, mtcars$wt)
p2 <- function() plot(mtcars$hp, mtcars$mpg)

expect_vdiff(p1, name = "base")
```

    ## ----- PASSED      : <-->
    ##  call| expect_vdiff(p1, name = "base")
    ##  info| pixels

``` r
expect_vdiff(p1, name = "base")
```

    ## ----- PASSED      : <-->
    ##  call| expect_vdiff(p1, name = "base")
    ##  info| pixels

``` r
expect_vdiff(p2, name = "base")
```

    ## ----- FAILED[]: <-->
    ##  call| expect_vdiff(p2, name = "base")
    ##  diff| 3232
    ##  info| pixels

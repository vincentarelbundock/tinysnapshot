# Visual regression tests with `R` and `tinytest`

`tinytest` is a ["lightweight, no-dependency, but full-featured package for unit testing in `R`"](https://cran.r-project.org/package=tinytest) created by Mark van der Loo.

The `tinyviztest` package extends `tinytest` with expectations to test plots created in either base `R` or `ggplot2`. In particular, `tinyviztest` allows:

1. Taking snapshots of known "target" plots.
2. Testing if the "current" plot matches the target.
3. Displaying the target and current plots side-by-side, along with a visual "diff" to facilitate comparison.

Under the hood, `tinyviztest` uses [the `magick` package by Jeroen Ooms](https://cran.r-project.org/package=magick) to read and compare images.

## Installation

This package requires a version of `tinytest` greater than 1.3.1. If this version is not yet available on CRAN, you can install it from Github:

```r
remotes::install_github("markvanderloo/tinytest/pkg")
```

`tinyviztest` is not available on CRAN yet. It can be installed from Github:

```r
remotes::install_github("vincentarelbundock/tinyviztest")
```

## Visual expectations

To test a visual expectation, we create an `R` script, give it a name that starts with "test", and save it in the `inst/tinytest/` directory of our package.

Each test script with visual expectations must include these two lines at the top:

```r
library("tinytest")
using("tinyviztest")
```

When users run the `tinytest` suite (`tinytest::run_test_dir("inst/tinytest")`), the `expect_vdiff()` expectations are executed and three main states can arise:

* On first run: 
    - The test fail and saves a visual snapshot in PNG format in the `inst/tinytest/_tinyviztest` directory.
* On subsequent runs:
    - Test pass when the plot matches the reference PNG file.
    - Test fail and saves comparison files in `inst/tinytest/_tinyviztest_review`

### `ggplot2`

In this example script, we test two `ggplot2` objects:

```r
library("ggplot2")
library("tinytest")
using("tinyviztest")

p1 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
p2 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()

# On first run: fail and save a snapshot
# On subsequent runs: pass
expect_vdiff(p1, label = "ggplot2_example")

# Always fails
expect_vdiff(p2, label = "ggplot2_example")
```

### Base `R` graphics

Testing a Base `R` plot is slightly different: we need to supply a function which prints the plot:

```r
library("tinytest")
using("tinyviztest")

p1 <- function() plot(mtcars$hp, mtcars$wt)
p2 <- function() plot(mtcars$hp, mtcars$mpg)

# On first run: fail and save a snapshot
# On subsequent runs: pass
expect_vdiff(p1, label = "base_example")

# always fails
expect_vdiff(p2, label = "base_example")
```

## Reviewing changes

If tests fail, you may want to review the plots to see what changed. First, we call `tinyvizreview()` to get a list of snapshots to review:

```r
tinyvizreview()
    [1] "base"             "ggplot2_theme"    "ggplot2_variable"
```

Then, we look at one of the choices:

```r
tinyvizreview("base")
```

![](https://user-images.githubusercontent.com/987057/210011007-757b7f6d-4b57-4f77-b586-22e7d13bf9f5.png)

## Updating snapshots

To update a test, simply delete the relevant snapshot from `inst/tinytest/_tinyviztest` and run the test suite again.

## Minimal package example

We now create a minimal `R` package to illustrate how to use `tinyviztest` in the "real world."

Create a `temp` directory and use the `pkgKitten` package to create an ultra-minimalist package (an alternative would be the `usethis` package):

```r
library(tinytest)
library(pkgKitten)
kitten(name = "testpkg")

    Creating directories ...
    Creating DESCRIPTION ...
    Creating NAMESPACE ...
    Adding pkgKitten overrides.
    >> added .gitignore file
    >> added .Rbuildignore file
    >> added tinytest support

    Consider reading the documentation for all the packaging details.
    A good start is the 'Writing R Extensions' manual.

    And run 'R CMD check'. Run it frequently. And think of those kittens.
```

Download an example test script from the `tinyviztest` repository:

```r
download.file(
    url = "https://raw.githubusercontent.com/vincentarelbundock/tinyviztest/main/inst/tinytest/test-basic.R",
    destfile = "testpkg/inst/tinytest/test-basic.R",
    quiet = TRUE)
```

Our package now includes 7 tests: 1 created by default by the `puppy()` function, and 6 tests in the `test-basic.R` script. When we run `tinytest` the first time, the 6 `test-basic.R` tests fail, but some generate snapshots in PNG format:

```r
setwd("testpkg")
tinytest::run_test_dir("inst/tinytest")

    test_testpkg.R................    1 tests OK 22ms
    test-basic.R..................    6 tests 6 fails 0.8s
    ----- FAILED[]: test-basic.R<15--15>
    call| expect_vdiff(p1, "base")
    diff| 0
    info| pixels
    ----- FAILED[]: test-basic.R<18--18>
    call| expect_vdiff(p2, "base")
    diff| 3232
    info| pixels
    ----- FAILED[]: test-basic.R<25--25>
    call| expect_vdiff(p1, "ggplot2_variable")
    diff| 0
    info| pixels
    FAILED[]: test-basic.R<28--28> expect_vdiff(p2, "ggplot2_variable")
    FAILED[]: test-basic.R<31--31> expect_vdiff(p3, "ggplot2_theme")
    FAILED[]: test-basic.R<34--34> expect_vdiff(p4, "ggplot2_theme")
    
    Showing 6 out of 7 results: 6 fails, 1 passes (0.8s)
    Warning messages:
    1: Creating reference file: _tinyviztest/base.png 
    2: Creating reference file: _tinyviztest/ggplot2_variable.png 
    3: Creating reference file: _tinyviztest/ggplot2_theme.png 
```

The second time we run the test suite, only 3 of the `test-basic.R` tests fail:

```r
tinytest::run_test_dir("inst/tinytest")

    test_testpkg.R................    1 tests OK 6ms
    test-basic.R..................    6 tests 3 fails 0.6s
    ----- FAILED[]: test-basic.R<18--18>
    call| expect_vdiff(p2, "base")
    diff| 3232
    info| pixels
    ----- FAILED[]: test-basic.R<28--28>
    call| expect_vdiff(p2, "ggplot2_variable")
    diff| 33536
    info| pixels
    ----- FAILED[]: test-basic.R<34--34>
    call| expect_vdiff(p4, "ggplot2_theme")
    diff| 191955
    info| pixels
    
    Showing 3 out of 7 results: 3 fails, 4 passes (0.7s)
```

If you read through the `test-basic.R` code, you will see that this is the expected number of test failures.
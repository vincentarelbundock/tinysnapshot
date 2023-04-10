# `tinysnapshot`: Snapshots for unit tests in `R` using the `tinytest` framework.

`tinytest` is a ["lightweight, no-dependency, but full-featured package for unit testing in `R`"](https://cran.r-project.org/package=tinytest) created by Mark van der Loo.

`tinysnapshot` extends `tinytest` with expectations to test plots (base `R` or `ggplot2`) and `print()` output. In particular, `tinysnapshot` allows:

1. Taking snapshots of known "target" plots or `print()` output.
2. Testing if the "current" plot or `print()` output matches the target.
3. Displaying a visual "diff" to facilitate comparison when a test fails.

Under the hood, `tinysnapshot` uses [the `magick` package](https://cran.r-project.org/package=magick) by Jeroen Ooms to read and compare images, and [the `diffobj`package](https://CRAN.R-project.org/package=diffobj) by Brodie Gaslam to compare printed output.

## Installation

```r
install.packages("tinysnapshot")
```

Install the development version of `tinysnapshot`:

```r
remotes::install_github("vincentarelbundock/tinysnapshot")
```

You may also want to install additional packages to benefit from extra features:

```r
install.packages(c("rsvg", "ragg", "svglite"))
```

## Visual expectations: `expect_snapshot_plot()`

To test a visual expectation, we create an `R` script, give it a name which starts with "test", and save it in the `inst/tinytest/` directory of our package.

Each test script with visual expectations must include these two lines at the top:

```r
library("tinytest")
using("tinysnapshot")
```

When users run the `tinytest` suite, the `expect_snapshot_plot()` and `expect_snapshot_print()` expectations are executed and three main states can arise:

* On first run: 
    - Test fails and saves a visual snapshot in the `inst/tinytest/_tinysnapshot` directory.
* On subsequent runs:
    - Test passes when the plot matches the snapshot file.
    - Test fails and saves comparison files in `inst/tinytest/_tinysnapshot_review`

### `ggplot2`

In this example script, we test two `ggplot2` objects:

```r
library("ggplot2")
library("tinytest")
using("tinysnapshot")

p1 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
p2 <- ggplot(mtcars, aes(mpg, hp)) + geom_point()

# On first run: fail and save a snapshot
# On subsequent runs: pass
expect_snapshot_plot(p1, label = "ggplot2_example")

# Always fails
expect_snapshot_plot(p2, label = "ggplot2_example")
```

### Base `R` graphics

Testing a Base `R` plot is slightly different: we need to supply a function which prints the plot:

```r
library("tinytest")
using("tinysnapshot")

p1 <- function() plot(mtcars$hp, mtcars$wt)
p2 <- function() plot(mtcars$hp, mtcars$mpg)

# On first run: fail and save a snapshot
# On subsequent runs: pass
expect_snapshot_plot(p1, label = "base_example")

# Always fails
expect_snapshot_plot(p2, label = "base_example")
```

### Options and arguments

`expect_snapshot_plot` supports 4 graphics devices: `png` and `ragg` for PNG, and `svg` and `svglite` for SVG. It can set different values for the height and width of the pictures (pixels for PNG and inches for SVG). Most of the arguments can also be fixed globally using options:


```{r}
options(tinysnapshot_device = "svglite")
options(tinysnapshot_height = 7) # inches
options(tinysnapshot_width = 7)
options(tinysnapshot_tol = 200) # pixels
```

### Visual diff

When (not "if") tests fail, `tinysnapshot` will save diff files in the `inst/tinytest/_tinysnapshot_review/` folder. Diff files for plots look like this:

![](https://user-images.githubusercontent.com/987057/210011007-757b7f6d-4b57-4f77-b586-22e7d13bf9f5.png)

## Print expectations: `expect_snapshot_print()`

First, we save this script in `inst/tinytest/test-print.R`:

```r
library("tinytest")
using("tinysnapshot")

mod1 <- lm(mpg ~ hp + factor(gear), mtcars)
expect_snapshot_print(summary(mod1), label = "print-lm_summary")

mod2 <- lm(mpg ~ factor(gear), mtcars)
expect_snapshot_print(summary(mod2), label = "print-lm_summary")
```

Then, we run the tests. 

```r
tinytest::run_test_file("inst/tinytest/test-print.R")
```

The first time we run the test, it fails and saves a reference file. The second time we run it, there is already a reference text file, so only one of the tests fails. This is the expected result.

### Print diff

When tests fail, `tinytest` will return a diff like this one: 

```{r}
    test-print.R..................    2 tests 2 fails 0.3s
    ----- FAILED[]: test-print.R<12--12>
    call| expect_snapshot_print(summary(mod1), label = "print-lm_summary")
    diff| Missing reference file.
    info| diffobj::printDiff()
    ----- FAILED[]: test-print.R<15--15>
    call| expect_snapshot_print(summary(mod2), label = "print-lm_summary")
    diff| < ref                                                           
    diff| > x                                                             
    diff| @@ 1,21 / 1,20 @@                                               
    diff| 
    diff| Call:                                                         
    diff| < lm(formula = mpg ~ hp + factor(gear), data = mtcars)          
    diff| > lm(formula = mpg ~ factor(gear), data = mtcars)               
    diff| 
    diff| Residuals:                                                    
    diff| Min      1Q  Median      3Q     Max                       
    diff| < -4.4937 -2.3586 -0.8277  2.2753  7.7287                       
    diff| > -6.7333 -3.2333 -0.9067  2.8483  9.3667                       
    diff| 
    diff| Coefficients:                                                 
    diff| Estimate Std. Error t value Pr(>|t|)            
    diff| < (Intercept)   27.88193    2.10908  13.220 1.47e-13 ***        
    diff| < hp            -0.06685    0.01105  -6.052 1.59e-06 ***        
    diff| > (Intercept)     16.107      1.216  13.250 7.87e-14 ***        
    diff| < factor(gear)4  2.63486    1.55164   1.698 0.100575            
    diff| > factor(gear)4    8.427      1.823   4.621 7.26e-05 ***        
    diff| < factor(gear)5  6.57476    1.64268   4.002 0.000417 ***        
    diff| > factor(gear)5    5.273      2.431   2.169   0.0384 *          
    diff| ---                                                           
    diff| Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    diff| 
    diff| < Residual standard error: 3.154 on 28 degrees of freedom       
    diff| > Residual standard error: 4.708 on 29 degrees of freedom       
    diff| < Multiple R-squared:  0.7527,    Adjusted R-squared:  0.7262   
    diff| > Multiple R-squared:  0.4292,    Adjusted R-squared:  0.3898   
    diff| < F-statistic: 28.41 on 3 and 28 DF,  p-value: 1.217e-08        
    diff| > F-statistic:  10.9 on 2 and 29 DF,  p-value: 0.0002948        
    diff| 
    info| diffobj::printDiff()
    
    Warning message:
    Creating reference file: _tinysnapshot/print-lm_summary.txt 
```

When there are too many failures, `tinytest` will not always print the full diff. In those cases, you can save the `tinytest` object and print it out manually while specifying the `nlong` argument:

```r
results <- tinytest::run_test_dir()
print(results, nlong = Inf)
```

## Updating snapshots

To update the snapshot for a test, simply delete the relevant snapshot from the `inst/tinytest/_tinysnapshot` folder and run the test suite again. As when we ran the suite for the very first time, this will report a failure but generate a new snapshot.

## CRAN, continuous integration, and deterministic plots

The images produced by `R` are not *deterministic*, in the sense that they can vary slightly based on the operating system, graphics device, `R` version, etc. Unfortunately, this means that visual expectations will often fail on CRAN, where tests are run on many different platforms.

Here are some steps you can take to make testing images more portable:

1. Use the `svglite` graphics device.
2. Use a pre-defined font.
3. Run continuous integration tests on the same Operating System where you generated the original snapshot files.
4. Skip visual expectations on CRAN.

From `tinysnapshot` 0.0.3 (or using the development version from Github), many of these steps can be taken automatically by setting a few options at the top of your test scripts:

```{r}
library(tinytest)
library(tinysnapshot)
library(fontquiver)
library(svglite)
library(rsvg)
using("tinysnapshot")

options(tinysnapshot_os = "Darwin") # see Sys.info()["sysname"]
options(tinysnapshot_device = "svglite")
options(tinysnapshot_device_args = list(user_fonts = fontquiver::font_families("Liberation")))
```

Other packages [like `vdiffr`](https://vdiffr.r-lib.org/) ship with an embedded version `svglite` and their own fonts to ensure deterministic plots, but `tinysnapshot` does not do that (yet).

## Minimal package example

We now create a minimal `R` package to illustrate how to use `tinysnapshot` in the "real world."

Create a `temp` directory and use the `pkgKitten` package to create an ultra-minimalist package (an alternative would be the `usethis` package):

```r
library(tinytest)
library(pkgKitten)
kitten(name = "testpkg")
```
```r
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

Download an example test script from the `tinysnapshot` repository:

```r
download.file(
    url = "https://raw.githubusercontent.com/vincentarelbundock/tinysnapshot/main/inst/tinytest/test-png.R",
    destfile = "testpkg/inst/tinytest/test-png.R",
    quiet = TRUE)
```

Our package now includes 7 tests: 1 created by default by the `puppy()` function, and 6 tests in the `test-png.R` script. When we run `tinytest` the first time, the 6 `test-png.R` tests fail, but some generate snapshots in PNG format:

```r
setwd("testpkg")
tinytest::run_test_dir("inst/tinytest")
```
```r
    test_testpkg.R................    1 tests OK 22ms
    test-png.R..................    6 tests 6 fails 0.8s
    ----- FAILED[]: test-png.R<15--15>
    call| expect_snapshot_plot(p1, "base")
    diff| 0
    info| pixels
    ----- FAILED[]: test-png.R<18--18>
    call| **expect_snapshot_plot**(p2, "base")
    diff| 3232
    info| pixels
    ----- FAILED[]: test-png.R<25--25>
    call| expect_snapshot_plot(p1, "ggplot2_variable")
    diff| 0
    info| pixels
    FAILED[]: test-png.R<28--28> expect_snapshot_plot(p2, "ggplot2_variable")
    FAILED[]: test-png.R<31--31> expect_snapshot_plot(p3, "ggplot2_theme")
    FAILED[]: test-png.R<34--34> expect_snapshot_plot(p4, "ggplot2_theme")
    
    Showing 6 out of 7 results: 6 fails, 1 passes (0.8s)
    Warning messages:
    1: Creating reference file: _tinysnapshot/base.png 
    2: Creating reference file: _tinysnapshot/ggplot2_variable.png 
    3: Creating reference file: _tinysnapshot/ggplot2_theme.png 
```

The second time we run the test suite, only 3 of the `test-png.R` tests fail:

```r
tinytest::run_test_dir("inst/tinytest")
```

```r
    test_testpkg.R................    1 tests OK 6ms
    test-png.R....................    6 tests 3 fails 0.6s
    ----- FAILED[]: test-png.R<18--18>
    call| expect_snapshot_plot(p2, "base")
    diff| 3232
    info| pixels
    ----- FAILED[]: test-png.R<28--28>
    call| expect_snapshot_plot(p2, "ggplot2_variable")
    diff| 33536
    info| pixels
    ----- FAILED[]: test-png.R<34--34>
    call| expect_snapshot_plot(p4, "ggplot2_theme")
    diff| 191955
    info| pixels
    
    Showing 3 out of 7 results: 3 fails, 4 passes (0.7s)
```

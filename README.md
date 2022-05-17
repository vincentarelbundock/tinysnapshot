
# `tinyviztest` offers custom expectations for visual tests in the `tinytest` framework

To begin, load the libraries and change the working directory to
`inst/tinytest`:

``` r
library(ggplot2)
library(tinyviztest)
setwd("inst/tinytest")
```

### `ggplot2` example

``` r
write_vdiff(
    ggplot(mtcars, aes(mpg, wt)) + geom_point(),
    name = "ggplot2")

expect_vdiff(
    ggplot(mtcars, aes(mpg, wt)) + geom_point(),
    name = "ggplot2")
```

    ## ----- PASSED      : <-->
    ##  call| expect_vdiff(ggplot(mtcars, aes(mpg, wt)) + geom_point(), name = "ggplot2")
    ##  info| pixels

``` r
expect_vdiff(
    ggplot(mtcars, aes(mpg, hp)) + geom_point(), 
    name = "ggplot2")
```

    ## ----- FAILED[]: <-->
    ##  call| expect_vdiff(ggplot(mtcars, aes(mpg, hp)) + geom_point(), name = "ggplot2")
    ##  diff| 33536
    ##  info| pixels

The target plots are “protected” from overwriting:

``` r
write_vdiff(
    ggplot(mtcars, aes(mpg, wt)) + geom_point(),
    name = "ggplot2")
```

    ## Error: The target plot already exists. Use `overwrite=TRUE` to overwrite the files located here: _tinyviztest_target/ggplot2

But we can overwrite them with an argument:

``` r
write_vdiff(
    ggplot(mtcars, aes(mpg, wt)) + geom_point(),
    name = "ggplot2",
    overwrite = TRUE)
```

### Base `R` plot example

To test a Base `R` plot, we supply a function which prints the plot:

``` r
write_vdiff(
    function() with(mtcars, plot(hp, wt)),
    name = "base")

expect_vdiff(
    function() with(mtcars, plot(hp, wt)),
    name = "base")
```

    ## ----- PASSED      : <-->
    ##  call| expect_vdiff(function() with(mtcars, plot(hp, wt)), name = "base")
    ##  info| pixels

``` r
expect_vdiff(
    function() with(mtcars, plot(hp, mpg)),
    name = "base")
```

    ## ----- FAILED[]: <-->
    ##  call| expect_vdiff(function() with(mtcars, plot(hp, mpg)), name = "base")
    ##  diff| 2904
    ##  info| pixels

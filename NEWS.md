# 0.2.0

* Plot tests are skipped by default on CRAN, that is, when either of these conditions is false:
    - `interactive()` is `FALSE`
    - The `NOT_CRAN` environment variable is not `true`

# 0.1.0

New arguments to `expect_snapshot_print()`:

* `fn_current`: A function to process the current snapshot string before comparison.
* `fn_target`: A function to process the target snapshot string before comparison.
* `review`: TRUE (default) to write the diff plot to file. FALSE to return a failure but no file.

# 0.0.8

* New `style` argument to `expect_snapshot_plot()` and `expect_equivalent_images()` to control the style of the diff image to print. Plot with "old", "new", and "diff" facets.

# 0.0.7

* New `ignore_white_space` argument in `expect_snapshot_print()`.

# 0.0.6

* Allow extensions in snapshot labels to save an .html file instead of .txt

# 0.0.5

* Allow `mode` argument in `expect_snapshot_print()`
* Silence some useless `diffobj` messages

# 0.0.4

* `diffObj::diffPrint(guides = FALSE)` because `guides` generated errors in some long text comparisons.

# 0.0.3

* New `os` argument to skip tests on unspecified operating systems.
* New `device_args` argument to pass additional arguments to the device function.

# 0.0.2

* Do not write to the user library on CRAN.

# 0.0.1

* Initial release

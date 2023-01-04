.onLoad = function(libname, pkgname) {
    tinytest::register_tinytest_extension(
        "tinyviztest",
        c("expect_vdiff", "expect_pdiff", "expect_equivalent_images", "expect_snapshot_plot", "expect_snapshot_print"))
}

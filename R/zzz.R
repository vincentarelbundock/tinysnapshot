.onLoad = function(libname, pkgname) {
    tinytest::register_tinytest_extension(
        "tinysnapshot",
        c("expect_equivalent_images", "expect_snapshot_plot", "expect_snapshot_print"))
}

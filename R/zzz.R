.onLoad = function(libname, pkgname) {
    tinytest::register_tinytest_extension(
        "tinyviztest",
        c("expect_vdiff", "expect_pdiff"))
}

if (requireNamespace("tinytest", quietly = TRUE) && isTRUE(Sys.info()["sysname"] != "Windows")) {
    tinytest::test_package("tinysnapshot")
}
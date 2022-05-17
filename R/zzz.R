register_tinytest = function() {
  ns = getNamespace("tinyviztest")
  expectations = names(ns)[grepl("^expect_", names(ns))]
  tinytest::register_tinytest_extension("tinyviztest", expectations)
}

.onLoad = function(libpath, pkgname) {
  backports::import(pkgname)
  if ("tinytest" %in% loadedNamespaces())
    register_tinytest()
  setHook(packageEvent("tinytest", "onLoad"), function(...) register_tinytest(), action = "append")
}


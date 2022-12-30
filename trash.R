p = function() plot(mtcars$wt, mtcars$mpg)

pkgload::load_all()
distance_plot(p, "inst/tinytest/_tinyviztest/base.png", metric = "AE")

distance_plot(p, "inst/tinytest/_tinyviztest/base.png", metric = "Fuzz")

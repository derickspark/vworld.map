test_that("vworld_marker accepts multiple input shapes for points", {
  m1 <- vworld_marker(c(126.97, 37.56))
  expect_s3_class(m1, "vworld_marker")
  expect_match(as.character(m1), "^point:126\\.97 37\\.56$")

  m2 <- vworld_marker(rbind(c(126.97, 37.56), c(127.02, 37.58)))
  expect_match(as.character(m2),
               "^point:126\\.97 37\\.56,127\\.02 37\\.58$")

  m3 <- vworld_marker(list(c(126.97, 37.56), c(127.02, 37.58)))
  expect_equal(as.character(m2), as.character(m3))
})

test_that("color converts named, rgb(), and arbitrary R colors", {
  expect_match(as.character(vworld_marker(c(126, 37), label = "A", color = "red")),
               "color:red")
  expect_match(as.character(vworld_marker(c(126, 37), label = "A",
                                          color = "rgb(255,0,0)")),
               "color:rgb\\(255,0,0\\)")
  expect_match(as.character(vworld_marker(c(126, 37), label = "A", color = "#FF0000")),
               "color:rgb\\(255,0,0\\)")
})

test_that("vworld_route validates style", {
  expect_error(
    vworld_route(rbind(c(126, 37), c(127, 38)), style = "wiggly"),
    "style"
  )
  ok <- vworld_route(rbind(c(126, 37), c(127, 38)),
                     color = "blue", width = 2, style = "dashdot")
  expect_match(as.character(ok), "style:dashdot")
  expect_match(as.character(ok), "width:2")
  expect_match(as.character(ok), "color:blue")
})

test_that("marker drops NULL sub-params and orders fields", {
  s <- as.character(
    vworld_marker(c(126, 37), label = "Hi",
                  color = "red", image = "img01")
  )
  # required field comes first, no font/size emitted
  expect_match(s, "^point:")
  expect_false(grepl("\\|font:", s))
  expect_false(grepl("\\|size:", s))
})

test_that("vworld_static_map_url builds a valid URL with required params", {
  url <- vworld_static_map_url(
    key    = "TESTKEY",
    center = c(126.978271, 37.566643),
    zoom   = 16,
    size   = c(400, 400)
  )

  expect_type(url, "character")
  expect_length(url, 1)
  expect_match(url, "^https://api\\.vworld\\.kr/req/image\\?")
  expect_match(url, "service=image")
  expect_match(url, "version=2\\.0")
  expect_match(url, "request=getmap")
  expect_match(url, "key=TESTKEY")
  expect_match(url, "center=126\\.978271%2C37\\.566643", fixed = FALSE)
  expect_match(url, "crs=EPSG%3A4326")
  expect_match(url, "zoom=16")
  expect_match(url, "size=400%2C400")
  expect_match(url, "basemap=GRAPHIC")
})

test_that("defaults are zoom=10, size=400x400, basemap=GRAPHIC", {
  url <- vworld_static_map_url("K", c(126, 37))
  expect_match(url, "zoom=10")
  expect_match(url, "size=400%2C400")
  expect_match(url, "basemap=GRAPHIC")
})

test_that("vworld_static_map_url validates zoom and size", {
  expect_error(
    vworld_static_map_url("K", c(126, 37), zoom = 5, size = c(400, 400)),
    "zoom"
  )
  expect_error(
    vworld_static_map_url("K", c(126, 37), zoom = 19, size = c(400, 400)),
    "zoom"
  )
  expect_error(
    vworld_static_map_url("K", c(126, 37), zoom = 12, size = c(2000, 400)),
    "1024"
  )
})

test_that("vworld_static_map_url rejects invalid basemap and key", {
  expect_error(
    vworld_static_map_url("K", c(126, 37), 12, c(400, 400),
                          basemap = "FOO"),
    "basemap"
  )
  expect_error(
    vworld_static_map_url("", c(126, 37), 12, c(400, 400)),
    "key"
  )
})

test_that("basemap aliases map to API codes", {
  expect_match(vworld_static_map_url("K", c(126, 37), basemap = "geographic"),
               "basemap=GRAPHIC")
  expect_match(vworld_static_map_url("K", c(126, 37), basemap = "satellite"),
               "basemap=PHOTO")
  expect_match(vworld_static_map_url("K", c(126, 37), basemap = "hybrid"),
               "basemap=PHOTO_HYBRID")
  expect_match(vworld_static_map_url("K", c(126, 37), basemap = "white"),
               "basemap=GRAPHIC_WHITE")
  expect_match(vworld_static_map_url("K", c(126, 37), basemap = "night"),
               "basemap=GRAPHIC_NIGHT")
})

test_that("CRS is normalized from short name and numeric code", {
  url1 <- vworld_static_map_url("K", c(126, 37), 12, c(100, 100), crs = "UTMK")
  url2 <- vworld_static_map_url("K", c(126, 37), 12, c(100, 100), crs = 5179)
  expect_match(url1, "crs=EPSG%3A5179")
  expect_match(url2, "crs=EPSG%3A5179")
})

test_that("marker and route are emitted as separate query params", {
  m1 <- vworld_marker(c(126.97, 37.56), label = "A", color = "red")
  m2 <- vworld_marker(c(127.02, 37.58), label = "B", color = "blue", image = "img01")
  r1 <- vworld_route(rbind(c(126.97, 37.56), c(127.02, 37.58)),
                     color = "red", width = 1, style = "dot")

  url <- vworld_static_map_url(
    "K", c(127, 37.57), 13, c(640, 640),
    markers = list(m1, m2), routes = r1
  )

  marker_hits <- gregexpr("(^|&)marker=", url)[[1]]
  expect_equal(length(marker_hits[marker_hits > 0]), 2)

  expect_match(url, "label%3AA")
  expect_match(url, "label%3AB")
  expect_match(url, "image%3Aimg01")
  expect_match(url, "style%3Adot")
})

test_that("string 'x,y' center is parsed", {
  url <- vworld_static_map_url("K", "126.978,37.566")
  expect_match(url, "center=126\\.978%2C37\\.566")
})

test_that("non-coordinate center routes through geocoding helper", {
  # Empty key short-circuits the geocoder call with a clear error message
  expect_error(
    vworld.map:::.resolve_center("서울시청", key = ""),
    "geocode"
  )
  # Numeric pair is returned as-is
  expect_equal(
    vworld.map:::.resolve_center(c(126.97, 37.56), key = ""),
    c(126.97, 37.56)
  )
  # "x,y" string is parsed without geocoding
  expect_equal(
    vworld.map:::.resolve_center("126.97, 37.56", key = ""),
    c(126.97, 37.56)
  )
})

test_that(".elide_key hides the api key", {
  url <- vworld_static_map_url("SECRET", c(126, 37), 12, c(100, 100))
  hidden <- vworld.map:::.elide_key(url)
  expect_false(grepl("SECRET", hidden))
  expect_match(hidden, "key=\\*\\*\\*")
})

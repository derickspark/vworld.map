# vworld.map

An R client for the **VWorld StaticMap API 2.0** — build static map image
URLs or download maps directly from R, with full support for markers,
routes, overlay layers, custom CRS, and integration with **ggplot2** /
**leaflet**.

> Reference: <https://api.vworld.kr/req/image> (VWorld 오픈플랫폼 StaticMap API 2.0)

## Installation

```r
# install.packages("remotes")
remotes::install_github("derickspark/vworld.map")
```

## Get an API key

Sign up at <https://www.vworld.kr> and issue an API key in the developer
console. All `vworld.map` functions require the key as an argument:

```r
key <- "YOUR_VWORLD_KEY"
# or, recommended, store it once:
# Sys.setenv(VWORLD_API_KEY = "YOUR_VWORLD_KEY")
```

## Build a request URL

```r
library(vworld.map)

url <- vworld_static_map_url(
  key    = key,
  center = c(126.978271, 37.566643),   # Seoul City Hall, EPSG:4326
  zoom   = 16,
  size   = c(400, 400),
  markers = vworld_marker(
    c(126.978271, 37.566643),
    label = "City Hall",
    color = "red",
    image = "img01"
  )
)
url
#> "https://api.vworld.kr/req/image?service=image&...&marker=point%3A126.978271%2037.566643%7Clabel%3ACity%20Hall%7Ccolor%3Ared%7Cimage%3Aimg01"
```

## Download an image

```r
img_path <- vworld_static_map(
  key     = key,
  center  = c(126.978271, 37.566643),
  zoom    = 16,
  size    = c(640, 640),
  basemap = "PHOTO_HYBRID",
  markers = vworld_marker(
    c(126.978271, 37.566643),
    label = "City Hall", color = "red", image = "img01"
  ),
  routes  = vworld_route(
    rbind(c(126.97, 37.56), c(126.99, 37.58), c(127.02, 37.55)),
    color = "blue", width = 3, style = "dashdot"
  )
)

# View it
if (requireNamespace("magick", quietly = TRUE)) {
  magick::image_read(img_path)
}
```

## Multiple marker / route styles

Pass a **list** of `vworld_marker()` / `vworld_route()` objects to use
different styles:

```r
markers <- list(
  vworld_marker(c(126.97, 37.56), label = "A", color = "red"),
  vworld_marker(c(127.02, 37.58), label = "B", color = "blue", image = "img01")
)

routes <- list(
  vworld_route(rbind(c(126.97, 37.56), c(127.02, 37.58)),
               color = "red",  width = 1, style = "dot"),
  vworld_route(rbind(c(127.02, 37.58), c(127.05, 37.55)),
               color = "blue", width = 3, style = "solid")
)

vworld_static_map_url(
  key = key, center = c(127.0, 37.57),
  zoom = 13, size = c(640, 640),
  markers = markers, routes = routes
)
```

## ggplot2 background

```r
library(ggplot2)

ggplot() +
  vworld_ggmap_layer(
    key    = key,
    center = c(126.978271, 37.566643),
    zoom   = 16,
    size   = c(640, 640),
    basemap = "GRAPHIC"
  ) +
  geom_point(aes(x = 126.978271, y = 37.566643),
             color = "red", size = 4)
```

## leaflet underlay

```r
library(leaflet)

overlay <- vworld_leaflet_image(
  key    = key,
  center = c(126.978271, 37.566643),
  zoom   = 16,
  size   = c(640, 640),
  basemap = "PHOTO"
)

leaflet() |>
  setView(126.978271, 37.566643, zoom = 16) |>
  overlay()
```

## Supported parameters

| Argument       | API param      | Notes                                                  |
|----------------|----------------|--------------------------------------------------------|
| `key`          | `key`          | Required.                                              |
| `center`       | `center`       | `c(x, y)` or `"x,y"`.                                   |
| `zoom`         | `zoom`         | 6..18.                                                  |
| `size`         | `size`         | `c(width, height)`, max `c(1024, 1024)`.                |
| `basemap`      | `basemap`      | One of `VWORLD_BASEMAPS`. Default `GRAPHIC`.            |
| `crs`          | `crs`          | `"EPSG:4326"` (default) or any in `VWORLD_CRS`.         |
| `format`       | `format`       | `png` (default) / `jpeg` / `bmp`.                       |
| `markers`      | `marker`       | One or a list of `vworld_marker()` objects.             |
| `routes`       | `route`        | One or a list of `vworld_route()` objects.              |
| `layers`       | `layers`       | Overlay WMS layer names.                                |
| `styles`       | `styles`       | Style names matching `layers`.                          |
| `error_format` | `errorFormat`  | `json` / `xml` / `image` / `blank`.                     |
| `extra`        | (any)          | Named list of additional query parameters.              |

## Coordinate systems

`VWORLD_CRS` exposes the supported EPSG codes by short name:

```r
VWORLD_CRS
#>            WGS84            GRS80   GoogleMercator   ...
#>      "EPSG:4326"      "EPSG:4019"      "EPSG:3857"   ...
```

You can pass any of:

```r
crs = "EPSG:5179"     # raw EPSG string
crs = 5179            # numeric code -> "EPSG:5179"
crs = "UTMK"          # short name from VWORLD_CRS
```

## License

GPL-3 © 2026 Derick S. Park

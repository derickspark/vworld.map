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

`center` can be a coordinate `c(x, y)`, an `"x,y"` string, **or a place
name / address** — non-coordinate strings are auto-geocoded via the VWorld
Search API.

```r
library(vworld.map)

# (1) Coordinates
url <- vworld_static_map_url(
  key    = key,
  center = c(126.978271, 37.566643)   # Seoul City Hall
)

# (2) Place name (auto-geocoded)
url <- vworld_static_map_url(
  key    = key,
  center = "서울시청"
)

# (3) Road address (auto-geocoded)
url <- vworld_static_map_url(
  key    = key,
  center = "서울특별시 중구 세종대로 110",
  zoom   = 16
)

# Or geocode explicitly to reuse the coordinates:
xy <- vworld_geocode("서울시청", key = key)
url <- vworld_static_map_url(
  key    = key,
  center = xy,
  zoom   = 16,
  markers = vworld_marker(xy, label = "City Hall", color = "red")
)
```

Defaults: `zoom = 10`, `size = c(400, 400)`, `basemap = "GRAPHIC"` (alias
`"geographic"`).

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

## ggplot2 background — `geom_vworld()`

```r
library(ggplot2)

# Coordinates
ggplot() +
  geom_vworld(key = key, center = c(126.978271, 37.566643), zoom = 16) +
  geom_point(aes(x = 126.978271, y = 37.566643),
             color = "red", size = 4)

# Place name (auto-geocoded)
ggplot() +
  geom_vworld(key = key, center = "서울시청", zoom = 15)

# Different basemap aliases
ggplot() + geom_vworld(key = key, center = "서울시청",
                       basemap = "satellite", zoom = 14)
ggplot() + geom_vworld(key = key, center = "서울시청",
                       basemap = "hybrid",    zoom = 14)
```

`vworld_ggmap_layer()` is kept as a backwards-compatible alias.

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

| Argument       | API param      | Notes                                                                      |
|----------------|----------------|----------------------------------------------------------------------------|
| `key`          | `key`          | Required.                                                                  |
| `center`       | `center`       | `c(x, y)`, `"x,y"`, or **place name / address** (auto-geocoded).            |
| `zoom`         | `zoom`         | 6..18. **Default `10`.**                                                   |
| `size`         | `size`         | `c(width, height)`, max `c(1024, 1024)`. **Default `c(400, 400)`.**         |
| `basemap`      | `basemap`      | One of `VWORLD_BASEMAPS` or alias (`geographic`, `satellite`, `hybrid`, `white`, `night`, `none`). Default `GRAPHIC`. |
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

## Geocoding

```r
# Top match as c(x, y) in EPSG:4326
vworld_geocode("서울시청", key = key)
#> 126.9779 37.5663

# All matches as a data.frame
vworld_geocode("강남역", key = key, all_results = TRUE)
#>           x        y    title category address_road address_parcel  type
#> 1  127.02762 37.49799 강남역    ...      ...          ...           place
#> 2  ...

# Address-only search
vworld_geocode("세종대로 110", key = key, type = "address")
```

## License

GPL-3 © 2026 Derick S. Park

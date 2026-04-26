#' VWorld StaticMap API 2.0 endpoint
#'
#' Base URL of the VWorld StaticMap GetMap operation.
#' @keywords internal
#' @noRd
VWORLD_ENDPOINT <- "https://api.vworld.kr/req/image"

#' Allowed basemap codes
#'
#' Character vector of valid `basemap` values accepted by
#' `vworld_static_map()` / `vworld_static_map_url()`.
#'
#' \itemize{
#'   \item `NONE` - no background (white)
#'   \item `GRAPHIC` - default base map
#'   \item `GRAPHIC_WHITE` - blank base map
#'   \item `GRAPHIC_NIGHT` - night base map
#'   \item `PHOTO` - aerial / satellite
#'   \item `PHOTO_HYBRID` - aerial + facility labels
#' }
#' @export
VWORLD_BASEMAPS <- c(
  "NONE", "GRAPHIC", "GRAPHIC_WHITE", "GRAPHIC_NIGHT",
  "PHOTO", "PHOTO_HYBRID"
)

#' Supported coordinate reference systems
#'
#' Named character vector of EPSG codes that the VWorld StaticMap API
#' accepts for the `crs` parameter. Names are human-readable labels.
#' @export
VWORLD_CRS <- c(
  "WGS84"            = "EPSG:4326",
  "GRS80"            = "EPSG:4019",
  "GoogleMercator"   = "EPSG:3857",
  "GoogleMercator2"  = "EPSG:900913",
  "West50"           = "EPSG:5180",
  "West"             = "EPSG:5185",
  "Center50"         = "EPSG:5181",
  "Center"           = "EPSG:5186",
  "Jeju"             = "EPSG:5182",
  "East50"           = "EPSG:5183",
  "East"             = "EPSG:5187",
  "EastSea50"        = "EPSG:5184",
  "EastSea"          = "EPSG:5188",
  "UTMK"             = "EPSG:5179"
)

#' Allowed image formats
#' @keywords internal
#' @noRd
VWORLD_FORMATS <- c("png", "jpeg", "bmp")

#' Allowed marker label colors (named)
#' @keywords internal
#' @noRd
VWORLD_NAMED_COLORS <- c("black", "white", "red", "blue", "green")

#' Allowed line styles for `route`
#' @keywords internal
#' @noRd
VWORLD_LINE_STYLES <- c(
  "solid", "dash", "dot", "dashdot",
  "dashdotdot", "longdash", "longdashdot"
)

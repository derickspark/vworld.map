#' vworld.map: VWorld StaticMap API 2.0 client for R
#'
#' This package wraps the VWorld Open Platform StaticMap API
#' (<https://api.vworld.kr/req/image>) so you can build map image URLs or
#' download static maps directly from R, complete with markers, routes, and
#' overlay layers, and embed the result into ggplot2 or leaflet.
#'
#' @section Quick start:
#' ```r
#' library(vworld.map)
#'
#' url <- vworld_static_map_url(
#'   key    = "YOUR_VWORLD_KEY",
#'   center = c(126.978271, 37.566643),  # Seoul City Hall
#'   zoom   = 16, size = c(400, 400),
#'   markers = vworld_marker(c(126.978271, 37.566643),
#'                            label = "City Hall",
#'                            color = "red", image = "img01")
#' )
#' ```
#'
#' @section API key:
#' All functions take a `key` argument. You can pass it explicitly, or wrap
#' your own helper that pulls it from `Sys.getenv("VWORLD_API_KEY")`.
#'
#' @keywords internal
"_PACKAGE"

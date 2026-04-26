\name{geom_vworld}
\alias{geom_vworld}
\alias{vworld_ggmap_layer}
\title{Add a VWorld static map as a ggplot2 background layer}
\usage{
geom_vworld(key, center,
  zoom = 10, size = c(400, 400),
  basemap = "GRAPHIC", crs = "EPSG:4326", format = "png",
  markers = NULL, routes = NULL,
  layers = NULL, styles = NULL,
  bbox = NULL, ...)

vworld_ggmap_layer(...)
}
\arguments{
\item{key}{VWorld API key (required).}
\item{center}{Map center. Numeric \code{c(x, y)}, \code{"x,y"} string, or a place
name / address (e.g. \code{"서울시청"}, \code{"서울특별시 중구 세종대로 110"}) —
auto-geocoded via \code{\link{vworld_geocode}}.}
\item{zoom}{Integer zoom level, 6..18. Default \code{10}.}
\item{size}{\code{c(width, height)}. Default \code{c(400, 400)}.}
\item{basemap}{One of \code{\link{VWORLD_BASEMAPS}} or an alias such as
\code{"geographic"}, \code{"satellite"}, \code{"hybrid"}, \code{"white"},
\code{"night"}. Default \code{"GRAPHIC"}.}
\item{crs}{Coordinate reference system. Default \code{"EPSG:4326"}.}
\item{format}{\code{"png"} (default), \code{"jpeg"}, or \code{"bmp"}.}
\item{markers, routes, layers, styles}{See \code{\link{vworld_static_map_url}}.}
\item{bbox}{Optional explicit \code{c(xmin, ymin, xmax, ymax)} bbox in the same CRS as \code{center}.}
\item{...}{Forwarded to \code{\link{vworld_static_map}}.}
}
\value{A list of ggplot2 layers — add to a ggplot with \code{+}.}
\description{Downloads a VWorld static map and returns ggplot2 layers (an
\code{annotation_raster} plus a matching \code{coord_fixed}) for use as a map
background.}
\details{
\code{vworld_ggmap_layer()} is kept as a backwards-compatible alias for
\code{geom_vworld()}.
}

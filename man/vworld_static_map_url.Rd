% Generated manually for vworld.map (no roxygen build required)
\name{vworld_static_map_url}
\alias{vworld_static_map_url}
\title{Build a VWorld StaticMap (GetMap) request URL}
\usage{
vworld_static_map_url(key, center, zoom, size,
  basemap = "GRAPHIC", crs = "EPSG:4326", format = "png",
  markers = NULL, routes = NULL,
  layers = NULL, styles = NULL,
  error_format = "json",
  service = "image", version = "2.0", request = "getmap",
  extra = NULL)
}
\arguments{
\item{key}{VWorld API key (required).}
\item{center}{Map center as \code{c(x, y)} or \code{"x,y"}.}
\item{zoom}{Integer zoom level, 6..18.}
\item{size}{Image size as \code{c(width, height)}, max 1024 each.}
\item{basemap}{One of \link{VWORLD_BASEMAPS}. Default \code{"GRAPHIC"}.}
\item{crs}{EPSG code or short name from \link{VWORLD_CRS}. Default \code{"EPSG:4326"}.}
\item{format}{\code{"png"}, \code{"jpeg"}, or \code{"bmp"}.}
\item{markers}{A \code{vworld_marker} object or list of them.}
\item{routes}{A \code{vworld_route} object or list of them.}
\item{layers}{Optional WMS layer names.}
\item{styles}{Optional style names matching \code{layers}.}
\item{error_format}{\code{"json"} (default), \code{"xml"}, \code{"image"}, or \code{"blank"}.}
\item{service, version, request}{Generally leave as defaults.}
\item{extra}{Optional named list of additional query parameters.}
}
\value{A character scalar (the GetMap URL).}
\description{Assembles a VWorld StaticMap API 2.0 GetMap URL.}
\seealso{\code{\link{vworld_static_map}}}

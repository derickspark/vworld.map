\name{vworld_static_map}
\alias{vworld_static_map}
\title{Download a VWorld StaticMap image}
\usage{
vworld_static_map(key, center,
  zoom = 10, size = c(400, 400),
  basemap = "GRAPHIC", crs = "EPSG:4326", format = "png",
  markers = NULL, routes = NULL,
  layers = NULL, styles = NULL,
  error_format = "image",
  path = NULL, read = FALSE, overwrite = TRUE,
  verbose = FALSE, extra = NULL)
}
\arguments{
\item{key, center, zoom, size, basemap, crs, format, markers, routes,
layers, styles, error_format, extra}{See \code{\link{vworld_static_map_url}}.}
\item{path}{Optional file path to write the image to.}
\item{read}{If \code{TRUE}, also return the image in R memory.}
\item{overwrite}{Overwrite existing file at \code{path}? Default \code{TRUE}.}
\item{verbose}{Message the request URL (with key elided) when \code{TRUE}.}
}
\value{A path (with the URL attached as \code{attr(., "url")}), or an image object if \code{read = TRUE}.}
\description{Downloads a static map from the VWorld API.}

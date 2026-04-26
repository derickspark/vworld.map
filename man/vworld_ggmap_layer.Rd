\name{vworld_ggmap_layer}
\alias{vworld_ggmap_layer}
\title{Use a VWorld static map as a ggplot2 background layer}
\usage{
vworld_ggmap_layer(key, center, zoom, size,
  basemap = "GRAPHIC", crs = "EPSG:4326", format = "png",
  markers = NULL, routes = NULL, layers = NULL, styles = NULL,
  bbox = NULL, ...)
}
\arguments{
\item{key, center, zoom, size, basemap, crs, format, markers, routes, layers, styles}{See \code{\link{vworld_static_map_url}}.}
\item{bbox}{Optional explicit \code{c(xmin, ymin, xmax, ymax)} in the same CRS as \code{center}.}
\item{...}{Forwarded to \code{\link{vworld_static_map}}.}
}
\value{A list of ggplot2 layers — add to a ggplot with \code{+}.}
\description{Returns a list of ggplot2 layers that draw the static map as a background and lock \code{coord_fixed} to its bounding box.}

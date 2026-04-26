\name{vworld_leaflet_image}
\alias{vworld_leaflet_image}
\title{Add a VWorld static map as a leaflet image overlay}
\usage{
vworld_leaflet_image(key, center, zoom, size,
  basemap = "GRAPHIC", crs = "EPSG:4326", format = "png",
  markers = NULL, routes = NULL, layers = NULL, styles = NULL,
  bbox = NULL, opacity = 1, ...)
}
\arguments{
\item{key, center, zoom, size, basemap, crs, format, markers, routes, layers, styles, bbox}{See \code{\link{vworld_ggmap_layer}}.}
\item{opacity}{Layer opacity, 0..1.}
\item{...}{Forwarded to \code{\link{vworld_static_map}}.}
}
\value{A function \code{function(map)} returning the leaflet map with the overlay added.}
\description{Downloads a VWorld static map and returns a function that adds it to a leaflet map as a raster image overlay.}

\name{vworld_route}
\alias{vworld_route}
\title{Build a VWorld route (polyline) spec}
\usage{
vworld_route(point, color = NULL, width = NULL, style = NULL)
}
\arguments{
\item{point}{Polyline vertices as 2-column matrix/data.frame.}
\item{color}{Line color (named, \code{rgb()}, or any R color).}
\item{width}{Line width in pixels.}
\item{style}{One of \code{"solid"}, \code{"dash"}, \code{"dot"}, \code{"dashdot"}, \code{"dashdotdot"}, \code{"longdash"}, \code{"longdashdot"}.}
}
\value{A character of class \code{vworld_route}.}
\description{Returns a serialized route sub-parameter string for use with \code{\link{vworld_static_map_url}}.}

\name{vworld_marker}
\alias{vworld_marker}
\title{Build a VWorld marker spec}
\usage{
vworld_marker(point, label = NULL, color = NULL, font = NULL,
  size = NULL, image = NULL)
}
\arguments{
\item{point}{Length-2 numeric, 2-column matrix/data.frame, or list of length-2 vectors.}
\item{label}{Optional label string.}
\item{color}{Label color: a named color, \code{rgb(r,g,b)} string, or any R color.}
\item{font}{Optional font family.}
\item{size}{Optional label font size in pixels.}
\item{image}{Optional VWorld marker image ID (e.g. \code{"img01"}).}
}
\value{A character of class \code{vworld_marker}.}
\description{Returns a serialized marker sub-parameter string for use with \code{\link{vworld_static_map_url}}.}

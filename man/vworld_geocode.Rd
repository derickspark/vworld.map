\name{vworld_geocode}
\alias{vworld_geocode}
\title{Geocode a place name or address using the VWorld Search API}
\usage{
vworld_geocode(query, key,
  type = c("place", "address"),
  category = NULL,
  all_results = FALSE,
  size = 10L,
  verbose = FALSE)
}
\arguments{
\item{query}{Character — place name or address.}
\item{key}{VWorld API key (same key used for StaticMap).}
\item{type}{Search types to try, in order. Each one of \code{"place"}, \code{"address"}, \code{"district"}.}
\item{category}{Optional category filter for \code{type = "place"}.}
\item{all_results}{If \code{TRUE} return a data.frame of all matches, else only the top match as \code{c(x, y)}.}
\item{size}{Max results per request (default 10).}
\item{verbose}{Message the request URL when \code{TRUE}.}
}
\value{Either \code{c(x, y)} numeric in EPSG:4326, or a data.frame of matches.}
\description{Resolves a free-text query to longitude/latitude via \url{https://api.vworld.kr/req/search}.}
\seealso{\code{\link{vworld_static_map_url}}, \code{\link{geom_vworld}}.}

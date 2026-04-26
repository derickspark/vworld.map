# marker_route.R ------------------------------------------------------------

#' Build a VWorld marker specification
#'
#' Returns a `vworld_marker` object — a serialized sub-parameter string suitable
#' for passing to [vworld_static_map_url()] and [vworld_static_map()] via the
#' `markers` argument. All points sharing this marker spec inherit the same
#' `label`, `color`, `font`, `size`, and `image` styling. To use different
#' styles, build multiple `vworld_marker()` objects and pass them as a list.
#'
#' @param point Marker point(s). One of:
#'   * a length-2 numeric vector `c(x, y)`,
#'   * a 2-column matrix or data.frame,
#'   * a list of length-2 numeric vectors.
#' @param label Optional label string shown next to the marker(s).
#' @param color Label color. One of `"black"`, `"white"`, `"red"`, `"blue"`,
#'   `"green"`, an `rgb(r,g,b)` string, or any R color (e.g. `"#FF8800"`,
#'   `"tomato"`) which is auto-converted to `rgb()`. Only effective when
#'   `label` is set.
#' @param font Optional font family for the label.
#' @param size Optional label font size in pixels.
#' @param image Optional marker icon ID (e.g. `"img01"`, `"img01s"`) as
#'   listed in the VWorld marker ID catalog.
#' @return A character string of class `vworld_marker`.
#' @examples
#' vworld_marker(c(126.978271, 37.566643), label = "Seoul City Hall",
#'               color = "red", image = "img01")
#' @export
vworld_marker <- function(point,
                          label = NULL,
                          color = NULL,
                          font  = NULL,
                          size  = NULL,
                          image = NULL) {
  point_str <- .points_to_wkt(point)
  parts <- list(
    point = point_str,
    label = label,
    color = .normalize_color(color),
    font  = font,
    size  = if (!is.null(size)) as.integer(size) else NULL,
    image = image
  )
  out <- .encode_subparams(parts)
  structure(out, class = c("vworld_marker", "character"))
}

#' Build a VWorld route (polyline) specification
#'
#' Returns a `vworld_route` object — a serialized sub-parameter string suitable
#' for passing to [vworld_static_map_url()] and [vworld_static_map()] via the
#' `routes` argument. Build multiple route objects and pass them as a list to
#' draw lines with different styles.
#'
#' @param point Polyline vertices. Same accepted forms as [vworld_marker()],
#'   but typically a 2-column matrix/data.frame of consecutive vertices.
#' @param color Line color (see [vworld_marker()] for accepted values).
#' @param width Line width in pixels.
#' @param style Line dash style. One of `"solid"`, `"dash"`, `"dot"`,
#'   `"dashdot"`, `"dashdotdot"`, `"longdash"`, `"longdashdot"`.
#' @return A character string of class `vworld_route`.
#' @examples
#' vworld_route(rbind(c(126.97, 37.56), c(126.99, 37.58), c(127.02, 37.55)),
#'              color = "red", width = 3, style = "dashdot")
#' @export
vworld_route <- function(point,
                         color = NULL,
                         width = NULL,
                         style = NULL) {
  point_str <- .points_to_wkt(point)
  if (!is.null(style)) {
    style <- tolower(style)
    .assert(style %in% VWORLD_LINE_STYLES,
            paste0("`style` must be one of: ",
                   paste(VWORLD_LINE_STYLES, collapse = ", ")))
  }
  parts <- list(
    point = point_str,
    color = .normalize_color(color),
    width = if (!is.null(width)) as.integer(width) else NULL,
    style = style
  )
  out <- .encode_subparams(parts)
  structure(out, class = c("vworld_route", "character"))
}

#' @export
print.vworld_marker <- function(x, ...) {
  cat("<vworld_marker>\n  ", as.character(x), "\n", sep = "")
  invisible(x)
}

#' @export
print.vworld_route <- function(x, ...) {
  cat("<vworld_route>\n  ", as.character(x), "\n", sep = "")
  invisible(x)
}

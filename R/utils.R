# Internal helpers for vworld.map -------------------------------------------

#' Strict assertion utility
#' @keywords internal
#' @noRd
.assert <- function(cond, msg) {
  if (!isTRUE(cond)) stop("[vworld.map] ", msg, call. = FALSE)
}

#' Coerce points argument to a numeric matrix with x,y columns.
#'
#' Accepts:
#'   * a numeric vector of length 2 (single point)
#'   * a numeric matrix / data.frame with at least 2 columns
#'   * a list of length-2 numeric vectors
#' Returns a 2-column numeric matrix.
#' @keywords internal
#' @noRd
.as_xy <- function(points) {
  if (is.numeric(points) && is.null(dim(points)) && length(points) == 2L) {
    return(matrix(points, nrow = 1L))
  }
  if (is.data.frame(points)) points <- as.matrix(points)
  if (is.list(points) && !is.matrix(points)) {
    if (!all(vapply(points, length, integer(1)) == 2L)) {
      stop("[vworld.map] each list element must be a length-2 numeric vector",
           call. = FALSE)
    }
    points <- do.call(rbind, points)
  }
  if (!is.matrix(points) || ncol(points) < 2L) {
    stop("[vworld.map] `points` must be a length-2 vector, ",
         "a 2-column matrix/data.frame, or a list of length-2 vectors.",
         call. = FALSE)
  }
  storage.mode(points) <- "double"
  points[, 1:2, drop = FALSE]
}

#' Format a numeric value for the API (no scientific, sensible precision).
#' @keywords internal
#' @noRd
.fmt_num <- function(x, digits = 8L) {
  formatC(x, format = "f", digits = digits, drop0trailing = TRUE)
}

#' Build a "x y,x y,..." WKT-style point list (used in marker/route).
#' @keywords internal
#' @noRd
.points_to_wkt <- function(points, digits = 8L) {
  m <- .as_xy(points)
  paste(
    apply(m, 1, function(row) {
      paste(.fmt_num(row[1], digits), .fmt_num(row[2], digits))
    }),
    collapse = ","
  )
}

#' Validate and normalize a color spec for marker/route.
#'
#' Accepts named colors ("red", "blue", ...) or "rgb(r,g,b)".
#' Also accepts an R color (e.g. "#FF0000" or "tomato") and converts to rgb().
#' @keywords internal
#' @noRd
.normalize_color <- function(color) {
  if (is.null(color)) return(NULL)
  .assert(is.character(color) && length(color) == 1L,
          "`color` must be a single character string.")
  if (color %in% VWORLD_NAMED_COLORS) return(color)
  if (grepl("^rgb\\(", color)) return(color)
  # try to convert any R color to rgb()
  rgb_mat <- tryCatch(grDevices::col2rgb(color),
                      error = function(e) NULL)
  if (is.null(rgb_mat)) {
    stop("[vworld.map] invalid `color`: ", color, call. = FALSE)
  }
  sprintf("rgb(%d,%d,%d)", rgb_mat[1, 1], rgb_mat[2, 1], rgb_mat[3, 1])
}

#' Serialize a list of sub-parameters into "key:val|key:val" form
#' as used by the marker/route parameters.
#' @keywords internal
#' @noRd
.encode_subparams <- function(parts) {
  parts <- parts[!vapply(parts, is.null, logical(1))]
  paste(
    vapply(names(parts), function(k) paste0(k, ":", parts[[k]]),
           character(1)),
    collapse = "|"
  )
}

#' Validate a center argument and turn it into "x,y".
#'
#' Accepts:
#'   * a numeric length-2 vector `c(x, y)`
#'   * a string `"x,y"` (or `"x y"`)
#'   * a free-text place name / address string — auto-geocoded via
#'     [vworld_geocode()] when a `key` is provided.
#'
#' @param center One of the forms above.
#' @param key VWorld API key — required only when geocoding a non-numeric
#'   string.
#' @param verbose If `TRUE`, message about the geocoding lookup.
#' @keywords internal
#' @noRd
.encode_center <- function(center, key = NULL, verbose = FALSE) {
  # numeric vector path
  if (is.numeric(center) && length(center) == 2L && all(is.finite(center))) {
    return(paste(.fmt_num(center[1]), .fmt_num(center[2]), sep = ","))
  }

  # string path
  if (is.character(center) && length(center) == 1L && nzchar(center)) {
    # try to parse as "x,y" / "x y"
    parsed <- suppressWarnings(
      as.numeric(strsplit(center, "[,\\s]+", perl = TRUE)[[1]])
    )
    if (length(parsed) == 2L && all(is.finite(parsed))) {
      return(paste(.fmt_num(parsed[1]), .fmt_num(parsed[2]), sep = ","))
    }

    # fall back to geocoding
    if (is.null(key) || !nzchar(key)) {
      stop("[vworld.map] `center` looks like a place name / address ('",
           center, "'), so a `key` argument is required to geocode it.",
           call. = FALSE)
    }
    if (verbose) {
      message("[vworld.map] geocoding center: '", center, "'")
    }
    xy <- vworld_geocode(center, key = key, verbose = verbose)
    return(paste(.fmt_num(xy[1]), .fmt_num(xy[2]), sep = ","))
  }

  stop("[vworld.map] `center` must be c(x, y), 'x,y', or a place / address string.",
       call. = FALSE)
}

#' Validate `size` and return "WxH" string.
#' @keywords internal
#' @noRd
.encode_size <- function(size) {
  if (is.character(size) && length(size) == 1L) {
    parts <- strsplit(size, "[,xX\\s]+", perl = TRUE)[[1]]
    .assert(length(parts) == 2L,
            "`size` string must be of the form 'width,height'.")
    size <- as.integer(parts)
  }
  .assert(is.numeric(size) && length(size) == 2L,
          "`size` must be c(width, height).")
  size <- as.integer(size)
  .assert(all(size > 0 & size <= 1024),
          "`size` width/height must be in (0, 1024].")
  paste(size[1], size[2], sep = ",")
}

#' Friendly aliases for `basemap`. Case-insensitive, mapped to API codes.
#' @keywords internal
#' @noRd
.basemap_aliases <- c(
  GEOGRAPHIC   = "GRAPHIC",
  MAP          = "GRAPHIC",
  WHITE        = "GRAPHIC_WHITE",
  BLANK        = "GRAPHIC_WHITE",
  NIGHT        = "GRAPHIC_NIGHT",
  DARK         = "GRAPHIC_NIGHT",
  SATELLITE    = "PHOTO",
  AERIAL       = "PHOTO",
  HYBRID       = "PHOTO_HYBRID"
)

#' Validate `basemap` (with friendly aliases).
#' @keywords internal
#' @noRd
.encode_basemap <- function(basemap) {
  if (is.null(basemap)) return("GRAPHIC")
  bm_up <- toupper(basemap)
  if (bm_up %in% names(.basemap_aliases)) {
    bm_up <- unname(.basemap_aliases[bm_up])
  }
  .assert(bm_up %in% VWORLD_BASEMAPS,
          paste0("`basemap` must be one of: ",
                 paste(VWORLD_BASEMAPS, collapse = ", "),
                 " (or aliases: ",
                 paste(names(.basemap_aliases), collapse = ", "), ")"))
  bm_up
}

#' Validate `zoom`.
#' @keywords internal
#' @noRd
.encode_zoom <- function(zoom) {
  .assert(is.numeric(zoom) && length(zoom) == 1L,
          "`zoom` must be a single number.")
  zoom <- as.integer(zoom)
  .assert(zoom >= 6L && zoom <= 18L,
          "`zoom` must be in 6..18.")
  as.character(zoom)
}

#' Validate `crs`.
#' @keywords internal
#' @noRd
.encode_crs <- function(crs) {
  if (is.null(crs)) return("EPSG:4326")
  .assert(is.character(crs) && length(crs) == 1L,
          "`crs` must be a single character string (e.g. 'EPSG:4326').")
  if (!grepl("^EPSG:", crs, ignore.case = TRUE)) {
    if (crs %in% names(VWORLD_CRS)) {
      crs <- VWORLD_CRS[[crs]]
    } else if (grepl("^[0-9]+$", crs)) {
      crs <- paste0("EPSG:", crs)
    }
  }
  crs
}

#' Validate `format`.
#' @keywords internal
#' @noRd
.encode_format <- function(format) {
  if (is.null(format)) return("png")
  format <- tolower(format)
  .assert(format %in% VWORLD_FORMATS,
          paste0("`format` must be one of: ",
                 paste(VWORLD_FORMATS, collapse = ", ")))
  format
}

#' URL-encode a single query value, leaving comma/colon/pipe unescaped
#' where the API tolerates them, but always escaping spaces to %20.
#' We do a strict encodeURIComponent-like pass for safety.
#' @keywords internal
#' @noRd
.url_encode <- function(x) {
  utils::URLencode(as.character(x), reserved = TRUE)
}

#' Assemble a query string from a named list, dropping NULLs.
#' Repeated parameter names (e.g. `marker`) are supported by passing
#' a character vector for that name.
#' @keywords internal
#' @noRd
.build_query <- function(params) {
  params <- params[!vapply(params, is.null, logical(1))]
  pairs <- character(0)
  for (nm in names(params)) {
    val <- params[[nm]]
    for (v in val) {
      pairs <- c(pairs, paste0(nm, "=", .url_encode(v)))
    }
  }
  paste(pairs, collapse = "&")
}

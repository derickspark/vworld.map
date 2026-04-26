# static_map.R --------------------------------------------------------------

#' Build a VWorld StaticMap (GetMap) request URL
#'
#' Assembles a VWorld StaticMap API 2.0 GetMap request URL from R-friendly
#' arguments. No network call is made — use [vworld_static_map()] to actually
#' download the image.
#'
#' @param key Your VWorld API key. **Required.** Sign up at
#'   <https://www.vworld.kr/dev/v4dv_apikeyList_s001.do>.
#' @param center Map center as `c(x, y)` or `"x,y"`.
#' @param zoom Integer zoom level, 6..18.
#' @param size Image size as `c(width, height)`. Each side must be in (0, 1024].
#' @param basemap One of [VWORLD_BASEMAPS]. Default `"GRAPHIC"`.
#' @param crs Coordinate reference system for `center`, `markers`, and
#'   `routes`. Either an EPSG string (`"EPSG:4326"`), a numeric EPSG code
#'   (`4326`), or one of the names in [VWORLD_CRS]. Default `"EPSG:4326"`.
#' @param format Image format. One of `"png"` (default), `"jpeg"`, `"bmp"`.
#' @param markers Optional. A `vworld_marker` object or a list of them.
#'   Use [vworld_marker()] to construct.
#' @param routes Optional. A `vworld_route` object or a list of them.
#'   Use [vworld_route()] to construct.
#' @param layers Optional character vector of WMS layer names to overlay.
#' @param styles Optional character vector of style names matching `layers`.
#' @param error_format How VWorld should report errors:
#'   `"json"` (default), `"xml"`, `"image"`, or `"blank"`.
#' @param service,version,request Generally leave as defaults.
#' @param extra Optional named list of additional query parameters that will
#'   be appended verbatim — useful for any future API parameter not yet
#'   wrapped here.
#' @return A character scalar — the fully encoded GetMap URL.
#' @seealso [vworld_static_map()] to download the image directly.
#' @examples
#' \dontrun{
#' # Sample URL from the VWorld reference
#' vworld_static_map_url(
#'   key    = "YOUR_KEY",
#'   center = c(126.978271, 37.566643),
#'   zoom   = 16,
#'   size   = c(400, 400),
#'   markers = vworld_marker(c(126.978271, 37.566643))
#' )
#' }
#' @export
vworld_static_map_url <- function(key,
                                  center,
                                  zoom        = 10,
                                  size        = c(400, 400),
                                  basemap     = "GRAPHIC",
                                  crs         = "EPSG:4326",
                                  format      = "png",
                                  markers     = NULL,
                                  routes      = NULL,
                                  layers      = NULL,
                                  styles      = NULL,
                                  error_format = "json",
                                  service     = "image",
                                  version     = "2.0",
                                  request     = "getmap",
                                  extra       = NULL,
                                  verbose     = FALSE) {

  .assert(is.character(key) && length(key) == 1L && nzchar(key),
          "`key` is required (a single non-empty character string).")
  .assert(error_format %in% c("json", "xml", "image", "blank"),
          "`error_format` must be one of 'json','xml','image','blank'.")

  marker_strs <- .as_marker_strings(markers)
  route_strs  <- .as_route_strings(routes)

  layer_str <- if (!is.null(layers)) paste(layers, collapse = ",") else NULL
  style_str <- if (!is.null(styles)) paste(styles, collapse = ",") else NULL

  params <- list(
    service     = service,
    version     = version,
    request     = request,
    key         = key,
    format      = .encode_format(format),
    errorFormat = error_format,
    basemap     = .encode_basemap(basemap),
    center      = .encode_center(center, key = key, verbose = verbose),
    crs         = .encode_crs(crs),
    zoom        = .encode_zoom(zoom),
    size        = .encode_size(size),
    layers      = layer_str,
    styles      = style_str,
    marker      = marker_strs,
    route       = route_strs
  )

  if (!is.null(extra)) {
    .assert(is.list(extra) && !is.null(names(extra)),
            "`extra` must be a named list.")
    for (nm in names(extra)) params[[nm]] <- as.character(extra[[nm]])
  }

  paste0(VWORLD_ENDPOINT, "?", .build_query(params))
}

#' Download a VWorld StaticMap image
#'
#' Calls [vworld_static_map_url()] to build the request URL, then downloads
#' the resulting image. By default returns the local file path; pass
#' `read = TRUE` to load the image into R.
#'
#' @inheritParams vworld_static_map_url
#' @param path Optional file path to write the image to. If `NULL` (default)
#'   a path in [tempdir()] is used.
#' @param read If `TRUE`, read the image into R. Returns a `magick-image`
#'   object when the **magick** package is available, otherwise a `nativeRaster`
#'   array (PNG/JPEG only).
#' @param overwrite If `TRUE`, overwrite an existing `path`. Default `TRUE`.
#' @param verbose If `TRUE`, message the request URL (with the key elided).
#' @return If `read = FALSE`, a character path to the downloaded file (with the
#'   request URL attached as the `"url"` attribute). If `read = TRUE`, the
#'   in-memory image (see `read`).
#' @examples
#' \dontrun{
#' img_path <- vworld_static_map(
#'   key    = Sys.getenv("VWORLD_API_KEY"),
#'   center = c(126.978271, 37.566643),
#'   zoom   = 16,
#'   size   = c(400, 400),
#'   markers = vworld_marker(c(126.978271, 37.566643), label = "City Hall",
#'                           color = "red", image = "img01")
#' )
#' # View it:
#' if (requireNamespace("magick", quietly = TRUE))
#'   magick::image_read(img_path)
#' }
#' @export
vworld_static_map <- function(key,
                              center,
                              zoom        = 10,
                              size        = c(400, 400),
                              basemap     = "GRAPHIC",
                              crs         = "EPSG:4326",
                              format      = "png",
                              markers     = NULL,
                              routes      = NULL,
                              layers      = NULL,
                              styles      = NULL,
                              error_format = "image",
                              path        = NULL,
                              read        = FALSE,
                              overwrite   = TRUE,
                              verbose     = FALSE,
                              extra       = NULL) {

  url <- vworld_static_map_url(
    key = key, center = center, zoom = zoom, size = size,
    basemap = basemap, crs = crs, format = format,
    markers = markers, routes = routes,
    layers = layers, styles = styles,
    error_format = error_format,
    verbose = verbose,
    extra = extra
  )

  format <- .encode_format(format)
  if (is.null(path)) {
    path <- tempfile(pattern = "vworld_", fileext = paste0(".", format))
  }
  if (file.exists(path) && !overwrite) {
    stop("[vworld.map] file exists and `overwrite = FALSE`: ", path,
         call. = FALSE)
  }

  if (verbose) message("[vworld.map] GET ", .elide_key(url))

  resp <- httr::GET(
    url,
    httr::write_disk(path, overwrite = TRUE),
    httr::user_agent("vworld.map R package (https://github.com/derickspark/vworld.map)")
  )

  status <- httr::status_code(resp)
  if (status >= 400L) {
    stop(sprintf("[vworld.map] VWorld API request failed (HTTP %s). URL: %s",
                 status, .elide_key(url)),
         call. = FALSE)
  }

  attr(path, "url") <- url

  if (!read) return(path)

  if (requireNamespace("magick", quietly = TRUE)) {
    return(magick::image_read(path))
  }
  if (format == "png") return(png::readPNG(path, native = TRUE))
  if (format == "jpeg") return(jpeg::readJPEG(path, native = TRUE))
  warning("[vworld.map] cannot read ", format,
          " in-memory without the 'magick' package. Returning file path.")
  path
}

# --- helpers ---------------------------------------------------------------

#' Coerce a `markers` argument to a character vector of encoded sub-params.
#' @keywords internal
#' @noRd
.as_marker_strings <- function(markers) {
  if (is.null(markers)) return(NULL)
  if (inherits(markers, "vworld_marker")) return(as.character(markers))
  if (is.list(markers)) {
    .assert(all(vapply(markers, inherits, logical(1), "vworld_marker")),
            "every element of `markers` must be a vworld_marker object.")
    return(vapply(markers, as.character, character(1)))
  }
  if (is.character(markers)) return(markers)
  stop("[vworld.map] `markers` must be a vworld_marker, a list of them, or NULL.",
       call. = FALSE)
}

#' Coerce a `routes` argument to a character vector of encoded sub-params.
#' @keywords internal
#' @noRd
.as_route_strings <- function(routes) {
  if (is.null(routes)) return(NULL)
  if (inherits(routes, "vworld_route")) return(as.character(routes))
  if (is.list(routes)) {
    .assert(all(vapply(routes, inherits, logical(1), "vworld_route")),
            "every element of `routes` must be a vworld_route object.")
    return(vapply(routes, as.character, character(1)))
  }
  if (is.character(routes)) return(routes)
  stop("[vworld.map] `routes` must be a vworld_route, a list of them, or NULL.",
       call. = FALSE)
}

#' Replace key=...&  with key=***&  for printing.
#' @keywords internal
#' @noRd
.elide_key <- function(url) {
  sub("(?i)([?&]key=)[^&]*", "\\1***", url, perl = TRUE)
}

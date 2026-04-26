# integrations.R ------------------------------------------------------------

#' Use a VWorld static map as a ggplot2 background layer
#'
#' Downloads a VWorld static map for the requested area and returns it as a
#' `ggplot2::annotation_raster()` layer that can be added to a ggplot. The
#' raster is positioned in the **same coordinate system as `center`/`crs`**,
#' so points/lines you plot on top of it should use matching coordinates.
#'
#' Because VWorld doesn't expose the exact map bounding box for a given
#' (center, zoom, size), we approximate it from a Web Mercator pixel scale
#' equation (`metersPerPixel = 156543.03392 * cos(lat) / 2^zoom`) when
#' `crs = EPSG:4326` or any Web-Mercator-aligned projection. For other
#' projections, you can pass `bbox = c(xmin, ymin, xmax, ymax)` directly.
#'
#' Requires the `ggplot2` and `magick` (or `png`/`jpeg`) packages.
#'
#' @inheritParams vworld_static_map
#' @param bbox Optional `c(xmin, ymin, xmax, ymax)` bounding box in the same
#'   CRS as `center`. If `NULL`, computed from the Web-Mercator pixel scale
#'   when `crs` is `EPSG:4326`.
#' @return A list of ggplot2 layers — add to a ggplot with `+`.
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot() +
#'   vworld_ggmap_layer(
#'     key = Sys.getenv("VWORLD_API_KEY"),
#'     center = c(126.978271, 37.566643),
#'     zoom = 16, size = c(640, 640)
#'   ) +
#'   coord_fixed() +
#'   geom_point(aes(x = 126.978271, y = 37.566643), color = "red", size = 3)
#' }
#' @export
vworld_ggmap_layer <- function(key, center, zoom, size,
                               basemap = "GRAPHIC", crs = "EPSG:4326",
                               format = "png",
                               markers = NULL, routes = NULL,
                               layers = NULL, styles = NULL,
                               bbox = NULL, ...) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("[vworld.map] vworld_ggmap_layer() needs the 'ggplot2' package.",
         call. = FALSE)
  }

  img_path <- vworld_static_map(
    key = key, center = center, zoom = zoom, size = size,
    basemap = basemap, crs = crs, format = format,
    markers = markers, routes = routes,
    layers = layers, styles = styles,
    error_format = "image",
    ...
  )

  raster <- .read_raster(img_path, format)

  if (is.null(bbox)) {
    bbox <- .approx_bbox(center, zoom, size, crs)
  }
  .assert(is.numeric(bbox) && length(bbox) == 4L,
          "`bbox` must be c(xmin, ymin, xmax, ymax).")

  list(
    ggplot2::annotation_raster(
      raster = raster,
      xmin = bbox[1], xmax = bbox[3],
      ymin = bbox[2], ymax = bbox[4],
      interpolate = TRUE
    ),
    ggplot2::coord_fixed(
      xlim = c(bbox[1], bbox[3]),
      ylim = c(bbox[2], bbox[4]),
      expand = FALSE
    )
  )
}

#' Add a VWorld static map as a leaflet image overlay
#'
#' Returns a function that takes a `leaflet` map and adds the static map as
#' an `imageOverlay` over the computed bounds. Useful when you want to use
#' VWorld imagery as a fixed-bounds underlay together with leaflet markers,
#' polygons, etc.
#'
#' Requires the `leaflet` package.
#'
#' @inheritParams vworld_ggmap_layer
#' @param opacity Layer opacity, in 0..1.
#' @return A function `function(map)` returning the leaflet map with the
#'   overlay added.
#' @examples
#' \dontrun{
#' library(leaflet)
#' overlay <- vworld_leaflet_image(
#'   key = Sys.getenv("VWORLD_API_KEY"),
#'   center = c(126.978271, 37.566643),
#'   zoom = 16, size = c(640, 640)
#' )
#' leaflet() |>
#'   setView(126.978271, 37.566643, zoom = 16) |>
#'   overlay()
#' }
#' @export
vworld_leaflet_image <- function(key, center, zoom, size,
                                 basemap = "GRAPHIC", crs = "EPSG:4326",
                                 format = "png",
                                 markers = NULL, routes = NULL,
                                 layers = NULL, styles = NULL,
                                 bbox = NULL, opacity = 1, ...) {
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    stop("[vworld.map] vworld_leaflet_image() needs the 'leaflet' package.",
         call. = FALSE)
  }

  img_path <- vworld_static_map(
    key = key, center = center, zoom = zoom, size = size,
    basemap = basemap, crs = crs, format = format,
    markers = markers, routes = routes,
    layers = layers, styles = styles,
    error_format = "image",
    ...
  )

  if (is.null(bbox)) bbox <- .approx_bbox(center, zoom, size, crs)
  .assert(is.numeric(bbox) && length(bbox) == 4L,
          "`bbox` must be c(xmin, ymin, xmax, ymax).")

  function(map) {
    leaflet::addRasterImage  # silence R CMD check (keep dependency hint)
    leaflet::addRasterImage(
      map,
      x       = .read_raster(img_path, format),
      bounds  = list(c(bbox[2], bbox[1]), c(bbox[4], bbox[3])),
      opacity = opacity
    )
  }
}

# --- internal helpers ------------------------------------------------------

#' Read a raster from a downloaded file, preferring magick.
#' @keywords internal
#' @noRd
.read_raster <- function(path, format) {
  if (requireNamespace("magick", quietly = TRUE)) {
    img <- magick::image_read(path)
    return(as.raster(img))
  }
  format <- tolower(format)
  if (format == "png") return(png::readPNG(path))
  if (format == "jpeg") return(jpeg::readJPEG(path))
  stop("[vworld.map] cannot read '", format,
       "' without the 'magick' package.", call. = FALSE)
}

#' Approximate map extent in EPSG:4326 from center / zoom / size,
#' using the Web Mercator pixel scale.
#' @keywords internal
#' @noRd
.approx_bbox <- function(center, zoom, size, crs) {
  if (is.character(center)) {
    center <- as.numeric(strsplit(center, "[,\\s]+", perl = TRUE)[[1]])
  }
  if (is.character(size)) {
    size <- as.integer(strsplit(size, "[,xX\\s]+", perl = TRUE)[[1]])
  }
  crs_norm <- toupper(.encode_crs(crs))
  if (!crs_norm %in% c("EPSG:4326", "EPSG:4019",
                        "EPSG:3857", "EPSG:900913")) {
    stop("[vworld.map] auto bbox is only supported for EPSG:4326/4019/3857/900913. ",
         "Pass `bbox = c(xmin, ymin, xmax, ymax)` manually.", call. = FALSE)
  }
  if (crs_norm %in% c("EPSG:3857", "EPSG:900913")) {
    # meters per pixel in Web Mercator
    mpp <- 156543.03392 / 2^as.numeric(zoom)
    halfW <- size[1] / 2 * mpp
    halfH <- size[2] / 2 * mpp
    return(c(center[1] - halfW, center[2] - halfH,
             center[1] + halfW, center[2] + halfH))
  }
  # geographic (EPSG:4326)
  lat <- center[2]
  mpp <- 156543.03392 * cos(lat * pi / 180) / 2^as.numeric(zoom)
  halfW_m <- size[1] / 2 * mpp
  halfH_m <- size[2] / 2 * mpp
  # meters -> degrees (rough)
  deg_per_m_lat <- 1 / 111320
  deg_per_m_lon <- 1 / (111320 * cos(lat * pi / 180))
  c(center[1] - halfW_m * deg_per_m_lon,
    center[2] - halfH_m * deg_per_m_lat,
    center[1] + halfW_m * deg_per_m_lon,
    center[2] + halfH_m * deg_per_m_lat)
}

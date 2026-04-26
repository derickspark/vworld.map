# geocode.R -----------------------------------------------------------------

#' Geocode a place name or address using the VWorld Search API
#'
#' Converts a free-text query (place name like `"서울시청"`, road address like
#' `"서울특별시 중구 세종대로 110"`, or jibun address) into longitude/latitude
#' (`EPSG:4326`) by calling the VWorld Search REST API
#' (<https://api.vworld.kr/req/search>).
#'
#' By default this tries the `"place"` type first, then falls back to
#' `"address"` if no result is returned. Pass `type` explicitly to skip the
#' fallback.
#'
#' @param query Character string — place name or address to geocode.
#' @param key Your VWorld API key. (Required — same key used for StaticMap.)
#' @param type Character vector of search types to try, in order. Each element
#'   is one of `"place"`, `"address"`, `"district"`. Default
#'   `c("place", "address")`.
#' @param category Optional category filter for `type = "place"`
#'   (e.g. `"L1"` ~ `"L4"` per VWorld spec). Usually leave `NULL`.
#' @param all_results If `TRUE`, return a data.frame of every match; if
#'   `FALSE` (default), return only the top match as `c(x, y)`.
#' @param size Maximum number of results to fetch (default 10, max 1000).
#' @param verbose If `TRUE`, message the request URL with key elided.
#' @return If `all_results = FALSE`: a length-2 numeric vector
#'   `c(x, y)` in EPSG:4326. If `all_results = TRUE`: a data.frame with
#'   columns `x`, `y`, `title`, `category`, `address_road`, `address_parcel`,
#'   `type` (the matched search type).
#' @examples
#' \dontrun{
#' vworld_geocode("서울시청", key = Sys.getenv("VWORLD_API_KEY"))
#' #> c(126.978..., 37.566...)
#'
#' vworld_geocode("서울특별시 중구 세종대로 110",
#'                key = Sys.getenv("VWORLD_API_KEY"),
#'                type = "address")
#' }
#' @export
vworld_geocode <- function(query,
                           key,
                           type        = c("place", "address"),
                           category    = NULL,
                           all_results = FALSE,
                           size        = 10L,
                           verbose     = FALSE) {

  .assert(is.character(query) && length(query) == 1L && nzchar(query),
          "`query` must be a single non-empty character string.")
  .assert(is.character(key) && length(key) == 1L && nzchar(key),
          "`key` is required to call the VWorld geocoder.")
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("[vworld.map] vworld_geocode() needs the 'jsonlite' package. ",
         "Install with: install.packages('jsonlite')",
         call. = FALSE)
  }

  type <- tolower(type)
  valid <- c("place", "address", "district")
  bad <- setdiff(type, valid)
  if (length(bad)) {
    stop("[vworld.map] invalid `type`: ", paste(bad, collapse = ", "),
         ". Use one of ", paste(valid, collapse = ", "), call. = FALSE)
  }

  for (t in type) {
    rows <- .vworld_search_one(query, key, t, category, size, verbose)
    if (nrow(rows) > 0L) {
      if (all_results) return(rows)
      return(c(rows$x[1], rows$y[1]))
    }
  }

  if (all_results) {
    return(data.frame(
      x = numeric(0), y = numeric(0),
      title = character(0), category = character(0),
      address_road = character(0), address_parcel = character(0),
      type = character(0), stringsAsFactors = FALSE
    ))
  }
  stop("[vworld.map] no geocoding result for query: '", query, "'",
       call. = FALSE)
}

# --- internal --------------------------------------------------------------

#' Run a single VWorld search request and return a normalized data.frame.
#' @keywords internal
#' @noRd
.vworld_search_one <- function(query, key, type, category, size, verbose) {
  params <- list(
    service     = "search",
    request     = "search",
    version     = "2.0",
    crs         = "EPSG:4326",
    size        = as.integer(size),
    page        = 1L,
    query       = query,
    type        = toupper(type),
    category    = category,
    format      = "json",
    errorformat = "json",
    key         = key
  )
  qs  <- .build_query(params)
  url <- paste0("https://api.vworld.kr/req/search?", qs)
  if (verbose) message("[vworld.map] GET ", .elide_key(url))

  resp <- httr::GET(
    url,
    httr::user_agent("vworld.map R package (https://github.com/derickspark/vworld.map)")
  )
  if (httr::http_error(resp)) {
    stop("[vworld.map] VWorld geocoder HTTP error: ",
         httr::status_code(resp), call. = FALSE)
  }

  raw <- httr::content(resp, as = "text", encoding = "UTF-8")
  obj <- tryCatch(jsonlite::fromJSON(raw, simplifyVector = FALSE),
                  error = function(e) NULL)
  if (is.null(obj) || is.null(obj$response)) {
    return(.empty_search_df())
  }

  status <- obj$response$status
  if (!identical(status, "OK")) {
    return(.empty_search_df())
  }

  items <- obj$response$result$items
  if (is.null(items) || length(items) == 0L) {
    return(.empty_search_df())
  }

  do.call(rbind, lapply(items, function(it) {
    pt <- it$point
    addr <- it$address
    data.frame(
      x              = if (!is.null(pt$x)) as.numeric(pt$x) else NA_real_,
      y              = if (!is.null(pt$y)) as.numeric(pt$y) else NA_real_,
      title          = if (!is.null(it$title)) it$title else NA_character_,
      category       = if (!is.null(it$category)) it$category else NA_character_,
      address_road   = if (!is.null(addr$road)) addr$road else NA_character_,
      address_parcel = if (!is.null(addr$parcel)) addr$parcel else NA_character_,
      type           = type,
      stringsAsFactors = FALSE
    )
  }))
}

#' @keywords internal
#' @noRd
.empty_search_df <- function() {
  data.frame(
    x = numeric(0), y = numeric(0),
    title = character(0), category = character(0),
    address_road = character(0), address_parcel = character(0),
    type = character(0), stringsAsFactors = FALSE
  )
}

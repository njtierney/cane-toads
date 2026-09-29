#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param toads
#' @param map
#' @return
#' @author njtierney
#' @export
find_state <- function(toads = toads, map = ozmap_states) {
  ## can we find what state a given point is in
  toads_sf <- st_as_sf(x = toads, coords = c("lon", "lat"), crs = 4326)
  # update CRS of ozmap
  oz_states <- map |>
    st_transform(crs = 4326)

  toads_states <- st_join(toads_sf, oz_states) |>
    select(-state) |>
    rename(state = NAME) |>
    relocate(state, .before = everything())

  toads_states
}

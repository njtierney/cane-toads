# Which state each record falls inside, as a new `point_in_state` column.
find_state <- function(toads, map) {
  # `map` is ozmap_states, or anything with a NAME column for each polygon.
  map_states <- map |>
    st_transform(crs = 4326) |>
    select(point_in_state = NAME)

  toads |>
    # Transformed to WGS84 to match ALA. Records outside every state get NA.
    # remove = FALSE keeps the lon/lat
    st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE) |>
    st_join(map_states) |>
    st_drop_geometry()
}

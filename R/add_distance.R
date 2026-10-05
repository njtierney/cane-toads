# How far each row is from the row before it, in kilometres.
add_distance <- function(data, lon = "lon", lat = "lat") {
  # geodist() calculates distance between lon/lat pairs
  dist_mat <- cbind(lon = data[[lon]], lat = data[[lat]])

  distances_m <- dist_mat |>
    geodist(
      measure = "geodesic",
      # `sequential = TRUE` makes it row-to-row rather than pairwise.
      sequential = TRUE,
      # No step into the first row, so it is padded with NA.
      pad = TRUE
    )

  data |>
    mutate(
      distance_km = distances_m / 1000,
      .after = decade
    )
}

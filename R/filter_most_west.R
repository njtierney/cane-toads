# The westernmost record in each decade: the smallest longitude.
filter_most_west <- function(toads) {
  toads |>
    group_by(decade) |>
    slice_min(lon, n = 1) |>
    ungroup()
}

tidy_toads <- function(toads_raw) {
  toads_raw |>
    clean_names() |>
    rename(
      lat = decimal_latitude,
      lon = decimal_longitude,
      date = event_date,
      coord_var_m = coordinate_uncertainty_in_meters,
      resource_name = data_resource_name
    ) |>
    # Year is computed from date, decade computed from year
    mutate(
      year = year(date),
      decade = floor(year / 10) * 10,
      .after = date
    ) |>
    # Drop records with no date/lat/lon info
    drop_na(date, lon, lat)
}

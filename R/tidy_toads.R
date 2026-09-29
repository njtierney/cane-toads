#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param toads_raw
#' @return
#' @author njtierney
#' @export
tidy_toads <- function(toads_raw) {
  result <- toads_raw |>
    # from janitor
    clean_names() |>
    rename(
      lat = decimal_latitude,
      lon = decimal_longitude,
      date = event_date,
      coord_var_m = coordinate_uncertainty_in_meters,
      resource_name = data_resource_name
    ) |>
    relocate(
      year,
      .before = date
    ) |>
    mutate(
      # lubridate::year
      year = year(date),
      decade = floor(year / 10) * 10,
      .after = year
    ) |>
    drop_na(
      lat,
      lon,
      date
    )

  result
}

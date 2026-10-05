library(targets)
library(tarchetypes)
# Chapter 3, starter: where the session begins.
source("packages.R")
library(conflicted)
conflicts_prefer(dplyr::select)
conflicts_prefer(dplyr::filter)
tar_source()

tar_assign({
  # ---- read ----
  qld_toads_path <- "data-raw/cane-toad-wildnet.parquet" |> tar_file()
  qld_toads_raw <- read_parquet(qld_toads_path) |> tar_target()
  nt_toads_path <- "data-raw/cane-toad-fauna-atlas-nt.parquet" |> tar_file()
  nt_toads_raw <- read_parquet(nt_toads_path) |> tar_target()

  # ---- analysis ----
  toads_raw <- bind_rows(
    "Queensland" = qld_toads_raw,
    "Northern Territory" = nt_toads_raw,
    .id = "state"
  ) |>
    tar_target()

  toads <- tidy_toads(toads_raw) |> tar_target()
  toads_states <- find_state(toads, map = ozmap_states) |> tar_target()
  toads_west_front <- filter_most_west(toads_states) |> tar_target()
  toad_distances <- add_distance(toads_west_front) |> tar_target()

  # ---- results ----
  ## exploring code
  # toads_states |> count(state, point_in_state)
  # toads |> count(decade)
  # ggplot(toads, aes(x = decade)) + geom_bar()

  gg_toads_count_decade <- tar_target({
    ggplot(toad_distances, aes(x = decade, y = distance_km)) +
      geom_col() +
      scale_x_continuous(breaks = scales::breaks_width(width = 10))
  })

  # ---- maps ----
  gg_oz_map <- tar_target({
    ozmap_states |>
      filter(NAME %in% unique(toads_states$point_in_state)) |>
      ggplot() +
      geom_sf()
  })

  plot_toads_decade <- gg_toads_decade(gg_oz_map, toads_states) |> tar_target()
  plot_toads_west <- gg_toads_west_path(
    gg_oz_map,
    toads_states,
    toads_west_front
  ) |>
    tar_target()
})

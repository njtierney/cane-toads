# setup code
source("packages.R")
# **tar**gets
tar_source("R")

# facilitate this working in parallel
example_controller <- crew_controller_local(
  name = "anything",
  workers = 4,
  seconds_idle = 3
)

tar_option_set(
  controller = example_controller
)

tar_assign({
  # ---- read ----
  qld_toads_path <- "data-raw/cane-toad-wildnet.parquet" |> tar_file()
  qld_toads_raw <- read_parquet(qld_toads_path) |> tar_target()

  nt_toads_path <- "data-raw/cane-toad-fauna-atlas-nt.parquet" |>
    tar_file()
  nt_toads_raw <- read_parquet(nt_toads_path) |> tar_target()

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

  # plot_toads_decade <- tar_target(ggplot(toads, aes(x = decade)) + geom_bar())
  plot_toads_decade <- tar_target({
    ggplot(toads, aes(x = decade)) +
      geom_bar()
  })

  gg_oz_map <- tar_target({
    ozmap_states |>
      filter(NAME %in% unique(toads_states$point_in_state)) |>
      ggplot() +
      geom_sf()
  })

  plot_toads_facet <- gg_toads_decade(gg_oz_map, toads_states) |> tar_target()
  plot_western_path <- gg_toads_west_path(
    gg_oz_map,
    toads_states,
    toads_west_front
  ) |>
    tar_target(description = "plot of toads western pathway")

  # ---- explore ----
  report <- tar_quarto("explore-targets.qmd")
})

# toads <- tar_read(toads)
# equivalent to
# tar_load(toads)

# tar_make

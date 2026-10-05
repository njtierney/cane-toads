# Chapter 3, starter: where the session begins.
source("packages.R")
source("functions.R")

# ---- read ----
qld_toads_raw <- read_parquet(here("data-raw/cane-toad-wildnet.parquet"))
nt_toads_raw <- read_parquet(here("data-raw/cane-toad-fauna-atlas-nt.parquet"))

# ---- analysis ----
toads_raw <- bind_rows(
  "Queensland" = qld_toads_raw,
  "Northern Territory" = nt_toads_raw,
  .id = "state"
)

toads <- tidy_toads(toads_raw)
toads_states <- find_state(toads, map = ozmap_states)
toads_west_front <- filter_most_west(toads_states)
toad_distances <- add_distance(toads_west_front)

# ---- results ----
toads_states |> count(state, point_in_state)

toads |> count(decade)

ggplot(toads, aes(x = decade)) + geom_bar()

ggplot(toad_distances, aes(x = decade, y = distance_km)) +
  geom_col() +
  scale_x_continuous(breaks = scales::breaks_width(width = 10))

# ---- maps ----
gg_oz_map <- ozmap_states |>
  filter(NAME %in% unique(toads_states$point_in_state)) |>
  ggplot() +
  geom_sf()

gg_oz_map

gg_toads_decade(gg_oz_map, toads_states)
gg_toads_west_path(gg_oz_map, toads_states, toads_west_front)

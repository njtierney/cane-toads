## ---------------------------------------------------------------------
#| label: packages
#| echo: false
#| include: false
library(tidyverse)
library(here)
library(arrow)
library(janitor)
library(visdat)
library(geodist)
library(ozmaps)
library(sf)


## ---------------------------------------------------------------------
#| label: data-read-in
qld_toads_raw <- read_parquet(
  file = here("data-raw/cane-toad-wildnet-to-2010.parquet")
)

nt_toads_raw <- read_parquet(
  file = here("data-raw/cane-toad-fauna-atlas-nt.parquet")
)

toads_raw <- bind_rows(
  "Queensland" = qld_toads_raw,
  "Northern Territory" = nt_toads_raw,
  .id = "state"
)

source("R/tidy_toads.R")
toads <- tidy_toads(toads_raw)

head(toads)
glimpse(toads)
range(toads$year)


## ---------------------------------------------------------------------
#| label: eda-vis
vis_dat(toads)
vis_miss(toads, facet = state)
vis_miss(toads)

library(naniar)
gg_miss_var(toads, facet = state)

range(toads$year)

toads |>
  count(year)

ggplot(toads, aes(x = year)) +
  geom_bar()

toads |>
  count(decade)

ggplot(toads, aes(x = decade)) +
  geom_bar()


## ---------------------------------------------------------------------
#| label: gg-pts
# let's look at maps
ggplot(toads, aes(x = lon, y = lat)) +
  geom_point()

gg_oz <- ggplot() +
  geom_sf(data = ozmap_states)

gg_oz

gg_oz +
  geom_point(
    data = toads,
    aes(x = lon, y = lat)
  )

## functions in terms of inputs and outputs
## inputs:
# toad data with lat/lon
# ozmap geospatial SF data
## outputs:
# toads data with state added based on spatial join

## imagine the function you want to create
## verb_noun
source("R/find_state.R")
toads_states <- find_state(toads = toads, map = ozmap_states)
toads_states

## ---------------------------------------------------------------------
#| label: gg-qld

oz_map <- ozmap_states |>
  filter(NAME %in% unique(toads_states$state))

gg_oz_map <- ggplot() + geom_sf(data = oz_map)

gg_oz_map

gg_oz_map +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.2
  )

## ---------------------------------------------------------------------
# per decade
gg_oz_map +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.2
  ) +
  facet_wrap(
    facets = vars(decade),
    nrow = 2
  )

## ---------------------------------------------------------------------
toads_west_front <- toads |>
  group_by(decade) |>
  # smallest lon == most west
  # filter(lon == min(lon))
  slice_min(
    lon,
    n = 1
  ) |>
  ungroup()

# let's explore the travel
# sense check this western front
gg_oz_map +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.2
  ) +
  geom_point(
    data = toads_west_front,
    aes(x = lon, y = lat),
    colour = "orange"
  ) +
  # connects the lines in order
  geom_path(
    data = toads_west_front,
    aes(x = lon, y = lat),
    colour = "orange"
  )


## ---------------------------------------------------------------------
# calculating distances
toads_west_front

west_mat <- cbind(lon = toads_west_front$lon, lat = toads_west_front$lat)

distances_m <- geodist(
  west_mat,
  sequential = TRUE,
  measure = "geodesic",
  pad = TRUE
)

# keeping the "western" movement fixes from the first point.
# toads_west_front |>
#   mutate(
#     lat_fixed = first(lat),
#     .before = lat
#   )

toad_distances <- toads_west_front |>
  mutate(
    distance_km = distances_m / 1000,
    .after = decade
  )

toad_distances

ggplot(toad_distances, aes(x = decade, y = distance_km)) +
  geom_col()


## ---------------------------------------------------------------------
dir.create("data/")
write_csv(
  x = toad_distances,
  file = here("data/toad-distances-2010.csv")
)

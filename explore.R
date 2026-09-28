library(tidyverse)
library(here)

library(arrow)
toads_raw <- read_parquet(
  file = here("data-raw/cane-toad-wildnet-to-1999.parquet")
)

toads_raw

View(toads_raw)

toads_raw |> names()

# janitor::excel_numeric_to_date()
# janitor::clean_names()

library(janitor)

toads <- toads_raw |>
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
    decade = floor(year / 10) * 10,
    .after = year
  )

toads

glimpse(toads)

library(visdat)

vis_dat(toads)
vis_miss(toads)

range(toads$year)
summary(toads)

View(toads)

toads |>
  count(year)

ggplot(toads, aes(x = year)) +
  geom_bar()

toads |>
  count(decade)

ggplot(toads, aes(x = decade)) +
  geom_bar()

# let's look at maps
toads

ggplot(toads, aes(x = lon, y = lat)) +
  geom_point()

library(ozmaps)
library(sf)
gg_oz <- ggplot() +
  geom_sf(data = ozmap_states)

gg_oz +
  geom_point(
    data = toads,
    aes(x = lon, y = lat)
  )
ozmap_states

qld <- ozmap_states |>
  filter(NAME == "Queensland")

gg_qld <- ggplot() + geom_sf(data = qld)

gg_qld +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.2
  )

# per decade
gg_qld +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.2
  ) +
  facet_wrap(
    facets = vars(decade),
    nrow = 2
  )

toads_west_front <- toads |>
  group_by(decade) |>
  # smallest lon == most west
  # filter(lon == min(lon))
  slice_min(
    lon,
    n = 1
  ) |>
  ungroup()

# sense check this western front
gg_qld +
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
  facet_wrap(
    facets = vars(decade),
    nrow = 2
  )

# let's explore the travel
# sense check this western front
gg_qld +
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

# calculating distances
library(geodist)

toads_west_front

west_mat <- cbind(lon = toads_west_front$lon, lat = toads_west_front$lat)

west_mat
geodist(west_mat)

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

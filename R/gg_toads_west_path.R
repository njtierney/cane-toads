# "Front" is the westernmost record in each decade, in orange
# `map` is a ggplot of the states.
gg_toads_west_path <- function(map, toads, toads_west) {
  map +
    geom_point(
      data = toads,
      aes(x = lon, y = lat),
      alpha = 0.2
    ) +
    geom_point(
      data = toads_west,
      aes(x = lon, y = lat),
      colour = "orange"
    ) +
    geom_path(
      data = toads_west,
      aes(x = lon, y = lat),
      colour = "orange"
    )
}

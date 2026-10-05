# Every record on a map, one panel per decade. `map` is a ggplot of the states.
gg_toads_decade <- function(map, toads) {
  map +
    geom_point(
      data = toads,
      aes(x = lon, y = lat),
      alpha = 0.2
    ) +
    facet_wrap(
      facets = vars(decade),
      nrow = 2
    )
}

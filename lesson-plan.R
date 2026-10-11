# goals for today
# Debugging - how to inspect and look around inside functions
# common problems with library() - conflicts!
# convert our existing script into targets!
# discuss the key features of the targets pipeline and how the functions
# sit in there, and what is different to a script.

## Your turn:
## Explore using debugonce() and browser() to
## explore functions
## add library(conflicted)

# ---- lesson notes ----

# explaining how the `+` in ggplot with tar_target creates issues
quote(find_state(toads, map = ozmap_states) |> tar_target())
ggplot(toads, aes(x = decade)) + geom_bar() |> tar_target()

quote(ggplot(toads, aes(x = decade)) + geom_bar() |> tar_target())

# expect:
tar_target(ggplot(toads, aes(x = decade)) + geom_bar())

## "lexical scoping"
my_add <- function(x) {
  x + y
}
my_add(1)
y <- 3
my_add(1)

## questions:
# - what is the benefit of lexical scoping?
# - Can we simplify tar_visnetwork()? Can you collapse things down somehow based on a "grouping"
# - Other
# - what is the benefit of lexical scoping?
# - In debug mode, is there a way to stop browser() kicking you out when there is an error shown with `n`? Like, can we have
# - How to set up a template of targets with tar_assign? Can we update {tflow}
# - How to specify tar_make(script = ...)

## Common problems in targets
## - Have you saved your file?
## - ggplot() + geom_point() |> tar_target()
## - removing usage of here() in targets to avoid the system file being specific to me
## - Is there a recommended way to debug a targets pipeline? Like, if there's just a regular error inside the pipeline because you aren't using targets properly, e.g.,

library(targets)
library(tarchetypes)
library(ggplot2)
tar_assign({
  ggplot(penguins, aes(bill_len, bill_dep)) +
    geom_point() |> tar_target()
})

## this doesn't actually tell you where the error happened in the pipeline?

## Thoughts for next lessons
## using tar_read()/tar_load()
## Using tar_quarto() with tar_load() inside, which logs dependencies approrpiately
## But the mechanism is still --> tar_make() to render report
## Just making one thing with tar_make()
## Using keyboard shortcuts to load targets under cursor
## Writing out data with targets (write_csv_path())
## Using tar_workspace(), tar_errored(), ter_meta(), debugonce(), browser()
## nested pipes and co
# group_by(filter(select(data)))
#
# data |>
#   select() |>
#   filter() |>
#   group_by()
#
# data_selected <- select(data, ...)
# data_selected <- filter(data_selected, ...)
# data_grouped_by <- group_by(data_selected)

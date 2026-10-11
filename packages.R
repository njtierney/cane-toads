# ---- packages ----
library(arrow)
library(fs)
library(geodist)
library(here)
library(janitor)
# library(MASS)
library(ozmaps)
library(sf)
library(targets)
# extension to targets - gives us tar_file(), and tar_assign()
library(tarchetypes)
library(tidyverse)
# explore glm.nb function

library(conflicted)
conflicts_prefer(
  dplyr::select,
  dplyr::filter
)

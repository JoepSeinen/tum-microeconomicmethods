# =============================================================================
# 00_setup.R  -  Microeconometric Methods for Big Data (TUM, WiSe 26/27)
# Run this ONCE (or whenever you add a new package). Every tutorial script
# then just calls  source("R/00_setup.R")  at the top.
# =============================================================================

# Packages used in the course so far -- add new ones here as tutorials need them
pkgs <- c(
  "wooldridge",  # textbook datasets (ceosal2, wage1, ...)
  "tidyverse"    # ggplot2, dplyr, readr, ...
)

options(repos = c(CRAN = "https://cloud.r-project.org"))  # fixed CRAN mirror, no prompt

# Install anything that's missing, then load everything
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))

# Global options
options(digits = 4, scipen = 999)  # 4 significant digits, no scientific notation
set.seed(42)                       # reproducible simulations (Monte Carlo!)

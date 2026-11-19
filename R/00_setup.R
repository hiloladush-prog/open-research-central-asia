# =============================================================================
# 00_setup.R — Project settings shared by every R script
# -----------------------------------------------------------------------------
# Purpose : Install/load packages, define folder paths, and set the country
#           list and indicator list used throughout the workflow.
# Usage   : You do not normally run this file on its own. Every other script
#           starts with  source("R/00_setup.R").
# Author  : Open Research Central Asia contributors
# Licence : MIT (see LICENSE)
# =============================================================================

# ---- 1. Packages ------------------------------------------------------------
# We keep the dependency list short so that students can install everything
# on a university lab computer in a few minutes.
#   WDI      : downloads World Development Indicators from the World Bank API
#   dplyr    : data manipulation (filter, mutate, group_by, ...)
#   tidyr    : reshaping data between long and wide formats
#   readr    : fast, predictable CSV reading and writing
#   ggplot2  : graphs
#   plm      : panel-data econometrics (fixed effects, random effects, tests)
#   lmtest   : coefficient tests with a custom variance matrix (coeftest)
#   sandwich : robust / clustered variance estimators
required_packages <- c("WDI", "dplyr", "tidyr", "readr", "ggplot2",
                       "plm", "lmtest", "sandwich")

# Install any package that is missing (runs only the first time).
missing_packages <- required_packages[!vapply(required_packages,
                                              requireNamespace,
                                              logical(1),
                                              quietly = TRUE)]
if (length(missing_packages) > 0) {
  message("Installing missing packages: ",
          paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

# Load all packages quietly.
invisible(lapply(required_packages, library, character.only = TRUE))

# ---- 2. Folder paths --------------------------------------------------------
# All paths are relative to the project root (the folder that contains
# README.md). Open the project in RStudio or setwd() to that folder first.
if (!file.exists("README.md")) {
  stop("Please set your working directory to the project root ",
       "(the folder that contains README.md) before running the scripts.")
}

paths <- list(
  raw       = file.path("data", "raw"),
  processed = file.path("data", "processed"),
  figures   = file.path("output", "figures"),
  tables    = file.path("output", "tables")
)
# Create the folders if they do not exist yet (e.g. after a fresh clone).
invisible(lapply(paths, dir.create, recursive = TRUE, showWarnings = FALSE))

# ---- 3. Countries -----------------------------------------------------------
# Core sample: the five Central Asian republics (ISO 2-letter codes).
central_asia <- c(
  KZ = "Kazakhstan",
  KG = "Kyrgyz Republic",
  TJ = "Tajikistan",
  TM = "Turkmenistan",
  UZ = "Uzbekistan"
)

# Comparison group: other post-Soviet / neighbouring economies.
# WHY: with only five countries, panel regressions have very few clusters and
# standard errors become unreliable. Adding comparable economies gives the
# models more information and lets us ask whether Central Asia is different.
comparison <- c(
  AM = "Armenia",
  AZ = "Azerbaijan",
  BY = "Belarus",
  GE = "Georgia",
  MD = "Moldova",
  MN = "Mongolia",
  RU = "Russian Federation",
  UA = "Ukraine"
)

countries <- c(central_asia, comparison)

# ---- 4. Time period ---------------------------------------------------------
# 2000 onwards avoids the most turbulent early-transition years, when data
# for several countries are missing or unreliable.
start_year <- 2000
end_year   <- 2024

# ---- 5. Indicators ----------------------------------------------------------
# Names on the left become the variable names in our data set; codes on the
# right are the official WDI series codes (searchable at
# https://data.worldbank.org/indicator).
indicators <- c(
  gdp_pc        = "NY.GDP.PCAP.KD",       # GDP per capita, constant US$
  gdp_pc_growth = "NY.GDP.PCAP.KD.ZG",    # GDP per capita growth, annual %
  remit_gdp     = "BX.TRF.PWKR.DT.GD.ZS", # Personal remittances received, % GDP
  trade_gdp     = "NE.TRD.GNFS.ZS",       # Trade (exports + imports), % GDP
  inflation     = "FP.CPI.TOTL.ZG",       # Inflation, consumer prices, annual %
  hh_cons_pc    = "NE.CON.PRVT.PC.KD",    # Household consumption per capita, constant US$
  unemployment  = "SL.UEM.TOTL.ZS",       # Unemployment, % labour force (ILO modelled)
  population    = "SP.POP.TOTL"           # Population, total
)

# ---- 6. Reproducibility -----------------------------------------------------
# Fix the random seed so anything that involves randomness (e.g. simulated
# teaching data, bootstraps) gives the same answer every time.
set.seed(20261119)

message("Setup complete: ", length(countries), " countries, ",
        length(indicators), " indicators, ", start_year, "-", end_year, ".")

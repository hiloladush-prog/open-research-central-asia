# =============================================================================
# 01_download_wdi.R — Download World Development Indicators
# -----------------------------------------------------------------------------
# Input  : nothing (data come from the World Bank API; internet required)
# Output : data/raw/wdi_raw.csv   — data exactly as downloaded
#          data/raw/wdi_download_log.txt — when and what was downloaded
#
# Why keep a "raw" copy?
#   The World Bank revises its data several times a year. Saving the exact file
#   you downloaded (plus the date) means you — or a referee — can reproduce
#   your results later, even after the online numbers change.
#
# No internet? Run R/utils/simulate_panel.R instead. It writes a simulated
# file with the same structure so you can still practise every later step.
# -----------------------------------------------------------------------------
# Copyright (c) 2026 Khilola Ruziboeva
# Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
#            and non-commercial research; commercial use needs permission.
# Citation : see CITATION.cff
# =============================================================================

source("R/00_setup.R")

# ---- 1. Download ------------------------------------------------------------
# WDI() takes:
#   country   : ISO-2 codes (names(countries) gives "KZ", "KG", ...)
#   indicator : a NAMED vector, so columns arrive with our short names
#   start/end : years
#   extra     : TRUE adds region, income group, capital, lat/long, etc.
message("Downloading ", length(indicators), " indicators for ",
        length(countries), " countries from the World Bank ...")

wdi_raw <- tryCatch(
  WDI(country   = names(countries),
      indicator = indicators,
      start     = start_year,
      end       = end_year,
      extra     = TRUE),
  error = function(e) {
    stop("Download failed: ", conditionMessage(e),
         "\nCheck your internet connection, or run ",
         "R/utils/simulate_panel.R to practise with simulated data.")
  }
)

# ---- 2. Quick sanity checks -------------------------------------------------
# Always look at what you downloaded before using it.
stopifnot(nrow(wdi_raw) > 0)
message("Rows downloaded: ", nrow(wdi_raw))
message("Countries found: ", paste(sort(unique(wdi_raw$iso2c)), collapse = ", "))

# Share of missing values per indicator — Turkmenistan in particular has many
# gaps in WDI, which matters for what we can conclude about it.
missing_share <- sapply(wdi_raw[names(indicators)], function(x) mean(is.na(x)))
print(round(missing_share, 2))

# ---- 3. Save ----------------------------------------------------------------
out_file <- file.path(paths$raw, "wdi_raw.csv")
write_csv(wdi_raw, out_file)

# A small log file documents the download for reproducibility.
writeLines(c(
  paste("Downloaded on:", format(Sys.time(), "%Y-%m-%d %H:%M %Z")),
  paste("WDI package version:", as.character(packageVersion("WDI"))),
  paste("Countries:", paste(names(countries), collapse = ", ")),
  paste("Years:", start_year, "-", end_year),
  "Indicators:",
  paste0("  ", names(indicators), " = ", indicators)
), file.path(paths$raw, "wdi_download_log.txt"))

message("Saved: ", out_file)

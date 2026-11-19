# =============================================================================
# 02_clean_panel.R — Turn the raw download into an analysis-ready panel
# -----------------------------------------------------------------------------
# Input  : data/raw/wdi_raw.csv
# Output : data/processed/panel_central_asia.csv
#          data/processed/panel_central_asia.rds  (keeps R data types)
#
# Golden rule: never edit raw data by hand. Every change happens here, in
# code, so it is documented and can be repeated.
# -----------------------------------------------------------------------------
# Copyright (c) 2026 Khilola Ruziboeva
# Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
#            and non-commercial research; commercial use needs permission.
# Citation : see CITATION.cff
# =============================================================================

source("R/00_setup.R")

raw <- read_csv(file.path(paths$raw, "wdi_raw.csv"), show_col_types = FALSE)

# ---- 1. Keep only the columns we need --------------------------------------
panel <- raw |>
  select(iso2c, country, year, all_of(names(indicators))) |>
  # Sort by country then year — panel commands expect this order.
  arrange(iso2c, year)

# ---- 2. Check the panel structure ------------------------------------------
# Each country-year must appear exactly once. Duplicates would silently
# double-count observations in a regression.
dups <- panel |> count(iso2c, year) |> filter(n > 1)
if (nrow(dups) > 0) stop("Duplicate country-year rows found:\n",
                         paste(capture.output(print(dups)), collapse = "\n"))

# ---- 3. Create new variables -----------------------------------------------
panel <- panel |>
  mutate(
    # Group indicator: 1 for the five Central Asian republics, 0 otherwise.
    central_asia = as.integer(iso2c %in% names(central_asia)),

    # Logs: we use log GDP per capita because income is right-skewed and
    # differences in logs approximate percentage differences.
    log_gdp_pc   = log(gdp_pc),
    log_pop      = log(population),

    # Period dummies that matter for the region:
    #   2009 — global financial crisis (remittances from Russia fell sharply)
    #   2014-15 — oil-price collapse and rouble depreciation
    #   2020 — COVID-19
    gfc_2009     = as.integer(year == 2009),
    rouble_14_15 = as.integer(year %in% 2014:2015),
    covid_2020   = as.integer(year == 2020)
  ) |>
  # Lagged remittances (previous year) — a common first step to reduce, not
  # eliminate, reverse-causality worries. Lag WITHIN each country only.
  group_by(iso2c) |>
  mutate(remit_gdp_lag1 = dplyr::lag(remit_gdp, n = 1, order_by = year)) |>
  ungroup()

# ---- 4. Report missing data -------------------------------------------------
# Students often skip this step. Missing data decide which countries actually
# enter your regression — always report it.
missing_by_country <- panel |>
  group_by(country) |>
  summarise(across(all_of(names(indicators)), ~ round(mean(is.na(.x)), 2)),
            .groups = "drop")
write_csv(missing_by_country, file.path(paths$tables, "missing_by_country.csv"))
print(missing_by_country, n = Inf, width = Inf)

# ---- 5. Save ----------------------------------------------------------------
write_csv(panel, file.path(paths$processed, "panel_central_asia.csv"))
saveRDS(panel, file.path(paths$processed, "panel_central_asia.rds"))

message("Clean panel saved: ", nrow(panel), " rows, ",
        n_distinct(panel$iso2c), " countries.")

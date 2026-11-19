# =============================================================================
# simulate_panel.R — Create a SIMULATED data set with the WDI structure
# -----------------------------------------------------------------------------
# Output : data/raw/wdi_raw.csv  (overwrites any real download!)
#
# When to use this
#   * Teaching in a lab without reliable internet.
#   * Testing that the workflow runs end to end.
#   * Exercises where students should recover a KNOWN true effect.
#
# The numbers are NOT real. The true effect of remittances on GDP per capita
# growth is set below (true_beta_remit), so students can check whether the
# fixed-effects estimator recovers it and the pooled OLS estimator does not.
# =============================================================================

source("R/00_setup.R")

true_beta_remit <- 0.15   # each +1 p.p. of remittances/GDP adds 0.15 p.p. growth

years <- start_year:end_year
panel <- expand.grid(iso2c = names(countries), year = years,
                     stringsAsFactors = FALSE)
panel$country <- unname(countries[panel$iso2c])
panel$iso3c   <- NA_character_            # not needed for the exercise
panel$region  <- ifelse(panel$iso2c %in% names(central_asia),
                        "Central Asia (simulated)", "Comparison (simulated)")

n_c <- length(countries)

# Country-specific characteristics that do not change over time.
# They are correlated with remittances on purpose: this creates omitted-
# variable bias in pooled OLS that fixed effects removes.
country_effect <- setNames(rnorm(n_c, 0, 2), names(countries))
remit_level    <- setNames(pmax(0, 8 - 2 * country_effect + rnorm(n_c, 0, 3)),
                           names(countries))

# Common shocks hitting every country in the same year (e.g. 2009, 2020).
year_shock <- setNames(rnorm(length(years), 0, 1.5), years)
year_shock[c("2009", "2020")] <- c(-6, -4)

ce <- country_effect[panel$iso2c]
ys <- year_shock[as.character(panel$year)]

panel$remit_gdp     <- pmax(0, remit_level[panel$iso2c] + rnorm(nrow(panel), 0, 3))
panel$trade_gdp     <- pmax(10, 80 + 10 * ce + rnorm(nrow(panel), 0, 8))
panel$inflation     <- pmax(-2, 8 + rnorm(nrow(panel), 0, 4))
panel$unemployment  <- pmax(1, 7 + rnorm(nrow(panel), 0, 2))
panel$population    <- round(exp(15 + abs(ce) + rnorm(nrow(panel), 0, 0.05)))

panel$gdp_pc_growth <- 3 + ce + ys +
  true_beta_remit * panel$remit_gdp +
  0.02 * panel$trade_gdp -
  0.05 * panel$inflation +
  rnorm(nrow(panel), 0, 1)

# Build GDP per capita levels from the growth rates.
panel <- panel[order(panel$iso2c, panel$year), ]
panel$gdp_pc <- ave(panel$gdp_pc_growth, panel$iso2c, FUN = function(g) {
  3000 * cumprod(1 + g / 100)
})
panel$hh_cons_pc <- 0.6 * panel$gdp_pc * exp(rnorm(nrow(panel), 0, 0.03))

# Mimic real data: Turkmenistan has many missing values in WDI.
tm_rows <- panel$iso2c == "TM"
panel$remit_gdp[tm_rows]    <- NA
panel$unemployment[tm_rows & panel$year < 2010] <- NA

write_csv(panel, file.path(paths$raw, "wdi_raw.csv"))
writeLines(c("SIMULATED DATA — not real WDI values.",
             paste("Created:", format(Sys.time(), "%Y-%m-%d %H:%M %Z")),
             paste("True remittance effect:", true_beta_remit)),
           file.path(paths$raw, "wdi_download_log.txt"))

message("Simulated panel written to data/raw/wdi_raw.csv (true beta = ",
        true_beta_remit, ").")

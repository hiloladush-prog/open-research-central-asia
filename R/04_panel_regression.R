# =============================================================================
# 04_panel_regression.R — Do remittances help growth? A panel-data example
# -----------------------------------------------------------------------------
# Input  : data/processed/panel_central_asia.rds
# Output : output/tables/regression_results.csv   (tidy, one row per coef)
#          output/tables/regression_table.txt     (formatted, paper style)
#          output/tables/hausman_test.txt
#
# Research question
#   Is a higher remittance share of GDP associated with faster GDP per capita
#   growth, once we control for fixed differences between countries and for
#   shocks common to all countries in a given year?
#
# Model ladder (each step fixes a problem with the one before)
#   (1) Pooled OLS            — ignores that countries differ permanently
#   (2) Country fixed effects — removes time-invariant country differences
#   (3) Two-way fixed effects — also removes common year shocks (2009, 2020)
#   (4) TWFE, lagged remittances — reduces same-year reverse causality
#   (5) TWFE + interaction    — is the association different in Central Asia?
#
# IMPORTANT for interpretation
#   These are associations, not causal effects. Remittances respond to growth
#   at home and in Russia, so reverse causality and omitted variables remain.
#   Causal designs (instruments such as host-country shocks, or difference-in-
#   differences around policy changes) are a natural next step.
# -----------------------------------------------------------------------------
# Copyright (c) 2026 Khilola Ruziboeva
# Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
#            and non-commercial research; commercial use needs permission.
# Citation : see CITATION.cff
# =============================================================================

source("R/00_setup.R")

panel <- readRDS(file.path(paths$processed, "panel_central_asia.rds"))

# Turn the data frame into a panel object: plm needs to know which column is
# the individual (country) and which is time (year).
pdata <- pdata.frame(as.data.frame(panel), index = c("iso2c", "year"))

# ---- 1. Estimate the models -------------------------------------------------
controls <- "trade_gdp + inflation"

f_main <- as.formula(paste("gdp_pc_growth ~ remit_gdp +", controls))
f_lag  <- as.formula(paste("gdp_pc_growth ~ remit_gdp_lag1 +", controls))
f_int  <- as.formula(paste("gdp_pc_growth ~ remit_gdp + remit_gdp:central_asia +",
                           controls))

models <- list(
  "(1) Pooled OLS"    = plm(f_main, data = pdata, model = "pooling"),
  "(2) Country FE"    = plm(f_main, data = pdata, model = "within",
                            effect = "individual"),
  "(3) Two-way FE"    = plm(f_main, data = pdata, model = "within",
                            effect = "twoways"),
  "(4) TWFE, lag"     = plm(f_lag,  data = pdata, model = "within",
                            effect = "twoways"),
  "(5) TWFE, CA int." = plm(f_int,  data = pdata, model = "within",
                            effect = "twoways")
)
# Note on model (5): central_asia itself does not change over time, so it is
# absorbed by the country fixed effects. Only its interaction with
# remittances can be estimated.

# ---- 2. Standard errors -----------------------------------------------------
# Observations from the same country are correlated over time, so default
# (i.i.d.) standard errors are too small. Two options:
#
#   * Clustered by country (vcovHC, cluster = "group"): standard choice, but
#     unreliable with few clusters (we have ~13). Treat p-values with care.
#   * Driscoll-Kraay (vcovSCC): robust to serial AND cross-country correlation
#     (e.g. a Russian recession hitting all remittance receivers at once).
#     Designed for macro panels where T is reasonably large relative to N.
#
# We report Driscoll-Kraay in the main table and save clustered SEs as well.
se_dk <- function(m) vcovSCC(m, type = "HC1", maxlag = 2)
se_cl <- function(m) vcovHC(m, method = "arellano", type = "HC1",
                            cluster = "group")

tidy_model <- function(model, name, vcov_fun, se_label) {
  ct <- coeftest(model, vcov. = vcov_fun(model))
  data.frame(
    model     = name,
    se_type   = se_label,
    term      = rownames(ct),
    estimate  = ct[, 1],
    std_error = ct[, 2],
    p_value   = ct[, 4],
    row.names = NULL
  )
}

results <- do.call(rbind, c(
  Map(tidy_model, models, names(models),
      MoreArgs = list(vcov_fun = se_dk, se_label = "Driscoll-Kraay")),
  Map(tidy_model, models, names(models),
      MoreArgs = list(vcov_fun = se_cl, se_label = "Clustered by country"))
))
write_csv(results, file.path(paths$tables, "regression_results.csv"))

# ---- 3. A paper-style regression table --------------------------------------
# Coefficients with stars on one line, standard errors in brackets below.
stars <- function(p) ifelse(p < 0.01, "***", ifelse(p < 0.05, "**",
                                                    ifelse(p < 0.10, "*", "")))

make_table <- function(res, models) {
  res   <- res[res$se_type == "Driscoll-Kraay", ]
  terms <- unique(res$term)
  cells <- sapply(names(models), function(mn) {
    unlist(lapply(terms, function(tm) {
      r <- res[res$model == mn & res$term == tm, ]
      if (nrow(r) == 0) return(c("", ""))
      c(sprintf("%.3f%s", r$estimate, stars(r$p_value)),
        sprintf("(%.3f)", r$std_error))
    }))
  })
  row_names <- as.vector(rbind(terms, ""))
  # Footer rows: sample size, R-squared, which fixed effects are included.
  footer <- rbind(
    "Observations" = sapply(models, function(m) nobs(m)),
    "Countries"    = sapply(models, function(m) pdim(m)$nT$n),
    "R-squared"    = sapply(models, function(m) sprintf("%.3f", summary(m)$r.squared["rsq"])),
    "Country FE"   = c("No", "Yes", "Yes", "Yes", "Yes"),
    "Year FE"      = c("No", "No", "Yes", "Yes", "Yes")
  )
  out <- rbind(cells, footer)
  rownames(out) <- c(row_names, rownames(footer))
  out
}

reg_table <- make_table(results, models)

sink(file.path(paths$tables, "regression_table.txt"))
cat("Dependent variable: GDP per capita growth (annual %)\n\n")
print(noquote(reg_table))
cat("\nDriscoll-Kraay standard errors in parentheses.",
    "\n*** p<0.01, ** p<0.05, * p<0.1",
    "\nR-squared for FE models is the within R-squared.\n")
sink()

print(noquote(reg_table))

# ---- 4. Fixed or random effects? Hausman test -------------------------------
# H0: random effects is consistent (country effects uncorrelated with the
#     regressors). Rejecting H0 favours fixed effects.
re_model <- plm(f_main, data = pdata, model = "random")
hausman  <- phtest(models[["(2) Country FE"]], re_model)
capture.output(print(hausman),
               file = file.path(paths$tables, "hausman_test.txt"))
print(hausman)

message("Regression outputs saved to output/tables/.")

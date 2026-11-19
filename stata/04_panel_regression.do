* =============================================================================
* 04_panel_regression.do — Do remittances help growth? A panel-data example
* -----------------------------------------------------------------------------
* Input  : data/processed/panel_central_asia.dta
* Output : output/tables/regression_table_stata.rtf  (opens in Word)
*          output/tables/regression_table_stata.csv
* Mirrors: R/04_panel_regression.R  (same five models)
*
* Model ladder (each step fixes a problem with the one before)
*   (1) Pooled OLS               — ignores permanent country differences
*   (2) Country fixed effects    — removes time-invariant differences
*   (3) Two-way fixed effects    — also removes common year shocks
*   (4) TWFE, lagged remittances — reduces same-year reverse causality
*   (5) TWFE + interaction       — is the association different in Central Asia?
*
* These are associations, not causal effects (reverse causality and omitted
* variables remain). See the README for ideas on causal designs.
* -----------------------------------------------------------------------------
* Copyright (c) 2026 Khilola Ruziboeva
* Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
*            and non-commercial research; commercial use needs permission.
* Citation : see CITATION.cff
* =============================================================================

do "stata/00_setup.do"
use "$processed/panel_central_asia.dta", clear
xtset country_id year

local controls trade_gdp inflation

* Year dummies and the interaction are built by hand rather than with factor
* variables (i.year, c.x#i.z) because older versions of xtscc do not accept
* factor-variable notation. yr_1 (the first year) is the omitted base.
capture drop yr_*
quietly tab year, gen(yr_)
drop yr_1
gen remit_x_ca = remit_gdp * central_asia
label var remit_x_ca "Remittances x Central Asia"

eststo clear

* ---- 1. The models ---------------------------------------------------------
* Standard errors: we use Driscoll-Kraay (xtscc), robust to serial
* correlation within countries AND correlation across countries in the same
* year (e.g. a Russian recession hits all remittance receivers at once).
* lag(2) allows correlation up to two years apart.
*
* Why not just vce(cluster country_id)? Clustering is standard, but with only
* ~13 countries the cluster-robust p-values are unreliable. The clustered
* versions are shown in section 3 for comparison.

* (1) Pooled OLS
eststo m1: xtscc gdp_pc_growth remit_gdp `controls', lag(2)

* (2) Country fixed effects
eststo m2: xtscc gdp_pc_growth remit_gdp `controls', fe lag(2)

* (3) Two-way fixed effects: yr_* adds a dummy for every year
eststo m3: xtscc gdp_pc_growth remit_gdp `controls' yr_*, fe lag(2)

* (4) Lagged remittances
eststo m4: xtscc gdp_pc_growth remit_gdp_lag1 `controls' yr_*, fe lag(2)

* (5) Interaction with Central Asia. The main effect of central_asia is
*     absorbed by the country FE; only the interaction is identified.
*     remit_x_ca is the extra slope for Central Asian countries.
eststo m5: xtscc gdp_pc_growth remit_gdp remit_x_ca `controls' yr_*, fe lag(2)

* ---- 2. Publication-style table --------------------------------------------
* keep() hides the year dummies; indicate() adds a "Year FE: Yes/No" row.
* Note: esttab reads the fixed-effects choice from the model, so the country
* FE are described in the column titles.
local tabopts b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) label ///
    keep(remit_gdp remit_gdp_lag1 remit_x_ca trade_gdp inflation) ///
    indicate("Year FE = yr_*") ///
    mtitles("Pooled OLS" "Country FE" "Two-way FE" "TWFE, lag" "TWFE, CA int.") ///
    stats(N, labels("Observations")) ///
    addnotes("Driscoll-Kraay standard errors in parentheses.")

esttab m1 m2 m3 m4 m5, `tabopts'
esttab m1 m2 m3 m4 m5 using "$tables/regression_table_stata.rtf", replace `tabopts'
esttab m1 m2 m3 m4 m5 using "$tables/regression_table_stata.csv", replace `tabopts'

* ---- 3. Robustness: clustered standard errors ------------------------------
xtreg gdp_pc_growth remit_gdp `controls' yr_*, fe vce(cluster country_id)
* With few clusters, a wild cluster bootstrap gives more reliable p-values:
*   ssc install boottest
*   boottest remit_gdp, reps(9999)

* ---- 4. Fixed or random effects? Hausman test ------------------------------
* The Hausman test needs the default (non-robust) standard errors.
* H0: random effects is consistent. Rejecting H0 favours fixed effects.
quietly xtreg gdp_pc_growth remit_gdp `controls', fe
estimates store fe
quietly xtreg gdp_pc_growth remit_gdp `controls', re
estimates store re
hausman fe re

display as result "Regressions done. Tables in $tables/."

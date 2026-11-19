* =============================================================================
* 03_descriptives.do — Summary statistics and figures
* -----------------------------------------------------------------------------
* Input  : data/processed/panel_central_asia.dta
* Output : output/tables/summary_statistics_stata.csv
*          output/figures/remittances_over_time_stata.png
*          output/figures/remittances_vs_growth_stata.png
* Mirrors: R/03_descriptives.R
* -----------------------------------------------------------------------------
* Copyright (c) 2026 Khilola Ruziboeva
* Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
*            and non-commercial research; commercial use needs permission.
* Citation : see CITATION.cff
* =============================================================================

do "stata/00_setup.do"
use "$processed/panel_central_asia.dta", clear

local vars gdp_pc gdp_pc_growth remit_gdp trade_gdp inflation hh_cons_pc unemployment

* ---- 1. Summary statistics ("Table 1") -------------------------------------
summarize `vars'

* Export N, mean, SD, min, max with esttab (from the estout package).
estpost summarize `vars'
esttab using "$tables/summary_statistics_stata.csv", replace ///
    cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    label nonumber noobs

* Means for Central Asia vs comparison countries.
tabstat `vars', by(central_asia) statistics(mean) format(%9.2f)

* Panel-specific summary: splits each variable's variation into BETWEEN
* countries and WITHIN countries over time. Fixed-effects models use only
* the within part — if it is small, FE estimates will be imprecise.
xtsum gdp_pc_growth remit_gdp trade_gdp inflation

* ---- 2. Figures ------------------------------------------------------------
* Remittances over time, Central Asia only, one line per country.
xtline remit_gdp if central_asia == 1, overlay ///
    title("Personal remittances received, % of GDP") ///
    ytitle("% of GDP") xtitle("") ///
    note("Source: World Bank, World Development Indicators.") ///
    legend(rows(1) size(small))
graph export "$figures/remittances_over_time_stata.png", replace width(2400)

* Scatter with a pooled OLS line — for illustration, NOT a causal estimate.
twoway (scatter gdp_pc_growth remit_gdp if central_asia == 0, msize(small)) ///
       (scatter gdp_pc_growth remit_gdp if central_asia == 1, msize(small)) ///
       (lfit gdp_pc_growth remit_gdp, lpattern(dash) lcolor(gs6)), ///
    title("Remittances and GDP per capita growth") ///
    xtitle("Remittances, % of GDP") ytitle("GDP per capita growth, %") ///
    legend(order(1 "Comparison" 2 "Central Asia" 3 "Pooled OLS fit") rows(1)) ///
    note("Each point is one country-year.")
graph export "$figures/remittances_vs_growth_stata.png", replace width(2400)

display as result "Descriptives done."

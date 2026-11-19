* =============================================================================
* 02_clean_panel.do — Turn the raw download into an analysis-ready panel
* -----------------------------------------------------------------------------
* Input  : data/raw/wdi_raw_stata.dta
*          (or data/raw/wdi_raw.csv produced by the R scripts — see below)
* Output : data/processed/panel_central_asia.dta
* Mirrors: R/02_clean_panel.R
*
* Golden rule: never edit raw data by hand; every change happens in code.
* -----------------------------------------------------------------------------
* Copyright (c) 2026 Khilola Ruziboeva
* Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
*            and non-commercial research; commercial use needs permission.
* Citation : see CITATION.cff
* =============================================================================

do "stata/00_setup.do"

* ---- 1. Load data ----------------------------------------------------------
* Option A (default): the Stata download from 01_download_wdi.do.
* Option B: the CSV created in R (real or simulated). Useful if your Stata
*           cannot reach the internet. Set the local below to "csv".
local source "dta"

if "`source'" == "dta" {
    use "$raw/wdi_raw_stata.dta", clear

    * Rename WDI codes to short, readable names (same names as in R).
    rename ny_gdp_pcap_kd       gdp_pc
    rename ny_gdp_pcap_kd_zg    gdp_pc_growth
    rename bx_trf_pwkr_dt_gd_zs remit_gdp
    rename ne_trd_gnfs_zs       trade_gdp
    rename fp_cpi_totl_zg       inflation
    rename ne_con_prvt_pc_kd    hh_cons_pc
    rename sl_uem_totl_zs       unemployment
    rename sp_pop_totl          population
    rename countrycode          iso3c
    rename countryname          country
}
else {
    import delimited "$raw/wdi_raw.csv", clear varnames(1) case(preserve)
    * The R file uses ISO-2 codes; we keep them as the country identifier.
    rename iso2c iso3c
    * R writes missing values as "NA", which Stata reads as text. destring
    * with force turns "NA" into Stata missing values (.).
    destring gdp_pc gdp_pc_growth remit_gdp trade_gdp inflation ///
        hh_cons_pc unemployment population, replace force
}

keep iso3c country year gdp_pc gdp_pc_growth remit_gdp trade_gdp ///
     inflation hh_cons_pc unemployment population

* ---- 2. Check the panel structure ------------------------------------------
* Each country-year must appear exactly once.
duplicates report iso3c year
isid iso3c year          // stops with an error if there are duplicates

* ---- 3. Panel identifiers --------------------------------------------------
* xtset needs a NUMERIC country identifier; encode creates one with labels.
encode iso3c, gen(country_id)
xtset country_id year

* ---- 4. New variables ------------------------------------------------------
gen central_asia = inlist(iso3c, "KAZ", "KGZ", "TJK", "TKM", "UZB") | ///
                   inlist(iso3c, "KZ", "KG", "TJ", "TM", "UZ")
label var central_asia "Central Asian republic (1/0)"

gen log_gdp_pc = ln(gdp_pc)
gen log_pop    = ln(population)

* Shocks that matter for the region.
gen gfc_2009     = year == 2009
gen rouble_14_15 = inrange(year, 2014, 2015)
gen covid_2020   = year == 2020

* Lagged remittances. L. uses the panel structure set by xtset, so the lag
* never crosses from one country to another.
gen remit_gdp_lag1 = L.remit_gdp

* ---- 5. Labels (they appear in tables and graphs) --------------------------
label var gdp_pc         "GDP per capita (constant US$)"
label var gdp_pc_growth  "GDP per capita growth (%)"
label var remit_gdp      "Remittances (% GDP)"
label var remit_gdp_lag1 "Remittances, t-1 (% GDP)"
label var trade_gdp      "Trade (% GDP)"
label var inflation      "Inflation, CPI (%)"
label var hh_cons_pc     "Household consumption per capita (constant US$)"
label var unemployment   "Unemployment (% labour force)"
label var population     "Population"

* ---- 6. Missing data report ------------------------------------------------
* Missing data decide which countries enter your regression. Report them.
misstable summarize gdp_pc_growth remit_gdp trade_gdp inflation unemployment
tabstat remit_gdp unemployment, by(country) statistics(n) nototal

* ---- 7. Save ---------------------------------------------------------------
compress
save "$processed/panel_central_asia.dta", replace
display as result "Clean panel saved."

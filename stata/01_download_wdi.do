* =============================================================================
* 01_download_wdi.do — Download World Development Indicators
* -----------------------------------------------------------------------------
* Input  : nothing (World Bank API; internet required)
* Output : data/raw/wdi_raw_stata.dta
* Mirrors: R/01_download_wdi.R
*
* Why keep a raw copy? The World Bank revises its data several times a year.
* Saving the exact file you downloaded, with the date, lets anyone reproduce
* your results later.
* -----------------------------------------------------------------------------
* Copyright (c) 2026 Khilola Ruziboeva
* Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
*            and non-commercial research; commercial use needs permission.
* Citation : see CITATION.cff
* =============================================================================

do "stata/00_setup.do"

* ---- 1. Download -----------------------------------------------------------
* Options:
*   indicator() : WDI codes separated by ;
*   country()   : ISO-3 codes separated by ;
*   year()      : start:end
*   long        : one row per country-year (panel format) instead of
*                 one column per year
*   clear       : replace data in memory
wbopendata, indicator("$indicators") country("$countries") ///
    year($start_year:$end_year) long clear

* ---- 2. Sanity checks ------------------------------------------------------
* Always look at what you downloaded.
describe, short
tab countrycode
misstable summarize ny_* bx_* ne_* fp_* sl_* sp_*

* ---- 3. Save with a note recording the download date -----------------------
notes: Downloaded from World Bank WDI on `c(current_date)' `c(current_time)'
compress
save "$raw/wdi_raw_stata.dta", replace

display as result "Saved $raw/wdi_raw_stata.dta"

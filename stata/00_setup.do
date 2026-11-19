* =============================================================================
* 00_setup.do — Project settings shared by every Stata do-file
* -----------------------------------------------------------------------------
* Purpose : Install user-written commands, set folder paths, define the
*           country list and indicator list.
* Usage   : Called automatically by every other do-file. Change the working
*           directory to the project root (the folder with README.md) first:
*               cd "C:/Users/you/Documents/open-research-central-asia"
* Mirrors : R/00_setup.R  (same countries, years and indicators)
* =============================================================================

version 16
clear all
set more off

* ---- 1. Check working directory --------------------------------------------
capture confirm file "README.md"
if _rc {
    display as error "Please cd to the project root (the folder with README.md)."
    exit 601
}

* ---- 2. User-written commands (installed once from SSC) -------------------
*   wbopendata : downloads World Development Indicators from the World Bank
*   xtscc      : Driscoll-Kraay standard errors for panel regressions
*   estout     : esttab, for publication-style regression tables
foreach pkg in wbopendata xtscc estout {
    capture which `pkg'
    if _rc {
        display as text "Installing `pkg' from SSC ..."
        ssc install `pkg', replace
    }
}

* ---- 3. Folder paths -------------------------------------------------------
global raw       "data/raw"
global processed "data/processed"
global figures   "output/figures"
global tables    "output/tables"

foreach d in data data/raw data/processed output output/figures output/tables {
    capture mkdir "`d'"
}

* ---- 4. Countries (ISO 3-letter codes, separated by ;) ---------------------
* Core sample: the five Central Asian republics.
global central_asia "KAZ;KGZ;TJK;TKM;UZB"
* Comparison group: other post-Soviet / neighbouring economies. With only five
* countries, standard errors are unreliable, so we add comparable economies.
global comparison   "ARM;AZE;BLR;GEO;MDA;MNG;RUS;UKR"
global countries    "$central_asia;$comparison"

* ---- 5. Time period --------------------------------------------------------
global start_year 2000
global end_year   2024

* ---- 6. Indicators (WDI series codes) --------------------------------------
* wbopendata turns each code into a variable name: dots become underscores
* and letters become lower case, e.g. NY.GDP.PCAP.KD -> ny_gdp_pcap_kd.
* We rename them to short names in 02_clean_panel.do.
global indicators "NY.GDP.PCAP.KD;NY.GDP.PCAP.KD.ZG;BX.TRF.PWKR.DT.GD.ZS;NE.TRD.GNFS.ZS;FP.CPI.TOTL.ZG;NE.CON.PRVT.PC.KD;SL.UEM.TOTL.ZS;SP.POP.TOTL"

* ---- 7. Reproducibility ----------------------------------------------------
set seed 20261119

display as result "Setup complete."

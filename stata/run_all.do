* =============================================================================
* run_all.do — Run the whole Stata workflow from start to finish
* -----------------------------------------------------------------------------
* Usage: in Stata,
*     cd "path/to/open-research-central-asia"
*     do stata/run_all.do
*
* Offline? Run the R simulation (Rscript R/utils/simulate_panel.R), set
* local source "csv" in 02_clean_panel.do, and skip step 01 below.
* =============================================================================

capture log close
log using "output/run_all_stata.log", replace text

do "stata/01_download_wdi.do"
do "stata/02_clean_panel.do"
do "stata/03_descriptives.do"
do "stata/04_panel_regression.do"

log close
display as result "All steps finished. See output/tables and output/figures."

# =============================================================================
# run_all.R — Run the whole R workflow from start to finish
# -----------------------------------------------------------------------------
# Usage (from the project root):
#   Rscript R/run_all.R            # downloads real WDI data (needs internet)
#   Rscript R/run_all.R simulate   # uses simulated data instead (offline)
#
# Running everything from one file is what makes a project reproducible:
# anyone can get from raw data to final tables with a single command.
# =============================================================================

args <- commandArgs(trailingOnly = TRUE)
use_simulated <- length(args) > 0 && args[1] == "simulate"

steps <- c(
  if (use_simulated) "R/utils/simulate_panel.R" else "R/01_download_wdi.R",
  "R/02_clean_panel.R",
  "R/03_descriptives.R",
  "R/04_panel_regression.R"
)

for (s in steps) {
  message("\n==== Running ", s, " ====")
  # local = new.env() keeps each script's objects separate, so a script
  # cannot accidentally depend on something left over from an earlier one.
  source(s, local = new.env())
}

message("\nAll steps finished. See output/tables and output/figures.")

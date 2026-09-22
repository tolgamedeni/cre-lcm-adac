#!/usr/bin/env Rscript
# =============================================================================
# run_all.R -- reproduce every result, figure and table from one command:
#   Rscript run_all.R            # everything (grid takes hours; resumable)
#   Rscript run_all.R --steps=1,2,3   # subset of steps
# Steps: 1 baselines, 2 pilot, 3 identifiability, 4 simulation grid, 5 outputs
# All seeds are fixed inside the scripts (base seed 2026).
# =============================================================================
args  <- commandArgs(trailingOnly = TRUE)
steps <- 1:5
if (length(args) && grepl("^--steps=", args[1]))
  steps <- as.integer(strsplit(sub("^--steps=", "", args[1]), ",")[[1]])

source("R/00_setup.R")
record_session()
cat(sprintf("[run_all] backend=%s cores=%d steps=%s\n", STAN_BACKEND, N_CORES,
            paste(steps, collapse = ",")))

run_step <- function(k, script, label) {
  if (!k %in% steps) return(invisible())
  t0 <- Sys.time()
  source(script, local = new.env())
  cat(sprintf("[step %d] %s done in %.1f min\n", k, label,
              as.numeric(difftime(Sys.time(), t0, units = "mins"))))
}
run_step(1, "R/02b_baseline_table.R", "baselines (README table, seed 2026)")
run_step(2, "R/03_pilot.R",           "pilot 4 chains x 2000")
run_step(3, "R/04_identifiability.R", "identifiability variants")
run_step(4, "R/05_grid.R",            "simulation grid")
run_step(5, "R/06_outputs.R",         "figures and tables")

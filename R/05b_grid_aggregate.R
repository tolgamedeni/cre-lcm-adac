# =============================================================================
# 05b_grid_aggregate.R
# Aggregates results/grid/reps/*.rds into results/grid/grid_reps.csv (one row per
# replication) and results/grid/grid_cells.csv (per-cell metrics). Safe to run
# while the grid is still running (partial cells are labelled by n_reps).
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
rep_dir <- "results/grid/reps"
# --- aggregate ------------------------------------------------------------------
files <- list.files(rep_dir, pattern = "\\.rds$", full.names = TRUE)
reps <- do.call(rbind, lapply(files, function(f) {
  r <- readRDS(f)
  ok <- !is.null(r$CRE)
  data.frame(r$cell, rep = r$rep, seed = r$seed, variant = r$variant,
             true_prev = r$truth[["prev"]], true_sens = r$truth[["sens"]], true_spec = r$truth[["spec"]],
             true_share_item = r$truth[["share_item"]], true_share_model = r$truth[["share_model"]],
             true_share_prompt = r$truth[["share_prompt"]], true_share_run = r$truth[["share_run"]],
             MV_prev = r$MV[["prev"]], MV_acc = r$MV[["accuracy"]], MV_brier = r$MV[["brier"]],
             DS_prev = r$DS[["prev"]], DS_sens = r$DS[["sens"]], DS_spec = r$DS[["spec"]],
             DS_acc = r$DS[["accuracy"]], DS_brier = r$DS[["brier"]],
             CRE_ok = ok,
             CRE_prev = if (ok) r$CRE[["prev_1"]] else NA, CRE_prev_lo = if (ok) r$CRE[["prev_2"]] else NA, CRE_prev_hi = if (ok) r$CRE[["prev_3"]] else NA,
             CRE_sens = if (ok) r$CRE[["sens.sens"]] else NA, CRE_sens_lo = if (ok) r$CRE[["sens.sens_lo"]] else NA, CRE_sens_hi = if (ok) r$CRE[["sens.sens_hi"]] else NA,
             CRE_spec = if (ok) r$CRE[["spec.spec"]] else NA, CRE_spec_lo = if (ok) r$CRE[["spec.spec_lo"]] else NA, CRE_spec_hi = if (ok) r$CRE[["spec.spec_hi"]] else NA,
             CRE_share_item = if (ok) r$CRE[["share_item_1"]] else NA, CRE_share_model = if (ok) r$CRE[["share_model_1"]] else NA,
             CRE_share_prompt = if (ok) r$CRE[["share_prompt_1"]] else NA, CRE_share_run = if (ok) r$CRE[["share_run_1"]] else NA,
             CRE_share_item_lo = if (ok) r$CRE[["share_item_2"]] else NA, CRE_share_item_hi = if (ok) r$CRE[["share_item_3"]] else NA,
             CRE_share_model_lo = if (ok) r$CRE[["share_model_2"]] else NA, CRE_share_model_hi = if (ok) r$CRE[["share_model_3"]] else NA,
             CRE_share_prompt_lo = if (ok) r$CRE[["share_prompt_2"]] else NA, CRE_share_prompt_hi = if (ok) r$CRE[["share_prompt_3"]] else NA,
             CRE_acc = if (ok) r$CRE[["accuracy"]] else NA, CRE_brier = if (ok) r$CRE[["brier"]] else NA,
             CRE_acc_nonanchor = if (ok) r$CRE[["accuracy_nonanchor"]] else NA, CRE_brier_nonanchor = if (ok) r$CRE[["brier_nonanchor"]] else NA,
             max_rhat = if (ok) r$diag[["max_rhat"]] else NA, divergences = if (ok) r$diag[["divergences"]] else NA,
             runtime_sec = r$diag[["runtime_sec"]], stringsAsFactors = FALSE)
}))
write.csv(reps, "results/grid/grid_reps.csv", row.names = FALSE)

cov <- function(lo, hi, tr) mean(tr >= lo & tr <= hi, na.rm = TRUE)
# variance shares are positive parameters: when the true share is exactly 0
# (delta = 0) a credible interval can never contain it, so coverage is undefined
cov_pos <- function(lo, hi, tr) { ok <- !is.na(tr) & tr > 0; if (!any(ok)) NA_real_ else mean(tr[ok] >= lo[ok] & tr[ok] <= hi[ok], na.rm = TRUE) }
cells_out <- reps |>
  dplyr::group_by(cell_id, cell, dep, N, P, re_dist, variant) |>
  dplyr::summarise(
    n_reps = dplyr::n(), n_cre_ok = sum(CRE_ok),
    MV_prev_bias = mean(MV_prev - true_prev), MV_prev_rmse = sqrt(mean((MV_prev - true_prev)^2)),
    DS_prev_bias = mean(DS_prev - true_prev), DS_prev_rmse = sqrt(mean((DS_prev - true_prev)^2)),
    CRE_prev_bias = mean(CRE_prev - true_prev, na.rm = TRUE), CRE_prev_rmse = sqrt(mean((CRE_prev - true_prev)^2, na.rm = TRUE)),
    DS_sens_bias = mean(DS_sens - true_sens), DS_sens_rmse = sqrt(mean((DS_sens - true_sens)^2)),
    CRE_sens_bias = mean(CRE_sens - true_sens, na.rm = TRUE), CRE_sens_rmse = sqrt(mean((CRE_sens - true_sens)^2, na.rm = TRUE)),
    DS_spec_bias = mean(DS_spec - true_spec), DS_spec_rmse = sqrt(mean((DS_spec - true_spec)^2)),
    CRE_spec_bias = mean(CRE_spec - true_spec, na.rm = TRUE), CRE_spec_rmse = sqrt(mean((CRE_spec - true_spec)^2, na.rm = TRUE)),
    MV_acc = mean(MV_acc), DS_acc = mean(DS_acc), CRE_acc = mean(CRE_acc, na.rm = TRUE),
    MV_brier = mean(MV_brier), DS_brier = mean(DS_brier), CRE_brier = mean(CRE_brier, na.rm = TRUE),
    CRE_acc_nonanchor = mean(CRE_acc_nonanchor, na.rm = TRUE), CRE_brier_nonanchor = mean(CRE_brier_nonanchor, na.rm = TRUE),
    CRE_cov_prev = cov(CRE_prev_lo, CRE_prev_hi, true_prev),
    CRE_cov_sens = cov(CRE_sens_lo, CRE_sens_hi, true_sens),
    CRE_cov_spec = cov(CRE_spec_lo, CRE_spec_hi, true_spec),
    CRE_cov_share_item = cov_pos(CRE_share_item_lo, CRE_share_item_hi, true_share_item),
    CRE_cov_share_model = cov_pos(CRE_share_model_lo, CRE_share_model_hi, true_share_model),
    CRE_cov_share_prompt = cov_pos(CRE_share_prompt_lo, CRE_share_prompt_hi, true_share_prompt),
    share_item_bias = mean(CRE_share_item - true_share_item, na.rm = TRUE),
    share_model_bias = mean(CRE_share_model - true_share_model, na.rm = TRUE),
    share_prompt_bias = mean(CRE_share_prompt - true_share_prompt, na.rm = TRUE),
    share_run_bias = mean(CRE_share_run - true_share_run, na.rm = TRUE),
    share_item_rmse = sqrt(mean((CRE_share_item - true_share_item)^2, na.rm = TRUE)),
    share_model_rmse = sqrt(mean((CRE_share_model - true_share_model)^2, na.rm = TRUE)),
    share_prompt_rmse = sqrt(mean((CRE_share_prompt - true_share_prompt)^2, na.rm = TRUE)),
    frac_rhat_gt_1.05 = mean(max_rhat > 1.05, na.rm = TRUE), mean_divergences = mean(divergences, na.rm = TRUE),
    mean_runtime_min = mean(runtime_sec, na.rm = TRUE) / 60, .groups = "drop") |>
  dplyr::mutate(flag_rhat = frac_rhat_gt_1.05 > 0.10)
write.csv(cells_out, "results/grid/grid_cells.csv", row.names = FALSE)
cat(sprintf("[grid] aggregated %d replications into %d cells; %d cells flagged (>10%% reps with R-hat > 1.05)\n",
            nrow(reps), nrow(cells_out), sum(cells_out$flag_rhat)))

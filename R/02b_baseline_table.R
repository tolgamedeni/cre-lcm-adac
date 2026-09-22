# =============================================================================
# 02b_baseline_table.R
# Reproduces the baseline table in README.md (seed 2026, N = 300, M = 3,
# P = 5, R = 3): true vs. Dawid-Skene sensitivity/specificity/prevalence as
# the three dependence SDs (1.0, 0.8, 0.5) are scaled by dep in {0,.5,1,1.5}.
# Output: results/baseline_table.csv
# =============================================================================
source("R/01_simulate.R"); source("R/02_baselines.R")
rows <- lapply(c(0, 0.5, 1, 1.5), function(d) {
  sim <- simulate_lcre(s_th = 1.0 * d, s_ph = 0.8 * d, s_ps = 0.5 * d, seed = 2026)
  X <- expand_ratings(sim); tru <- true_marginal_accuracy(sim)
  ds <- dawid_skene_binary(X); mv <- majority_vote(X)
  data.frame(dep = d,
             true_sens = mean(tru$sens), DS_sens = mean(ds$se),
             true_spec = mean(tru$spec), DS_spec = mean(ds$sp),
             true_prev = mean(sim$c_true), DS_prev = ds$pi1, MV_prev = mean(mv),
             DS_acc = mean((ds$post > 0.5) == sim$c_true),
             MV_acc = mean(mv == sim$c_true))
})
baseline_table <- do.call(rbind, rows)
dir.create("results", showWarnings = FALSE)
write.csv(baseline_table, "results/baseline_table.csv", row.names = FALSE)
print(round(baseline_table, 3), row.names = FALSE)

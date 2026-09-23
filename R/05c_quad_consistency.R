# =============================================================================
# 05c_quad_consistency.R
# Consistency check between the sampled-theta model (variant e, results/grid/reps)
# and the quadrature model (variant q, results/grid/reps_q) on the same
# replications (same seeds) in the dep 0.5, N 300 cells, where both converge.
# Run after:  GRID_VARIANT=q GRID_CELLS="dep0.5_N300_" GRID_REPS=10 Rscript R/05_grid.R
# Output: results/grid/quad_consistency.md, results/grid/quad_consistency.csv
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
fq <- list.files("results/grid/reps_q", pattern = "^dep0\\.5_N300_.*\\.rds$", full.names = TRUE)
stopifnot(length(fq) > 0)
get <- function(f) { r <- readRDS(f); c(cell = r$cell$cell, rep = r$rep, seed = r$seed, variant = r$variant,
  chains = r$chains, warmup = r$warmup, sampling = r$sampling,
  quad_Q = if (is.null(r$quad_Q)) NA else r$quad_Q, runtime_min = r$diag$runtime_sec / 60,
  max_rhat = r$diag$max_rhat, min_ess = r$diag$min_ess_bulk,
  prev = r$CRE[["prev_1"]], prev_lo = r$CRE[["prev_2"]], prev_hi = r$CRE[["prev_3"]],
  sens = r$CRE[["sens.sens"]], spec = r$CRE[["spec.spec"]],
  s_th = r$CRE[["s_th_1"]], s_ph = r$CRE[["s_ph_1"]], s_ps = r$CRE[["s_ps_1"]],
  share_item = r$CRE[["share_item_1"]], share_model = r$CRE[["share_model_1"]],
  share_prompt = r$CRE[["share_prompt_1"]], accuracy = r$CRE[["accuracy"]], brier = r$CRE[["brier"]],
  true_prev = r$truth[["prev"]]) }
q <- as.data.frame(do.call(rbind, lapply(fq, get)), stringsAsFactors = FALSE)
e <- as.data.frame(do.call(rbind, lapply(file.path("results/grid/reps", basename(fq)), get)), stringsAsFactors = FALSE)
num <- c("rep", "seed", "chains", "warmup", "sampling", "quad_Q", "runtime_min", "max_rhat", "min_ess", "prev", "prev_lo", "prev_hi", "sens", "spec",
         "s_th", "s_ph", "s_ps", "share_item", "share_model", "share_prompt", "accuracy", "brier", "true_prev")
q[num] <- lapply(q[num], as.numeric); e[num] <- lapply(e[num], as.numeric)
stopifnot(all(q$seed == e$seed))
vars <- c("prev", "sens", "spec", "s_th", "s_ph", "s_ps", "share_item", "share_model", "share_prompt", "accuracy", "brier")
agree <- do.call(rbind, lapply(vars, function(v) data.frame(
  quantity = v, mean_e = mean(e[[v]]), mean_q = mean(q[[v]]), mean_diff_q_minus_e = mean(q[[v]] - e[[v]]),
  sd_diff = sd(q[[v]] - e[[v]]), max_abs_diff = max(abs(q[[v]] - e[[v]])), corr = cor(q[[v]], e[[v]]))))
percell <- rbind(cbind(variant = "e", aggregate(cbind(prev_bias = prev - true_prev, runtime_min, max_rhat, min_ess) ~ cell, e, mean)),
                 cbind(variant = "q", aggregate(cbind(prev_bias = prev - true_prev, runtime_min, max_rhat, min_ess) ~ cell, q, mean)))
write.csv(rbind(cbind(model = "e", e), cbind(model = "q", q)), "results/grid/quad_consistency.csv", row.names = FALSE)
md_tab <- function(df, d = 3) { df[] <- lapply(df, function(x) if (is.numeric(x)) formatC(x, digits = d, format = "f") else as.character(x))
  c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
    apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))) }
writeLines(c("# Consistency of the quadrature model (q) with the sampled-theta model (e)", "",
             sprintf("%d replications (same seeds) in %s; (q) uses %d Gauss-Hermite nodes, %d chains x %d iterations (%d warmup); (e) %d chains x %d iterations (%d warmup).",
                     nrow(q), paste(unique(q$cell), collapse = " and "), max(q$quad_Q, na.rm = TRUE),
                     q$chains[1], q$warmup[1] + q$sampling[1], q$warmup[1], e$chains[1], e$warmup[1] + e$sampling[1], e$warmup[1]),
             "", "## Agreement across replications", "", md_tab(agree),
             "", "## Per cell: prevalence bias, runtime (min), convergence", "", md_tab(percell),
             "", "Interpretation: differences of the order of the Monte Carlo error of the posterior means (a few 0.001 for prevalence)",
             "mean that the two estimation routes target the same posterior and one model can be reported across the grid."),
           "results/grid/quad_consistency.md")
cat(readLines("results/grid/quad_consistency.md"), sep = "\n")

# =============================================================================
# 05_grid.R
# Simulation grid: dependence {0, 0.5, 1, 1.5} x N {150, 300, 600} x P {3, 5};
# M = 3, R = 3; 100 replications per cell; plus a misspecification arm with
# t(df = 4) random effects at dependence 1, N = 300, P = 5.
# Competitors: majority vote, Dawid-Skene (EM), CRE-LCM (variant VARIANT).
# CRE-LCM chains: 2 x 1000 (500 warmup); cells with R-hat > 1.05 are flagged.
#
# Resumable: each replication is written to results/grid/reps/<cell>_r<rep>.rds
# as soon as it finishes and is skipped on the next run. Seeds:
#   data seed  = 1e6 + cell_id * 1000 + rep      (recorded in every file)
#   Stan seed  = data seed
# Aggregate output: results/grid/grid_cells.csv (per-cell metrics),
#                   results/grid/grid_reps.csv (per-replication metrics).
# Usage:  Rscript R/05_grid.R                (or via run_all.R --steps=4)
#   env GRID_VARIANT = base|a|b|c|d (default: value in results/identifiability/chosen_variant.txt)
#   env GRID_REPS    = number of replications (default 100)
#   env GRID_WORKERS = parallel workers (default N_CORES)
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
source("R/01_simulate.R"); source("R/02_baselines.R")

VARIANT <- Sys.getenv("GRID_VARIANT", unset = NA)
if (is.na(VARIANT) || VARIANT == "") {
  vf <- "results/identifiability/chosen_variant.txt"
  VARIANT <- if (file.exists(vf)) trimws(readLines(vf, n = 1)) else "base"
}
N_REPS   <- as.integer(Sys.getenv("GRID_REPS", unset = "100"))
WORKERS  <- as.integer(Sys.getenv("GRID_WORKERS", unset = as.character(N_CORES)))
CHAINS <- 2; WARMUP <- 500; SAMPLING <- 500
ANCHOR_FRAC <- 0.05
stan_file <- switch(VARIANT,
  base = "stan/crossed_lcre.stan",
  a = "stan/crossed_lcre_a_classscale.stan",
  b = "stan/crossed_lcre_b_notheta.stan",
  c = "stan/crossed_lcre_c_anchor.stan",
  d = "stan/crossed_lcre_d_infprior.stan",
  stop("unknown GRID_VARIANT: ", VARIANT))
rep_dir <- "results/grid/reps"; dir.create(rep_dir, showWarnings = FALSE, recursive = TRUE)

# --- cells --------------------------------------------------------------------
cells <- expand.grid(dep = c(0, 0.5, 1, 1.5), N = c(150, 300, 600), P = c(3, 5),
                     re_dist = "normal", stringsAsFactors = FALSE)
cells <- rbind(cells, data.frame(dep = 1, N = 300, P = 5, re_dist = "t4"))
cells$cell_id <- seq_len(nrow(cells))
cells$cell <- sprintf("dep%.1f_N%d_P%d_%s", cells$dep, cells$N, cells$P, cells$re_dist)
write.csv(cells, "results/grid/cells.csv", row.names = FALSE)

# --- marginal sensitivity / specificity implied by CRE-LCM draws --------------
# Averaged over (m, p) and over the item random effects (MC over z), for a
# thinned set of posterior draws; returns posterior mean and 95% interval.
implied_accuracy <- function(g, M, P, variant, n_draws = 100, nmc = 2000) {
  set.seed(1)
  idx <- round(seq(1, nrow(g), length.out = n_draws))
  z0 <- rnorm(nmc)
  out <- t(sapply(idx, function(d) {
    r <- g[d, ]
    mu <- c(r[["mu[1]"]], r[["mu[2]"]])
    a  <- matrix(sapply(1:2, function(k) sapply(1:M, function(m) r[[sprintf("a[%d,%d]", m, k)]])), M, 2)
    b  <- matrix(sapply(1:2, function(k) sapply(1:P, function(p) r[[sprintf("b[%d,%d]", p, k)]])), P, 2)
    s_ph <- r[["s_ph"]]; s_ps <- r[["s_ps"]]
    s_th_k <- if (variant == "a") c(r[["s_th[1]"]], r[["s_th[2]"]])
              else if (variant == "b") c(0, 0) else rep(r[["s_th"]], 2)
    sens <- spec <- 0
    for (m in 1:M) for (p in 1:P) {
      sens <- sens + mean(plogis(mu[2] + a[m, 2] + b[p, 2] + sqrt(s_th_k[2]^2 + s_ph^2 + s_ps^2) * z0))
      spec <- spec + mean(1 - plogis(mu[1] + a[m, 1] + b[p, 1] + sqrt(s_th_k[1]^2 + s_ph^2 + s_ps^2) * z0))
    }
    c(sens = sens / (M * P), spec = spec / (M * P))
  }))
  c(sens = mean(out[, "sens"]), sens_lo = unname(quantile(out[, "sens"], .025)), sens_hi = unname(quantile(out[, "sens"], .975)),
    spec = mean(out[, "spec"]), spec_lo = unname(quantile(out[, "spec"], .025)), spec_hi = unname(quantile(out[, "spec"], .975)))
}

# --- one replication -----------------------------------------------------------
run_rep <- function(cell_row, rep, mod) {
  f <- file.path(rep_dir, sprintf("%s_r%03d.rds", cell_row$cell, rep))
  if (file.exists(f)) return(invisible(f))
  seed <- 1e6 + cell_row$cell_id * 1000 + rep
  sim <- simulate_lcre(N = cell_row$N, M = 3, P = cell_row$P, R = 3,
                       s_th = 1.0 * cell_row$dep, s_ph = 0.8 * cell_row$dep, s_ps = 0.5 * cell_row$dep,
                       seed = seed, re_dist = cell_row$re_dist)
  X <- expand_ratings(sim); tru <- true_marginal_accuracy(sim)
  tv <- sim$truth; vt <- tv$s_th^2 + tv$s_ph^2 + tv$s_ps^2 + pi^2 / 3
  truth <- c(prev = mean(sim$c_true), prev_pop = tv$pi1, sens = mean(tru$sens), spec = mean(tru$spec),
             s_th = tv$s_th, s_ph = tv$s_ph, s_ps = tv$s_ps,
             share_item = tv$s_th^2 / vt, share_model = tv$s_ph^2 / vt,
             share_prompt = tv$s_ps^2 / vt, share_run = (pi^2 / 3) / vt)
  lab <- function(post, ct) c(accuracy = mean((post > 0.5) == ct), brier = mean((post - ct)^2))

  mv <- majority_vote(X); ds <- dawid_skene_binary(X)
  res <- list(
    MV = c(prev = mean(mv), lab(mv, sim$c_true)),
    DS = c(prev = ds$pi1, sens = mean(ds$se), spec = mean(ds$sp), lab(ds$post, sim$c_true), iter = ds$iter))

  data <- list(N = sim$N, M = sim$M, P = sim$P, R = sim$R, S = sim$S)
  anchor_idx <- integer(0)
  if (VARIANT == "c") {
    set.seed(seed + 1)
    anchor_idx <- sort(sample(sim$N, ceiling(ANCHOR_FRAC * sim$N)))
    data <- c(data, list(N_anchor = length(anchor_idx), anchor_idx = anchor_idx,
                         anchor_lab = sim$c_true[anchor_idx]))
  }
  t0 <- Sys.time()
  s <- tryCatch(sample_stan(mod, data = data, chains = CHAINS, iter_warmup = WARMUP,
                            iter_sampling = SAMPLING, seed = seed, adapt_delta = 0.9,
                            parallel_chains = 1), error = function(e) e)
  cre <- NULL; diag <- NULL
  if (!inherits(s, "error")) {
    gv <- c("pi1", "mu", "a", "b", "s_th", "s_ph", "s_ps", "share_item", "share_model", "share_prompt", "share_run")
    g  <- posterior::subset_draws(s$draws, variable = gv)
    sm <- summ_vars(g, gv); rownames(sm) <- sm$variable
    post1 <- colMeans(posterior::as_draws_matrix(posterior::subset_draws(s$draws, variable = "post1")))
    acc <- implied_accuracy(as.data.frame(posterior::as_draws_matrix(g)), sim$M, sim$P, VARIANT)
    free <- setdiff(seq_len(sim$N), anchor_idx)
    est <- function(v) if (v %in% rownames(sm)) c(sm[v, "mean"], sm[v, "q2.5"], sm[v, "q97.5"]) else c(NA, NA, NA)
    s_th_est <- if (VARIANT == "a") {
      # prevalence-weighted item SD for comparability
      dd <- posterior::as_draws_matrix(g)
      v <- sqrt((1 - dd[, "pi1"]) * dd[, "s_th[1]"]^2 + dd[, "pi1"] * dd[, "s_th[2]"]^2)
      c(mean(v), quantile(v, .025), quantile(v, .975))
    } else est("s_th")
    cre <- c(prev = est("pi1"), sens = acc[c("sens", "sens_lo", "sens_hi")], spec = acc[c("spec", "spec_lo", "spec_hi")],
             s_th = s_th_est, s_ph = est("s_ph"), s_ps = est("s_ps"),
             share_item = est("share_item"), share_model = est("share_model"),
             share_prompt = est("share_prompt"), share_run = est("share_run"),
             lab(post1, sim$c_true),
             setNames(lab(post1[free], sim$c_true[free]), c("accuracy_nonanchor", "brier_nonanchor")))
    names(cre) <- sub("\\.(2\\.5|97\\.5)%$", "", names(cre))
    names(cre)[grepl("[0-9]$", names(cre)) & !grepl("_(lo|hi)$", names(cre))] <-
      sub("([a-z_]+)([123])$", "\\1_\\2", names(cre)[grepl("[0-9]$", names(cre)) & !grepl("_(lo|hi)$", names(cre))])
    diag <- c(s$diag, runtime_sec = s$runtime_sec, max_rhat = max(sm$rhat, na.rm = TRUE),
              min_ess_bulk = min(sm$ess_bulk, na.rm = TRUE), min_ess_tail = min(sm$ess_tail, na.rm = TRUE))
  } else {
    diag <- list(error = conditionMessage(s), runtime_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")))
  }
  saveRDS(list(cell = cell_row, rep = rep, seed = seed, variant = VARIANT, truth = truth,
               MV = res$MV, DS = res$DS, CRE = cre, diag = diag, anchor_idx = anchor_idx,
               chains = CHAINS, warmup = WARMUP, sampling = SAMPLING), f)
  invisible(f)
}

# --- run in parallel (each worker: one replication at a time, chains serial) --
jobs <- expand.grid(rep = seq_len(N_REPS), cell_id = cells$cell_id)
jobs <- jobs[order(jobs$rep, jobs$cell_id), ]        # rep 1 of every cell first
todo <- jobs[!file.exists(file.path(rep_dir, sprintf("%s_r%03d.rds",
                                       cells$cell[jobs$cell_id], jobs$rep))), ]
cat(sprintf("[grid] variant=%s cells=%d reps=%d todo=%d workers=%d\n",
            VARIANT, nrow(cells), N_REPS, nrow(todo), WORKERS))
if (nrow(todo)) {
  mod <- compile_stan(stan_file)   # compile once in the parent; workers reuse the exe
  future::plan(future::multisession, workers = WORKERS)
  furrr::future_walk(seq_len(nrow(todo)), function(j) {
    source("R/00_setup.R"); source("R/01_simulate.R"); source("R/02_baselines.R")
    mod_w <- compile_stan(stan_file)
    run_rep(cells[todo$cell_id[j], ], todo$rep[j], mod_w)
  }, .options = furrr::furrr_options(seed = NULL, globals = c("cells", "todo", "stan_file",
                     "rep_dir", "run_rep", "implied_accuracy", "VARIANT", "CHAINS", "WARMUP",
                     "SAMPLING", "ANCHOR_FRAC"), scheduling = Inf), .progress = TRUE)
  future::plan(future::sequential)
}

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
    CRE_cov_share_item = cov(CRE_share_item_lo, CRE_share_item_hi, true_share_item),
    CRE_cov_share_model = cov(CRE_share_model_lo, CRE_share_model_hi, true_share_model),
    CRE_cov_share_prompt = cov(CRE_share_prompt_lo, CRE_share_prompt_hi, true_share_prompt),
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

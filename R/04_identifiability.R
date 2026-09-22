# =============================================================================
# 04_identifiability.R
# Compare remedies for the weak identification of the global item effect
# theta_i against the latent class, on scenario-B data
# (s_th = 1, s_ph = 0.8, s_ps = 0.5, N = 300, M = 3, P = 5, R = 3, seed 2026).
#
# Variants (stan/):
#   base  crossed_lcre.stan              common scale for theta (pilot model)
#   a     crossed_lcre_a_classscale.stan class-specific scale (Qu, Tan & Kutner 1996)
#   b     crossed_lcre_b_notheta.stan    theta omitted
#   c     crossed_lcre_c_anchor.stan     5% of items anchored with known labels
#   d     crossed_lcre_d_infprior.stan   half-normal(0, 0.5) prior on s_th
# Each: 4 chains x 2000 iterations (1000 warmup), seed 2026, adapt_delta 0.9.
# The base fit is taken from results/pilot/fit_B.rds when present (same data,
# same settings); otherwise it is refitted here.
#
# Outputs in results/identifiability/ (existing files are never overwritten):
#   fits/fit_<v>.rds      full fit objects (git-ignored)
#   draws_<v>.rds         global-parameter draws, post1, log_lik, diagnostics
#   recovery.csv          posterior mean / 95% CI / truth / covered per parameter
#   labels.csv            accuracy and Brier of posterior labels
#   loo.csv               PSIS-LOO (base, a, b, d; c has a different likelihood)
#   diagnostics.csv       R-hat, ESS, divergences, runtime
#   comparison.md         tables + recommendation (reasoning written by hand)
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
source("R/01_simulate.R"); source("R/02_baselines.R")

CHAINS <- 4; WARMUP <- 1000; SAMPLING <- 1000; SEED <- 2026
ANCHOR_FRAC <- 0.05; ANCHOR_SEED <- 20261
out_dir <- "results/identifiability"; dir.create(file.path(out_dir, "fits"), showWarnings = FALSE, recursive = TRUE)

sim <- simulate_lcre(s_th = 1.0, s_ph = 0.8, s_ps = 0.5, seed = SEED)
X   <- expand_ratings(sim); ds <- dawid_skene_binary(X); mv <- majority_vote(X)
tv  <- sim$truth; vt <- tv$s_th^2 + tv$s_ph^2 + tv$s_ps^2 + pi^2 / 3
truth_vec <- c(pi1 = tv$pi1, `mu[1]` = tv$mu[1], `mu[2]` = tv$mu[2],
               setNames(as.vector(tv$a), sprintf("a[%d,%d]", row(tv$a), col(tv$a))),
               s_th = tv$s_th, `s_th[1]` = tv$s_th, `s_th[2]` = tv$s_th,
               s_ph = tv$s_ph, s_ps = tv$s_ps,
               share_item = tv$s_th^2 / vt, share_model = tv$s_ph^2 / vt,
               share_prompt = tv$s_ps^2 / vt, share_run = (pi^2 / 3) / vt)

set.seed(ANCHOR_SEED)
anchor_idx <- sort(sample(sim$N, ceiling(ANCHOR_FRAC * sim$N)))
anchor_lab <- sim$c_true[anchor_idx]
base_data  <- list(N = sim$N, M = sim$M, P = sim$P, R = sim$R, S = sim$S)

variants <- list(
  base = list(file = "stan/crossed_lcre.stan",              data = base_data,
              label = "base: common scale for theta"),
  a    = list(file = "stan/crossed_lcre_a_classscale.stan", data = base_data,
              label = "(a) class-specific scale for theta"),
  b    = list(file = "stan/crossed_lcre_b_notheta.stan",    data = base_data,
              label = "(b) theta omitted"),
  c    = list(file = "stan/crossed_lcre_c_anchor.stan",
              data = c(base_data, list(N_anchor = length(anchor_idx),
                                       anchor_idx = anchor_idx, anchor_lab = anchor_lab)),
              label = sprintf("(c) anchoring: %d items (%.0f%%) with known labels",
                              length(anchor_idx), 100 * ANCHOR_FRAC)),
  d    = list(file = "stan/crossed_lcre_d_infprior.stan",   data = base_data,
              label = "(d) half-normal(0, 0.5) prior on s_th"),
  # (e) computational check, not a model change: base model with every chain
  # initialised at the Dawid-Skene solution (does the merged-class mode persist?)
  e    = list(file = "stan/crossed_lcre.stan", data = base_data,
              label = "(e) base model, chains initialised from Dawid-Skene",
              init = function() list(pi1 = ds$pi1,
                                     mu = c(qlogis(1 - mean(ds$sp)), qlogis(mean(ds$se))),
                                     a_raw = matrix(0, sim$M - 1, 2), b_z = matrix(0, sim$P, 2),
                                     tau_b = c(0.3, 0.3), s_th = 0.5, s_ph = 0.5, s_ps = 0.5,
                                     th_z = rep(0, sim$N), ph_z = matrix(0, sim$N, sim$M),
                                     ps_z = matrix(0, sim$N, sim$P))))

gvars <- c("pi1", "mu", "a", "tau_b", "s_th", "s_ph", "s_ps",
           "share_item", "share_model", "share_prompt", "share_run", "lp__")

fit_variant <- function(v, spec) {
  dpath <- file.path(out_dir, paste0("draws_", v, ".rds"))
  if (file.exists(dpath)) { message("[ident] reuse ", dpath); return(readRDS(dpath)) }
  pilot_fit <- "results/pilot/fit_B.rds"
  if (v == "base" && file.exists(pilot_fit) && STAN_BACKEND == "cmdstanr") {
    message("[ident] base: reusing pilot fit ", pilot_fit)
    fit <- readRDS(pilot_fit)
    sd <- fit$sampler_diagnostics(format = "df")
    s <- list(fit = fit, draws = posterior::as_draws_df(fit$draws()),
              diag = data.frame(divergences = sum(sd$divergent__), max_treedepth_hits = sum(sd$treedepth__ >= 10)),
              runtime_sec = fit$time()$total)
  } else {
    mod <- compile_stan(spec$file)
    extra <- if (!is.null(spec$init)) list(init = spec$init) else list()
    s <- do.call(sample_stan, c(list(mod = mod, data = spec$data, chains = CHAINS, iter_warmup = WARMUP,
                                     iter_sampling = SAMPLING, seed = SEED, adapt_delta = 0.9), extra))
    fpath <- file.path(out_dir, "fits", paste0("fit_", v, ".rds"))
    if (!protect(fpath)) {
      if (STAN_BACKEND == "cmdstanr") s$fit$save_object(fpath) else saveRDS(s$fit, fpath)
    }
  }
  draws <- s$draws
  out <- list(variant = v, label = spec$label,
              global = posterior::subset_draws(draws, variable = gvars),
              post1  = posterior::as_draws_matrix(posterior::subset_draws(draws, variable = "post1")),
              log_lik = posterior::as_draws_matrix(posterior::subset_draws(draws, variable = "log_lik")),
              chain_id = posterior::as_draws_df(draws)$.chain,
              diag = cbind(s$diag, runtime_sec = s$runtime_sec, chains = CHAINS,
                           iter_warmup = WARMUP, iter_sampling = SAMPLING, seed = SEED),
              anchor_idx = if (v == "c") anchor_idx else integer(0))
  pc <- posterior::subset_draws(draws, variable = c("pi1", "mu", "s_th", "s_ph", "s_ps", "lp__"))
  out$per_chain <- t(apply(posterior::as_draws_array(pc), c(2, 3), mean))
  saveRDS(out, dpath); out
}

fits <- list()
FIT_ONLY <- Sys.getenv("IDENT_FIT_ONLY", unset = "")   # e.g. "a,b": fit these and stop
if (nzchar(FIT_ONLY)) {
  for (v in strsplit(FIT_ONLY, ",")[[1]]) {
    cat(sprintf("[ident] fitting %s ...\n", variants[[v]]$label))
    f <- fit_variant(v, variants[[v]])
    cat(sprintf("[ident] %s done: %.1f min, %d divergences\n", v, f$diag$runtime_sec / 60, f$diag$divergences))
  }
  quit(save = "no")
}
for (v in names(variants)) {
  cat(sprintf("[ident] fitting %s ...\n", variants[[v]]$label))
  fits[[v]] <- fit_variant(v, variants[[v]])
  cat(sprintf("[ident] %s done: %.1f min, %d divergences\n", v,
              fits[[v]]$diag$runtime_sec / 60, fits[[v]]$diag$divergences))
}

# --- 1. parameter recovery ------------------------------------------------------
recovery <- do.call(rbind, lapply(fits, function(f) {
  s <- summ_vars(f$global, gvars)
  s$variant <- f$variant
  s$true <- unname(truth_vec[s$variable])
  s$covered <- with(s, ifelse(is.na(true), NA, true >= q2.5 & true <= q97.5))
  s$abs_err <- abs(s$mean - s$true)
  s
}))
recovery <- recovery[, c("variant", "variable", "mean", "sd", "q2.5", "q97.5", "true",
                         "covered", "abs_err", "rhat", "ess_bulk", "ess_tail")]
write.csv(recovery, file.path(out_dir, "recovery.csv"), row.names = FALSE)

# --- 2. posterior labels --------------------------------------------------------
lab_metrics <- function(post, ct) c(accuracy = mean((post > 0.5) == ct), brier = mean((post - ct)^2))
free_idx <- setdiff(seq_len(sim$N), anchor_idx)
labels <- rbind(
  data.frame(variant = "majority vote", t(lab_metrics(mv, sim$c_true)),
             t(setNames(lab_metrics(mv[free_idx], sim$c_true[free_idx]), c("accuracy_nonanchor", "brier_nonanchor")))),
  data.frame(variant = "Dawid-Skene", t(lab_metrics(ds$post, sim$c_true)),
             t(setNames(lab_metrics(ds$post[free_idx], sim$c_true[free_idx]), c("accuracy_nonanchor", "brier_nonanchor")))),
  do.call(rbind, lapply(fits, function(f) {
    p <- colMeans(f$post1)
    data.frame(variant = f$variant, t(lab_metrics(p, sim$c_true)),
               t(setNames(lab_metrics(p[free_idx], sim$c_true[free_idx]), c("accuracy_nonanchor", "brier_nonanchor"))))
  })))
write.csv(labels, file.path(out_dir, "labels.csv"), row.names = FALSE)

# --- 3. LOO (same data and likelihood only: base, a, b, d) ----------------------
loo_list <- lapply(fits[c("base", "a", "b", "d", "e")], function(f) {
  ll <- f$log_lik
  r_eff <- loo::relative_eff(exp(ll), chain_id = f$chain_id)
  loo::loo(ll, r_eff = r_eff)
})
loo_tab <- do.call(rbind, lapply(names(loo_list), function(v) {
  l <- loo_list[[v]]
  data.frame(variant = v, elpd_loo = l$estimates["elpd_loo", "Estimate"],
             se_elpd = l$estimates["elpd_loo", "SE"],
             p_loo = l$estimates["p_loo", "Estimate"],
             n_k_gt_0.7 = sum(loo::pareto_k_values(l) > 0.7))
}))
# elpd difference to the best variant (SE of the difference omitted: with
# most Pareto k > 0.7 the PSIS estimates themselves are unreliable, see notes)
loo_tab$elpd_diff <- loo_tab$elpd_loo - max(loo_tab$elpd_loo)
loo_tab$frac_k_gt_0.7 <- loo_tab$n_k_gt_0.7 / sim$N
write.csv(loo_tab, file.path(out_dir, "loo.csv"), row.names = FALSE)

# --- 4. diagnostics -------------------------------------------------------------
diagnostics <- do.call(rbind, lapply(fits, function(f) {
  g <- recovery[recovery$variant == f$variant, ]
  p <- summ_vars(posterior::as_draws_matrix(f$post1), "post1")
  data.frame(variant = f$variant, label = f$label, f$diag,
             max_rhat_global = max(g$rhat, na.rm = TRUE),
             min_ess_bulk_global = min(g$ess_bulk, na.rm = TRUE),
             min_ess_tail_global = min(g$ess_tail, na.rm = TRUE),
             max_rhat_post1 = max(p$rhat, na.rm = TRUE))
}))
write.csv(diagnostics, file.path(out_dir, "diagnostics.csv"), row.names = FALSE)

# --- 5. markdown tables (reasoning/recommendation appended by hand) -------------
md_table <- function(df, digits = 3) {
  df[] <- lapply(df, function(x) if (is.numeric(x)) formatC(x, digits = digits, format = "f") else as.character(x))
  c(paste0("| ", paste(names(df), collapse = " | "), " |"),
    paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
    apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
}
key <- c("pi1", "mu[1]", "mu[2]", "a[2,1]", "a[3,1]", "a[2,2]", "a[3,2]",
         "s_th", "s_th[1]", "s_th[2]", "s_ph", "s_ps",
         "share_item", "share_model", "share_prompt", "share_run")
rec_wide <- recovery[recovery$variable %in% key, ]
rec_wide$cell <- sprintf("%.3f [%.2f, %.2f]%s", rec_wide$mean, rec_wide$q2.5, rec_wide$q97.5,
                         ifelse(is.na(rec_wide$covered), "", ifelse(rec_wide$covered, "", " *")))
w <- reshape(rec_wide[, c("variable", "variant", "cell")], idvar = "variable",
             timevar = "variant", direction = "wide")
names(w) <- sub("^cell\\.", "", names(w))
w <- w[match(key[key %in% w$variable], w$variable), ]
w$true <- formatC(truth_vec[w$variable], digits = 3, format = "f")
w <- w[, c("variable", "true", names(variants))]
md <- c("# Identifiability variants: comparison on scenario-B data",
        "",
        sprintf("Data: N = %d, M = %d, P = %d, R = %d; s_th = %.1f, s_ph = %.1f, s_ps = %.1f; seed %d. ",
                sim$N, sim$M, sim$P, sim$R, tv$s_th, tv$s_ph, tv$s_ps, SEED),
        sprintf("Sampler: %s, %d chains x %d iterations (%d warmup), adapt_delta 0.9, seed %d. ",
                STAN_BACKEND, CHAINS, WARMUP + SAMPLING, WARMUP, SEED),
        sprintf("Anchoring (c): %d items (%.0f%%), selected with seed %d; anchored items are excluded from the 'non-anchored' label metrics.",
                length(anchor_idx), 100 * ANCHOR_FRAC, ANCHOR_SEED),
        "", "Variants:", paste0("- `", names(variants), "`: ", sapply(variants, `[[`, "label")),
        "", "## 1. Parameter recovery (posterior mean [95% CI]; `*` = interval misses the truth)", "",
        md_table(w),
        "", "Note: in (a) `share_item` uses the prevalence-weighted item variance (1-pi1) s_th[1]^2 + pi1 s_th[2]^2; ",
        "in (b) `s_th` and `share_item` are 0 by construction, so the remaining shares are relative to a smaller total.",
        "", "## 2. Posterior labels", "", md_table(labels),
        "", "## 3. PSIS-LOO (base, a, b, d, e: same data and likelihood; c conditions on known labels and is not comparable)", "",
        md_table(loo_tab),
        "", "## 4. MCMC diagnostics", "",
        md_table(diagnostics[, c("variant", "runtime_sec", "divergences", "max_treedepth_hits",
                                 "max_rhat_global", "min_ess_bulk_global", "min_ess_tail_global", "max_rhat_post1")]),
        "", "## 5. Recommendation and reasoning", "",
        if (file.exists(file.path(out_dir, "recommendation.md")))
          readLines(file.path(out_dir, "recommendation.md")) else "[to be written after inspection]")
writeLines(md, file.path(out_dir, "comparison.md"))
saveRDS(list(recovery = recovery, labels = labels, loo = loo_tab, diagnostics = diagnostics,
             anchor_idx = anchor_idx, truth = truth_vec), file.path(out_dir, "comparison_tables.rds"))
cat("[ident] done: ", file.path(out_dir, "comparison.md"), "\n")

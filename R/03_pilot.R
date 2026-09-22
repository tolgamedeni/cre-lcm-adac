# =============================================================================
# 03_pilot.R
# Pilot: does Dawid-Skene mis-estimate accuracy under crossed dependence,
# and does the crossed random-effects model (CRE-LCM) recover it?
# Full pilot: 4 chains x 2000 iterations (1000 warmup), seed 2026.
# Run from the project root:  Rscript R/03_pilot.R
# Outputs (never overwritten if present): results/pilot/
#   fit_B.rds            full cmdstanr/rstan fit object (git-ignored, large)
#   draws_B.rds          posterior draws of the global parameters
#   summary_B.csv        mean / sd / 95% CI / R-hat / ESS for key parameters
#   diagnostics.csv      divergences, treedepth hits, runtime
#   pilot_results.rds    scenario tables A and B (same structure as pilot_results.rds)
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
source("R/01_simulate.R")
source("R/02_baselines.R")

CHAINS <- 4; WARMUP <- 1000; SAMPLING <- 1000; SEED <- 2026
out_dir <- "results/pilot"

summarise_fit <- function(label, c_true, post, pi_hat, se_hat = NA, sp_hat = NA) {
  data.frame(method = label,
             pi_hat = round(pi_hat, 3),
             accuracy = round(mean((post > 0.5) == c_true), 3),
             brier = round(mean((post - c_true)^2), 3),
             mean_sens_hat = round(mean(se_hat), 3),
             mean_spec_hat = round(mean(sp_hat), 3))
}

run_scenario <- function(name, tag, s_th, s_ph, s_ps, fit_stan = TRUE, seed = SEED) {
  sim <- simulate_lcre(s_th = s_th, s_ph = s_ph, s_ps = s_ps, seed = seed)
  X   <- expand_ratings(sim)
  tru <- true_marginal_accuracy(sim)

  mv <- majority_vote(X)
  ds <- dawid_skene_binary(X)

  res <- rbind(
    data.frame(method = "TRUTH", pi_hat = round(mean(sim$c_true), 3),
               accuracy = 1, brier = 0,
               mean_sens_hat = round(mean(tru$sens), 3),
               mean_spec_hat = round(mean(tru$spec), 3)),
    summarise_fit("Majority vote", sim$c_true, mv, mean(mv)),
    summarise_fit("Dawid-Skene",  sim$c_true, ds$post, ds$pi1, ds$se, ds$sp)
  )

  shares <- NULL; summ <- NULL; diag <- NULL
  if (fit_stan) {
    fit_path <- file.path(out_dir, paste0("fit_", tag, ".rds"))
    if (protect(fit_path)) {
      # raw fit exists: rebuild every derived quantity from it (never resample)
      fit <- readRDS(fit_path)
      draws <- posterior::as_draws_df(fit$draws())
      sd <- fit$sampler_diagnostics(format = "df")
      diag <- data.frame(divergences = sum(sd$divergent__),
                         max_treedepth_hits = sum(sd$treedepth__ >= 10),
                         runtime_sec = fit$time()$total, chains = CHAINS,
                         iter_warmup = WARMUP, iter_sampling = SAMPLING,
                         seed = seed, backend = STAN_BACKEND)
    } else {
      s <- sample_stan(stan_mod, data = list(N = sim$N, M = sim$M, P = sim$P, R = sim$R, S = sim$S),
                       chains = CHAINS, iter_warmup = WARMUP, iter_sampling = SAMPLING,
                       seed = seed, adapt_delta = 0.9)
      draws <- s$draws; diag <- s$diag; diag$runtime_sec <- s$runtime_sec
      diag$chains <- CHAINS; diag$iter_warmup <- WARMUP; diag$iter_sampling <- SAMPLING
      diag$seed <- seed; diag$backend <- STAN_BACKEND
      if (STAN_BACKEND == "cmdstanr") s$fit$save_object(fit_path) else saveRDS(s$fit, fit_path)
    }
    {
      saveRDS(list(draws = posterior::subset_draws(draws, variable = c("pi1","mu","a","b","tau_b","s_th","s_ph","s_ps","share_item","share_model","share_prompt","share_run","lp__")),
                   post1 = colMeans(posterior::as_draws_matrix(posterior::subset_draws(draws, variable = "post1"))),
                   diag = diag, truth = sim$truth, c_true = sim$c_true),
              file.path(out_dir, paste0("draws_", tag, ".rds")))
    }
    post1  <- colMeans(posterior::as_draws_matrix(posterior::subset_draws(draws, variable = "post1")))
    pi_hat <- mean(posterior::extract_variable(draws, "pi1"))
    res <- rbind(res, summarise_fit("CRE-LCM (proposed)", sim$c_true, post1, pi_hat))

    summ <- summ_vars(draws, c("pi1", "mu", "a", "tau_b", "s_th", "s_ph", "s_ps",
                               "share_item", "share_model", "share_prompt", "share_run", "lp__"))
    tv <- sim$truth
    vt <- tv$s_th^2 + tv$s_ph^2 + tv$s_ps^2 + pi^2 / 3
    truth_vec <- c(pi1 = tv$pi1, `mu[1]` = tv$mu[1], `mu[2]` = tv$mu[2],
                   setNames(as.vector(tv$a), sprintf("a[%d,%d]", row(tv$a), col(tv$a))),
                   `tau_b[1]` = 0.4, `tau_b[2]` = 0.4,
                   s_th = tv$s_th, s_ph = tv$s_ph, s_ps = tv$s_ps,
                   share_item = tv$s_th^2 / vt, share_model = tv$s_ph^2 / vt,
                   share_prompt = tv$s_ps^2 / vt, share_run = (pi^2 / 3) / vt)
    summ$true <- unname(truth_vec[summ$variable])
    shares <- summ[summ$variable %in% c("s_th","s_ph","s_ps","share_item","share_model","share_prompt","share_run"),
                   c("variable","mean","q2.5","q97.5","rhat","true")]
    # posterior-label diagnostics also for the item-level post1
    pc <- posterior::subset_draws(draws, variable = c("pi1", "mu", "s_th", "s_ph", "s_ps", "a", "tau_b", "lp__"))
    per_chain <- t(apply(posterior::as_draws_array(pc), c(2, 3), mean))
    write.csv(round(per_chain, 4), file.path(out_dir, paste0("per_chain_means_", tag, ".csv")))
    post_summ <- summ_vars(draws, "post1")
    diag$post1_max_rhat <- max(post_summ$rhat, na.rm = TRUE)
    diag$post1_min_ess_bulk <- min(post_summ$ess_bulk, na.rm = TRUE)
    diag$global_max_rhat <- max(summ$rhat, na.rm = TRUE)
    diag$global_min_ess_bulk <- min(summ$ess_bulk, na.rm = TRUE)
    diag$global_min_ess_tail <- min(summ$ess_tail, na.rm = TRUE)
    write.csv(summ, file.path(out_dir, paste0("summary_", tag, ".csv")), row.names = FALSE)
    write.csv(diag, file.path(out_dir, "diagnostics.csv"), row.names = FALSE)
  }
  cat("\n==============================================================\n")
  cat("Scenario:", name, " (s_th =", s_th, ", s_ph =", s_ph, ", s_ps =", s_ps, ")\n")
  cat("==============================================================\n")
  print(res, row.names = FALSE)
  if (!is.null(shares)) {
    cat("\nVariance components (CRE-LCM):\n"); print(shares, row.names = FALSE, digits = 3)
    cat("\nDiagnostics:\n"); print(diag, row.names = FALSE)
    cat("\nPer-chain posterior means (rows = parameters, columns = chains):\n")
    print(round(read.csv(file.path(out_dir, paste0("per_chain_means_", tag, ".csv")), row.names = 1, check.names = FALSE), 3))
    cat("\nFull summary:\n"); print(summ, row.names = FALSE, digits = 3)
  }
  invisible(list(res = res, shares = shares, summary = summ, diag = diag))
}

stan_mod <- compile_stan("stan/crossed_lcre.stan")

out_A <- run_scenario("A: conditional independence", "A", 0, 0, 0, fit_stan = FALSE)
out_B <- run_scenario("B: crossed dependence", "B", 1.0, 0.8, 0.5, fit_stan = TRUE)

rp <- file.path(out_dir, "pilot_results.rds")
if (!protect(rp)) saveRDS(list(A = out_A, B = out_B), rp)
cat("[pilot] done: results in", out_dir, "\n")

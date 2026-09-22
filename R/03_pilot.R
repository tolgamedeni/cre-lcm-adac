# =============================================================================
# 03_pilot.R
# Pilot: does Dawid-Skene mis-estimate accuracy under crossed dependence,
# and does the crossed random-effects model (CRE-LCM) recover it?
# Run from the project root:  Rscript R/03_pilot.R
# =============================================================================
suppressPackageStartupMessages(library(rstan))
options(mc.cores = 1)
rstan_options(auto_write = TRUE)
source("R/01_simulate.R")
source("R/02_baselines.R")

summarise_fit <- function(label, c_true, post, pi_hat, se_hat = NA, sp_hat = NA) {
  data.frame(method = label,
             pi_hat = round(pi_hat, 3),
             accuracy = round(mean((post > 0.5) == c_true), 3),
             brier = round(mean((post - c_true)^2), 3),
             mean_sens_hat = round(mean(se_hat), 3),
             mean_spec_hat = round(mean(sp_hat), 3))
}

run_scenario <- function(name, s_th, s_ph, s_ps, fit_stan = TRUE, seed = 2026) {
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

  shares <- NULL
  if (fit_stan) {
    fit <- sampling(stan_mod,
                    data = list(N = sim$N, M = sim$M, P = sim$P, R = sim$R, S = sim$S),
                    chains = 2, iter = 1000, warmup = 500, seed = seed,
                    refresh = 0, control = list(adapt_delta = 0.9))
    post1 <- colMeans(rstan::extract(fit, "post1")[[1]])
    pi_hat <- mean(rstan::extract(fit, "pi1")[[1]])
    res <- rbind(res, summarise_fit("CRE-LCM (proposed)", sim$c_true, post1, pi_hat))
    sm <- summary(fit, pars = c("s_th", "s_ph", "s_ps", "share_item",
                                "share_model", "share_prompt", "share_run"))$summary
    shares <- round(sm[, c("mean", "2.5%", "97.5%", "Rhat")], 3)
    tv <- sim$truth
    vt <- tv$s_th^2 + tv$s_ph^2 + tv$s_ps^2 + pi^2 / 3
    shares <- cbind(shares, true = round(c(tv$s_th, tv$s_ph, tv$s_ps,
                                           tv$s_th^2 / vt, tv$s_ph^2 / vt,
                                           tv$s_ps^2 / vt, (pi^2 / 3) / vt), 3))
  }
  cat("\n==============================================================\n")
  cat("Scenario:", name, " (s_th =", s_th, ", s_ph =", s_ph, ", s_ps =", s_ps, ")\n")
  cat("==============================================================\n")
  print(res, row.names = FALSE)
  if (!is.null(shares)) { cat("\nVariance components (CRE-LCM):\n"); print(shares) }
  invisible(list(res = res, shares = shares))
}

stan_mod <- stan_model("stan/crossed_lcre.stan")

out_A <- run_scenario("A: conditional independence", 0, 0, 0, fit_stan = FALSE)
out_B <- run_scenario("B: crossed dependence",       1.0, 0.8, 0.5, fit_stan = TRUE)

saveRDS(list(A = out_A, B = out_B), "pilot_results.rds")

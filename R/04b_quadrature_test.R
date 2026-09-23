# =============================================================================
# 04b_quadrature_test.R
# Variant (q): theta_i integrated out by Gauss-Hermite quadrature (stan/
# crossed_lcre_q_quad.stan). Fitted to the scenario-B data of the identifiability
# study with the same settings as variant (e): 4 chains x 2000, seed 2026,
# Dawid-Skene initialisation. Compares mixing (ESS, R-hat), per-chain agreement,
# recovery and runtime with (e). Output: results/identifiability/draws_q.rds,
# results/identifiability/quadrature_test.md
# Usage: Rscript R/04b_quadrature_test.R   (env QUAD_Q = nodes, default 15)
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
source("R/01_simulate.R"); source("R/02_baselines.R")
Q <- as.integer(Sys.getenv("QUAD_Q", unset = "15"))
CHAINS <- 4; WARMUP <- 1000; SAMPLING <- 1000; SEED <- 2026
out_dir <- "results/identifiability"

# Gauss-Hermite rule for the standard normal weight (Golub-Welsch on the
# probabilists' Hermite recurrence): nodes x_q, weights w_q summing to 1.
gauss_hermite_normal <- function(Q) {
  J <- matrix(0, Q, Q); off <- sqrt(seq_len(Q - 1))
  J[cbind(1:(Q - 1), 2:Q)] <- off; J[cbind(2:Q, 1:(Q - 1))] <- off
  e <- eigen(J, symmetric = TRUE)
  list(x = e$values, w = e$vectors[1, ]^2)
}
gh <- gauss_hermite_normal(Q)
stopifnot(abs(sum(gh$w) - 1) < 1e-10, abs(sum(gh$w * gh$x^2) - 1) < 1e-8)

sim <- simulate_lcre(s_th = 1.0, s_ph = 0.8, s_ps = 0.5, seed = SEED)
X <- expand_ratings(sim); ds <- dawid_skene_binary(X)
data <- list(N = sim$N, M = sim$M, P = sim$P, R = sim$R, S = sim$S,
             Q = Q, x_q = gh$x, log_w_q = log(gh$w))
init <- function() list(pi1 = ds$pi1, mu = c(qlogis(1 - mean(ds$sp)), qlogis(mean(ds$se))),
                        a_raw = matrix(0, sim$M - 1, 2), b_z = matrix(0, sim$P, 2),
                        tau_b = c(0.3, 0.3), s_th = 0.5, s_ph = 0.5, s_ps = 0.5,
                        ph_z = matrix(0, sim$N, sim$M), ps_z = matrix(0, sim$N, sim$P))

tag <- if (Q == 15) "q" else paste0("q", Q)
dpath <- file.path(out_dir, paste0("draws_", tag, ".rds"))
if (file.exists(dpath)) { out <- readRDS(dpath) } else {
  mod <- compile_stan("stan/crossed_lcre_q_quad.stan")
  s <- sample_stan(mod, data = data, chains = CHAINS, iter_warmup = WARMUP, iter_sampling = SAMPLING,
                   seed = SEED, adapt_delta = 0.9, init = init)
  gvars <- c("pi1", "mu", "a", "tau_b", "s_th", "s_ph", "s_ps", "share_item", "share_model", "share_prompt", "share_run", "lp__")
  draws <- s$draws
  pc <- posterior::subset_draws(draws, variable = c("pi1", "mu", "s_th", "s_ph", "s_ps", "lp__"))
  out <- list(variant = tag, label = sprintf("(q) theta integrated by %d-node Gauss-Hermite, DS init", Q),
              global = posterior::subset_draws(draws, variable = gvars),
              post1 = posterior::as_draws_matrix(posterior::subset_draws(draws, variable = "post1")),
              log_lik = posterior::as_draws_matrix(posterior::subset_draws(draws, variable = "log_lik")),
              chain_id = posterior::as_draws_df(draws)$.chain,
              diag = cbind(s$diag, runtime_sec = s$runtime_sec, chains = CHAINS, iter_warmup = WARMUP,
                           iter_sampling = SAMPLING, seed = SEED, Q = Q),
              per_chain = t(apply(posterior::as_draws_array(pc), c(2, 3), mean)),
              chain_time = if (STAN_BACKEND == "cmdstanr") s$fit$time()$chains else NULL)
  fpath <- file.path(out_dir, "fits", paste0("fit_", tag, ".rds"))
  if (!protect(fpath) && STAN_BACKEND == "cmdstanr") s$fit$save_object(fpath)
  saveRDS(out, dpath)
}

# --- comparison with (e) --------------------------------------------------------
e <- readRDS(file.path(out_dir, "draws_e.rds"))
tv <- sim$truth; vt <- tv$s_th^2 + tv$s_ph^2 + tv$s_ps^2 + pi^2 / 3
truth <- c(pi1 = tv$pi1, `mu[1]` = tv$mu[1], `mu[2]` = tv$mu[2], `a[3,1]` = tv$a[3, 1], `a[3,2]` = tv$a[3, 2],
           s_th = tv$s_th, s_ph = tv$s_ph, s_ps = tv$s_ps, share_item = tv$s_th^2 / vt,
           share_model = tv$s_ph^2 / vt, share_prompt = tv$s_ps^2 / vt, share_run = (pi^2 / 3) / vt)
key <- names(truth)
summ <- function(f) { s <- summ_vars(f$global, key); s <- s[match(key, s$variable), ]; s }
se <- summ(e); sq <- summ(out)
lab <- function(f) { p <- colMeans(f$post1); c(accuracy = mean((p > 0.5) == sim$c_true), brier = mean((p - sim$c_true)^2)) }
tab <- data.frame(parameter = key, true = round(truth, 3),
                  e_mean = round(se$mean, 3), e_ci = sprintf("[%.2f, %.2f]", se$q2.5, se$q97.5), e_rhat = round(se$rhat, 2), e_ess = round(se$ess_bulk),
                  q_mean = round(sq$mean, 3), q_ci = sprintf("[%.2f, %.2f]", sq$q2.5, sq$q97.5), q_rhat = round(sq$rhat, 2), q_ess = round(sq$ess_bulk))
md_tab <- function(df) c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
                         apply(df, 1, function(r) paste0("| ", paste(trimws(format(r)), collapse = " | "), " |")))
le <- lab(e); lq <- lab(out)
md <- c(sprintf("# Quadrature variant (q, Q = %d nodes) versus (e) on scenario B", Q), "",
        sprintf("Same data (N = 300, seed 2026), same sampler settings (4 chains x 2000, adapt_delta 0.9, Dawid-Skene initialisation)."), "",
        "## Recovery and mixing", "", md_tab(tab), "",
        "## Labels, diagnostics, runtime", "",
        sprintf("- (e): accuracy %.3f, Brier %.3f, divergences %d, runtime %.1f min (4 parallel chains)", le["accuracy"], le["brier"], e$diag$divergences, e$diag$runtime_sec / 60),
        sprintf("- (q): accuracy %.3f, Brier %.3f, divergences %d, runtime %.1f min (4 parallel chains); ESS per minute for pi1: (e) %.1f, (q) %.1f",
                lq["accuracy"], lq["brier"], out$diag$divergences, out$diag$runtime_sec / 60,
                se$ess_bulk[1] / (e$diag$runtime_sec / 60), sq$ess_bulk[1] / (out$diag$runtime_sec / 60)),
        "", "## Per-chain posterior means, (q)", "", md_tab(data.frame(parameter = rownames(out$per_chain), round(out$per_chain, 3))))
writeLines(md, file.path(out_dir, paste0("quadrature_test", if (Q != 15) paste0("_Q", Q) else "", ".md")))
cat(md, sep = "\n")

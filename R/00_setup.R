# =============================================================================
# 00_setup.R
# Environment checks shared by every script: packages, Stan backend, cores,
# output directories and a helper that records seeds/sessionInfo.
# Source from the project root:  source("R/00_setup.R")
# =============================================================================

required_pkgs <- c("ggplot2", "dplyr", "tidyr", "purrr", "posterior",
                   "bayesplot", "loo", "furrr", "future", "mvtnorm", "jsonlite")
missing <- required_pkgs[!vapply(required_pkgs, requireNamespace,
                                  logical(1), quietly = TRUE)]
if (length(missing)) {
  message("Installing missing packages: ", paste(missing, collapse = ", "))
  install.packages(missing, repos = "https://cloud.r-project.org")
}
invisible(lapply(required_pkgs, function(p)
  suppressPackageStartupMessages(library(p, character.only = TRUE))))

# --- Stan backend: cmdstanr preferred, rstan as fallback ---------------------
if (requireNamespace("cmdstanr", quietly = TRUE) &&
    !is.null(tryCatch(cmdstanr::cmdstan_path(), error = function(e) NULL))) {
  STAN_BACKEND <- "cmdstanr"
  suppressPackageStartupMessages(library(cmdstanr))
} else if (requireNamespace("rstan", quietly = TRUE)) {
  STAN_BACKEND <- "rstan"
  suppressPackageStartupMessages(library(rstan))
  rstan_options(auto_write = TRUE)
} else {
  stop("Neither cmdstanr (with CmdStan installed) nor rstan is available. ",
       "See README.md, section 'Setup'.")
}

# --- cores: all but one --------------------------------------------------------
N_CORES <- max(1L, parallel::detectCores() - 1L)
options(mc.cores = N_CORES)

# --- directories ---------------------------------------------------------------
for (d in c("results", "results/pilot", "results/identifiability",
            "results/grid", "figures", "tables"))
  dir.create(d, showWarnings = FALSE, recursive = TRUE)

# --- helpers -------------------------------------------------------------------
# Compile a Stan file (cached executable next to the .stan file for cmdstanr).
compile_stan <- function(file) {
  if (STAN_BACKEND == "cmdstanr") cmdstanr::cmdstan_model(file)
  else rstan::stan_model(file)
}

# Sample with a uniform interface; returns a list with a posterior::draws_df
# `draws`, a diagnostic data.frame `diag`, runtime in seconds and the fit.
sample_stan <- function(mod, data, chains = 4, iter_warmup = 1000,
                        iter_sampling = 1000, seed = 2026, adapt_delta = 0.9,
                        max_treedepth = 10, parallel_chains = min(chains, N_CORES),
                        refresh = 0, output_dir = NULL, ...) {
  t0 <- Sys.time()
  if (STAN_BACKEND == "cmdstanr") {
    fit <- mod$sample(data = data, chains = chains, parallel_chains = parallel_chains,
                      iter_warmup = iter_warmup, iter_sampling = iter_sampling,
                      seed = seed, adapt_delta = adapt_delta,
                      max_treedepth = max_treedepth, refresh = refresh,
                      output_dir = output_dir, show_messages = FALSE, ...)
    draws <- posterior::as_draws_df(fit$draws())
    sd <- fit$sampler_diagnostics(format = "df")
    diag <- data.frame(divergences = sum(sd$divergent__),
                       max_treedepth_hits = sum(sd$treedepth__ >= max_treedepth))
  } else {
    fit <- rstan::sampling(mod, data = data, chains = chains, cores = parallel_chains,
                           iter = iter_warmup + iter_sampling, warmup = iter_warmup,
                           seed = seed, refresh = refresh,
                           control = list(adapt_delta = adapt_delta,
                                          max_treedepth = max_treedepth), ...)
    draws <- posterior::as_draws_df(fit)
    sp <- rstan::get_sampler_params(fit, inc_warmup = FALSE)
    diag <- data.frame(divergences = sum(sapply(sp, function(x) sum(x[, "divergent__"]))),
                       max_treedepth_hits = sum(sapply(sp, function(x) sum(x[, "treedepth__"] >= max_treedepth))))
  }
  list(fit = fit, draws = draws, diag = diag,
       runtime_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")))
}

# Convergence summary for a set of variables (regex on names).
summ_vars <- function(draws, vars) {
  s <- posterior::summarise_draws(posterior::subset_draws(draws, variable = vars),
                                  "mean", "sd", ~quantile2(.x, probs = c(0.025, 0.975)),
                                  "rhat", "ess_bulk", "ess_tail")
  as.data.frame(s)
}

# Write session info once per run for the reproducibility record.
record_session <- function(path = "results/session_info.txt") {
  con <- file(path, "w"); on.exit(close(con))
  writeLines(c(paste("Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
               paste("Stan backend:", STAN_BACKEND,
                     if (STAN_BACKEND == "cmdstanr") paste("CmdStan", cmdstanr::cmdstan_version())),
               paste("Cores used:", N_CORES), "",
               capture.output(sessionInfo())), con)
}

# Ensure we never overwrite raw results: returns TRUE if a file already exists.
protect <- function(path) {
  if (file.exists(path)) { message("exists, not overwritten: ", path); TRUE } else FALSE
}

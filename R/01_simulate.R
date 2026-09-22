# =============================================================================
# 01_simulate.R
# Data-generating process: binary latent class with crossed random effects
#
# Each "rater" is a configuration (model m, prompt p, run r).
# Conditional on the true class c_i, the log-odds of label 1 is
#
#   eta_{i m p k} = mu_k + a_{m k} + b_{p k} + theta_i + phi_{i m} + psi_{i p}
#
#   theta_i  ~ N(0, s_th^2)  item ambiguity shared by ALL configurations
#   phi_{im} ~ N(0, s_ph^2)  item x model idiosyncrasy (shared across prompts/runs)
#   psi_{ip} ~ N(0, s_ps^2)  item x prompt idiosyncrasy (shared across models/runs)
#   runs r = 1..R are conditionally independent given all of the above.
#
# With s_th = s_ph = s_ps = 0 the model reduces to Dawid-Skene
# (conditional independence).
# =============================================================================

simulate_lcre <- function(N = 300, M = 3, P = 5, R = 3,
                          pi1  = 0.30,
                          mu   = c(-2.0, 1.5),            # class 0, class 1
                          a    = NULL,                    # M x 2 model effects
                          tau_b = c(0.4, 0.4),            # prompt effect SDs
                          s_th = 1.0, s_ph = 0.8, s_ps = 0.5,
                          seed = 1, re_dist = c("normal", "t4")) {
  # re_dist = "t4": item random effects theta, phi, psi follow a scaled
  # Student-t with 4 df (misspecification arm); scaled so that the SD equals
  # s_th, s_ph, s_ps as in the normal case. Default "normal" is unchanged.
  re_dist <- match.arg(re_dist)
  rre <- function(n, s) if (re_dist == "normal") rnorm(n, 0, s) else s * rt(n, df = 4) / sqrt(2)
  set.seed(seed)
  if (is.null(a)) {
    a <- cbind(seq(0, 0.6, length.out = M),               # FPR worsens
               seq(0.3, -0.5, length.out = M))            # sensitivity worsens
    a[1, ] <- 0                                            # reference model
  }
  b <- cbind(rnorm(P, 0, tau_b[1]), rnorm(P, 0, tau_b[2]))

  c_true <- rbinom(N, 1, pi1)
  theta  <- rre(N, s_th)
  phi    <- matrix(rre(N * M, s_ph), N, M)
  psi    <- matrix(rre(N * P, s_ps), N, P)

  # S[i, m, p] = number of runs (out of R) labelled 1
  S <- array(0L, c(N, M, P))
  for (i in 1:N) {
    k <- c_true[i] + 1
    for (m in 1:M) for (p in 1:P) {
      eta <- mu[k] + a[m, k] + b[p, k] + theta[i] + phi[i, m] + psi[i, p]
      S[i, m, p] <- rbinom(1, R, plogis(eta))
    }
  }

  list(S = S, c_true = c_true, N = N, M = M, P = P, R = R,
       truth = list(pi1 = pi1, mu = mu, a = a, b = b,
                    s_th = s_th, s_ph = s_ph, s_ps = s_ps, re_dist = re_dist))
}

# Expand counts into a binary rating matrix: rows = items,
# columns = configurations (m, p, r). Used by majority vote and Dawid-Skene.
expand_ratings <- function(sim) {
  with(sim, {
    X <- matrix(0L, N, M * P * R)
    col <- 0
    for (m in 1:M) for (p in 1:P) for (r in 1:R) {
      col <- col + 1
      X[, col] <- as.integer(S[, m, p] >= r)   # exchangeable within (m, p)
    }
    X
  })
}

# True marginal sensitivity / specificity of each (model, prompt) config,
# integrating over the item random effects by Monte Carlo.
true_marginal_accuracy <- function(sim, nmc = 20000) {
  tr <- sim$truth
  z <- if (is.null(tr$re_dist) || tr$re_dist == "normal")
    rnorm(nmc, 0, sqrt(tr$s_th^2 + tr$s_ph^2 + tr$s_ps^2))
  else (tr$s_th * rt(nmc, 4) + tr$s_ph * rt(nmc, 4) + tr$s_ps * rt(nmc, 4)) / sqrt(2)
  out <- expand.grid(m = 1:sim$M, p = 1:sim$P)
  out$sens <- mapply(function(m, p) mean(plogis(tr$mu[2] + tr$a[m, 2] + tr$b[p, 2] + z)),
                     out$m, out$p)
  out$spec <- mapply(function(m, p) mean(1 - plogis(tr$mu[1] + tr$a[m, 1] + tr$b[p, 1] + z)),
                     out$m, out$p)
  out
}

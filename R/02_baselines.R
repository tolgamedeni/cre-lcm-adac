# =============================================================================
# 02_baselines.R
# Baselines: majority vote and binary Dawid-Skene (EM, conditional independence)
# =============================================================================

majority_vote <- function(X) {
  as.integer(rowMeans(X) > 0.5)
}

# Binary Dawid-Skene: each column of X is a rater with its own
# sensitivity (se_j) and specificity (sp_j); raters assumed independent
# given the true class.
dawid_skene_binary <- function(X, max_iter = 500, tol = 1e-8, eps = 1e-6) {
  N <- nrow(X); J <- ncol(X)
  q <- rowMeans(X)                        # init posterior P(c_i = 1)
  ll_old <- -Inf
  for (it in 1:max_iter) {
    # M-step
    pi1 <- mean(q)
    se  <- pmin(pmax(colSums(q * X) / sum(q), eps), 1 - eps)
    sp  <- pmin(pmax(colSums((1 - q) * (1 - X)) / sum(1 - q), eps), 1 - eps)
    # E-step (log scale)
    l1 <- log(pi1)     + X %*% log(se)     + (1 - X) %*% log(1 - se)
    l0 <- log(1 - pi1) + X %*% log(1 - sp) + (1 - X) %*% log(sp)
    mx <- pmax(l0, l1)
    ll <- sum(mx + log(exp(l0 - mx) + exp(l1 - mx)))
    q  <- as.vector(1 / (1 + exp(l0 - l1)))
    if (abs(ll - ll_old) < tol) break
    ll_old <- ll
  }
  list(pi1 = pi1, se = se, sp = sp, post = q, loglik = ll, iter = it)
}

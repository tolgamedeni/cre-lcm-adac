# =============================================================================
# scripts/analyze_application.R  -- Section 5 analysis (manuscript/section5_data_plan.md, part 5)
# Inputs : data/bills_sample.csv, data/labels_long.csv, data/labels_temp0.csv
# Fits   : Dawid-Skene (EM, missing-aware), CRE-LCM quadrature (DS init, 4 x 1500),
#          CRE-LCM quadrature with 5% anchoring (30 working items, seed 2026)
#          All models are fitted to the LLM labels of all 800 bills; the CAP human labels are
#          never used except for the 30 anchors (working items only) and for evaluation.
# Outputs: results/application/  (tables as csv + tex, Fig5 calibration, Fig6 PPC, summary.md)
# Env    : APP_DATA_DIR (default data), APP_OUT (default results/application),
#          APP_WARMUP / APP_SAMPLING (default 750 / 750 = 1500 iterations), APP_CHAINS (4)
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
source("R/01_simulate.R"); source("R/02_baselines.R")
suppressPackageStartupMessages({library(ggplot2); library(dplyr); library(tidyr)})
DATA <- Sys.getenv("APP_DATA_DIR", "data"); OUT <- Sys.getenv("APP_OUT", "results/application")
WARMUP <- as.integer(Sys.getenv("APP_WARMUP", "750")); SAMPLING <- as.integer(Sys.getenv("APP_SAMPLING", "750"))
CHAINS <- as.integer(Sys.getenv("APP_CHAINS", "4")); SEED <- 2026; Q <- 15; ANCHOR_N <- 30
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
MM <- 1 / 25.4; W1 <- 84 * MM; W2 <- 174 * MM
theme_j <- function(base = 9) theme_bw(base_size = base, base_family = "Helvetica") +
  theme(panel.grid.minor = element_blank(), strip.background = element_rect(fill = "grey94", colour = NA),
        legend.position = "bottom", plot.title = element_blank(), plot.margin = margin(2, 4, 2, 2))
save_fig <- function(p, n, width, height) {
  ggsave(sprintf("figures/Fig%d.pdf", n), p, width = width, height = height, device = grDevices::pdf, family = "Helvetica", useDingbats = FALSE)
  ggsave(sprintf("figures/Fig%d.eps", n), p, width = width, height = height, device = grDevices::postscript, family = "Helvetica", horizontal = FALSE, onefile = FALSE, paper = "special")
}
fmt <- function(x, d = 3) { x <- ifelse(!is.na(x) & abs(x) < 0.5 * 10^-d, 0, x); ifelse(is.na(x), "--", formatC(x, digits = d, format = "f")) }
write_booktabs <- function(df, file, caption, label, header = NULL, align = NULL, note = NULL, size = "\\small", colsep = NULL) {
  if (is.null(align)) align <- paste0("l", strrep("r", ncol(df) - 1))
  hdr <- if (is.null(header)) paste(names(df), collapse = " & ") else header
  writeLines(c("\\begin{table}[htbp]", "\\centering", size, if (!is.null(colsep)) sprintf("\\setlength{\\tabcolsep}{%s}", colsep),
               sprintf("\\caption{%s}\\label{%s}", caption, label), sprintf("\\begin{tabular}{%s}", align), "\\toprule",
               paste0(hdr, " \\\\"), "\\midrule", paste0(apply(df, 1, paste, collapse = " & "), " \\\\"), "\\bottomrule", "\\end{tabular}",
               if (!is.null(note)) c("\\begin{flushleft}\\footnotesize", note, "\\end{flushleft}"), "\\end{table}"), file)
}

# ---- data -----------------------------------------------------------------------
bills <- read.csv(file.path(DATA, "bills_sample.csv"), stringsAsFactors = FALSE)
truth_col <- if ("health_true_sim" %in% names(bills)) "health_true_sim" else "health"   # synthetic test hook
bills$y <- bills[[truth_col]]
long <- read.csv(file.path(DATA, "labels_long.csv"), stringsAsFactors = FALSE)
models <- sort(unique(long$model)); M <- length(models); P <- max(long$prompt); R <- max(long$run)
N <- nrow(bills); bills$idx <- seq_len(N); long$i <- match(long$bill_id, bills$bill_id); long$m <- match(long$model, models)
stopifnot(!anyNA(long$i))
cat(sprintf("[app] %d bills, %d models (%s), %d prompts, %d runs, %d labels, %.2f%% missing\n",
            N, M, paste(models, collapse = "/"), P, R, nrow(long), 100 * mean(long$missing == 1)))
# counts S[i,m,p] and valid runs R_imp[i,m,p]
S <- array(0L, c(N, M, P)); Rv <- array(0L, c(N, M, P))
ok <- long$missing == 0
for (k in which(ok)) { S[long$i[k], long$m[k], long$prompt[k]] <- S[long$i[k], long$m[k], long$prompt[k]] + long$label[k]
                       Rv[long$i[k], long$m[k], long$prompt[k]] <- Rv[long$i[k], long$m[k], long$prompt[k]] + 1L }
# rating matrix (N x M*P*R) with NA for missing, columns ordered (m, p, r)
X <- matrix(NA_integer_, N, M * P * R); cfg <- expand.grid(r = 1:R, p = 1:P, m = 1:M)[, c("m", "p", "r")]
col_of <- function(m, p, r) (m - 1) * P * R + (p - 1) * R + r
X[cbind(long$i[ok], col_of(long$m[ok], long$prompt[ok], long$run[ok]))] <- long$label[ok]
cfg$name <- sprintf("%s-P%d-r%d", models[cfg$m], cfg$p, cfg$r)

# ---- 1. descriptives: agreement matrix, Fleiss kappa ----------------------------
agree <- matrix(NA, ncol(X), ncol(X), dimnames = list(cfg$name, cfg$name))
for (a in seq_len(ncol(X))) for (b in seq_len(ncol(X))) { v <- !is.na(X[, a]) & !is.na(X[, b]); agree[a, b] <- mean(X[v, a] == X[v, b]) }
write.csv(round(agree, 3), file.path(OUT, "agreement_matrix.csv"))
fleiss <- function(Xm) {   # Fleiss' kappa for binary ratings with a variable number of raters per item
  n1 <- rowSums(Xm == 1, na.rm = TRUE); nr <- rowSums(!is.na(Xm)); keep <- nr >= 2; n1 <- n1[keep]; nr <- nr[keep]
  Pi <- (n1 * (n1 - 1) + (nr - n1) * (nr - n1 - 1)) / (nr * (nr - 1)); Pbar <- mean(Pi)
  p1 <- sum(n1) / sum(nr); Pe <- p1^2 + (1 - p1)^2; (Pbar - Pe) / (1 - Pe) }
kap <- data.frame(model = c(models, "all 45 configurations"),
                  n_config = c(rep(P * R, M), M * P * R),
                  fleiss_kappa = c(sapply(1:M, function(m) fleiss(X[, cfg$m == m])), fleiss(X)),
                  mean_pairwise_agreement = c(sapply(1:M, function(m) { A <- agree[cfg$m == m, cfg$m == m]; mean(A[upper.tri(A)]) }), mean(agree[upper.tri(agree)])),
                  pct_label_1 = c(sapply(1:M, function(m) 100 * mean(X[, cfg$m == m], na.rm = TRUE)), 100 * mean(X, na.rm = TRUE)),
                  pct_missing = c(sapply(1:M, function(m) 100 * mean(is.na(X[, cfg$m == m]))), 100 * mean(is.na(X))))
# between-model agreement (mean pairwise agreement across models, same prompt & run)
between <- sapply(1:M, function(a) sapply(1:M, function(b) mean(agree[cfg$m == a, cfg$m == b][cfg$p[cfg$m == a] == rep(cfg$p[cfg$m == b], each = 1)])))
write.csv(kap, file.path(OUT, "fleiss_kappa.csv"), row.names = FALSE)
write_booktabs(data.frame(model = kap$model, k = kap$n_config, kappa = fmt(kap$fleiss_kappa), agree = fmt(kap$mean_pairwise_agreement), p1 = fmt(kap$pct_label_1, 1), miss = fmt(kap$pct_missing, 2)),
  file.path(OUT, "table7_agreement.tex"),
  caption = "Agreement among the LLM configurations on the 800 bills: Fleiss' $\\kappa$ and mean pairwise agreement within each model (15 configurations: 5 prompts $\\times$ 3 runs) and over all 45 configurations; percentage of labels equal to 1 and of missing (unparsable) answers",
  label = "tab:agreement", header = "Model & configurations & Fleiss' $\\kappa$ & pairwise agreement & \\% label 1 & \\% missing", align = "lrrrrr")

# ---- 2. Dawid-Skene (EM, missing-aware) and majority vote -----------------------
ds_missing <- function(X, max_iter = 500, tol = 1e-8, eps = 1e-6) {
  obs <- !is.na(X); X0 <- ifelse(obs, X, 0); q <- rowMeans(X, na.rm = TRUE); ll_old <- -Inf
  for (it in 1:max_iter) {
    pi1 <- mean(q)
    se <- pmin(pmax(colSums(q * X0) / colSums(q * obs), eps), 1 - eps)
    sp <- pmin(pmax(colSums((1 - q) * (1 - X0) * obs) / colSums((1 - q) * obs), eps), 1 - eps)
    l1 <- log(pi1) + (X0 %*% log(se)) + ((1 - X0) * obs) %*% log(1 - se)
    l0 <- log(1 - pi1) + (X0 %*% log(1 - sp)) + ((1 - X0) * obs) %*% log(sp)
    mx <- pmax(l0, l1); ll <- sum(mx + log(exp(l0 - mx) + exp(l1 - mx))); q <- as.vector(1 / (1 + exp(l0 - l1)))
    if (abs(ll - ll_old) < tol) break; ll_old <- ll }
  list(pi1 = pi1, se = se, sp = sp, post = q, loglik = ll, iter = it) }
ds <- ds_missing(X); mv <- as.integer(rowMeans(X, na.rm = TRUE) > 0.5)
cat(sprintf("[app] Dawid-Skene: prevalence %.3f, mean sens %.3f, mean spec %.3f (%d iterations)\n", ds$pi1, mean(ds$se), mean(ds$sp), ds$iter))

# ---- 3. CRE-LCM quadrature fits --------------------------------------------------
gauss_hermite_normal <- function(Q) { J <- matrix(0, Q, Q); off <- sqrt(seq_len(Q - 1)); J[cbind(1:(Q - 1), 2:Q)] <- off; J[cbind(2:Q, 1:(Q - 1))] <- off
  e <- eigen(J, symmetric = TRUE); list(x = e$values, w = e$vectors[1, ]^2) }
gh <- gauss_hermite_normal(Q)
set.seed(SEED); anchor_idx <- sort(sample(bills$idx[bills$split == "working"], ANCHOR_N)); anchor_lab <- bills$y[anchor_idx]
init <- function() list(pi1 = ds$pi1, mu = c(qlogis(1 - mean(ds$sp)), qlogis(mean(ds$se))), a_raw = matrix(0, M - 1, 2), b_z = matrix(0, P, 2),
                        tau_b = c(0.3, 0.3), s_th = 0.5, s_ph = 0.5, s_ps = 0.5, ph_z = matrix(0, N, M), ps_z = matrix(0, N, P))
mod <- compile_stan("stan/crossed_lcre_q_app.stan")
fit_app <- function(tag, n_anchor, a_idx, a_lab) {
  f <- file.path(OUT, paste0("fit_", tag, ".rds"))
  if (file.exists(f)) { message("[app] reuse ", f); return(readRDS(f)) }
  data <- list(N = N, M = M, P = P, R_imp = Rv, S = S, Q = Q, x_q = gh$x, log_w_q = log(gh$w), N_anchor = n_anchor, anchor_idx = as.array(a_idx), anchor_lab = as.array(a_lab))
  s <- sample_stan(mod, data = data, chains = CHAINS, iter_warmup = WARMUP, iter_sampling = SAMPLING, seed = SEED, adapt_delta = 0.9, init = init)
  gv <- c("pi1", "mu", "a", "b", "tau_b", "s_th", "s_ph", "s_ps", "share_item", "share_model", "share_prompt", "share_run", "lp__")
  g <- posterior::subset_draws(s$draws, variable = gv)
  out <- list(tag = tag, global = g, summ = summ_vars(g, gv),
              post1 = colMeans(posterior::as_draws_matrix(posterior::subset_draws(s$draws, variable = "post1"))),
              S_rep = posterior::as_draws_matrix(posterior::subset_draws(s$draws, variable = "S_rep"))[seq(1, CHAINS * SAMPLING, length.out = 200), ],
              per_chain = t(apply(posterior::as_draws_array(posterior::subset_draws(g, variable = c("pi1", "mu", "s_th"))), c(2, 3), mean)),
              diag = c(s$diag, runtime_sec = s$runtime_sec), anchor_idx = a_idx)
  saveRDS(out, f); out }
fq <- fit_app("cre_q", 0L, integer(0), integer(0))
cat(sprintf("[app] CRE-LCM (q): %.1f min, max R-hat %.3f, divergences %d\n", fq$diag[["runtime_sec"]] / 60, max(fq$summ$rhat, na.rm = TRUE), fq$diag[["divergences"]]))
fa <- fit_app("cre_q_anchor", ANCHOR_N, anchor_idx, anchor_lab)
cat(sprintf("[app] CRE-LCM (q, anchored): %.1f min, max R-hat %.3f, divergences %d\n", fa$diag[["runtime_sec"]] / 60, max(fa$summ$rhat, na.rm = TRUE), fa$diag[["divergences"]]))

# ---- 4. evaluation against CAP labels ----------------------------------------------
val <- bills$split == "validation"; nonanch <- bills$split == "working" & !(bills$idx %in% anchor_idx)
metrics <- function(post, sub) { y <- bills$y[sub]; p <- post[sub]; c(n = sum(sub), accuracy = mean((p > 0.5) == y), brier = mean((p - y)^2),
  sens = mean(p[y == 1] > 0.5), spec = mean(p[y == 0] <= 0.5), prev_hat = mean(p)) }
posts <- list(`Majority vote` = mv, `Dawid--Skene` = ds$post, `CRE-LCM` = fq$post1, `CRE-LCM, 5\\% anchored` = fa$post1)
ev <- do.call(rbind, lapply(names(posts), function(nm) rbind(
  data.frame(method = nm, set = "validation (200)", t(metrics(posts[[nm]], val))),
  data.frame(method = nm, set = sprintf("working, non-anchored (%d)", sum(nonanch)), t(metrics(posts[[nm]], nonanch))))))
ev$true_prev <- ifelse(grepl("validation", ev$set), mean(bills$y[val]), mean(bills$y[nonanch]))
write.csv(ev, file.path(OUT, "evaluation.csv"), row.names = FALSE)
write_booktabs(data.frame(method = ev$method, set = ev$set, acc = fmt(ev$accuracy), brier = fmt(ev$brier), sens = fmt(ev$sens), spec = fmt(ev$spec), prev = fmt(ev$prev_hat), tp = fmt(ev$true_prev)),
  file.path(OUT, "table8_evaluation.tex"),
  caption = "Posterior labels against the CAP human codes: accuracy, Brier score, sensitivity and specificity of the labels (threshold 0.5) and the estimated prevalence, on the 200 validation bills (never anchored) and on the non-anchored working bills",
  label = "tab:app_eval", header = "Method & Set & Accuracy & Brier & Sens. & Spec. & $\\hat\\pi_1$ & $\\pi_1$ (CAP)", align = "llrrrrrr", size = "\\scriptsize")

# ---- 5. variance shares ------------------------------------------------------------
sh <- fq$summ[fq$summ$variable %in% c("s_th", "s_ph", "s_ps", "share_item", "share_model", "share_prompt", "share_run", "pi1"), ]
sha <- fa$summ[fa$summ$variable %in% sh$variable, ]
shares <- data.frame(quantity = sh$variable, q_mean = sh$mean, q_lo = sh$q2.5, q_hi = sh$q97.5, q_ess = sh$ess_bulk, q_rhat = sh$rhat,
                     anchored_mean = sha$mean[match(sh$variable, sha$variable)], anchored_lo = sha$q2.5[match(sh$variable, sha$variable)], anchored_hi = sha$q97.5[match(sh$variable, sha$variable)])
write.csv(shares, file.path(OUT, "variance_shares.csv"), row.names = FALSE)
lab_q <- c(pi1 = "$\\pi_1$", s_th = "$\\sigma_\\theta$", s_ph = "$\\sigma_\\phi$", s_ps = "$\\sigma_\\psi$", share_item = "item share", share_model = "model share", share_prompt = "prompt share", share_run = "run share")
write_booktabs(data.frame(q = lab_q[shares$quantity], a = sprintf("%s [%s, %s]", fmt(shares$q_mean), fmt(shares$q_lo, 2), fmt(shares$q_hi, 2)),
                          b = sprintf("%s [%s, %s]", fmt(shares$anchored_mean), fmt(shares$anchored_lo, 2), fmt(shares$anchored_hi, 2)), ess = fmt(shares$q_ess, 0)),
  file.path(OUT, "table9_shares.tex"),
  caption = "CRE-LCM estimates on the bills: prevalence, random-effect standard deviations and variance shares (posterior mean and 95\\% credible interval) without and with 30 anchored bills; bulk ESS of the unanchored fit",
  label = "tab:app_shares", header = "Quantity & CRE-LCM & CRE-LCM, anchored & ESS", align = "llll")

# ---- 6. per-configuration sensitivity / specificity ----------------------------------
gm <- posterior::as_draws_matrix(fq$global); set.seed(1); z0 <- rnorm(4000); idx <- round(seq(1, nrow(gm), length.out = 200))
cfg_mp <- expand.grid(p = 1:P, m = 1:M)[, c("m", "p")]
model_based <- t(sapply(seq_len(nrow(cfg_mp)), function(j) { m <- cfg_mp$m[j]; p <- cfg_mp$p[j]
  v <- t(sapply(idx, function(d) { s <- sqrt(gm[d, "s_th"]^2 + gm[d, "s_ph"]^2 + gm[d, "s_ps"]^2)
    c(sens = mean(plogis(gm[d, "mu[2]"] + gm[d, sprintf("a[%d,2]", m)] + gm[d, sprintf("b[%d,2]", p)] + s * z0)),
      spec = mean(1 - plogis(gm[d, "mu[1]"] + gm[d, sprintf("a[%d,1]", m)] + gm[d, sprintf("b[%d,1]", p)] + s * z0))) }))
  c(sens = mean(v[, "sens"]), sens_lo = quantile(v[, "sens"], .025), sens_hi = quantile(v[, "sens"], .975), spec = mean(v[, "spec"]), spec_lo = quantile(v[, "spec"], .025), spec_hi = quantile(v[, "spec"], .975)) }))
empirical <- t(sapply(seq_len(nrow(cfg_mp)), function(j) { cols <- which(cfg$m == cfg_mp$m[j] & cfg$p == cfg_mp$p[j]); xs <- X[, cols]
  c(sens_h = mean(xs[bills$y == 1, ] == 1, na.rm = TRUE), spec_h = mean(xs[bills$y == 0, ] == 0, na.rm = TRUE),
    sens_ds = mean(ds$se[cols]), spec_ds = mean(ds$sp[cols])) }))
percfg <- data.frame(model = models[cfg_mp$m], prompt = cfg_mp$p, model_based, empirical)
names(percfg) <- gsub("\\.2\\.5%|\\.97\\.5%", "", names(percfg))
write.csv(percfg, file.path(OUT, "per_configuration_accuracy.csv"), row.names = FALSE)
write_booktabs(data.frame(model = percfg$model, p = percfg$prompt, sh = fmt(percfg$sens_h), sds = fmt(percfg$sens_ds), sq = sprintf("%s [%s, %s]", fmt(percfg$sens), fmt(percfg$sens_lo, 2), fmt(percfg$sens_hi, 2)),
                          ph = fmt(percfg$spec_h), pds = fmt(percfg$spec_ds), pq = sprintf("%s [%s, %s]", fmt(percfg$spec), fmt(percfg$spec_lo, 2), fmt(percfg$spec_hi, 2))),
  file.path(OUT, "table10_per_configuration.tex"),
  caption = "Sensitivity and specificity of each model--prompt configuration (averaged over its three runs): against the CAP human codes, as estimated by Dawid--Skene, and as implied by CRE-LCM (marginal over the item effects, posterior mean and 95\\% interval)",
  label = "tab:app_percfg", header = "Model & Prompt & \\multicolumn{3}{c}{Sensitivity} & \\multicolumn{3}{c}{Specificity} \\\\\n\\cmidrule(lr){3-5}\\cmidrule(lr){6-8}\n & & CAP & DS & CRE-LCM & CAP & DS & CRE-LCM", align = "llrrlrrl", size = "\\scriptsize", colsep = "3pt")

# ---- 7. Fig 5: calibration (reliability diagram) ------------------------------------
sub <- val | nonanch
short <- c(`Dawid--Skene` = "Dawid-Skene", `CRE-LCM` = "CRE-LCM", `CRE-LCM, 5\\% anchored` = "CRE-LCM anchored")
cal <- do.call(rbind, lapply(names(short), function(nm) { p <- posts[[nm]][sub]; y <- bills$y[sub]
  b <- cut(p, breaks = seq(0, 1, 0.1), include.lowest = TRUE)
  data.frame(method = short[[nm]], bin = b, p_mean = tapply(p, b, mean), y_rate = tapply(y, b, mean), n = as.vector(table(b))) }))
cal <- cal[!is.na(cal$p_mean), ]; cal$method <- factor(cal$method, levels = short)
p5 <- ggplot(cal, aes(p_mean, y_rate, colour = method, shape = method)) + geom_abline(slope = 1, intercept = 0, colour = "grey60", linewidth = 0.3) +
  geom_line(data = cal[cal$n >= 5, ], linewidth = 0.4) + geom_point(aes(size = n)) + scale_size_area(max_size = 4, name = "bills") +
  scale_colour_manual(values = c("#E69F00", "#0072B2", "#009E73"), name = NULL) + scale_shape_manual(values = c(17, 16, 15), name = NULL) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) + labs(x = "Posterior probability of Health (bin mean)", y = "Observed share of Health (CAP)") +
  theme_j() + theme(legend.box = "vertical", legend.spacing.y = unit(0, "mm")) + guides(colour = guide_legend(nrow = 1, order = 1), shape = guide_legend(nrow = 1, order = 1), size = guide_legend(nrow = 1, order = 2))
save_fig(p5, 5, W1, 110 * MM)

# ---- 8. Fig 6: posterior predictive check on per-item agreement counts --------------
obs_cnt <- rowSums(X == 1, na.rm = TRUE); nvalid <- rowSums(!is.na(X))
rep_cnt <- t(sapply(seq_len(nrow(fq$S_rep)), function(d) { Sr <- matrix(fq$S_rep[d, ], N, M * P); rowSums(Sr) }))
ppc <- rbind(data.frame(source = "observed", count = obs_cnt),
             data.frame(source = "replicated", count = as.vector(rep_cnt[1:50, ])))
p6 <- ggplot(ppc, aes(count, after_stat(density), fill = source)) + geom_histogram(binwidth = 3, position = "identity", alpha = 0.55, colour = "grey30", linewidth = 0.2) +
  scale_fill_manual(values = c(observed = "#0072B2", replicated = "#E69F00"), name = NULL) +
  labs(x = sprintf("Configurations labelling the bill Health (of %d)", M * P * R), y = "Density") + theme_j()
save_fig(p6, 6, W1, 70 * MM)
ppc_stat <- data.frame(stat = c("mean count", "SD of counts", "share of bills with 0-5", "share with 40-45", "share with 15-30 (ambiguous)"),
  observed = c(mean(obs_cnt), sd(obs_cnt), mean(obs_cnt <= 5), mean(obs_cnt >= 40), mean(obs_cnt >= 15 & obs_cnt <= 30)),
  replicated_mean = c(mean(rowMeans(rep_cnt)), mean(apply(rep_cnt, 1, sd)), mean(rep_cnt <= 5), mean(rep_cnt >= 40), mean(rep_cnt >= 15 & rep_cnt <= 30)))
write.csv(ppc_stat, file.path(OUT, "ppc_statistics.csv"), row.names = FALSE)

# ---- 9. temperature-0 sensitivity ---------------------------------------------------
t0f <- file.path(DATA, "labels_temp0.csv"); t0tab <- NULL
if (file.exists(t0f) && nrow(t0 <- read.csv(t0f)) > 0) {
  t0$i <- match(t0$bill_id, bills$bill_id); t0 <- t0[t0$missing == 0, ]
  W <- matrix(NA, N, M, dimnames = list(NULL, models)); W[cbind(t0$i, match(t0$model, models))] <- t0$label
  t0tab <- data.frame(model = models, acc_vs_CAP_T0 = sapply(1:M, function(m) mean(W[, m] == bills$y, na.rm = TRUE)),
                      acc_vs_CAP_T07_P1 = sapply(1:M, function(m) mean(X[, cfg$m == m & cfg$p == 1] == bills$y, na.rm = TRUE)),
                      within_model_T07_P1_agreement = sapply(1:M, function(m) { A <- agree[cfg$m == m & cfg$p == 1, cfg$m == m & cfg$p == 1]; mean(A[upper.tri(A)]) }))
  pair <- combn(M, 2); t0pair <- data.frame(pair = apply(pair, 2, function(k) paste(models[k], collapse = " vs ")), agreement_T0 = apply(pair, 2, function(k) mean(W[, k[1]] == W[, k[2]], na.rm = TRUE)))
  write.csv(t0tab, file.path(OUT, "temp0_sensitivity.csv"), row.names = FALSE); write.csv(t0pair, file.path(OUT, "temp0_between_models.csv"), row.names = FALSE)
}

# ---- 10. summary.md ------------------------------------------------------------------
md_tab <- function(df, d = 3) { df[] <- lapply(df, function(x) if (is.numeric(x)) formatC(x, digits = d, format = "f") else as.character(x))
  c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"), apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))) }
md <- c("# Application: policy-topic coding of US congressional bills (Section 5)", "",
  sprintf("Generated %s. %d bills (%d validation, %d working, %d anchored), %d models (%s), %d prompts, %d runs; %d labels, %.2f%% missing.",
          format(Sys.time(), "%Y-%m-%d %H:%M"), N, sum(val), sum(bills$split == "working"), ANCHOR_N, M, paste(models, collapse = ", "), P, R, nrow(long), 100 * mean(long$missing == 1)),
  sprintf("CRE-LCM: quadrature (%d nodes), %d chains x %d iterations (%d warm-up), Dawid-Skene initialisation; unanchored fit %.1f min, max R-hat %.3f; anchored fit %.1f min, max R-hat %.3f. Models fitted to the LLM labels of all 800 bills; CAP labels used only for the 30 anchors and for evaluation.",
          Q, CHAINS, WARMUP + SAMPLING, WARMUP, fq$diag[["runtime_sec"]] / 60, max(fq$summ$rhat, na.rm = TRUE), fa$diag[["runtime_sec"]] / 60, max(fa$summ$rhat, na.rm = TRUE)),
  "", "## Agreement", "", md_tab(kap), "", "## Evaluation against CAP", "", md_tab(ev[, c("method", "set", "n", "accuracy", "brier", "sens", "spec", "prev_hat", "true_prev")]),
  "", sprintf("Dawid-Skene: prevalence %.3f, mean sensitivity %.3f, mean specificity %.3f. CAP prevalence in the sample: %.3f.", ds$pi1, mean(ds$se), mean(ds$sp), mean(bills$y)),
  "", "## Variance shares (CRE-LCM)", "", md_tab(shares), "", "## Per-configuration sensitivity / specificity", "", md_tab(percfg),
  "", "## Posterior predictive check (agreement counts per bill)", "", md_tab(ppc_stat),
  "", "## Per-chain means (unanchored fit)", "", md_tab(data.frame(parameter = rownames(fq$per_chain), round(fq$per_chain, 3))),
  if (!is.null(t0tab)) c("", "## Temperature-0 sensitivity (prompt 1)", "", md_tab(t0tab), "", md_tab(t0pair)) else "",
  "", "Figures: figures/Fig5 (calibration), figures/Fig6 (posterior predictive check). Tables: results/application/table7-10*.tex.")
writeLines(md, file.path(OUT, "summary.md"))
cat("[app] done ->", OUT, "\n")

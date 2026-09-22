# =============================================================================
# 06_outputs.R
# Journal-format outputs (ADAC / Springer Nature):
#   figures/FigN.pdf + FigN.eps  -- ggplot2, vector, 84 mm or 174 mm wide,
#                                   <= 234 mm high, Helvetica 8-12 pt, no titles,
#                                   series distinguished by shape/linetype as well
#                                   as colour (Okabe-Ito, greyscale-safe)
#   tables/tableN_*.tex           -- booktabs, caption above, \label, ready for \input
# Inputs: results/baseline_table.csv, results/pilot/, results/identifiability/,
#         results/grid/grid_cells.csv (+ grid_reps.csv). Works on partial grids.
# =============================================================================
if (!exists("STAN_BACKEND")) source("R/00_setup.R")
suppressPackageStartupMessages({library(ggplot2); library(dplyr); library(tidyr)})
dir.create("figures", showWarnings = FALSE); dir.create("tables", showWarnings = FALSE)

# ---- journal figure conventions ----------------------------------------------
MM <- 1 / 25.4
W1 <- 84 * MM; W2 <- 174 * MM; HMAX <- 234 * MM
theme_j <- function(base = 9) {
  theme_bw(base_size = base, base_family = "Helvetica") +
    theme(panel.grid.minor = element_blank(),
          panel.grid.major = element_line(linewidth = 0.25, colour = "grey88"),
          strip.background = element_rect(fill = "grey94", colour = NA),
          strip.text = element_text(size = base),
          legend.position = "bottom", legend.title = element_text(size = base),
          legend.text = element_text(size = base), legend.key.width = unit(9, "mm"),
          axis.text = element_text(size = base - 1), axis.title = element_text(size = base),
          plot.title = element_blank(), plot.margin = margin(2, 4, 2, 2))
}
# Okabe-Ito subset ordered by luminance so the series stay distinct in greyscale
pal_method <- c("Majority vote" = "#000000", "Dawid-Skene" = "#E69F00", "CRE-LCM" = "#0072B2")
shp_method <- c("Majority vote" = 15, "Dawid-Skene" = 17, "CRE-LCM" = 16)
save_fig <- function(p, n, width, height) {
  stopifnot(height <= HMAX + 1e-9)
  ggsave(sprintf("figures/Fig%d.pdf", n), p, width = width, height = height,
         device = grDevices::pdf, family = "Helvetica", useDingbats = FALSE)
  ggsave(sprintf("figures/Fig%d.eps", n), p, width = width, height = height,
         device = grDevices::postscript, family = "Helvetica",
         horizontal = FALSE, onefile = FALSE, paper = "special")
  cat(sprintf("[outputs] Fig%d: %.0f x %.0f mm\n", n, width / MM, height / MM))
}
fmt <- function(x, d = 3) { x <- ifelse(!is.na(x) & abs(x) < 0.5 * 10^-d, 0, x)   # no signed zeros
  ifelse(is.na(x), "--", formatC(x, digits = d, format = "f")) }
# Minimal booktabs writer: caption above, label, optional footnote block
write_booktabs <- function(df, file, caption, label, align = NULL, header = NULL,
                           note = NULL, digits = 3, size = "\\small", colsep = NULL) {
  if (is.null(align)) align <- paste0("l", strrep("r", ncol(df) - 1))
  body <- apply(df, 1, function(r) paste(r, collapse = " & "))
  hdr <- if (is.null(header)) paste(names(df), collapse = " & ") else header
  lines <- c("\\begin{table}[htbp]", "\\centering", size,
             if (!is.null(colsep)) sprintf("\\setlength{\\tabcolsep}{%s}", colsep),
             sprintf("\\caption{%s}\\label{%s}", caption, label),
             sprintf("\\begin{tabular}{%s}", align), "\\toprule", paste0(hdr, " \\\\"),
             "\\midrule", paste0(body, " \\\\"), "\\bottomrule", "\\end{tabular}",
             if (!is.null(note)) c("\\begin{flushleft}\\footnotesize", note, "\\end{flushleft}"),
             "\\end{table}")
  writeLines(lines, file); cat("[outputs] wrote", file, "\n")
}

# =============================================================================
# Table 1: baseline (Dawid-Skene under increasing dependence), seed 2026
# =============================================================================
bt <- read.csv("results/baseline_table.csv")
t1 <- data.frame(dep = fmt(bt$dep, 1),
                 ts = fmt(bt$true_sens), ds = fmt(bt$DS_sens),
                 tp = fmt(bt$true_spec), dp = fmt(bt$DS_spec),
                 tv = fmt(bt$true_prev), dv = fmt(bt$DS_prev), mv = fmt(bt$MV_prev))
write_booktabs(t1, "tables/table1_baseline.tex",
  caption = "Dawid--Skene under crossed dependence: one simulated data set per dependence level ($N = 300$, $M = 3$, $P = 5$, $R = 3$, seed 2026). Dependence level $\\delta$ scales the three random-effect standard deviations $(\\sigma_\\theta, \\sigma_\\phi, \\sigma_\\psi) = \\delta \\times (1.0, 0.8, 0.5)$. Sensitivity and specificity are averaged over the $M \\times P$ configurations",
  label = "tab:baseline",
  header = "$\\delta$ & \\multicolumn{2}{c}{Sensitivity} & \\multicolumn{2}{c}{Specificity} & \\multicolumn{3}{c}{Prevalence} \\\\\n\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}\\cmidrule(lr){6-8}\n & true & DS & true & DS & true & DS & MV",
  align = "lrrrrrrr")

# =============================================================================
# Table 2: identifiability variants (scenario B)
# =============================================================================
if (file.exists("results/identifiability/comparison_tables.rds")) {
  ct <- readRDS("results/identifiability/comparison_tables.rds")
  rec <- ct$recovery; lab <- ct$labels; dg <- ct$diagnostics
  vlab <- c(base = "Base", a = "(a) class-specific $\\sigma_\\theta$", b = "(b) $\\theta$ omitted",
            c = "(c) 5\\% anchored", d = "(d) HN(0,\\,0.5) prior", e = "(e) DS initialisation")
  cell <- function(v, var) { r <- rec[rec$variant == v & rec$variable == var, ]
    if (!nrow(r) || is.na(r$mean)) return("--"); sprintf("%s [%s, %s]", fmt(r$mean, 2), fmt(r$q2.5, 2), fmt(r$q97.5, 2)) }
  sth <- function(v) if (v == "a") sprintf("%s / %s", fmt(rec$mean[rec$variant=="a" & rec$variable=="s_th[1]"], 2),
                                           fmt(rec$mean[rec$variant=="a" & rec$variable=="s_th[2]"], 2)) else cell(v, "s_th")
  t2 <- do.call(rbind, lapply(names(vlab), function(v) data.frame(
    variant = vlab[[v]], pi1 = cell(v, "pi1"),
    mu = sprintf("%s, %s", fmt(rec$mean[rec$variant == v & rec$variable == "mu[1]"], 2), fmt(rec$mean[rec$variant == v & rec$variable == "mu[2]"], 2)),
    s_th = sth(v), acc = fmt(lab$accuracy[lab$variant == v]), brier = fmt(lab$brier[lab$variant == v]),
    rhat = fmt(dg$max_rhat_global[dg$variant == v], 2))))
  t2 <- rbind(data.frame(variant = "Majority vote", pi1 = "--", mu = "--", s_th = "--",
                         acc = fmt(lab$accuracy[lab$variant == "majority vote"]), brier = fmt(lab$brier[lab$variant == "majority vote"]), rhat = "--"),
              data.frame(variant = "Dawid--Skene", pi1 = "--", mu = "--", s_th = "--",
                         acc = fmt(lab$accuracy[lab$variant == "Dawid-Skene"]), brier = fmt(lab$brier[lab$variant == "Dawid-Skene"]), rhat = "--"), t2)
  write_booktabs(t2, "tables/table2_identifiability.tex",
    caption = "Identifiability variants fitted to one scenario-B data set ($N = 300$, $\\sigma_\\theta = 1$, $\\sigma_\\phi = 0.8$, $\\sigma_\\psi = 0.5$, true $\\pi_1 = 0.30$, $\\mu = (-2, 1.5)$; four chains of 2000 iterations). Posterior means, with 95\\% credible intervals for $\\pi_1$ and $\\sigma_\\theta$; $\\widehat{R}$ is the largest split-$\\widehat{R}$ over the global parameters",
    label = "tab:ident",
    header = "Variant & $\\pi_1$ & $\\mu_0, \\mu_1$ & $\\sigma_\\theta$ & Acc. & Brier & max $\\widehat{R}$",
    align = "llllrrr", size = "\\scriptsize", colsep = "3pt",
    note = "In (a) the two entries are $\\sigma_{\\theta,0}$ / $\\sigma_{\\theta,1}$. Accuracy and Brier score of the posterior class probabilities against the simulated true classes (all 300 items; for (c) the 15 anchored items are included).")
}

# =============================================================================
# Grid outputs (work on whatever replications are finished)
# =============================================================================
if (file.exists("results/grid/grid_cells.csv")) {
  gc <- read.csv("results/grid/grid_cells.csv")
  gr <- read.csv("results/grid/grid_reps.csv")
  gn <- gc[gc$re_dist == "normal", ]
  gn$Nlab <- factor(paste0("N = ", gn$N), levels = paste0("N = ", c(150, 300, 600)))
  gn$Plab <- factor(paste0("P = ", gn$P))

  # ---- Fig 1: bias of prevalence, sensitivity, specificity ------------------
  long_bias <- gn |>
    select(dep, Nlab, Plab, MV_prev_bias, DS_prev_bias, CRE_prev_bias,
           DS_sens_bias, CRE_sens_bias, DS_spec_bias, CRE_spec_bias) |>
    pivot_longer(-c(dep, Nlab, Plab), names_to = "key", values_to = "bias") |>
    mutate(method = recode(sub("_.*", "", key), MV = "Majority vote", DS = "Dawid-Skene", CRE = "CRE-LCM"),
           metric = recode(sub("^[A-Z]+_([a-z]+)_bias$", "\\1", key),
                           prev = "Prevalence", sens = "Sensitivity", spec = "Specificity"),
           method = factor(method, levels = names(pal_method)),
           metric = factor(metric, levels = c("Prevalence", "Sensitivity", "Specificity")))
  p1 <- ggplot(long_bias, aes(dep, bias, colour = method, shape = method, linetype = Plab, group = interaction(method, Plab))) +
    geom_hline(yintercept = 0, colour = "grey60", linewidth = 0.3) +
    geom_line(linewidth = 0.45) + geom_point(size = 1.6, fill = "white") +
    facet_grid(metric ~ Nlab, scales = "free_y") +
    scale_colour_manual(values = pal_method, name = NULL) +
    scale_shape_manual(values = shp_method, name = NULL) +
    scale_linetype_manual(values = c("P = 3" = "22", "P = 5" = "solid"), name = NULL) +
    scale_x_continuous(breaks = c(0, 0.5, 1, 1.5)) +
    labs(x = expression(paste("Dependence level ", delta)), y = "Bias (estimate minus truth)") +
    theme_j() + guides(colour = guide_legend(order = 1), shape = guide_legend(order = 1), linetype = guide_legend(order = 2))
  save_fig(p1, 1, W2, 150 * MM)

  # ---- Fig 2: accuracy and Brier of posterior labels ------------------------
  long_lab <- gn |>
    select(dep, Nlab, Plab, MV_acc, DS_acc, CRE_acc, MV_brier, DS_brier, CRE_brier) |>
    pivot_longer(-c(dep, Nlab, Plab), names_to = "key", values_to = "value") |>
    mutate(method = factor(recode(sub("_.*", "", key), MV = "Majority vote", DS = "Dawid-Skene", CRE = "CRE-LCM"), levels = names(pal_method)),
           metric = factor(ifelse(grepl("acc", key), "Accuracy", "Brier score"), levels = c("Accuracy", "Brier score")))
  p2 <- ggplot(long_lab, aes(dep, value, colour = method, shape = method, linetype = Plab, group = interaction(method, Plab))) +
    geom_line(linewidth = 0.45) + geom_point(size = 1.6) +
    facet_grid(metric ~ Nlab, scales = "free_y") +
    scale_colour_manual(values = pal_method, name = NULL) + scale_shape_manual(values = shp_method, name = NULL) +
    scale_linetype_manual(values = c("P = 3" = "22", "P = 5" = "solid"), name = NULL) +
    scale_x_continuous(breaks = c(0, 0.5, 1, 1.5)) +
    labs(x = expression(paste("Dependence level ", delta)), y = NULL) + theme_j()
  save_fig(p2, 2, W2, 110 * MM)

  # ---- Fig 3: 95% interval coverage of CRE-LCM ------------------------------
  long_cov <- gn |>
    select(dep, Nlab, Plab, CRE_cov_prev, CRE_cov_sens, CRE_cov_spec, CRE_cov_share_item, CRE_cov_share_model, CRE_cov_share_prompt) |>
    pivot_longer(-c(dep, Nlab, Plab), names_to = "key", values_to = "coverage") |>
    mutate(quantity = factor(recode(sub("CRE_cov_", "", key), prev = "Prevalence", sens = "Sensitivity", spec = "Specificity",
                                    share_item = "Item share", share_model = "Model share", share_prompt = "Prompt share"),
                             levels = c("Prevalence", "Sensitivity", "Specificity", "Item share", "Model share", "Prompt share")))
  pal_q <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#D55E00", "#CC79A7"); shp_q <- c(16, 17, 15, 3, 7, 8)
  p3 <- ggplot(long_cov, aes(dep, coverage, colour = quantity, shape = quantity, linetype = Plab, group = interaction(quantity, Plab))) +
    geom_hline(yintercept = 0.95, colour = "grey50", linewidth = 0.3, linetype = "dotted") +
    geom_line(linewidth = 0.45) + geom_point(size = 1.6) +
    facet_wrap(~ Nlab, nrow = 1) +
    scale_colour_manual(values = pal_q, name = NULL) + scale_shape_manual(values = shp_q, name = NULL) +
    scale_linetype_manual(values = c("P = 3" = "22", "P = 5" = "solid"), name = NULL) +
    scale_x_continuous(breaks = c(0, 0.5, 1, 1.5)) + scale_y_continuous(limits = c(0, 1)) +
    labs(x = expression(paste("Dependence level ", delta)), y = "Coverage of 95% intervals") +
    theme_j() + guides(colour = guide_legend(nrow = 2, order = 1), shape = guide_legend(nrow = 2, order = 1), linetype = guide_legend(order = 2))
  save_fig(p3, 3, W2, 80 * MM)

  # ---- Fig 4: variance-share recovery (replication-level, N = 300, P = 5) ----
  rr <- gr[gr$re_dist == "normal" & gr$N == 300 & gr$P == 5 & gr$CRE_ok, ]
  if (nrow(rr)) {
    long_sh <- rr |>
      select(dep, rep, CRE_share_item, CRE_share_model, CRE_share_prompt, CRE_share_run,
             true_share_item, true_share_model, true_share_prompt, true_share_run) |>
      pivot_longer(starts_with("CRE_share"), names_to = "comp", values_to = "est") |>
      mutate(comp = sub("CRE_share_", "", comp),
             truth = case_when(comp == "item" ~ true_share_item, comp == "model" ~ true_share_model,
                               comp == "prompt" ~ true_share_prompt, TRUE ~ true_share_run),
             comp = factor(recode(comp, item = "Item", model = "Model", prompt = "Prompt", run = "Run"), levels = c("Item", "Model", "Prompt", "Run")),
             dep_f = factor(dep))
    tr <- distinct(long_sh, dep_f, comp, truth)
    p4 <- ggplot(long_sh, aes(dep_f, est)) +
      geom_boxplot(outlier.size = 0.6, linewidth = 0.35, width = 0.6, fill = "grey92") +
      geom_point(data = tr, aes(dep_f, truth), shape = 4, size = 2.2, colour = "#D55E00", stroke = 0.8) +
      facet_wrap(~ comp, nrow = 1, scales = "free_y") +
      labs(x = expression(paste("Dependence level ", delta)), y = "Estimated variance share") + theme_j()
    save_fig(p4, 4, W2, 65 * MM)
  }

  # ---- Table 3: prevalence bias and RMSE -------------------------------------
  t3 <- gn |> arrange(P, N, dep) |>
    transmute(P = P, N = N, dep = fmt(dep, 1), n = n_reps,
              mvb = fmt(MV_prev_bias), mvr = fmt(MV_prev_rmse), dsb = fmt(DS_prev_bias), dsr = fmt(DS_prev_rmse),
              crb = fmt(CRE_prev_bias), crr = fmt(CRE_prev_rmse), cov = fmt(CRE_cov_prev, 2))
  t3$P <- ifelse(duplicated(t3$P), "", t3$P); t3$N <- ifelse(duplicated(paste(gn$P[order(gn$P, gn$N, gn$dep)], gn$N[order(gn$P, gn$N, gn$dep)])), "", t3$N)
  write_booktabs(t3, "tables/table3_prevalence.tex",
    caption = "Prevalence estimation over the simulation grid ($M = 3$, $R = 3$; $n$ replications per cell): bias and root mean squared error of majority vote (MV), Dawid--Skene (DS) and CRE-LCM, and coverage of the CRE-LCM 95\\% credible interval",
    label = "tab:prev",
    header = "$P$ & $N$ & $\\delta$ & $n$ & \\multicolumn{2}{c}{MV} & \\multicolumn{2}{c}{DS} & \\multicolumn{3}{c}{CRE-LCM} \\\\\n\\cmidrule(lr){5-6}\\cmidrule(lr){7-8}\\cmidrule(lr){9-11}\n & & & & bias & RMSE & bias & RMSE & bias & RMSE & cov.",
    align = "lllrrrrrrrr", size = "\\scriptsize", colsep = "4pt")

  # ---- Table 4: sensitivity / specificity bias, DS vs CRE-LCM ----------------
  t4 <- gn |> arrange(P, N, dep) |>
    transmute(P = P, N = N, dep = fmt(dep, 1),
              dss = fmt(DS_sens_bias), crs = fmt(CRE_sens_bias), covs = fmt(CRE_cov_sens, 2),
              dsp = fmt(DS_spec_bias), crp = fmt(CRE_spec_bias), covp = fmt(CRE_cov_spec, 2))
  t4$P <- t3$P; t4$N <- t3$N
  write_booktabs(t4, "tables/table4_sens_spec.tex",
    caption = "Bias of mean sensitivity and mean specificity (averaged over the $M \\times P$ configurations) for Dawid--Skene (DS) and CRE-LCM, with coverage of the CRE-LCM 95\\% intervals",
    label = "tab:sensspec",
    header = "$P$ & $N$ & $\\delta$ & \\multicolumn{3}{c}{Sensitivity} & \\multicolumn{3}{c}{Specificity} \\\\\n\\cmidrule(lr){4-6}\\cmidrule(lr){7-9}\n & & & DS & CRE & cov. & DS & CRE & cov.",
    align = "lllrrrrrr", size = "\\scriptsize")

  # ---- Table 5: labels (accuracy, Brier) and MCMC flags ----------------------
  t5 <- gn |> arrange(P, N, dep) |>
    transmute(P = P, N = N, dep = fmt(dep, 1),
              mva = fmt(MV_acc), dsa = fmt(DS_acc), cra = fmt(CRE_acc),
              mvb = fmt(MV_brier), dsb = fmt(DS_brier), crb = fmt(CRE_brier),
              rh = fmt(frac_rhat_gt_1.05, 2), rt = fmt(mean_runtime_min, 1))
  t5$P <- t3$P; t5$N <- t3$N
  write_booktabs(t5, "tables/table5_labels.tex",
    caption = "Posterior label quality: classification accuracy and Brier score of the item-level class probabilities (MV and DS: EM posterior; CRE-LCM: posterior mean), the fraction of replications with any split-$\\widehat{R} > 1.05$ among the CRE-LCM global parameters, and mean CRE-LCM runtime per replication (minutes, two chains of 1500 iterations on one core)",
    label = "tab:labels",
    header = "$P$ & $N$ & $\\delta$ & \\multicolumn{3}{c}{Accuracy} & \\multicolumn{3}{c}{Brier} & $\\widehat{R} > 1.05$ & min \\\\\n\\cmidrule(lr){4-6}\\cmidrule(lr){7-9}\n & & & MV & DS & CRE & MV & DS & CRE & &",
    align = "lllrrrrrrrr", size = "\\scriptsize", colsep = "4pt")

  # ---- Table 6: variance shares and misspecification arm ---------------------
  sub6 <- gc[gc$N == 300 & gc$P == 5, ] |> arrange(re_dist != "normal", dep)
  t6 <- sub6 |> transmute(dgp = ifelse(re_dist == "normal", "Gaussian", "$t_4$"), dep = fmt(dep, 1), n = n_reps,
                          ib = fmt(share_item_bias), ir = fmt(share_item_rmse), ic = fmt(CRE_cov_share_item, 2),
                          mb = fmt(share_model_bias), mr = fmt(share_model_rmse), mc = fmt(CRE_cov_share_model, 2),
                          pb = fmt(share_prompt_bias), pr = fmt(share_prompt_rmse), pc = fmt(CRE_cov_share_prompt, 2),
                          pv = fmt(CRE_prev_bias), ac = fmt(CRE_acc), br = fmt(CRE_brier))
  write_booktabs(t6, "tables/table6_shares_misspec.tex",
    caption = "Recovery of the variance shares by CRE-LCM at $N = 300$, $P = 5$ (bias, RMSE and 95\\% coverage), with the misspecification arm in which the three item random effects follow a scaled $t_4$ distribution at $\\delta = 1$; the last three columns give the CRE-LCM prevalence bias, accuracy and Brier score in the same cells",
    label = "tab:shares",
    header = "DGP & $\\delta$ & $n$ & \\multicolumn{3}{c}{Item share} & \\multicolumn{3}{c}{Model share} & \\multicolumn{3}{c}{Prompt share} & \\multicolumn{3}{c}{CRE-LCM} \\\\\n\\cmidrule(lr){4-6}\\cmidrule(lr){7-9}\\cmidrule(lr){10-12}\\cmidrule(lr){13-15}\n & & & bias & RMSE & cov. & bias & RMSE & cov. & bias & RMSE & cov. & prev.\\ bias & acc. & Brier",
    align = "llrrrrrrrrrrrrrr", size = "\\tiny", colsep = "2.5pt")
  # misspecification comparison at replication level: normal vs t4 (dep 1, N 300, P 5)
  ms <- gr[gr$N == 300 & gr$P == 5 & gr$dep == 1, ] |> group_by(re_dist) |>
    summarise(n = n(), DS_prev_bias = mean(DS_prev - true_prev), CRE_prev_bias = mean(CRE_prev - true_prev, na.rm = TRUE),
              DS_acc = mean(DS_acc), CRE_acc = mean(CRE_acc, na.rm = TRUE), DS_brier = mean(DS_brier), CRE_brier = mean(CRE_brier, na.rm = TRUE),
              cov_prev = mean(true_prev >= CRE_prev_lo & true_prev <= CRE_prev_hi, na.rm = TRUE), .groups = "drop")
  write.csv(ms, "results/grid/misspecification_summary.csv", row.names = FALSE)
}
cat("[outputs] done\n")

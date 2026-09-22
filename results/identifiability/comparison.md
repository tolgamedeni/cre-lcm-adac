# Identifiability variants: comparison on scenario-B data

Data: N = 300, M = 3, P = 5, R = 3; s_th = 1.0, s_ph = 0.8, s_ps = 0.5; seed 2026. 
Sampler: cmdstanr, 4 chains x 2000 iterations (1000 warmup), adapt_delta 0.9, seed 2026. 
Anchoring (c): 15 items (5%), selected with seed 20261; anchored items are excluded from the 'non-anchored' label metrics.

Variants:
- `base`: base: common scale for theta
- `a`: (a) class-specific scale for theta
- `b`: (b) theta omitted
- `c`: (c) anchoring: 15 items (5%) with known labels
- `d`: (d) half-normal(0, 0.5) prior on s_th
- `e`: (e) base model, chains initialised from Dawid-Skene

## 1. Parameter recovery (posterior mean [95% CI]; `*` = interval misses the truth)

| variable | true | base | a | b | c | d | e |
|---|---|---|---|---|---|---|---|
| pi1 | 0.300 | 0.422 [0.27, 0.74] | 0.308 [0.14, 0.60] | 0.413 [0.28, 0.71] | 0.309 [0.22, 0.38] | 0.423 [0.27, 0.75] | 0.323 [0.26, 0.39] |
| mu[1] | -2.000 | -1.841 [-2.47, 0.92] | -1.515 [-2.28, 0.24] | -1.618 [-2.46, 1.17] | -2.023 [-2.42, -1.61] | -1.648 [-2.45, 1.25] | -2.078 [-2.45, -1.71] |
| mu[2] | 1.500 | 0.648 [-1.94, 1.60] | 1.153 [-1.62, 2.51] | 0.915 [-2.00, 1.65] | 1.227 [0.70, 1.81] | 0.825 [-1.87, 1.67] | 1.202 [0.74, 1.68] |
| a[2,1] | 0.300 | 0.194 [-0.07, 0.46] | 0.156 [-0.10, 0.39] | 0.159 [-0.15, 0.45] | 0.179 [-0.05, 0.42] | 0.146 [-0.19, 0.41] | 0.178 [-0.07, 0.41] |
| a[3,1] | 0.600 | 0.226 [-0.56, 0.63] | 0.200 [-0.50, 0.60] | 0.251 [-0.47, 0.67] | 0.439 [0.22, 0.67] | 0.220 [-0.60, 0.64] | 0.439 [0.21, 0.67] |
| a[2,2] | -0.100 | 0.003 [-0.32, 0.29] | -0.001 [-0.46, 0.41] | 0.043 [-0.33, 0.38] | -0.004 [-0.36, 0.32] | 0.034 [-0.31, 0.35] | 0.013 [-0.30, 0.33] |
| a[3,2] | -0.500 | -0.151 [-0.61, 0.50] | -0.233 [-0.96, 0.78] | -0.151 [-0.65, 0.56] | -0.432 [-0.78, -0.11] | -0.176 [-0.66, 0.52] | -0.387 [-0.71, -0.06] |
| s_th | 1.000 | 0.861 [0.69, 1.09] | NA | 0.000 [0.00, 0.00] * | 0.934 [0.77, 1.12] | 0.859 [0.70, 1.03] | 0.831 [0.67, 1.00] * |
| s_th[1] | 1.000 | NA | 1.173 [0.70, 2.08] | NA | NA | NA | NA |
| s_th[2] | 1.000 | NA | 0.799 [0.37, 1.40] | NA | NA | NA | NA |
| s_ph | 0.800 | 0.837 [0.74, 0.93] | 0.832 [0.74, 0.93] | 1.060 [0.97, 1.16] * | 0.832 [0.74, 0.93] | 0.835 [0.75, 0.93] | 0.833 [0.75, 0.93] |
| s_ps | 0.500 | 0.505 [0.41, 0.60] | 0.495 [0.39, 0.59] | 0.568 [0.48, 0.65] | 0.494 [0.40, 0.59] | 0.497 [0.40, 0.59] | 0.508 [0.42, 0.59] |
| share_item | 0.193 | 0.150 [0.10, 0.22] | 0.215 [0.13, 0.38] | 0.000 [0.00, 0.00] * | 0.172 [0.12, 0.23] | 0.149 [0.10, 0.20] | 0.140 [0.09, 0.19] * |
| share_model | 0.124 | 0.140 [0.11, 0.17] | 0.129 [0.09, 0.16] | 0.237 [0.21, 0.27] * | 0.136 [0.11, 0.16] | 0.140 [0.11, 0.17] | 0.141 [0.11, 0.17] |
| share_prompt | 0.048 | 0.051 [0.03, 0.07] | 0.046 [0.03, 0.07] | 0.068 [0.05, 0.09] * | 0.048 [0.03, 0.07] | 0.050 [0.03, 0.07] | 0.053 [0.04, 0.07] |
| share_run | 0.635 | 0.659 [0.60, 0.70] | 0.610 [0.49, 0.68] | 0.695 [0.66, 0.73] * | 0.645 [0.60, 0.69] | 0.661 [0.62, 0.70] | 0.666 [0.62, 0.71] |

Note: in (a) `share_item` uses the prevalence-weighted item variance (1-pi1) s_th[1]^2 + pi1 s_th[2]^2; 
in (b) `s_th` and `share_item` are 0 by construction, so the remaining shares are relative to a smaller total.

## 2. Posterior labels

| variant | accuracy | brier | accuracy_nonanchor | brier_nonanchor |
|---|---|---|---|---|
| majority vote | 0.890 | 0.110 | 0.891 | 0.109 |
| Dawid-Skene | 0.887 | 0.109 | 0.888 | 0.108 |
| base | 0.897 | 0.121 | 0.898 | 0.121 |
| a | 0.897 | 0.107 | 0.895 | 0.107 |
| b | 0.897 | 0.114 | 0.898 | 0.113 |
| c | 0.913 | 0.063 | 0.909 | 0.067 |
| d | 0.883 | 0.123 | 0.884 | 0.121 |
| e | 0.913 | 0.084 | 0.916 | 0.081 |

## 3. PSIS-LOO (base, a, b, d, e: same data and likelihood; c conditions on known labels and is not comparable)

| variant | elpd_loo | se_elpd | p_loo | n_k_gt_0.7 | elpd_diff | frac_k_gt_0.7 |
|---|---|---|---|---|---|---|
| base | -4430.619 | 81.752 | 752.270 | 265.000 | -33.343 | 0.883 |
| a | -4397.276 | 81.030 | 750.584 | 277.000 | 0.000 | 0.923 |
| b | -4449.551 | 79.304 | 793.192 | 280.000 | -52.275 | 0.933 |
| d | -4421.870 | 82.266 | 741.629 | 267.000 | -24.594 | 0.890 |
| e | -4429.414 | 82.355 | 748.915 | 280.000 | -32.138 | 0.933 |

## 4. MCMC diagnostics

| variant | runtime_sec | divergences | max_treedepth_hits | max_rhat_global | min_ess_bulk_global | min_ess_tail_global | max_rhat_post1 |
|---|---|---|---|---|---|---|---|
| base | 618.250 | 0.000 | 0.000 | 1.814 | 5.822 | 26.224 | 3.825 |
| a | 669.057 | 0.000 | 0.000 | 2.665 | 4.710 | 20.210 | 3.204 |
| b | 763.296 | 0.000 | 0.000 | 1.611 | 6.616 | 26.998 | 4.965 |
| c | 174.011 | 0.000 | 0.000 | 1.444 | 7.816 | 23.284 | 3.112 |
| d | 696.408 | 0.000 | 0.000 | 1.639 | 6.476 | 18.624 | 4.356 |
| e | 143.532 | 0.000 | 0.000 | 1.202 | 13.440 | 78.891 | 3.008 |

## 5. Recommendation and reasoning

### What the fits show

1. **The problem is a second posterior mode, not only a flat likelihood.** With random
   initialisation (Stan default), one of four chains in the base model, in (b) and in (d)
   settles in a *merged-class* mode: prevalence about 0.70, the two class intercepts almost
   equal (mu[1] and mu[2] both between -0.4 and 0.0), model effects sign-flipped and the
   prompt SDs inflated (see the per-chain tables in `draws_*.rds` and
   `results/pilot/per_chain_means_B.csv`). In that mode the mixture has effectively collapsed
   to one class and all heterogeneity is carried by the item effects. The other three chains
   agree with each other and with the truth. This is why the base pilot shows R-hat 1.81 on
   pi1 and a pooled prevalence of 0.42: it averages two modes.
2. **(a) class-specific scale makes it worse.** Every chain ends at a different prevalence
   (0.17, 0.23, 0.51, 0.33), pi1 R-hat 2.67; the extra scale parameter trades off against
   prevalence and the intercepts, and the chain with the *highest* posterior density is the one
   with prevalence 0.17. In the M = 3, P = 5, R = 3 design the Qu-Tan-Kutner loading is not
   identified separately from the mixing proportion. Not recommended.
3. **(b) dropping theta does not remove the mode** (chain 3 again merged) and it biases the
   remaining components: s_ph 1.06 [0.97, 1.16] versus 0.80 and every variance share misses the
   truth, because the shared item variance is pushed into the crossed effects. Not recommended
   as the main model; it is a useful misspecification comparator.
4. **(d) half-normal(0, 0.5) on s_th changes nothing** (posterior s_th 0.86 vs 0.86 in the base
   model, same merged chain). The data dominate the prior; the problem is not prior width.
5. **(c) anchoring 5% of items removes the merged mode entirely.** All four chains agree
   (prevalence 0.26-0.33), all intervals cover the truth, prevalence 0.31 [0.22, 0.38],
   mu = (-2.02, 1.23), model effects a[3,.] recovered, s_th 0.93 [0.77, 1.12], and the labels
   are the best of all variants (accuracy 0.913, Brier 0.063; 0.909 / 0.067 on the 285
   non-anchored items). Runtime 3 min instead of 10-13. Residual R-hat of 1.44 on pi1 comes
   from slow within-mode mixing (bulk ESS 8), not from a separate mode.
6. **(e) base model initialised at the Dawid-Skene solution (added as a computational check)
   also removes the merged mode**: all chains at prevalence 0.30-0.35, pi1 0.32 [0.26, 0.39],
   mu = (-2.08, 1.20), a[3,.] recovered, accuracy 0.913, Brier 0.084, runtime 2.4 min. So the
   base model *is* estimable without a gold standard once chains start near the data-consistent
   mode. Two limitations remain: mixing on pi1 and s_th is slow (bulk ESS 13-15 from 4000
   draws) and s_th is shrunk downwards, 0.83 [0.67, 1.00] against a true value of 1.00; the
   same 10-20% shrinkage appears in every correct-mode chain of base, (d) and (c) (0.79-0.92),
   so it is a property of the likelihood at this design size, not of a particular variant.
   Item ambiguity is partially absorbed by the class mixture, exactly the weak-identification
   mechanism described in README.md. Anchoring reduces it (0.93).
7. **PSIS-LOO is not usable for this comparison.** Each item carries 1 + M + P of its own
   random effects, so leaving an item out changes the posterior substantially: p_loo about
   750 for N = 300 and 88-93% of Pareto k above 0.7 in every variant. The elpd values are
   reported for completeness only; a valid comparison would need the item effects integrated
   out (e.g. adaptive quadrature), which we do not attempt here. LOO is left out of the
   decision.

### Recommendation

Carry forward **the base model (common theta scale) with Dawid-Skene initialisation, variant
(e)** as the main CRE-LCM in the simulation grid, and keep **anchoring (c) as the practical
remedy** reported alongside it. Reasoning:

- (e) preserves the paper's claim (point identification without a gold standard, variance
  decomposition into item / model / prompt / run) and is the *same* model as the pilot, so
  nothing in the model section changes; only the estimation section gains one sentence
  (initialise at Dawid-Skene, check for the merged-class mode with per-chain summaries).
- (c) is what a practitioner with a small labelled subset should do; in the fits above it gives
  the sharpest recovery, the best Brier score and the fastest runtime. It is also the natural
  bridge to the application, where a held-out human-coded subset exists.
- (a) and (d) should be reported in one paragraph (and in an appendix table) as remedies that
  do not work here; (b) as a misspecification comparator.

Implications for the grid (step 4):
- Use (e): `GRID_VARIANT=e` (same Stan file as base; initialisation from the replication's own
  Dawid-Skene fit).
- With 2 chains x 1000 iterations, bulk ESS for pi1 will be low (roughly 3-8); posterior means
  are usable but R-hat will exceed 1.05 in many cells for pi1 alone. Suggest 2 chains x 1500
  (750 warmup) or the user-specified 2 x 1000 with the flag computed on the parameters other
  than pi1 / s_th as well; the flag is stored per replication either way.
- Expected cost (from the 2.4 min fit above, 4 parallel chains x 2000 at N = 300): roughly
  70 s per chain per 1000 iterations at N = 300, so about 2.5 min per replication at N = 300,
  1.2 min at N = 150, 5 min at N = 600 (P = 3 cells about 30% faster). 25 cells x 100
  replications on 9 workers: about 10-12 hours; adding a second variant arm doubles this.

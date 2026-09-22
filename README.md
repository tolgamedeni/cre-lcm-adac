# CRE-LCM: Crossed random-effects latent class model for LLM annotation ensembles

Target journal: Advances in Data Analysis and Classification (ADAC, Springer).

## Files
- `R/01_simulate.R` — data-generating process (model x prompt x run design)
- `R/02_baselines.R` — majority vote, binary Dawid-Skene (EM)
- `stan/crossed_lcre.stan` — proposed model (latent class marginalised)
- `R/03_pilot.R` — two-scenario pilot (independence vs crossed dependence)
- `R/00_setup.R` — packages, Stan backend, cores, helpers; `run_all.R` — one-command entry point
- `R/02b_baseline_table.R` — reproduces the baseline table below

## Setup

Two reproducible routes (the reported results used R 4.5.3, CmdStan 2.40.0, linux-aarch64):

```r
# route 1: system R + renv
install.packages("renv"); renv::restore()            # installs the exact versions in renv.lock
cmdstanr::install_cmdstan()                          # once, if CmdStan is not present
```
```bash
# route 2: no system R -- conda-forge environment (all packages + CmdStan + compilers)
micromamba create -n adac -f environment.yml && micromamba activate adac
```

Then, from the project root:

```bash
Rscript run_all.R                 # everything (the grid takes hours and is resumable)
Rscript run_all.R --steps=1,2     # baselines and pilot only
```

`R/00_setup.R` selects cmdstanr (preferred) or rstan (fallback), uses all cores but one,
and records `sessionInfo()` in `results/session_info.txt`. All seeds derive from 2026.

## Findings so far (seed 2026, N = 300, 3 models x 5 prompts x 3 runs)

Baselines vs. dependence level (s_th / s_ph / s_ps scaled together):

| dep. | true sens | DS sens | true spec | DS spec | true prev. | DS prev. |
|------|-----------|---------|-----------|---------|------------|----------|
| 0.0  | 0.710 | 0.710 | 0.853 | 0.856 | 0.290 | 0.290 |
| 0.5  | 0.696 | 0.720 | 0.832 | 0.832 | 0.290 | 0.287 |
| 1.0  | 0.666 | 0.703 | 0.787 | 0.822 | 0.290 | 0.327 |
| 1.5  | 0.638 | 0.714 | 0.741 | 0.819 | 0.290 | 0.359 |

=> Dawid-Skene increasingly OVERSTATES accuracy and biases prevalence as dependence grows (RQ1).

Preliminary CRE-LCM run (1 chain, 80 post-warmup draws — NOT converged):
- item x model SD: 0.85 (true 0.80); item x prompt SD: 0.53 (true 0.50) -> recovered well
- global item SD: 0.77 (true 1.00); prevalence 0.36 (true 0.29) -> NOT recovered

Interpretation: the global item effect theta_i (shared by all raters) is weakly
identified against the latent class itself. This is the key technical issue.

## Task plan for Claude Code
1. Run the full pilot with 4 chains x 2000 iterations; check R-hat / ESS.
2. Identifiability fix, compare variants:
   (a) class-specific scale for theta (Qu, Tan & Kutner 1996 style),
   (b) drop theta, keep only item x model and item x prompt effects,
   (c) small gold-standard subset (anchoring) as a practical remedy.
3. Full simulation grid: dependence {0, 0.5, 1, 1.5} x N {150, 300, 600}
   x prompts {3, 5}; 100 replications each; run in parallel.
   Metrics: prevalence bias, sens/spec bias, accuracy, Brier, coverage of 95% CIs.
4. Multiclass extension (K > 2) for the real-data application
   (Comparative Agendas Project policy topics).
5. Figures (ggplot2) and LaTeX tables for the manuscript.

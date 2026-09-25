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

## Results (22-23 Sept 2026; all outputs reproducible with `Rscript run_all.R`)

### Baseline: Dawid-Skene under crossed dependence (seed 2026, N = 300, 3 models x 5 prompts x 3 runs)

| dep. | true sens | DS sens | true spec | DS spec | true prev. | DS prev. |
|------|-----------|---------|-----------|---------|------------|----------|
| 0.0  | 0.710 | 0.710 | 0.853 | 0.856 | 0.290 | 0.290 |
| 0.5  | 0.696 | 0.720 | 0.832 | 0.832 | 0.290 | 0.287 |
| 1.0  | 0.666 | 0.703 | 0.787 | 0.822 | 0.290 | 0.327 |
| 1.5  | 0.638 | 0.714 | 0.741 | 0.819 | 0.290 | 0.359 |

Dawid-Skene increasingly overstates accuracy and inflates prevalence as dependence grows (RQ1).
`results/baseline_table.csv`, `tables/table1_baseline.tex`.

### Pilot (step 2): 4 chains x 2000, scenario B (s_th = 1, s_ph = 0.8, s_ps = 0.5)

The base model is multimodal under random initialisation: one chain of four sits in a
*merged-class* mode (prevalence 0.70, class intercepts nearly equal, model effects
sign-flipped); pooled R-hat on pi1 is 1.81. The crossed SDs are recovered by every chain
(s_ph 0.84 vs 0.80, s_ps 0.50 vs 0.50). `results/pilot/` (fit, summary, per-chain means).

### Identifiability variants (step 3): `results/identifiability/comparison.md`

| variant | prevalence (true 0.30) | s_th (true 1.0) | accuracy / Brier | chains |
|---|---|---|---|---|
| base, random inits | 0.42 [0.27, 0.74] | 0.86 | 0.897 / 0.121 | 1 of 4 in merged mode |
| (a) class-specific scale | 0.31 [0.14, 0.60] | 1.17 / 0.80 | 0.897 / 0.107 | every chain elsewhere, R-hat 2.67 |
| (b) theta omitted | 0.41 [0.28, 0.71] | -- | 0.897 / 0.114 | merged mode persists; s_ph inflates to 1.06 |
| (c) 5 % anchored | 0.31 [0.22, 0.38] | 0.93 | 0.913 / 0.063 | all chains agree |
| (d) half-normal(0, 0.5) prior | 0.42 [0.27, 0.75] | 0.86 | 0.883 / 0.123 | unchanged |
| (e) base + Dawid-Skene init | 0.32 [0.26, 0.39] | 0.83 [0.67, 1.00] | 0.913 / 0.084 | all chains agree |

Decision: (e) carried forward; (c) reported as the practical remedy. PSIS-LOO is unusable
(88-93 % of Pareto k > 0.7: each item has its own 1 + M + P random effects). s_th is shrunk
by 10-20 % in every correct-mode chain; anchoring reduces it.

### Simulation grid (step 4): 25 cells x 100 replications, variant (e), 2 chains x 1500

`results/grid/grid_cells.csv` (per cell), `grid_reps.csv` (per replication, seeds recorded),
`summary.md` (convergence), `figures/Fig1-4.{pdf,eps}`, `tables/table3-6*.tex`.

- Dawid-Skene prevalence bias: +0.003 (dep 0.5), +0.05 (dep 1), +0.10 to +0.11 (dep 1.5),
  independent of N and P; specificity bias +0.04 / +0.09 at dep 1 / 1.5.
- CRE-LCM at dep <= 0.5: unbiased for every quantity, coverage 1.00, Brier below Dawid-Skene in
  every cell; convergence fine (<= 20 % flagged, median ESS > 90).
- CRE-LCM at dep >= 1, sampled theta (variant e, first grid run): not converged in any cell (75-99 %
  flagged, median ESS 5-12); estimates stayed near the Dawid-Skene initial value. Kept in
  `grid_cells.csv` / `summary.md` for the record; superseded below.
- **CRE-LCM at dep >= 1, theta integrated by quadrature (variant q, rerun 23-25 Sept, 100 reps/cell,
  2 x 600, 15 nodes; `grid_cells_q.csv`, `summary_q.md`):** prevalence bias +0.006 to +0.018 at dep 1
  (DS +0.05) and +0.027 to +0.065 at dep 1.5 (DS +0.10 to +0.11); prevalence coverage 0.94-1.00;
  specificity bias -0.004 to -0.047 (DS +0.04 / +0.09); sensitivity underestimated by 0.01-0.09
  (worst at N = 150); Brier 0.65 x Dawid-Skene's in every cell; item/model/prompt shares recovered
  (item share bias +0.01 to +0.05, decreasing with N). Convergence: dep 1 5-20 % flagged, median
  min-ESS 89-162; dep 1.5 36-77 % flagged, median min-ESS 18-64, merged mode in 8 % of reps
  (18/100 at N = 600, P = 5). Runtime per replication 3.5/6 min (N 150), 8/14 (N 300), 21/37 (N 600)
  for P = 3/5.
- Final grid for the paper (`grid_cells_final.csv`): dep <= 0.5 from variant e, dep >= 1 from variant q;
  the two routes agree where both converge (`quad_consistency.md`).
- Misspecification (t4 random effects, dep 1, N 300, P 5; quadrature): CRE-LCM prevalence bias +0.009
  vs +0.001 Gaussian, accuracy 0.94 vs 0.93, Brier 0.046 vs 0.052, prevalence coverage 1.00 vs 0.99;
  only the item share is affected (bias -0.036, coverage 0.67 vs +0.012, 0.97).

### Slow mixing and its remedy (resolved 25 Sept 2026)

Slow mixing of pi1 and s_th at dep >= 1 (the theta/class trade-off of the identifiability
analysis) makes 2 x 1500 chains insufficient in every dep >= 1 cell, P = 3 and P = 5 alike.
Remedy chosen: variant (q), `stan/crossed_lcre_q_quad.stan`, integrates theta_i out by
Gauss-Hermite quadrature inside the class sum (phi and psi stay sampled). Results so far: (i) scenario-B
test against (e) with 10, 15 and 20 nodes: mixing fixed (pi1 bulk ESS 2095 / 2585 / 2398 vs 13 for (e);
all R-hat 1.00; prevalence 0.285 / 0.283 / 0.283 for a true 0.30, s_th 0.946 / 0.946 / 0.943 vs 0.83 for (e);
Brier 0.059 vs 0.084; runtime 9.9 / 11.4 / 16.9 min vs 2.4 min for 4 x 2000) -- 15 nodes adopted (`R/04b_quadrature_test.R`, results in
`results/identifiability/quadrature_test*.md`); (ii) consistency check, 10 replications each in
dep0.5_N300_P3 and dep0.5_N300_P5 refitted with (q) and compared with the (e) estimates, so that
one model can be used across the grid; (ii) consistency check done: 10 replications each in dep0.5_N300_P3 and dep0.5_N300_P5 refitted
with (q) at 2 x 600 agree with (e) at 2 x 1500 (prevalence difference -0.001, SD 0.002, correlation
0.995; all quantities within Monte Carlo error; `results/grid/quad_consistency.md`); (iii) rerun of the
13 dep >= 1 cells with (q) done 23 Sept 23:08 - 25 Sept 11:06 (36 h): 100 replications, 2 chains x 600
(300 warmup), 15 nodes, 9 workers
(`GRID_VARIANT=q GRID_CELLS="dep1.0_,dep1.5_" GRID_WARMUP=300 GRID_SAMPLING=300 Rscript R/05_grid.R`,
resumable; outputs in `results/grid/reps_q/`, `grid_cells_q.csv`, `summary_q.md`; runtime per
replication and node count recorded). Runtime of the present grid:
about 24 h on 9 cores (N = 150: 1-2 min, N = 300: 3-5 min, N = 600: 8-13 min per replication).

## Manuscript

`manuscript/main.tex` (anonymised, Springer Nature `sn-jnl` with `sn-mathphys-ay`), sections in
`manuscript/sections/`, `references.bib` (from `refs/` PDFs; provenance in `references_notes.md`),
`title_page.tex` and `cover_letter.tex` separate. Build: `pdflatex main; bibtex main; pdflatex main; pdflatex main`
(TeX Live with `sttools`, `ncctools`, `threeparttable`, `float` and the usual AMS packages).
Passages drafted from results rather than by the author are marked `% TODO-AUTHOR`.

## Original task plan
1. Full pilot 4 x 2000 -- done. 2. Identifiability variants -- done (a-e). 3. Grid -- done
(convergence caveat above). 4. Multiclass extension -- not started. 5. Figures and tables -- done.

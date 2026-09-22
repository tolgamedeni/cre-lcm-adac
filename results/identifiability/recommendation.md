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

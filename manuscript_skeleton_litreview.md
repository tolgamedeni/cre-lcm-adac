# A crossed random-effects latent class model for annotation ensembles of large language models

**Target:** Advances in Data Analysis and Classification (Springer) — double-blind, LaTeX (Springer Nature template)
**Status:** Skeleton + literature review draft, 22 Sept 2026. Sections marked [SIM] / [DATA] wait on Claude Code results.

---

## 0. One-paragraph pitch (for the cover letter and abstract)

Large language models (LLMs) are now routinely used as annotators, but each annotation is the output of a *configuration* — a model, a prompt, and a stochastic decoding run — and configurations built on shared training corpora and alignment procedures do not err independently. Classical label-aggregation models (Dawid & Skene, 1979) assume conditional independence of raters given the true class; we show by simulation that under realistic crossed dependence they overstate annotator accuracy and bias prevalence estimates. We propose a latent class model in which the dependence structure is derived directly from the factorial design of the annotation ensemble (model × prompt × run), estimated with crossed random effects in the tradition of Qu, Tan & Kutner (1996). The model recovers point identification without a gold standard, decomposes annotation error variance into item, model, prompt and run components, and yields calibrated posterior class probabilities. We study identifiability, compare against majority vote, Dawid–Skene and partial-identification bounds, and apply the method to policy-topic coding of [DATA: Comparative Agendas Project texts].

---

## 1. Introduction (target ≈ 1.5 pages)

1.1 LLMs as annotators: scale, cost, adoption in social science, management and public administration.
1.2 The reliability problem: outputs vary across models, prompts and decoding runs; variation propagates into downstream inference ("LLM hacking").
1.3 The aggregation problem: Dawid–Skene and its descendants assume conditionally independent raters; LLM configurations violate this in a *structured* way.
1.4 Contribution (three bullets):
  - a latent class model whose dependence structure follows the annotation design (crossed random effects for model and prompt, exchangeable runs);
  - identifiability analysis and a simulation study quantifying the bias of independence-based aggregators;
  - variance decomposition as a diagnostic for annotation design (how many models, prompts, runs).
1.5 Roadmap.

## 2. Background and related work (target ≈ 2 pages) — see §LR below

2.1 Aggregating noisy labels without a gold standard
2.2 Conditional dependence in latent class models
2.3 LLM annotation: variability, measurement error and remedies
2.4 Positioning

## 3. Model (target ≈ 2.5 pages)

3.1 Setting and notation. Items i = 1..N; true class c_i ∈ {0,1} (extension to K classes in §3.5); configurations (m, p, r), m = 1..M models, p = 1..P prompts, r = 1..R runs. Observed S_imp = number of runs labelled 1.

3.2 Crossed random-effects latent class model (CRE-LCM).
  logit P(Y_impr = 1 | c_i = k) = μ_k + a_mk + b_pk + θ_i + φ_im + ψ_ip
  - μ_k class intercepts (ordered for label identification)
  - a_mk fixed model effects (reference model = 0), b_pk random prompt effects
  - θ_i item ambiguity (shared by all configurations)
  - φ_im item × model, ψ_ip item × prompt
  - runs conditionally independent given all effects ⇒ S_imp | · ~ Binomial(R, ·)
  Special cases: θ = φ = ψ = 0 gives Dawid–Skene; φ = ψ = 0 gives the Qu–Tan–Kutner one-factor model.

3.3 Interpretation of the variance components. Latent logistic scale: total = σ²_θ + σ²_φ + σ²_ψ + π²/3. Shares give the fraction of annotation noise attributable to item ambiguity, model idiosyncrasy, prompt idiosyncrasy and decoding stochasticity. Design implications (adding prompts vs. runs vs. models).

3.4 Identifiability. [SIM — key section]
  - Pilot finding: φ and ψ are well identified from the crossed replication structure (the same item is seen under multiple prompts within a model and multiple models within a prompt); θ competes with the latent class itself (an item that "everyone labels 1" can be class 1 or ambiguous).
  - Variants to report: (a) class-specific scale σ_θ,k (Qu et al. 1996); (b) θ omitted; (c) small anchored gold-standard subset; (d) informative prior on σ_θ. State conditions (M ≥ 2, P ≥ 2, R ≥ 2, ordered μ, reference model) and discuss local vs. global identifiability, label switching.

3.5 Multiclass extension. Category-logit / multinomial formulation with class-specific confusion; or K one-vs-rest components with a shared item effect. [Decide after simulation]

3.6 Estimation. Bayesian (Stan, NUTS), latent class marginalised, non-centred parameterisation; priors; posterior class probabilities; posterior predictive checks. Runtime and scaling remarks. (Optional: EM with adaptive Gauss–Hermite quadrature as a fast alternative — mention as future work if not implemented.)

## 4. Simulation study (target ≈ 3 pages) [SIM]

4.1 Design. Dependence level {0, 0.5, 1, 1.5} × N {150, 300, 600} × P {3, 5}; M = 3, R = 3; 100 replications. Data-generating process as in §3.2 (also a misspecified DGP: t-distributed or bimodal random effects, to assess robustness).
4.2 Competitors. Majority vote; Dawid–Skene (EM); Bayesian DS-GLM (Zhang et al. 2025 style, no crossed effects); CRE-LCM; partial-identification bounds (for reference).
4.3 Metrics. Bias/RMSE of prevalence, sensitivity, specificity; classification accuracy and Brier score of posterior labels; coverage of 95% intervals; recovery of variance shares.
4.4 Results.
  - Pilot table (seed 2026, N = 300): DS overstates specificity by up to 8 points and inflates prevalence by ~24% at the highest dependence level; bias is monotone in dependence.
  - [SIM] CRE-LCM recovery; effect of the identifiability variants; coverage.
4.5 Sensitivity and misspecification.

## 5. Application: policy-topic coding [DATA] (target ≈ 2.5 pages)

5.1 Data. Comparative Agendas Project (human-coded major topics; choose a subset of K = 4–6 topics or a binary contrast); N ≈ 500–1000 documents.
5.2 Annotation design. M = 3–4 model families (at least one open-weights model for reproducibility), P = 5 semantically equivalent prompts, R = 3 runs at temperature > 0; version strings and dates recorded (GUIDE-LLM style reporting).
5.3 Results. Variance decomposition; comparison of DS vs. CRE-LCM against the human gold standard (held out from estimation); which configurations are informative; design recommendations.
5.4 Diagnostics and posterior predictive checks.

## 6. Discussion (≈ 1 page)

Practical guidance: prefer more prompts × models over more runs when prompt/model shares dominate; report variance shares alongside agreement statistics; the model as an audit tool against prompt-tweaking. Limitations: binary focus, Gaussian random effects, computational cost, temporal drift of model versions. Extensions: covariates on μ (as in Zhang et al.), ordinal outcomes, item-level text features.

## 7. Conclusion (½ page)

**Appendix.** Stan code; identifiability proofs/sketches; additional tables; prompt templates.
**Reproducibility.** GitHub repository; seeds; model versions; fixed API dates.

---

## LR. Literature review draft

### LR.1 Aggregating noisy labels without a gold standard

The problem of estimating true labels and rater accuracies jointly, when no reference standard exists, was formalised by **Dawid and Skene (1979)**, who modelled each rater by a class-conditional confusion matrix and estimated all quantities with EM. The model remains the dominant foundation for crowdsourcing and unsupervised ensemble aggregation; subsequent work added Bayesian priors, item difficulty (**GLAD**, Whitehill et al. 2009), spectral initialisation, online EM and hierarchical variants that improve calibration in sparse-label regimes. The common feature of this family is the assumption of conditional independence of raters given the true class. In the LLM setting the practical recommendation is to treat each model (or model–prompt pair) as an annotator and apply Dawid–Skene or GLAD, e.g. via crowd-kit (Camuffo et al. 2026). Our paper starts from the observation that this mapping inherits an assumption the LLM setting violates.

### LR.2 Conditional dependence in latent class models

The diagnostic-testing literature encountered the same violation decades ago: multiple tests applied to the same subject share unmeasured subject-level characteristics, so the conditional-independence latent class model fits poorly and biases accuracy estimates (**Vacek 1985**). **Qu, Tan and Kutner (1996, Biometrics)** introduced random effects into the latent class model to capture this dependence, with a class-specific scale parameter, and gave graphical diagnostics for detecting the pattern of residual correlation. Later work distinguished log-linear (fixed pairwise interaction) and Gaussian random-effects (GRE) formulations and studied their trade-offs — GRE models are more parsimonious when dependence is pervasive but numerically more delicate (Xu et al. 2019, AoAS, record linkage). Crossed subject × rater random effects have been proposed for ordinal ratings without a gold standard, with robustness checks against misspecified random-effects distributions (Wang & Zhou-type models; PMC3740052). Software exists (randomLCA, Beath). None of this work treats the rater itself as a factorial object; the rater is a single unit. That is the structural gap we fill: in LLM ensembles the rater has a known design (model × prompt × run), which allows the dependence structure to be specified rather than assumed.

### LR.3 LLM annotation: variability, measurement error and remedies

Three strands.

*(a) Documenting instability.* Prompt paraphrases that preserve meaning change classification accuracy substantially (Inter-Prompt Reliability, arXiv 2604.16413: accuracy ranging roughly 0.55–0.81 across 20 equivalent prompts on the same task). Prompt-stability scoring adapts Krippendorff's α to paraphrased prompts (Barrie, Palaiologou & Törnberg 2024). Decoding is not deterministic even at nominally deterministic settings (Atil et al. 2024), and performance drifts across monthly re-runs (Barrie, Palmer & Spirling 2025). Large-scale audits of LLM judges find high agreement with each other but limited validity against task-specific human annotation (Bavaresco et al. 2025; "Reliability without Validity", arXiv 2606.19544).

*(b) Downstream consequences.* **Baumann et al. (2025, "LLM hacking")** replicated 37 annotation tasks from 21 studies with 18 models (≈13M labels) and showed that implementation choices — model, prompt, temperature — change statistical conclusions, producing Type I/II/S/M errors. Egami et al. (2024) and Camuffo et al. (2026) formalise the measurement-error argument: if annotation error correlates with covariates, plug-in use of LLM labels yields inconsistent regression estimates regardless of average accuracy; Camuffo et al. report that in their setting the bulk of annotation variance is attributable to model choice rather than content. "Hidden Measurement Error in LLM Pipelines" (arXiv 2604.11581) extends this to evaluation and benchmarking. Carlson & Burbano (2025, SMJ) give guidelines and warnings for management research.

*(c) Statistical remedies.* Two model-based responses are closest to ours. **Zhang et al. (2025, arXiv 2510.23874)** reframe LLM stochasticity as measurement error and propose a Bayesian GLM version of Dawid–Skene, with covariates on the latent state and causal-effect estimation; their focus is repeated draws from a single pipeline, and raters remain conditionally independent. **Partial Identification from LLM Prompts (2026, arXiv 2606.15031)** takes the opposite route: because LLMs share corpora and alignment, their errors may be arbitrarily dependent, so the authors abandon point identification and derive bounds on prevalence, tightening them with reporter-specific calibration. Prediction-powered inference (Angelopoulos et al. 2023) offers a third, design-based route that requires a labelled subsample. Variance-aware protocols (Camuffo et al. 2026) and error-decomposition frameworks (arXiv 2601.11920) recommend prompt ensembles, replication and noise-aware aggregation, but do not supply a model in which the dependence between configurations is estimated.

### LR.4 Positioning

The literature therefore offers (i) independence-based aggregators that are known to be misspecified for LLM ensembles, (ii) bounds that discard the information contained in the ensemble's design, and (iii) protocols without an accompanying inferential model. CRE-LCM occupies the middle ground: dependence is neither ignored nor left unrestricted, but given the structure implied by how the annotations were generated. This yields point identification (under conditions we state), interpretable variance components that translate directly into annotation-design decisions, and a natural home for the covariate and multiclass extensions of the existing approaches.

---

## Reference list (to verify and format in Springer style; arXiv items to be checked for journal versions before submission)

- Angelopoulos, A.N., Bates, S., Fannjiang, C., Jordan, M.I., Zrnic, T. (2023). Prediction-powered inference. *Science* 382, 669–674.
- Atil, B. et al. (2024). Non-determinism of "deterministic" LLM settings. arXiv:2408.04667.
- Barrie, C., Palaiologou, E., Törnberg, P. (2024). Prompt stability scoring for text annotation with LLMs. arXiv:2407.02039.
- Barrie, C., Palmer, A., Spirling, A. (2025). Replication for language models. Working paper.
- Baumann, J., Röttger, P., Urman, A., Wendsjö, A., Plaza-del-Arco, F.M., Gruber, J.B., Hovy, D. (2025). Large language model hacking. arXiv:2509.08825.
- Bavaresco, A. et al. (2025). LLMs instead of human judges? arXiv:2406.18403.
- Beath, K.J. randomLCA: An R package for latent class with random effects analysis. *JSS*.
- Camuffo, A., Gambardella, A., Kazemi, S., Malachowski, J., Pandey, A. (2026). Variance-aware LLM annotation for strategy research. arXiv:2601.02370.
- Carlson, N.A., Burbano, V. (2025). The use of LLMs to annotate data in management research. *Strategic Management Journal*.
- Dawid, A.P., Skene, A.M. (1979). Maximum likelihood estimation of observer error-rates using the EM algorithm. *JRSS C* 28, 20–28.
- Egami, N., Hinck, M., Stewart, B., Wei, H. (2024). Using imperfect surrogates for downstream inference. (NeurIPS / working paper — verify)
- Gilardi, F., Alizadeh, M., Kubli, M. (2023). ChatGPT outperforms crowd workers for text-annotation tasks. *PNAS* 120(30).
- Qu, Y., Tan, M., Kutner, M.H. (1996). Random effects models in latent class analysis for evaluating accuracy of diagnostic tests. *Biometrics* 52, 797–810.
- Vacek, P.M. (1985). The effect of conditional dependence on the evaluation of diagnostic tests. *Biometrics* 41, 959–968.
- Whitehill, J. et al. (2009). Whose vote should count more? (GLAD). *NeurIPS*.
- Xu, H. et al. (2019). Incorporating conditional dependence in latent class models for probabilistic record linkage. *Annals of Applied Statistics* 13(3).
- Zhang, Y. et al. (2025). From stochasticity to signal: A Bayesian latent state model for reliable measurement with LLMs. arXiv:2510.23874.
- arXiv:2604.16413 (2026). Inter-prompt reliability as a measurement problem in LLM-based social science labeling.
- arXiv:2606.15031 (2026). Partial identification from LLM prompts.
- arXiv:2606.19544 (2026). Reliability without validity: LLM-as-a-judge across agreement, consistency and bias.
- arXiv:2604.11581 (2026). Hidden measurement error in LLM pipelines.
- arXiv:2601.11920 (2026). Enhancing LLM-based data annotation with error decomposition.
- PMC3740052. A crossed random effects modeling approach for estimating diagnostic accuracy from ordinal ratings without a gold standard.

# A crossed random-effects latent class model for annotation ensembles of large language models

**Target:** Advances in Data Analysis and Classification (ADAC, Springer). Draft v3, 22 Sept 2026. Citation keys now match manuscript/references.bib (file-stem keys).
**Status:** Sections 1 and 2 drafted in prose; Sections 3–6 remain as an annotated skeleton pending Claude Code results ([SIM], [DATA]). The reference list is split into ADAC-published work (to signal fit with the journal) and general references.

---

## Abstract (draft, 214 words)

Large language models (LLMs) are increasingly used to label text at scale, but every label is produced by a *configuration* — a model, a prompt, and a stochastic decoding run — and configurations that share training corpora and alignment procedures do not err independently. Classical aggregation models for multiple raters, from Dawid and Skene onward, assume conditional independence of raters given the true class. We show by simulation that, under the crossed dependence typical of LLM ensembles, such models increasingly overstate annotator accuracy and bias prevalence estimates as dependence grows. We propose a latent class model in which the dependence structure is derived from the factorial design of the annotation ensemble: item-level random effects that are shared across all configurations, crossed with item-by-model and item-by-prompt effects, while repeated decoding runs are treated as exchangeable. The model, estimated by Bayesian inference with the latent class marginalised, recovers point identification without a gold standard, decomposes annotation error variance into item, model, prompt and run components, and yields calibrated posterior class probabilities. We study identifiability, evaluate the method against majority vote, Dawid–Skene and partial-identification bounds in a simulation study, and apply it to policy-topic coding of legislative texts with human-coded reference labels. The variance decomposition translates directly into design guidance for how many models, prompts and runs to use.

**Keywords:** latent class analysis; conditional dependence; random effects; large language models; text annotation; measurement error

**MSC:** 62H30 · 62F15 · 62P25 · 68T50

---

## 1 Introduction

Text classification by large language models has moved, within three years, from a curiosity to routine research infrastructure. Studies in the social sciences, management and public administration now use LLMs to label sentiment, policy topics, stance, toxicity or compliance in corpora far too large for manual coding (Gilardi et al. 2023; Carlson and Burbano 2026). The attraction is obvious: labels arrive at a fraction of the cost and time of human annotation, and early comparisons suggested accuracy on a par with crowd workers.

The reliability of those labels is a different matter. An LLM label is not the output of a single, stable instrument. It is the output of a configuration: a particular model, a particular prompt wording, and a particular stochastic decoding run. Each of these varies, and each variation moves the label. Semantically equivalent prompts on the same task can shift accuracy by more than twenty points (Liu et al. 2026); nominally deterministic decoding settings do not in fact return deterministic output (Atil et al. 2024); and re-running the same pipeline months later yields different labels because the underlying model has changed (Barrie et al. 2025). At scale, these choices have downstream consequences. Baumann et al. (2025) replicated 37 annotation tasks from 21 published studies across 18 models and found that the choice of model, prompt and temperature alone was enough to change the sign or significance of substantive conclusions — a phenomenon they call LLM hacking. Camuffo et al. (2026) report that in their strategy-research setting the bulk of annotation variance was attributable to which model was queried rather than to the content being labelled.

The natural statistical response is to treat each configuration as a rater and aggregate. This is precisely what recent methodological guidance recommends: query several models with several prompts, replicate, and combine the labels with an aggregation model such as Dawid and Skene (1979) or GLAD (Whitehill et al. 2009) that estimates each rater's error rates jointly with the latent true labels (Camuffo et al. 2026). The recommendation is sensible, but it imports an assumption that the LLM setting violates in a specific and predictable way. Dawid–Skene and its descendants assume that raters are conditionally independent given the true class. Human crowd workers approximate this reasonably well; they err for idiosyncratic reasons. LLM configurations do not. Two prompts sent to the same model share that model's training data, tokenisation and alignment; two models given the same prompt share the prompt's framing and any ambiguity in the item itself; and all configurations share whatever makes a particular text genuinely hard to classify. The errors are therefore correlated, and the correlation has structure.

The diagnostic-testing literature met exactly this problem thirty years ago, when multiple imperfect tests applied to the same patient were found to share unmeasured patient-level characteristics. The conditional-independence latent class model fits such data poorly and biases estimated sensitivities and specificities (Vacek 1985). Qu, Tan and Kutner (1996) introduced subject-level random effects into the latent class model to absorb the shared dependence, and the approach has since been extended, tested and implemented in software (Oberski et al. 2013; Beath 2017; Xu et al. 2019). Within the classification community, relaxations of local independence have been developed for model-based clustering of categorical data (Marbac et al. 2016; Oberski 2016). What these models do not do is exploit the fact that, in an LLM ensemble, the rater is itself a designed object with a known factorial structure.

This paper makes three contributions. First, we propose a latent class model — the crossed random-effects latent class model, CRE-LCM — in which the dependence between LLM configurations is neither ignored nor left unrestricted but derived from the design of the annotation ensemble: an item effect shared by all configurations, crossed with item-by-model and item-by-prompt effects, with repeated decoding runs treated as exchangeable given these effects. Dawid–Skene and the one-factor model of Qu et al. (1996) are nested special cases. Second, we study identifiability. The crossed effects are identified by the replication structure of the design; the global item effect competes with the latent class itself, and we characterise the conditions and the remedies under which point identification is recovered, in contrast to the partial-identification route recently proposed for the same problem (Chen et al. 2026). Third, we show through simulation that independence-based aggregation overstates accuracy and biases prevalence monotonically in the strength of dependence, that CRE-LCM removes this bias, and that its variance decomposition provides direct guidance for annotation design: whether to add models, prompts or runs. An application to policy-topic coding of legislative texts, with human reference labels held out for validation, illustrates the method.

The remainder of the paper is organised as follows. Section 2 reviews related work. Section 3 presents the model, its special cases, identifiability and estimation. Section 4 reports the simulation study. Section 5 presents the application. Section 6 discusses design implications and limitations.

## 2 Background and related work

### 2.1 Aggregating labels from multiple raters without a gold standard

The joint estimation of true labels and rater error rates was formalised by Dawid and Skene (1979), who modelled each rater by a class-conditional confusion matrix and used EM. The model remains the reference point for crowdsourced labelling and unsupervised ensemble aggregation. Extensions add item difficulty (GLAD; Whitehill et al. 2009), Bayesian priors and hierarchical structure for sparse-label regimes, spectral initialisation, and online estimation. Within the classification literature, Salter-Townshend and Murphy (2014) fitted a finite mixture to annotator bias parameters in order to cluster inexpert sentiment annotators, showing that annotator heterogeneity is itself a clustering problem; Raykar and Yu (2012) ranked and filtered crowd annotators by estimated reliability. Agreement statistics such as multi-rater kappas (Warrens 2010, 2013) summarise concordance descriptively but do not estimate accuracy against a latent truth. The common thread in the model-based approaches is conditional independence of raters given the true class. The current LLM-annotation guidance — treat each model or model–prompt pair as an annotator and apply Dawid–Skene or GLAD via standard packages (Camuffo et al. 2026) — inherits this assumption.

### 2.2 Conditional dependence in latent class models

Violations of local independence are among the oldest concerns in latent class analysis. In diagnostic testing, Vacek (1985) showed that ignoring dependence between tests biases estimated accuracies, and Qu, Tan and Kutner (1996) introduced a latent class model with subject-level random effects, including a class-specific scale, to absorb it. The literature since has developed detection methods — bivariate residuals, bootstrapped residuals and score tests, whose relative performance was evaluated in this journal by Oberski et al. (2013) — and alternative parameterisations: log-linear (fixed pairwise) versus Gaussian random-effects (GRE) formulations, with GRE more parsimonious when dependence is pervasive but numerically more delicate (Xu et al. 2019). Crossed subject-by-rater random effects have been used for ordinal ratings without a gold standard, with robustness checks against misspecified random-effect distributions (Xie et al. 2013). Oberski (2016) distinguished substantive from nuisance dependence, modelling the former as additional discrete latent variables and absorbing the latter in extra parameters, with an application to misclassification of self-reported voting. In model-based clustering of categorical data, Marbac et al. (2016) relaxed local independence by grouping variables into conditionally independent blocks with parsimonious intra-block dependence. Software is available (randomLCA; Beath 2017).

None of this work treats the rater as a factorial object. The rater is a single unit — a test, a pathologist, a survey item — and dependence is either estimated freely or absorbed into a single subject-level factor. In an LLM ensemble the rater has a known design, model × prompt × run, and the design tells us where dependence can arise. This is the gap we address.

### 2.3 LLM annotation: variability, measurement error, and remedies

Three strands of recent work bear on the problem. The first documents instability: accuracy varies substantially across meaning-preserving prompt paraphrases (Liu et al. 2026; Barrie et al. 2024), across decoding runs (Atil et al. 2024), and across time as models are updated (Barrie et al. 2025); large-scale audits of LLM judges find high inter-model agreement but limited validity against task-specific human annotation (Bavaresco et al. 2025; Norman et al. 2026). The second traces consequences downstream: Baumann et al. (2025) quantified how configuration choices propagate into Type I, II, S and M errors in 2,361 hypothesis tests; Egami et al. (2024) and Camuffo et al. (2026) show that annotation error correlated with covariates yields inconsistent regression estimates regardless of average accuracy; Messing et al. (2026) extends the argument to evaluation and benchmarking.

The third strand proposes statistical remedies, and two are closest to ours. Zhang et al. (2025) reframe LLM stochasticity as measurement error and propose a Bayesian generalised-linear version of Dawid–Skene with covariates on the latent state; their focus is repeated draws from a single pipeline, and raters remain conditionally independent. Chen et al. (2026) takes the opposite route: because LLMs share corpora and alignment, their errors may be arbitrarily dependent, so the authors abandon point identification and derive bounds on prevalence, tightened by reporter-specific calibration. Prediction-powered inference (Angelopoulos et al. 2023) offers a design-based alternative that requires a labelled subsample. Protocol papers (Camuffo et al. 2026; Xu et al. 2026) recommend prompt ensembles, replication and noise-aware aggregation but supply no model in which the dependence between configurations is estimated.

### 2.4 Positioning

The literature therefore offers independence-based aggregators known to be misspecified for LLM ensembles; bounds that discard the information contained in the ensemble's design; and protocols without an accompanying inferential model. CRE-LCM occupies the middle ground. It gives dependence the structure implied by how the annotations were generated, which yields point identification under stated conditions, interpretable variance components that translate directly into annotation-design decisions, and a natural home for the covariate and multiclass extensions already present in the existing approaches. Methodologically it sits in the ADAC tradition of relaxing local independence in latent class and mixture models (Oberski et al. 2013; Marbac et al. 2016; Oberski 2016) and of modelling annotator heterogeneity as a statistical object (Salter-Townshend and Murphy 2014).

---

## 3 Model [skeleton — to be written after identifiability results]

3.1 Setting and notation. Items i = 1..N; true class c_i ∈ {0,1} (K classes in 3.5); configurations (m, p, r), m = 1..M models, p = 1..P prompts, r = 1..R runs; S_imp = number of runs labelled 1.

3.2 CRE-LCM.  logit P(Y_impr = 1 | c_i = k) = μ_k + a_mk + b_pk + θ_i + φ_im + ψ_ip.
  μ_k ordered class intercepts; a_mk fixed model effects (reference = 0); b_pk random prompt effects; θ_i ~ N(0, σ²_θ) item ambiguity shared by all configurations; φ_im ~ N(0, σ²_φ) item × model; ψ_ip ~ N(0, σ²_ψ) item × prompt; runs conditionally independent ⇒ S_imp | · ~ Binomial(R, ·).
  Nested cases: θ = φ = ψ = 0 → Dawid–Skene; φ = ψ = 0 → Qu–Tan–Kutner one-factor model; also relate to Oberski (2016) nuisance-dependence parameters.

3.3 Variance decomposition on the latent logistic scale: σ²_θ + σ²_φ + σ²_ψ + π²/3; shares and their design interpretation (adding models reduces φ-share, adding prompts reduces ψ-share, adding runs reduces only the π²/3 share; θ is irreducible by design).

3.4 Identifiability. [SIM] Pilot: φ and ψ recovered (0.85 vs 0.80; 0.53 vs 0.50); θ under-estimated (0.77 vs 1.00) and prevalence biased (0.36 vs 0.29). Report variants (a)–(d); state conditions M ≥ 2, P ≥ 2, R ≥ 2, ordered μ, reference model; local vs global identifiability; label switching handled by ordering μ (cf. Stephens 2000). Connect to the identifiability literature for latent class models with dependence (Jones et al. 2010) and for noisy-label mixtures (Nguyen et al. 2023: identifiability with ≥ 2C−1 i.i.d. noisy labels — our replication structure supplies these).

3.5 Multiclass extension. [decide after simulation]

3.6 Estimation. Bayesian (Stan/NUTS), latent class marginalised, non-centred parameterisation, priors, posterior class probabilities, posterior predictive checks; computational cost and scaling.

## 4 Simulation study [SIM]

Design: dependence {0, 0.5, 1, 1.5} × N {150, 300, 600} × P {3, 5}; M = 3, R = 3; 100 replications; misspecification arm with t(4) random effects.
Competitors: majority vote; Dawid–Skene (EM); Bayesian DS-GLM (Zhang et al. 2025 style); CRE-LCM; partial-identification bounds for reference.
Metrics: bias/RMSE of prevalence, sensitivity, specificity; accuracy and Brier of posterior labels; 95% coverage; recovery of variance shares.
Pilot result already in hand (seed 2026, N = 300): DS overstates specificity by up to 8 points and inflates prevalence by ~24% at the highest dependence level; bias monotone in dependence.

## 5 Application: policy-topic coding [DATA]

Comparative Agendas Project texts with human-coded major topics; N ≈ 500–1000; M = 3–4 model families (≥ 1 open-weights); P = 5 semantically equivalent prompts; R = 3 runs at temperature > 0; version strings and dates recorded. Human labels held out for validation. Report variance decomposition, DS vs CRE-LCM against human labels, configuration informativeness, design recommendations, posterior predictive checks.

## 6 Discussion and conclusion

Design guidance from variance shares; reporting recommendation (variance shares alongside kappa); the model as an audit against prompt-tweaking; limitations (binary focus, Gaussian effects, cost, temporal drift); extensions (covariates, ordinal outcomes, item text features).

---

## References — citation-key map (authoritative list is manuscript/references.bib)

In bib (28, keys = file stems): Angelopoulos2023, Atil2024, Barrie2024, Baumann2025, Bavaresco2025, Beath2017, Camuffo2026, Carlson2025 (year 2026), Chen2026 [Partial identification], Dawid1979, Egami2024, Jones2009 (year 2010), Liu2026 [Inter-prompt reliability], Marbac2016, Messing2026 [Hidden measurement error], Nguyen2023, Norman2026 [Reliability without validity], Oberski2013, Oberski2016, Qu1996, Salter-Townshend2014, Vacek1985, Warrens2010, Warrens2013, Xie2014 (year 2013) [crossed random effects, ordinal ratings], Xu2019, Xu2026 [Error decomposition], Zhang2025.

Cited in the text but NOT yet in bib (side citations, add by hand): Gilardi2023 (PNAS 120(30):e2305016120, doi 10.1073/pnas.2305016120), Whitehill2009 (GLAD, NeurIPS 22), Stephens2000 (JRSS-B 62:795-809), Raykar2012 (JMLR 13:491-518), Bacci2014 (ADAC 8:125-145, doi 10.1007/s11634-013-0154-2), Fibbi2024 (ADAC 18:121-161, doi 10.1007/s11634-023-00549-3), Babu2025 (ADAC 19:323-359, doi 10.1007/s11634-025-00623-y).

Open items from references_notes.md: add JSTOR DOIs (Dawid1979 10.2307/2346806; Qu1996 10.2307/2533043; Vacek1985 10.2307/2530967); Liu2026 is arXiv:2604.16413 (doi 10.48550/arXiv.2604.16413); re-check all arXiv items for journal versions before submission.

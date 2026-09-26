# Reference audit — CRE-LCM manuscript (ADAC submission)

Date: 26 September 2026. Scope: `manuscript/main.tex` with every file in `manuscript/sections/`, and `manuscript/references.bib` (37 entries). Source PDFs: `../../refs/` (28 PDFs).

**No manuscript text has been changed.** Every correction below is a proposal waiting for the author's approval.

## Summary

| Check | Result |
|---|---|
| 1a `\cite` keys with no bib entry | none |
| 1b bib entries never cited | 1: `Vehtari2017`, which should be cited at the LOO passage in §3 |
| 1c printed in the bibliography but not cited | none (36 cited = 36 printed) |
| 2 Metadata vs Crossref / arXiv | 1 author-order error (`Camuffo2026`); 3 preprints now published (`Atil2024`, `Bavaresco2025`, `Xu2026`); 2 working papers conditionally accepted at AJPS (`Egami2024`, `Barrie2025`); issue numbers missing in 7 entries; two keys whose year differs from the bib year (`Jones2009` → 2010, `Xie2014` → 2013) |
| 3 Claim verification | 73 (sentence, source) pairs in 45 citing sentences: see the verdict counts in Section 3 |
| **Also found (not a reference issue)** | **The application's Congress range is misstated.** See Section 0. |

## 0. Factual error found during the audit (application data)

`sections/05_application.tex` (lines 11–12) says the sample was drawn "From the 37,007 bills of the 111th to 116th Congresses (2009--2020)". CAP Congressional Bills v19.3, the file we downloaded, **ends at the 114th Congress**: it holds the 80th–114th Congresses, 468,437 records. `scripts/01_sample_bills.R` filters `cong >= 111 & cong <= 116`, which silently returns only the 111th–114th. The 800-bill sample contains 221/220/198/161 bills from the 111th/112th/113th/114th Congresses and **none from the 115th or 116th**. The 37,007 count is correct, but for **2009–2016**.

The same wrong range appears in `data/README.md` (lines 35–36), the top-level `README.md` (line 123) and the comment and message in `scripts/01_sample_bills.R`.

**Proposed correction (05_application.tex):** "From the 37,007 bills of the 111th to 114th Congresses (2009--2016), the most recent covered by version 19.3 of the dataset, we drew a stratified sample of 800 titles: …". Make the same change in both READMEs and the script comment. The filter can stay (it is harmless) or be tightened to `<= 114`. No result changes.

## 1. Consistency (cite keys vs bib vs printed bibliography)

Method: I built the manuscript in a scratch copy (pdflatex → bibtex → pdflatex ×2; 33 pages, no undefined citations or references). I then compared the `\citation` keys in `main.aux`, the entries in `references.bib` and the `\bibitem`s in `main.bbl`. All 62 citations use `\citep`/`\citet`, and there is no `\nocite`. Tables and figure captions contain no citations.

- **(a) Cited, no bib entry:** none.
- **(b) In the bib, never cited:** `Vehtari2017` (Vehtari, Gelman & Gabry, *Stat. Comput.* 27(5), 1413–1432: PSIS-LOO/WAIC). It does not print. **It should be cited, not deleted.** `sections/03_model.tex` line 78 ("Model comparison") discusses leave-one-out cross-validation, $p_{\mathrm{loo}}$ and Pareto-$k$ values with no citation, and those diagnostics come from that paper. **Proposed correction:** "Leave-one-out cross-validation \citep{Vehtari2017} is not usable here: …".
- **(c) Printed but not cited:** none. The 36 `\bibitem`s match the 36 cited keys exactly.

## 2. Metadata (Crossref for DOIs, arXiv API for preprints; queried 26 Sept 2026)

Titles and authors were compared after normalising case and diacritics. Unless listed below, everything matches: authors (all names, same order), year, title, journal, volume and pages. All arXiv version notes (`note = {Version n, date}`) match the latest arXiv version.

### 2.1 Errors

| Key | Field | bib | Source | Proposed fix |
|---|---|---|---|---|
| Camuffo2026 | author order | Camuffo, Gambardella, **Malachowski, Kazemi**, Pandey | arXiv API, abstract page and v3 PDF: Camuffo, Gambardella, **Kazemi, Malachowski**, Pandey | swap Kazemi and Malachowski |

### 2.2 Preprints / working papers with a published version

| Key | Published as | Proposed bib entry |
|---|---|---|
| Atil2024 | **Retitled:** "Non-Determinism of 'Deterministic' LLM System Settings in Hosted Environments", *Proceedings of the 5th Workshop on Evaluation and Comparison of NLP Systems (Eval4NLP 2025)*, pp. 135–148, doi:10.18653/v1/2025.eval4nlp-1.12 | `@inproceedings`, year 2025. The in-text citation becomes Atil et al. (2025): **rename the key** or keep it and accept the mismatch. The claims in S002/S022 still hold (checked against the arXiv PDF; the author should glance at the proceedings version) |
| Bavaresco2025 | *Proceedings of the 63rd Annual Meeting of the ACL (Volume 2: Short Papers)*, 2025, pp. 238–255, doi:10.18653/v1/2025.acl-short.20 | `@inproceedings`, same title and authors |
| Xu2026 | *LAK26: 16th International Learning Analytics and Knowledge Conference* (ACM), 2026, pp. 325–335, doi:10.1145/3785022.3785070 | `@inproceedings`, same authors in the same order |
| Egami2024 | Conditionally accepted at *American Journal of Political Science* (Egami's website); no DOI yet | keep `@unpublished`; optionally add `note = {Conditionally accepted, American Journal of Political Science}` |
| Barrie2025 | Conditionally accepted at *AJPS* (co-author's research page); no DOI; latest public draft 17 Dec 2024 | as for Egami2024 |

Still preprints only (no journal or proceedings version found): Barrie2024, Baumann2025, Camuffo2026, Chen2026, Liu2026, Messing2026, Norman2026, Zhang2025. Nguyen2023 has an OpenReview submission (forum 032sg6mGp9), but its venue and decision could not be read because of a bot check; it is not the different Nguyen et al. NeurIPS 2024 paper on instance-dependent outliers.

### 2.3 Minor (optional)

- **Missing issue numbers** (Crossref has them): Jones2009 66(**3**), Marbac2016 10(**2**), Oberski2013 7(**3**), Oberski2016 10(**2**), Salter-Townshend2014 8(**1**), Warrens2010 4(**4**), Warrens2013 7(**1**).
- **Key vs year:** `Jones2009` is Biometrics 66(3), **2010** (online Sept 2009); `Xie2014` is Stat. Med. 32(20), **2013**. The bib years are correct and the printed citations read "Jones et al. (2010)" and "Xie et al. (2013)"; only the keys are misleading, and they never print.
- **Online-first vs print year:** Oberski2016 (online 2015, print 2016), Salter-Townshend2014 (online 2013, print 2014), Carlson2025 (online Oct 2025, print 2026, 47(3)). The bib uses the print year in each case, which is correct for Springer/Wiley style.
- Whitehill2009 (NIPS 22, pp. 2035–2043) and Raykar2012 (JMLR 13, 491–518) have no DOI by nature; their metadata was checked against the proceedings and JMLR pages and is correct.
- **Wilkerson2025:** its URL (`https://www.comparativeagendas.net/us`) is fine. Do not replace it with the old `congressionalbills.org` domain, which now redirects to an unrelated site.

## 3. Claim verification

Method: every sentence that contains `\citep`/`\citet` was extracted (45 sentences, S001-S045). Each (sentence, source) pair was checked against the full text of the PDF in `refs/`, extracted page by page. Page numbers are given as printed page / PDF page. Sources with no PDF in `refs/` (Gilardi2023, Whitehill2009, Raykar2012, Barrie2025, Carpenter2017, Vehtari2021, Wilkerson2025, Jones2025) were checked against the abstract or the official page and are marked *abstract-only*. For Barrie2025 the Dec 2024 working-paper draft was also used. Numbers were required to match exactly, and verbs such as "show", "report" and "found" were required to reflect what the source itself claims.

**Verdicts (73 pairs):** SUPPORTED 51 · PARTLY SUPPORTED 17 · NOT SUPPORTED 5 · CANNOT VERIFY 0. Of these, 11 are abstract-only.

### 3.1 Overview (sorted by sentence)

| # | Section file | Source | Verdict |
|---|---|---|---|
| [S001](#s001----carlson2025) | 01_introduction.tex | Carlson2025 | SUPPORTED |
| [S001](#s001----gilardi2023) | 01_introduction.tex | Gilardi2023 | SUPPORTED (abstract-only) |
| [S002](#s002----atil2024) | 01_introduction.tex | Atil2024 | SUPPORTED |
| [S002](#s002----barrie2025) | 01_introduction.tex | Barrie2025 | **PARTLY SUPPORTED** (abstract-only) |
| [S002](#s002----liu2026) | 01_introduction.tex | Liu2026 | SUPPORTED |
| [S003](#s003----baumann2025) | 01_introduction.tex | Baumann2025 | **PARTLY SUPPORTED** |
| [S004](#s004----camuffo2026) | 01_introduction.tex | Camuffo2026 | **PARTLY SUPPORTED** |
| [S005](#s005----camuffo2026) | 01_introduction.tex | Camuffo2026 | SUPPORTED |
| [S005](#s005----dawid1979) | 01_introduction.tex | Dawid1979 | SUPPORTED |
| [S005](#s005----whitehill2009) | 01_introduction.tex | Whitehill2009 | SUPPORTED (abstract-only) |
| [S006](#s006----vacek1985) | 01_introduction.tex | Vacek1985 | **PARTLY SUPPORTED** |
| [S007](#s007----beath2017) | 01_introduction.tex | Beath2017 | SUPPORTED |
| [S007](#s007----oberski2013) | 01_introduction.tex | Oberski2013 | **NOT SUPPORTED** |
| [S007](#s007----qu1996) | 01_introduction.tex | Qu1996 | SUPPORTED |
| [S007](#s007----xu2019) | 01_introduction.tex | Xu2019 | SUPPORTED |
| [S008](#s008----marbac2016) | 01_introduction.tex | Marbac2016 | SUPPORTED |
| [S008](#s008----oberski2016) | 01_introduction.tex | Oberski2016 | SUPPORTED |
| [S009](#s009----qu1996) | 01_introduction.tex | Qu1996 | SUPPORTED |
| [S010](#s010----chen2026) | 01_introduction.tex | Chen2026 | SUPPORTED |
| [S011](#s011----dawid1979) | 02_background.tex | Dawid1979 | SUPPORTED |
| [S012](#s012----whitehill2009) | 02_background.tex | Whitehill2009 | SUPPORTED (abstract-only) |
| [S013](#s013----raykar2012) | 02_background.tex | Raykar2012 | SUPPORTED (abstract-only) |
| [S013](#s013----salter-townshend2014) | 02_background.tex | Salter-Townshend2014 | **PARTLY SUPPORTED** |
| [S014](#s014----warrens2010) | 02_background.tex | Warrens2010 | SUPPORTED |
| [S014](#s014----warrens2013) | 02_background.tex | Warrens2013 | **PARTLY SUPPORTED** |
| [S015](#s015----camuffo2026) | 02_background.tex | Camuffo2026 | SUPPORTED |
| [S016](#s016----qu1996) | 02_background.tex | Qu1996 | SUPPORTED |
| [S016](#s016----vacek1985) | 02_background.tex | Vacek1985 | SUPPORTED |
| [S017](#s017----oberski2013) | 02_background.tex | Oberski2013 | **PARTLY SUPPORTED** |
| [S017](#s017----xu2019) | 02_background.tex | Xu2019 | SUPPORTED |
| [S018](#s018----xie2014) | 02_background.tex | Xie2014 | SUPPORTED |
| [S019](#s019----oberski2016) | 02_background.tex | Oberski2016 | SUPPORTED |
| [S020](#s020----marbac2016) | 02_background.tex | Marbac2016 | SUPPORTED |
| [S021](#s021----beath2017) | 02_background.tex | Beath2017 | SUPPORTED |
| [S022](#s022----atil2024) | 02_background.tex | Atil2024 | SUPPORTED |
| [S022](#s022----barrie2024) | 02_background.tex | Barrie2024 | **PARTLY SUPPORTED** |
| [S022](#s022----barrie2025) | 02_background.tex | Barrie2025 | SUPPORTED (abstract-only) |
| [S022](#s022----bavaresco2025) | 02_background.tex | Bavaresco2025 | **PARTLY SUPPORTED** |
| [S022](#s022----liu2026) | 02_background.tex | Liu2026 | SUPPORTED |
| [S022](#s022----norman2026) | 02_background.tex | Norman2026 | **PARTLY SUPPORTED** |
| [S023](#s023----baumann2025) | 02_background.tex | Baumann2025 | SUPPORTED |
| [S023](#s023----camuffo2026) | 02_background.tex | Camuffo2026 | **PARTLY SUPPORTED** |
| [S023](#s023----egami2024) | 02_background.tex | Egami2024 | SUPPORTED |
| [S023](#s023----messing2026) | 02_background.tex | Messing2026 | SUPPORTED |
| [S024](#s024----zhang2025) | 02_background.tex | Zhang2025 | SUPPORTED |
| [S025](#s025----chen2026) | 02_background.tex | Chen2026 | SUPPORTED |
| [S026](#s026----angelopoulos2023) | 02_background.tex | Angelopoulos2023 | SUPPORTED |
| [S027](#s027----camuffo2026) | 02_background.tex | Camuffo2026 | SUPPORTED |
| [S027](#s027----xu2026) | 02_background.tex | Xu2026 | **NOT SUPPORTED** |
| [S028](#s028----marbac2016) | 02_background.tex | Marbac2016 | SUPPORTED |
| [S028](#s028----oberski2013) | 02_background.tex | Oberski2013 | SUPPORTED |
| [S028](#s028----oberski2016) | 02_background.tex | Oberski2016 | SUPPORTED |
| [S028](#s028----salter-townshend2014) | 02_background.tex | Salter-Townshend2014 | SUPPORTED |
| [S029](#s029----qu1996) | 03_model.tex | Qu1996 | SUPPORTED |
| [S030](#s030----oberski2016) | 03_model.tex | Oberski2016 | SUPPORTED |
| [S031](#s031----jones2009) | 03_model.tex | Jones2009 | **NOT SUPPORTED** |
| [S031](#s031----nguyen2023) | 03_model.tex | Nguyen2023 | **NOT SUPPORTED** |
| [S032](#s032----qu1996) | 03_model.tex | Qu1996 | **PARTLY SUPPORTED** |
| [S033](#s033----qu1996) | 03_model.tex | Qu1996 | SUPPORTED |
| [S034](#s034----carpenter2017) | 03_model.tex | Carpenter2017 | SUPPORTED (abstract-only) |
| [S035](#s035----qu1996) | 03_model.tex | Qu1996 | **PARTLY SUPPORTED** |
| [S036](#s036----vehtari2021) | 03_model.tex | Vehtari2021 | SUPPORTED (abstract-only) |
| [S037](#s037----dawid1979) | 04_simulation.tex | Dawid1979 | SUPPORTED |
| [S038](#s038----jones2025) | 05_application.tex | Jones2025 | SUPPORTED (abstract-only) |
| [S038](#s038----wilkerson2025) | 05_application.tex | Wilkerson2025 | **PARTLY SUPPORTED** (abstract-only) |
| [S039](#s039----carlson2025) | 05_application.tex | Carlson2025 | **PARTLY SUPPORTED** |
| [S040](#s040----barrie2025) | 05_application.tex | Barrie2025 | SUPPORTED (abstract-only) |
| [S041](#s041----carlson2025) | 05_application.tex | Carlson2025 | SUPPORTED |
| [S042](#s042----norman2026) | 05_application.tex | Norman2026 | **NOT SUPPORTED** |
| [S043](#s043----chen2026) | 06_discussion.tex | Chen2026 | SUPPORTED |
| [S044](#s044----angelopoulos2023) | 06_discussion.tex | Angelopoulos2023 | **PARTLY SUPPORTED** |
| [S044](#s044----egami2024) | 06_discussion.tex | Egami2024 | SUPPORTED |
| [S045](#s045----carlson2025) | 06_discussion.tex | Carlson2025 | **PARTLY SUPPORTED** |

### 3.2 Details

#### S001 -- Carlson2025
- **Manuscript:** Studies in the social sciences, management and public administration now use LLMs to label sentiment, policy topics, stance, toxicity or compliance in corpora far too large for manual coding \citep{Gilardi2023,Carlson2025}.
- **Claim attributed:** LLMs are used to label/annotate text in management research.
- **Source passage:** "We develop a foundational framework for effective LLM implementation in management research ... We illustrate this framework through an empirical application: classifying sustainability claims in crowdfunding projects." (p. 699 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S001 -- Gilardi2023
- **Manuscript:** Studies in the social sciences, management and public administration now use LLMs to label sentiment, policy topics, stance, toxicity or compliance in corpora far too large for manual coding \citep{Gilardi2023,Carlson2025}.
- **Claim attributed:** An example of social-science work that uses LLMs to annotate text (topics, stance).
- **Source passage:** "we show that ChatGPT outperforms crowd workers for several annotation tasks, including relevance, stance, topics, and frame detection." (Crossref abstract, PNAS 120(30):e2305016120)
- **Verdict:** SUPPORTED (abstract-only)
- **Note:** Gilardi covers stance and topics (plus relevance and frames) on tweets and news. It does not cover sentiment, toxicity or compliance, but these come from the joint cite with Carlson2025. Gilardi is a demonstration or benchmark study (n = 6,183), not an applied large-corpus study. It is still an acceptable cite for "use LLMs to label".
- **Proposed correction:** none

#### S002 -- Atil2024
- **Manuscript:** "nominally deterministic decoding settings do not in fact return deterministic output \citep{Atil2024}"
- **Claim attributed:** Settings configured to be deterministic (e.g., temperature 0) still produce non-identical outputs across runs.
- **Source passage:** "none of the LLMs consistently delivers repeatable accuracy across all tasks, much less identical output strings." (p. 1 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S002 -- Barrie2025
- **Manuscript:** ...and re-running the same pipeline months later yields different labels because the underlying model has changed \citep{Barrie2025}.
- **Claim attributed:** Barrie, Palmer and Spirling show that repeated runs over months give different labels, and that the cause is changes to the model.
- **Source passage:** "while it is true that LMs sometimes are very accurate relative to a gold standard, they also show considerable variance over time." (p. 3) ; "When LM responses change, we generally have no idea why. Most optimistically it is because the training data has been updated ... But it is just as likely ... to be the result of an ad hoc closed-source developer intervention." (p. 15) ; "Even in the cases in which adjusting temperature increases stability, this is immediately nullified by any background updates to the model." (p. 14)
- **Verdict:** PARTLY SUPPORTED (abstract-only; checked against the working-paper PDF draft of 17 Dec 2024 at arthurspirling.org)
- **Note:** The paper does show that labels and performance vary across monthly re-runs (rolling iterated design, up to 8 months). It does not establish that the variation happens *because* the model changed. The authors say the cause is generally unknown ("we generally have no idea why"). They also find month-to-month variance for OpenAI and Gemini similar to the within-month ("static") variance, so part of the instability is ordinary stochasticity, not model drift. Model updates and retirements (e.g. the Gemini 1.0 to 1.5 switch) are documented as *one* source.
- **Proposed correction:** "...and re-running the same pipeline over several months yields markedly different labels, in part because API-served models are silently updated or retired \citep{Barrie2025}."

#### S002 -- Liu2026
- **Manuscript:** "Semantically equivalent prompts on the same task can shift accuracy by more than twenty points \citep{Liu2026}"
- **Claim attributed:** On a single task, semantically equivalent prompts yield accuracies that differ by more than 20 percentage points.
- **Source passage:** "accuracy varies significantly across semantically equivalent prompts, ranging from 0.808 [...] to 0.546 [...] for GPT-4o mini, and from 0.756 to 0.392 for LLaMa3.1:8b." (pdf p. 9; Table 2, pdf pp. 9-10)
- **Verdict:** SUPPORTED
- **Note:** Metric is accuracy against ground truth on TREC question classification, 20 paraphrased prompts. Range is 26.2 pts (GPT-4o mini) and 36.4 pts (Llama 3.1 8B), so "more than twenty points" holds. The effect depends on the task: on PolitiFact the "Closeness" spread is only about 1.5 pts (SD 0.004-0.005, pdf p. 11). The introduction (pdf p. 3) gives a different TREC range ("0.61 to 0.90"), which is inconsistent with Table 2 inside the source; either range exceeds 20 pts. Optional precision: "on an interpretive classification task".
- **Proposed correction:** none (optional: "Semantically equivalent prompts on the same interpretive classification task can shift accuracy by more than twenty points \citep{Liu2026}")

#### S003 -- Baumann2025
- **Manuscript:** "\citet{Baumann2025} replicated 37 annotation tasks from 21 published studies across 18 models and found that the choice of model, prompt and temperature alone was enough to change the sign or significance of substantive conclusions---a phenomenon they call LLM hacking."
- **Claim attributed:** (a) 37 tasks, 21 published studies, 18 models; (b) varying model, prompt and temperature alone flips the sign or significance of conclusions; (c) the authors call this "LLM hacking".
- **Source passage:** "By replicating 37 data annotation tasks from 21 published social science studies, we show that, with just a handful of prompt paraphrases, virtually anything can be presented as statistically significant." (p. 1 / pdf p. 1); "our analysis of 13 million labels from 18 different LLMs across 2,361 realistic hypotheses" (p. 1); "We set the model temperature to 0 for reproducibility" (p. 11 / pdf p. 11); "By simply selecting one of the tested models with a handful of prompt paraphrases, malicious actors can arrive at any desired downstream conclusion." (p. 4)
- **Verdict:** PARTLY SUPPORTED
- **Note:** 37 / 21 / 18 and the term "LLM hacking" ("We call this phenomenon where configuration choices lead to incorrect conclusions LLM hacking", p. 1) are correct. Table 1 counts "21 datasets" (p. 9), while the abstract says "21 published social science studies", so "21 published studies" is acceptable. Temperature was NOT varied in the experiments: it was fixed at 0 (p. 11). The configuration space that was varied is model x prompt (199 prompts, 5-7 per task). Temperature appears only in the conceptual definition of the configuration space Phi (p. 6). "Change the sign or significance" matches the Type S and Type I/II findings (e.g., sign reversal feasible in 68.3% of true effects, p. 4).
- **Proposed correction:** "\citet{Baumann2025} replicated 37 annotation tasks from 21 published studies across 18 models and found that the choice of model and prompt alone was enough to change the sign or significance of substantive conclusions---a phenomenon they call LLM hacking."

#### S004 -- Camuffo2026
- **Manuscript:** \citet{Camuffo2026} report that in their strategy-research setting the bulk of annotation variance was attributable to which model was queried rather than to the content being labelled.
- **Claim attributed:** A variance decomposition in which most annotation variance is due to the model rather than to the item.
- **Source passage:** "Cross-model agreement analysis reveals significant annotation inconsistency (F = 13.847, p < 0.001). Most critically, in 90.0% of annotations, the choice of model determined the outcome" (p. 17 / pdf p. 19); "When 90% of annotation outcomes are determined by model choice rather than substantive content, conclusions hinge on API selection" (p. 28 / pdf p. 30)
- **Verdict:** PARTLY SUPPORTED
- **Note:** Camuffo et al. do not report a variance decomposition. A search for decomposition, variance components or G-study results finds none; generalizability theory is only invoked conceptually. The empirical statement is "in 90.0% of annotations, the choice of model determined the outcome". It comes from 6 models x 20 identical business-model pairwise comparisons (120 observations, 4 API failures excluded), backed by an ANOVA F = 13.847 and mean Cohen's kappa = 0.026. "Bulk of annotation variance was attributable to which model" paraphrases this into a variance-share claim the paper does not make. The task was also a pairwise A/B choice on 20 identical pairs, not labelling a corpus.
- **Proposed correction:** \citet{Camuffo2026} report that in their strategy-research setting the choice of model determined the outcome in 90\% of annotations of identical business-model comparisons, with cross-model agreement barely above chance (mean Cohen's $\kappa = 0.026$).

#### S005 -- Camuffo2026
- **Manuscript:** This is precisely what recent methodological guidance recommends: query several models with several prompts, replicate, and combine the labels with an aggregation model such as \citet{Dawid1979} or GLAD \citep{Whitehill2009} that estimates each rater's error rates jointly with the latent true labels \citep{Camuffo2026}.
- **Claim attributed:** Their protocol recommends multiple models and multiple prompts, replication, and Dawid-Skene/GLAD aggregation that jointly estimates rater reliability and true labels.
- **Source passage:** "Build P ≥ 3 meaning-preserving prompt templates ... draw S replicates at T ≈ 1 per prompt-model pair ... Use at least M ≥ 2 independent model families ... When cross-model agreement is modest (κ < 0.6), employ noise-aware aggregation methods such as Dawid–Skene (Dawid & Skene, 1979) or GLAD (Whitehill et al., 2009), which jointly estimate annotator reliability and true labels." (p. 28 / pdf p. 30)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. Optional precision: in the protocol, DS/GLAD is an upgrade from a majority-vote baseline "when cross-model agreement is modest (κ < 0.6)", and the appendix uses κ < 0.4. Within each prompt-model cell, labels are first combined by majority vote.

#### S005 -- Dawid1979
- **Manuscript:** "... combine the labels with an aggregation model such as \citet{Dawid1979} or GLAD ... that estimates each rater's error rates jointly with the latent true labels"
- **Claim attributed:** Dawid--Skene is an aggregation model that estimates each rater's error rates jointly with the latent true labels.
- **Source passage:** "A model is presented which allows individual error-rates to be estimated for polytomous facets even when the patient's 'true' response is not available." (p. 20 / pdf p. 2); "If ... the indicator variables {T_ij} are treated as missing data then the conditions of the EM algorithm are satisfied." (p. 23 / pdf p. 5)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S005 -- Whitehill2009
- **Manuscript:** ...combine the labels with an aggregation model such as \citet{Dawid1979} or GLAD \citep{Whitehill2009} that estimates each rater's error rates jointly with the latent true labels \citep{Camuffo2026}.
- **Claim attributed:** GLAD is an aggregation model that estimates rater quality jointly with the latent true labels.
- **Source passage:** "a probabilistic model ... to simultaneously infer the label of each image, the expertise of each labeler, and the difficulty of each image" (NeurIPS proceedings abstract page)
- **Verdict:** SUPPORTED (abstract-only)
- **Note:** GLAD estimates a scalar labeler *expertise* (ability) parameter, not a full error-rate (confusion) matrix like Dawid-Skene. The shared relative clause "estimates each rater's error rates" therefore fits D&S literally and GLAD loosely. Optional wording: "rater accuracy". Bib metadata checked. The authors (Whitehill, Ruvolo, Wu, Bergsma, Movellan) match dblp (conf/nips/WhitehillRWBM09). The venue, Advances in Neural Information Processing Systems 22 (NIPS 2009), matches, as do pp. 2035-2043 (dblp/search index). All correct.
- **Proposed correction:** none (optional: "...that estimates each rater's accuracy jointly with the latent true labels")

#### S006 -- Vacek1985
- **Manuscript:** "The conditional-independence latent class model fits such data poorly and biases estimated sensitivities and specificities \citep{Vacek1985}."
- **Claim attributed:** (a) the CI latent class model fits dependent-test data poorly; (b) it biases estimated sensitivities and specificities.
- **Source passage:** "If the tests are conditionally dependent, error rates for both tests can be substantially underestimated. Estimators for the prevalence rates ... can be positively or negatively biased" (p. 959 / pdf p. 2); "eb has the same effect on the false negative rate estimator as ea has on the false positive rate estimator." (p. 961 / pdf p. 4)
- **Verdict:** PARTLY SUPPORTED
- **Note:** (b) is supported for both sensitivities and specificities (false-negative and false-positive rates are underestimated, i.e. accuracies are overstated), but Vacek studies the Hui--Walter setting only: two tests applied to two populations, with covariance parameters e_a, e_b. (a) is not in Vacek. Her model is just-identified (6 df, 6 parameters), so she never assesses fit and cannot report a poor fit. The "fits poorly" statement is in Qu1996: "Consequently, the model generally fits the data poorly." (p. 797 / pdf p. 2). Side note: "thirty years ago" in the same paragraph fits Qu (1996) but not Vacek (1985, about 40 years).
- **Proposed correction:** "The conditional-independence latent class model fits such data poorly \citep{Qu1996} and overstates the tests' sensitivities and specificities \citep{Vacek1985}."

#### S007 -- Beath2017
- **Manuscript:** "... and the approach has since been extended, tested and implemented in software \citep{Oberski2013,Beath2017,Xu2019}."
- **Claim attributed:** Beath (2017) implements (and extends) the random-effects LCM in software.
- **Source passage:** "A solution is to include a normally distributed subject level random effect in the model ... A further extension is to incorporate an additional period level random effect ... The use of the randomLCA R package is demonstrated" (p. 1 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S007 -- Oberski2013
- **Manuscript:** \citet{Qu1996} introduced subject-level random effects into the latent class model to absorb the shared dependence, and the approach has since been extended, tested and implemented in software \citep{Oberski2013,Beath2017,Xu2019}.
- **Claim attributed:** Oberski2013 extended, tested or implemented Qu et al.'s random-effects latent class approach.
- **Source passage:** "This article evaluates three approaches to the evaluation of local dependencies in binary data latent class models: (1) referring the BVR to a Chi-square distribution ... (2) ... parametric bootstrap, and (3) the modification index" (p. 268-269 / pdf p. 2-3); the local-dependence model used is log-linear: "X(YY) ψ ... bivariate associations ψ" (p. 269 / pdf p. 3)
- **Verdict:** NOT SUPPORTED
- **Note:** Oberski2013 contains no random effects and does not cite or build on Qu et al. (grep for "random" / "Qu" finds nothing relevant). It is a Monte Carlo study of tests for detecting local dependence, where dependence is parameterised by fixed log-linear pairwise direct effects (psi). It does not extend, test or implement the random-effects approach. (The software remark, "implemented in version 5.0 of ... Latent GOLD", p. 277, refers to the BVR bootstrap and MI, not random effects.)
- **Proposed correction:** Drop Oberski2013 here: "... and the approach has since been extended, tested and implemented in software \citep{Beath2017,Xu2019}." (Oberski2013 is still cited correctly in S017.)

#### S007 -- Qu1996
- **Manuscript:** "\citet{Qu1996} introduced subject-level random effects into the latent class model to absorb the shared dependence"
- **Claim attributed:** Qu et al. added subject-level random effects to the LCM to model conditional dependence.
- **Source passage:** "we develop a general latent class model with random effects to model the conditional dependence among multiple diagnostic tests (or readers)." (p. 797 / pdf p. 2); "These characteristics can be summarized by an unobserved continuous variable T, which varies from subject to subject" (p. 799 / pdf p. 4)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S007 -- Xu2019
- **Manuscript:** (as above) ... extended, tested and implemented in software \citep{Oberski2013,Beath2017,Xu2019}.
- **Claim attributed:** Xu2019 extended/tested the Gaussian random-effects approach.
- **Source passage:** "the Gaussian random effects (GRE) model was applied to the record linkage literature ... (Daggy et al. (2014)). They introduced a random effect T" (p. 1761 / pdf p. 9); "These probabilities can be similarly calculated for the finite mixture extended LL and GRE models, denoted as the LLFM and GREFM models" (p. 1762 / pdf p. 10)
- **Verdict:** SUPPORTED
- **Note:** Xu2019 tests the GRE model (and a finite-mixture extension of it, GREFM) against FS and log-linear models for record linkage, on three real data sets and by simulation; a SAS program is provided. "Extended, tested" fits. The GRE model is attributed to Daggy et al. (2014) and Qu et al. (1996), not introduced by Xu.
- **Proposed correction:** none

#### S008 -- Marbac2016
- **Manuscript:** Within the classification community, relaxations of local independence have been developed for model-based clustering of categorical data \citep{Marbac2016,Oberski2016}.
- **Claim attributed:** Marbac2016 relaxes local independence for model-based clustering of categorical data.
- **Source passage:** "We propose a parsimonious extension of the classical latent class model to cluster categorical data by relaxing the conditional independence assumption." (p. 183 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S008 -- Oberski2016
- **Manuscript:** (as above)
- **Claim attributed:** Oberski2016 relaxes local independence in model-based clustering of categorical data.
- **Source passage:** "Latent class analysis (LCA) for categorical data is a model-based clustering and classification technique ... Its central assumption is conditional independence ... I suggest ... to model substantive local dependencies as additional discrete latent variables, while absorbing nuisance dependencies in additional parameters." (p. 171 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S009 -- Qu1996
- **Manuscript:** "Dawid--Skene and the one-factor model of \citet{Qu1996} are nested special cases."
- **Claim attributed:** Qu's model is a one-factor (single latent continuous variable) random-effects LCM, and it is nested in CRE-LCM.
- **Source passage:** "Pr(y_ik = 1 | D = d, T = t) = Φ(a_id + b_id t), d = 0, 1, T ~ N(0, 1)" (eq. 2.4, p. 799 / pdf p. 4); "F(.) is a c.d.f." with the logistic listed among "Three most frequently used distributions" (p. 807 / pdf p. 12; p. 809 / pdf p. 14)
- **Verdict:** SUPPORTED
- **Note:** Qu's model is one-factor, but its loadings b_id are specific to each test and class, and its base link is probit, with the logistic allowed as an alternative. CRE-LCM contains only the special case with a single common loading (see S029). This sentence does not say so; S029 does.
- **Proposed correction:** none (optionally: "... and a common-loading, logit-link version of the one-factor model of \citet{Qu1996} are nested special cases.")

#### S010 -- Chen2026
- **Manuscript:** ... in contrast to the partial-identification route recently proposed for the same problem \citep{Chen2026}.
- **Claim attributed:** Chen et al. propose partial identification for latent-class/LLM-panel annotation.
- **Source passage:** "We study partial identification of the prevalence (θ = P(X* = 1)) from panels of LLM reports whose errors may be arbitrarily dependent given the truth." (p. 1 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S011 -- Dawid1979
- **Manuscript:** "The joint estimation of true labels and rater error rates was formalised by \citet{Dawid1979}, who modelled each rater by a class-conditional confusion matrix and used EM."
- **Claim attributed:** Each rater k is described by a J x J matrix of probabilities of recording l given true j, estimated by EM with true classes as missing data.
- **Source passage:** "Let π_jl^(k) be the probability that an observer, k, will record value l given j is the true response. The probabilities π_jl^(k) ... are called the individual error-rates for the kth observer" (p. 20 / pdf p. 2); "This procedure is known as the EM algorithm" (p. 23 / pdf p. 5)
- **Verdict:** SUPPORTED
- **Note:** Dawid and Skene do not use the term "confusion matrix", but their "individual error-rates" are exactly that. They credit Dawid (1971, unpublished) with the binary case (p. 21). The formalisation and EM treatment are in the 1979 paper.
- **Proposed correction:** none

#### S012 -- Whitehill2009
- **Manuscript:** Extensions add item difficulty \citep[GLAD;][]{Whitehill2009}, ...
- **Claim attributed:** GLAD extends rater-accuracy models with an item-difficulty parameter.
- **Source passage:** "simultaneously infer the label of each image, the expertise of each labeler, and the difficulty of each image" (NeurIPS abstract page)
- **Verdict:** SUPPORTED (abstract-only)
- **Note:**
- **Proposed correction:** none

#### S013 -- Raykar2012
- **Manuscript:** ...\citet{Raykar2012} ranked and filtered crowd annotators by estimated reliability.
- **Claim attributed:** Raykar and Yu rank annotators and remove (filter) unreliable ones, using an estimated reliability measure.
- **Source passage:** Abstract (jmlr.org/papers/v13/raykar12a.html): SpEM "iteratively eliminates the spammers and estimates the consensus labels based only on the good annotators"; they propose a "spammer score" used to rank annotators.
- **Verdict:** SUPPORTED (abstract-only)
- **Note:** The ranking criterion is a model-based *spammer score*, which measures how far an annotator is from random labelling. "Estimated reliability" is a fair paraphrase. Metadata checked: Raykar, V. C. and Yu, S., "Eliminating spammers and ranking annotators for crowdsourced labeling tasks", JMLR 13 (issue 16), 491-518, 2012. All correct.
- **Proposed correction:** none (optional precision: "...ranked annotators by an estimated spammer score and filtered out spammers")

#### S013 -- Salter-Townshend2014
- **Manuscript:** \citet{Salter-Townshend2014} fitted a finite mixture to annotator bias parameters in order to cluster inexpert sentiment annotators, showing that annotator heterogeneity is itself a clustering problem;
- **Claim attributed:** (a) a finite mixture fitted to annotator bias parameters; (b) its purpose was to cluster inexpert sentiment annotators; (c) the paper "showed" that annotator heterogeneity is a clustering problem.
- **Source passage:** "can the annotators be usefully clustered into either predetermined or data-driven clusters, based on their biases? ... This paper presents work on fitting a finite mixture model to the annotators' bias." (p. 85 / pdf p. 1); "We have developed a finite mixture model for clustering biased sentiment annotators" (p. 101 / pdf p. 17); "We have observed interesting cluster behaviours detected in the media dataset. The clusters correspond to differing annotator behaviour types" (p. 102 / pdf p. 18)
- **Verdict:** PARTLY SUPPORTED
- **Note:** (a) and (b) are accurate. The bias parameters are cluster-specific error-rate ("bias") matrices, and the annotators are described as inexpert volunteers. (c) overstates the result. The paper frames the question and demonstrates that clusters of annotator bias types can be found in one data set; it does not "show" that heterogeneity is in general a clustering problem. That is our own framing.
- **Proposed correction:** "\citet{Salter-Townshend2014} fitted a finite mixture to annotator bias matrices in order to cluster inexpert sentiment annotators, treating annotator heterogeneity itself as a clustering problem;"

#### S014 -- Warrens2010
- **Manuscript:** Agreement statistics such as multi-rater kappas \citep{Warrens2010,Warrens2013} summarise concordance descriptively but do not estimate accuracy against a latent truth.
- **Claim attributed:** Warrens2010 concerns multi-rater kappas, which are descriptive agreement statistics.
- **Source passage:** "The paper presents inequalities between four descriptive statistics that have been used to measure the nominal agreement between two or more raters ... Light's kappa and Hubert's kappa are multi-rater versions of Cohen's kappa." (p. 271 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:** The title is "Inequalities between multi-rater kappas". The source does not say that kappas "do not estimate accuracy against a latent truth"; that is our own (uncontroversial) contrast, but it follows from "descriptive statistics".
- **Proposed correction:** none

#### S014 -- Warrens2013
- **Manuscript:** (as above)
- **Claim attributed:** Warrens2013 is about multi-rater kappas.
- **Source passage:** "Cohen's weighted kappa is a popular descriptive statistic for summarizing interrater agreement on an ordinal scale." (p. 41 / pdf p. 1); "The weighted kappa with additive weights can be extended to the case of multiple raters by taking a weighted average of all pairwise weighted kappas" (p. 53 / pdf p. 13)
- **Verdict:** PARTLY SUPPORTED
- **Note:** Warrens2013 studies Cohen's weighted kappa for two raters on an ordinal scale (additive weights, a generalisation of linear weights). The multi-rater case appears only in one closing remark that points to other papers. The "descriptive" part is supported, but the paper is not about multi-rater kappas.
- **Proposed correction:** "Agreement statistics such as multi-rater and weighted kappas \citep{Warrens2010,Warrens2013} summarise concordance descriptively but do not estimate accuracy against a latent truth." (or: "multi-rater kappas \citep{Warrens2010} and weighted kappas \citep{Warrens2013}")

#### S015 -- Camuffo2026
- **Manuscript:** The current LLM-annotation guidance---treat each model or model--prompt pair as an annotator and apply Dawid--Skene or GLAD via standard packages \citep{Camuffo2026}---inherits this assumption.
- **Claim attributed:** The guidance treats models (or model-prompt pairs) as annotators and applies DS/GLAD through off-the-shelf packages, which inherits conditional independence.
- **Source passage:** "Both models are implemented in packages such as crowdkit (Python) and can be applied to LLM annotation data by treating each model as an "annotator."" (p. 46 / pdf p. 88); "Conditional independence: Given true label y_i, annotators produce labels independently." (p. 44 / pdf p. 86); "the "raters" (model-prompt combinations) may exhibit correlated errors" (p. 11 / pdf p. 13)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S016 -- Qu1996
- **Manuscript:** "\citet{Qu1996} introduced a latent class model with subject-level random effects, including a class-specific scale, to absorb it."
- **Claim attributed:** Qu's model includes a random-effect scale that differs between the two latent classes.
- **Source passage:** "A very important special case is the random effects model with equal variance components in each population (b_id = b_d for all i). This model, which is referred to as the 2LCR1 model, has two more parameters, b_0 for the nondiseased population and b_1 for the diseased population" (p. 800 / pdf p. 5)
- **Verdict:** SUPPORTED
- **Note:** In the general model the scale b_id is specific to both class and test. 2LCR1 is the class-specific version that is common across tests.
- **Proposed correction:** none

#### S016 -- Vacek1985
- **Manuscript:** "In diagnostic testing, \citet{Vacek1985} showed that ignoring dependence between tests biases estimated accuracies"
- **Claim attributed:** Vacek showed analytically or numerically that assuming conditional independence biases accuracy estimates.
- **Source passage:** "If the tests are conditionally dependent, error rates for both tests can be substantially underestimated." (p. 959 / pdf p. 2); "the error rate estimates obtained under the assumption of conditional independence are much too small." (p. 967 / pdf p. 10)
- **Verdict:** SUPPORTED
- **Note:** The scope is two tests in two populations (Hui--Walter). The bias runs towards overstating accuracy.
- **Proposed correction:** none

#### S017 -- Oberski2013
- **Manuscript:** The literature since has developed detection methods---bivariate residuals, bootstrapped residuals and score tests, whose relative performance was evaluated in this journal by \citet{Oberski2013}---
- **Claim attributed:** Oberski2013 (ADAC) compared the performance of three detection methods: bivariate residuals, bootstrapped residuals and score tests.
- **Source passage:** "These methods were: (1) referring the bivariate residual (BVR) to a Chi-square distribution, (2) referring the BVR to its parametric bootstrap distribution, and (3) referring the modification index (MI) to a Chi-square distribution, also known as the score (or 'Lagrange multiplier') test. The latter two methods are novel to the field of latent class analysis." (p. 276-277 / pdf p. 10-11)
- **Verdict:** PARTLY SUPPORTED
- **Note:** The three methods and the ADAC venue ("Adv Data Anal Classif (2013) 7:267-279") are correct. Two points need fixing. (1) "Bootstrapped residuals" is loose. The method is the BVR with a parametric-bootstrap p-value (not bootstrapping residuals in general), and the score test is called the "modification index". (2) The sentence says the literature developed these methods and Oberski2013 evaluated them. In fact Oberski2013 itself introduced methods 2 and 3 to latent class analysis ("novel to the field"), so it did more than compare methods others had developed. Result: the chi-square reference for the BVR performs poorly, while the bootstrap and MI perform adequately.
- **Proposed correction:** "The literature since has developed detection methods---\citet{Oberski2013}, in this journal, introduced parametric-bootstrap p-values for the bivariate residual and the score test (modification index) to latent class analysis and showed that both outperform the customary chi-square reference for bivariate residuals---and alternative parameterisations: ..."

#### S017 -- Xu2019
- **Manuscript:** alternative parameterisations: log-linear (fixed pairwise) versus Gaussian random-effects (GRE) formulations, with GRE more parsimonious when dependence is pervasive but numerically more delicate \citep{Xu2019}.
- **Claim attributed:** Xu2019 compares LL and GRE; GRE uses fewer parameters when dependence is widespread but is numerically less stable.
- **Source passage:** "GRE models are computationally more intensive. They are also more likely to have numerical instability. In practice, GRE models can be a useful tool when the conditional dependence is prevalent among many fields as they involve fewer parameters than LL models." (p. 1774 / pdf p. 22); "The GRE model is not used due to the numerical instability" (Sect. on birth-record example)
- **Verdict:** SUPPORTED
- **Note:** Every part matches. Minor point: Xu2019 credits the computational-intensity remark to Daggy et al. (2014), but it states the instability and fewer-parameters points in its own voice. The LL model is fitted with pairwise interaction terms (plus a three-way term in one example), so "fixed pairwise" is a fair summary. The context is record linkage.
- **Proposed correction:** none

#### S018 -- Xie2014
- **Manuscript:** "Crossed subject-by-rater random effects have been used for ordinal ratings without a gold standard, with robustness checks against misspecified random-effect distributions \citep{Xie2014}."
- **Claim attributed:** (i) crossed subject and rater random effects; (ii) ordinal ratings; (iii) no gold standard; (iv) robustness to misspecified random-effect distributions assessed.
- **Source passage:** "we propose crossed subject- and rater-specific random effects to account for the dependence structure and assess the robustness of the proposed model to misspecification in the random effects distributions." (Abstract, pdf p. 1); "When MixNs are assumed as the working model, the estimates are nearly unbiased. However, when normal distributions are assumed, most estimates are biased." (pdf p. 11, author manuscript)
- **Verdict:** SUPPORTED
- **Note:** All four elements are present. The effects are crossed subject and rater main effects, not a subject-by-rater interaction. "Subject-by-rater" here means crossed, which is acceptable, but "crossed subject and rater random effects" would be more precise. The true disease status is also ordinal (5 stages). The robustness checks found bias when the normal assumption is misspecified. Bibliography: the key is Xie2014 but the bib year is correctly 2013 (Stat Med 32(20), 2013). Only the key name is inconsistent.
- **Proposed correction:** optional: "Crossed subject and rater random effects have been used for ordinal ratings without a gold standard, with robustness checks against misspecified random-effect distributions \citep{Xie2014}."

#### S019 -- Oberski2016
- **Manuscript:** \citet{Oberski2016} distinguished substantive from nuisance dependence, modelling the former as additional discrete latent variables and absorbing the latter in extra parameters, with an application to misclassification of self-reported voting.
- **Claim attributed:** Oberski2016 separated substantive from nuisance dependence; substantive dependence is modelled as extra discrete latent variables and nuisance dependence as extra parameters; the application is misclassification of self-reported voting.
- **Source passage:** "I suggest, in such cases, to model substantive local dependencies as additional discrete latent variables, while absorbing nuisance dependencies in additional parameters. An example application to the estimation of misclassification and turnover rates of the decision to vote in elections of 9510 Dutch residents" (p. 171 / pdf p. 1); "nuisance local dependencies such as memory effects are not part of the classification but are accounted for by local dependence parameters" (p. 178 / pdf p. 8)
- **Verdict:** SUPPORTED
- **Note:** The title uses "non-substantive"; the abstract and body use "nuisance", so the manuscript's wording is the paper's own. The "extra parameters" are pairwise local-dependence (direct-effect) parameters psi, freed one at a time using bootstrapped BVRs (pp. 175-178). The application is repeated self-reports of turnout in the Dutch LISS panel ("did you vote in the last election?"), so "self-reported voting" is accurate. Optional precision: "and turnover" could be added.
- **Proposed correction:** none

#### S020 -- Marbac2016
- **Manuscript:** In model-based clustering of categorical data, \citet{Marbac2016} relaxed local independence by grouping variables into conditionally independent blocks with parsimonious intra-block dependence.
- **Claim attributed:** The CMM groups variables into conditionally independent blocks and models dependence within each block parsimoniously.
- **Source passage:** "Under this new mixture model, named conditional modes model (CMM), variables are grouped into conditionally independent blocks. Each block follows a parsimonious multinomial distribution where the few free parameters model the probabilities of the most likely levels, while the remaining probability mass is uniformly spread over the other levels of the block." (p. 183 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:** Accurate summary. Optional detail: the parsimony comes from class-specific "modes" (a few free level probabilities per block), and the block partition is the same in every class (footnote 1, p. 186 / pdf p. 4).
- **Proposed correction:** none

#### S021 -- Beath2017
- **Manuscript:** "Software is available \citep[randomLCA;][]{Beath2017}."
- **Claim attributed:** randomLCA is software for random-effects LCA.
- **Source passage:** "The advantage of randomLCA over the other packages is that it will fit both standard latent class models and those incorporating random effects." (p. 2 / pdf p. 2)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S022 -- Atil2024
- **Manuscript:** "[accuracy varies substantially] ... across decoding runs \citep{Atil2024}"
- **Claim attributed:** Accuracy varies across repeated runs under the same (deterministic) decoding configuration.
- **Source passage:** "We see accuracy variations up to 15% across naturally occurring runs with a gap of best possible performance to worst possible performance up to 70%." (p. 1 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:** Atil reports both accuracy variation and raw-string variation (TARr@N / TARa@N). "Decoding runs" means repeated runs at fixed, nominally deterministic settings, which is correct.
- **Proposed correction:** none

#### S022 -- Barrie2024
- **Manuscript:** "accuracy varies substantially across meaning-preserving prompt paraphrases \citep{Liu2026,Barrie2024}"
- **Claim attributed:** Barrie et al. show that ACCURACY varies across meaning-preserving paraphrases.
- **Source passage:** "We focus on stability rather than accuracy because stability is a precondition for reproducibility. A highly stable classifier can still be wrong" (pdf p. 4); "It should be noted that while PSS is not a measure of accuracy" (pdf p. 35)
- **Verdict:** PARTLY SUPPORTED
- **Note:** Barrie et al. measure prompt STABILITY: Krippendorff-alpha-style agreement between the outputs of PEGASUS-generated paraphrases (inter-PSS) and between repeated runs (intra-PSS). They explicitly do not measure accuracy against ground truth. They also find that stability falls as paraphrases become more semantically distant from the original (pdf p. 11), so not all variants are strictly meaning-preserving. The source supports "outputs/labels vary across paraphrases", not "accuracy varies".
- **Proposed correction:** "accuracy varies substantially across meaning-preserving prompt paraphrases \citep{Liu2026}, and so do the labels themselves \citep{Barrie2024}, across decoding runs \citep{Atil2024}, ..." -- or more simply: "outputs and accuracy vary substantially across meaning-preserving prompt paraphrases \citep{Barrie2024,Liu2026}"

#### S022 -- Barrie2025
- **Manuscript:** ...accuracy varies substantially ... across time as models are updated \citep{Barrie2025}; ...
- **Claim attributed:** LLM annotation accuracy varies over time, and this is linked to model updates.
- **Source passage:** "they also show considerable variance over time" (p. 3) ; "as researchers update to newer and newer models, Figure 2 makes clear that there is no reason for them to expect that effect sizes from earlier models will be preserved." (p. 26)
- **Verdict:** SUPPORTED (abstract-only; working-paper PDF)
- **Note:** This is acceptable as worded. The paper documents variance over time and names model updates as a contributor, although it does not isolate updates as the cause (see S002). Minimal hedge if wanted: "across time, as models are updated".
- **Proposed correction:** none

#### S022 -- Bavaresco2025
- **Manuscript:** "large-scale audits of LLM judges find high inter-model agreement but limited validity against task-specific human annotation \citep{Bavaresco2025,Norman2026}"
- **Claim attributed:** (a) LLM judges agree highly with each other; (b) their agreement with task-specific human annotation is limited.
- **Source passage:** "Our evaluations show substantial variance across models and datasets. Models are reliable evaluators on some tasks, but overall display substantial variability depending on the property being evaluated [...] We conclude that LLMs should be carefully validated against human judgments" (pdf p. 1)
- **Verdict:** PARTLY SUPPORTED
- **Note:** Part (b) is supported: across 20 datasets and 11 LLMs, Cohen's kappa and Spearman correlation with human judgements vary widely and are often low. Part (a) is NOT in the paper. Bavaresco et al. compare each model only with humans and never report model-model agreement. The only inter-rater table is human inter-annotator agreement (Table 3, pdf p. 16). They in fact stress "substantial variance across models".
- **Proposed correction:** "large-scale audits of LLM judges find that agreement with human annotation varies widely across tasks and is often limited \citep{Bavaresco2025}, and that high run-to-run reliability can coexist with systematic bias \citep{Norman2026}."

#### S022 -- Liu2026
- **Manuscript:** "accuracy varies substantially across meaning-preserving prompt paraphrases \citep{Liu2026,Barrie2024}"
- **Claim attributed:** Accuracy varies substantially across semantically equivalent prompt paraphrases.
- **Source passage:** "accuracy varies significantly across semantically equivalent prompts, ranging from 0.808 [...] to 0.546" (pdf p. 9)
- **Verdict:** SUPPORTED
- **Note:** This holds for TREC (interpretive task). On PolitiFact the spread is small (pdf p. 11), so the effect depends on the task. This is acceptable for "varies substantially" as a general statement.
- **Proposed correction:** none

#### S022 -- Norman2026
- **Manuscript:** same clause as above
- **Claim attributed:** High inter-model agreement but limited validity against task-specific human annotation.
- **Source passage:** "high test–retest reliability (> 0.95) coexists with severe position bias (> 0.10) in two production-deployed judges (instantiating a consistency–bias paradox)" (pdf p. 1); "Test-retest reliability is the agreement of a judge with itself across independent re-evaluations of the same items." (pdf p. 3)
- **Verdict:** PARTLY SUPPORTED
- **Note:** Norman's "reliability" is WITHIN-judge test-retest reliability, not inter-model agreement. The paper does not report agreement between judges. Its "validity" findings are (i) kappa deflation: exact-match agreement with human labels overstates chance-corrected kappa by 33-41 pp; (ii) position bias; (iii) judge rankings shift by up to 14 positions across benchmarks. The human labels come from general judge benchmarks (MT-Bench, JudgeBench, RewardBench), not from "task-specific human annotation". It does support "limited validity against human labels" in a general sense, but not "high inter-model agreement".
- **Proposed correction:** see the S022 -- Bavaresco2025 correction (Norman cited for "high test-retest reliability coexisting with bias and chance-inflated agreement with human labels").

#### S023 -- Baumann2025
- **Manuscript:** "\citet{Baumann2025} quantified how configuration choices propagate into Type I, II, S and M errors in 2,361 hypothesis tests"
- **Claim attributed:** Quantification of Type I, II, S and M error risks arising from LLM configuration choices over 2,361 hypothesis tests.
- **Source passage:** "a large-scale empirical assessment of over 13 million annotations across 37 diverse CSS tasks (see Table 1), 18 LLMs, and 2,361 realistic hypothesis tests." (p. 3 / pdf p. 3); Table 3 columns "LLM Hacking Risk | Type I Risk | Type II Risk | Type S Risk | Type M Risk" (p. 19)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S023 -- Camuffo2026
- **Manuscript:** \citet{Egami2024} and \citet{Camuffo2026} show that annotation error correlated with covariates yields inconsistent regression estimates regardless of average accuracy
- **Claim attributed:** Camuffo et al. show this result.
- **Source passage:** "Ludwig et al. (2025) formalize the measurement error ... and demonstrate that if this error correlates with economic covariates W_r, plug-in regression using LLM annotations produces inconsistent parameter estimates—regardless of how small the average annotation error may be." (p. 4 / pdf p. 6). Abstract: "annotation errors correlated with covariates bias parameter estimates regardless of average accuracy" (p. 2 / pdf p. 2)
- **Verdict:** PARTLY SUPPORTED
- **Note:** Camuffo et al. state the result but do not show it. They attribute the demonstration to Ludwig et al. (2025), and their own empirical work concerns annotation variance, not downstream regressions. The wording "inconsistent ... regardless of" is theirs, paraphrasing Ludwig et al.
- **Proposed correction:** \citet{Egami2024} show, and \citet{Camuffo2026} stress (following Ludwig et al., 2025), that annotation error correlated with covariates yields inconsistent regression estimates regardless of average accuracy. If Ludwig et al. (2025) is in the bib, cite it directly in place of Camuffo2026.

#### S023 -- Egami2024
- **Manuscript:** \citet{Egami2024} and \citet{Camuffo2026} show that annotation error correlated with covariates yields inconsistent regression estimates regardless of average accuracy
- **Claim attributed:** Egami et al. show that non-random prediction error, correlated with variables in the downstream model, biases downstream estimates even when accuracy is high.
- **Source passage:** "Biases from prediction errors exist even when the prediction accuracy in the text classification step is extremely high, e.g., above 90% or even at 95%. This is because prediction errors are not necessarily random—they can be correlated with observed and unobserved variables" (p. 2 / pdf p. 3). Figure 4 shows bias and under-coverage at 90% and 95% accuracy (p. 17 / pdf p. 18).
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. Egami et al. use "bias" and "invalid confidence intervals" rather than "inconsistent", but the bias does not shrink with sample size, so the wording is acceptable.

#### S023 -- Messing2026
- **Manuscript:** "\citet{Messing2026} extends the argument to evaluation and benchmarking."
- **Claim attributed:** Messing extends the measurement-error / configuration-sensitivity argument to LLM evaluation and benchmarking.
- **Source passage:** "Yet standard confidence intervals ignore variability from judge model choice, model temperature, and prompt phrasing [...] The omitted variance can shift results enough to reverse conclusions [Baumann et al., 2025 ...]" (pdf p. 1); title: "Hidden Measurement Error in LLM Pipelines Distorts Annotation, Evaluation, and Benchmarking"
- **Verdict:** SUPPORTED
- **Note:** The paper covers annotation as well as evaluation and benchmarking (Chatbot Arena, MMLU, AILuminate), and builds explicitly on Baumann et al.
- **Proposed correction:** none

#### S024 -- Zhang2025
- **Manuscript:** \citet{Zhang2025} reframe LLM stochasticity as measurement error and propose a Bayesian generalised-linear version of Dawid--Skene with covariates on the latent state; their focus is repeated draws from a single pipeline, and raters remain conditionally independent.
- **Claim attributed:** (a) LLM stochasticity is reframed as measurement error; (b) a Bayesian GLM latent-class (DS-type) model with covariates on the latent state; (c) repeated draws from one LLM pipeline; (d) conditional independence retained.
- **Source passage:** "We reframe the problem of LLM variability as a solvable measurement error problem" (p. 2); "multiple rounds of LLM ratings as noisy indicators, our Bayesian generalized linear model" (p. 2); "N_c independent ratings R_{c,i} ∈ {0,1} from the LLM ... logit(θ_c) = θ + X_c β + τ T_c" (p. 3); "One of the key model assumptions is the conditional independence assumption that the observed LLM ratings are independent given the true latent model states." (p. 4)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. Optional precision: the "raters" are exchangeable repeated ratings from one LLM, with common error rates ε0 and ε1 in the base model, so "ratings remain conditionally independent" would be more exact. Extension 1 lets the error rates depend on an observed difficulty covariate H_c, which induces marginal within-call correlation. The ratings are still independent given D_c and H_c.

#### S025 -- Chen2026
- **Manuscript:** \citet{Chen2026} take the opposite route: because LLMs share corpora and alignment, their errors may be arbitrarily dependent, so the authors abandon point identification and derive bounds on prevalence, tightened by reporter-specific calibration.
- **Claim attributed:** The reason for dependence is shared corpora and alignment; they drop point identification; the target is bounds on prevalence; reporter-specific calibration tightens the bounds.
- **Source passage:** "Our setting deliberately drops conditional independence: LLMs share training corpora, benchmarks, synthetic data, distillation pipelines, and alignment procedures, so their errors can be arbitrarily dependent given X*." (p. 4 / pdf p. 4); "reporter-specific calibration on the named vector roughly halves the width of the identified set relative to the count coarsening" (p. 3 / pdf p. 3)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. Strictly, externally calibrated scores and events are the source of all identifying power; without them the identified set is [0, 1]. The "halving" is relative to the count coarsening.

#### S026 -- Angelopoulos2023
- **Manuscript:** Prediction-powered inference \citep{Angelopoulos2023} offers a design-based alternative that requires a labelled subsample.
- **Claim attributed:** PPI needs a gold-standard labelled subsample; it is "design-based".
- **Source passage:** "combining predictions, which are abundant but not always trustworthy, with gold-standard data, which are trusted but scarce" (p. 669 / pdf p. 1); "Both datasets are sampled at random from a larger population." (p. 669 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. Angelopoulos et al. never use the term "design-based". Validity rests on the labelled and unlabelled sets being random samples from the same population, which justifies the label as an interpretation.

#### S027 -- Camuffo2026
- **Manuscript:** Protocol papers \citep{Camuffo2026,Xu2026} recommend prompt ensembles, replication and noise-aware aggregation but supply no model in which the dependence between configurations is estimated.
- **Claim attributed:** Camuffo et al. recommend prompt ensembles, replication and noise-aware aggregation, and do not estimate dependence between configurations.
- **Source passage:** "Prompt ensemble and extraction. Build P ≥ 3 meaning-preserving prompt templates ... employ noise-aware aggregation methods such as Dawid–Skene ... or GLAD" (p. 28 / pdf p. 30); "the "raters" (model-prompt combinations) may exhibit correlated errors rather than independent noise" (p. 11 / pdf p. 13); "treating each family as an independent coder" (p. 28 / pdf p. 30)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. Camuffo et al. acknowledge correlated errors (p. 11) but only recommend DS/GLAD, which assume conditional independence (Appendix D, p. 44). No model estimates the dependence.

#### S027 -- Xu2026
- **Manuscript:** Protocol papers \citep{Camuffo2026,Xu2026} recommend prompt ensembles, replication and noise-aware aggregation but supply no model in which the dependence between configurations is estimated.
- **Claim attributed:** Xu et al. is a protocol paper recommending prompt ensembles, replication and noise-aware aggregation.
- **Source passage:** "we propose a diagnostic evaluation paradigm that incorporates a human-in-the-loop step to separate task-inherent ambiguity from model-driven inaccuracies ... (1) a diagnostic taxonomy ... (2) a lightweight human annotation test ... (3) a computational method to decompose observed LLM annotation errors" (Abstract, pdf p. 1)
- **Verdict:** NOT SUPPORTED
- **Note:** Xu et al. (2026) is an error-decomposition and diagnostic paper. It uses GPT-3.5/GPT-5 on four ordinal education tasks and separates task-inherent from model-specific errors, and boundary from conceptual errors, using a small human test. It does not recommend prompt ensembles, replication or noise-aware aggregation. Self-consistency (5 outputs, majority vote) appears only as one of five prompting strategies compared (pdf p. 5). It is not a recommendation, and there is no DS/GLAD-style aggregation. The "no dependence model" half is trivially true.
- **Proposed correction:** Protocol papers \citep{Camuffo2026} recommend prompt ensembles, replication and noise-aware aggregation but supply no model in which the dependence between configurations is estimated; diagnostic work such as \citet{Xu2026} decomposes annotation error into task-inherent and model-specific components, again without modelling dependence. Alternatively, drop Xu2026 from this sentence.

#### S028 -- Marbac2016
- **Manuscript:** (as above)
- **Claim attributed:** An ADAC paper relaxing local independence in latent class/mixture models.
- **Source passage:** "Adv Data Anal Classif (2016) 10:183-207 ... parsimonious extension of the classical latent class model ... by relaxing the conditional independence assumption" (p. 183 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S028 -- Oberski2013
- **Manuscript:** Methodologically it sits in the ADAC tradition of relaxing local independence in latent class and mixture models \citep{Oberski2013,Marbac2016,Oberski2016} and of modelling annotator heterogeneity as a statistical object \citep{Salter-Townshend2014}.
- **Claim attributed:** Oberski2013 is an ADAC paper on relaxing local independence in latent class models.
- **Source passage:** "Adv Data Anal Classif (2013) 7:267-279 ... This article evaluates three methods of doing so [investigating local dependence]" (p. 267 / pdf p. 1); local-dependence model with free psi, p. 269 / pdf p. 3
- **Verdict:** SUPPORTED
- **Note:** Small nuance: Oberski2013 is mainly about detecting violations of local independence, not about relaxation models. It does, however, work inside the local-dependence (direct-effect) latent class model, so it belongs to this ADAC line of work. If exact wording is wanted: "of detecting and relaxing local independence".
- **Proposed correction:** none (optional: "the ADAC tradition of detecting and relaxing local independence ...")

#### S028 -- Oberski2016
- **Manuscript:** (as above)
- **Claim attributed:** An ADAC paper relaxing local independence in latent class models.
- **Source passage:** "Adv Data Anal Classif (2016) 10:171-182 ... Beyond the number of classes: separating substantive from non-substantive dependence in latent class analysis" (p. 171 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S028 -- Salter-Townshend2014
- **Manuscript:** (as above) ... and of modelling annotator heterogeneity as a statistical object \citep{Salter-Townshend2014}.
- **Claim attributed:** An ADAC paper that models annotator heterogeneity statistically.
- **Source passage:** "Adv Data Anal Classif (2014) 8:85-103 ... Mixtures of biased sentiment analysers ... fitting a finite mixture model to the annotators' bias" (p. 85 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S029 -- Qu1996
- **Manuscript:** "with $\phi = \psi = 0$ it is the one-factor random-effects model of \citet{Qu1996} with a common loading."
- **Claim attributed:** With φ = ψ = 0, CRE-LCM (logit link, θ_i ~ N(0, σ_θ²) added identically for both classes and all configurations) equals Qu's model restricted to one loading b_id = b for all tests and classes.
- **Source passage:** "Φ(a_id + b_id t)" (eq. 2.4, p. 799 / pdf p. 4); "random effects model with equal variance components in each population (b_id = b_d for all i)" (p. 800 / pdf p. 5); "F(a_id + b_id t + c_id z_ik), d = 0, 1, T ~ N(0, 1), where F(.) is a c.d.f." (eq. 4.1, p. 807 / pdf p. 12)
- **Verdict:** SUPPORTED
- **Note:** Qu's loadings are specific to test and class. A "common loading" (b_0 = b_1 = σ_θ) goes one step further than Qu's 2LCR1, but it is a valid special case. Qu's main model is probit. The logit version is the 2LCM generalisation with F logistic ("Three most frequently used distributions are the normal, the logistic, and the extreme-value", p. 809). Also, CRE-LCM's configuration intercepts include random prompt effects b_pk rather than free test intercepts a_id. This is a minor difference that the sentence already covers with the Dawid--Skene clause.
- **Proposed correction:** none (optionally "... the one-factor random-effects model of \citet{Qu1996}, in its logistic form, with a common loading.")

#### S030 -- Oberski2016
- **Manuscript:** The random effects play the role of the nuisance-dependence parameters of \citet{Oberski2016}, with the difference that their placement is dictated by the design.
- **Claim attributed:** Oberski2016 has "nuisance-dependence parameters" that absorb nuisance dependence; in that paper their placement is chosen from the data rather than from the design.
- **Source passage:** "absorbing nuisance dependencies in additional parameters" (p. 171 / pdf p. 1); "it may be preferable to model local dependencies by freeing elements of psi. Freeing all local dependencies is, however, usually not desirable ... We therefore use the 'bivariate residual' (BVR) between item pairs to monitor whether it might be necessary to free local dependencies" (p. 175-176 / pdf p. 5-6)
- **Verdict:** SUPPORTED
- **Note:** The analogy is fair, and the stated difference is accurate: in Oberski2016 the nuisance parameters are fixed pairwise log-linear local-dependence terms (psi), freed from the data using bootstrapped BVRs plus substantive reasoning (memory effects). Being explicit that they are pairwise direct effects, not random effects, would sharpen the contrast.
- **Proposed correction:** none (optional: "... play the role of the pairwise nuisance-dependence parameters of \citet{Oberski2016}, with the difference that their placement is dictated by the design rather than selected from local-fit diagnostics.")

#### S031 -- Jones2009
- **Manuscript:** "... and the fixed-effect part of the model is a Dawid--Skene model with a shared logistic random effect, whose identification for $M \ge 3$ raters follows \citet{Jones2009}."
- **Claim attributed:** Jones et al. establish identifiability, for M ≥ 3 raters, of a Dawid--Skene model with a shared (logistic) random effect.
- **Source passage:** "if we confine our attention to the region in which 0 < π < 1, Se_s + Sp_s > 1, s = 1, 2, 3, the model is locally identifiable at every parameter value." (Section 3.2.1, one population, three **independent** tests; p. 859 / pdf p. 5); "The latent trait model of Qu et al. (1996) has four parameters ... for each test, giving r = 4k + M. In the equal variance components version, the b are the same for each test, so r = 2k + 2 + M." and "With one population, at least four tests are required if any correlations are to be included; with four tests we can add up to six pairwise covariances or use the equal-variances latent trait model without overparameterizing the model." (p. 858 / pdf p. 4)
- **Verdict:** NOT SUPPORTED
- **Note:** (1) Jones et al. prove **local (weak) identifiability** via the Jacobian rank only for the **conditional-independence** model with three tests (and for several fixed-effect covariance models of the Dendukuri--Joseph type with 4-5 tests). They do not prove identifiability of any random-effects (latent-trait) model. (2) For Qu's latent-trait models they give **parameter counts only** (Table 1). Such counts are necessary, not sufficient, conditions, and the paper stresses that "a sufficiency of degrees of freedom does not guarantee unique estimates". (3) Their counting contradicts "M ≥ 3". With one population and k = 3 binary tests there are q = 7 df. The latent-trait model needs r_lt = 13 and the equal-variance version r_lt1 = 9. Even a single common loading needs 2k + 1 + 1 = 8 > 7. Any dependence therefore requires **at least four** tests. (4) They also write that identification in general cannot be established globally, and that their method checks designs case by case. (5) The phrase "fixed-effect part ... with a shared logistic random effect" contradicts itself. Bibliography: the key is Jones2009 but the article is Biometrics 66(3), 855-863, **2010** (online 2009). The bib year 2010 is correct; the key name is misleading.
- **Proposed correction:** "... and without random effects the model is a Dawid--Skene model, which is locally identified with three or more conditionally independent raters \citep{Jones2009}; for the random-effect (latent-trait) extension \citet{Jones2009} give only necessary parameter-counting conditions---at least four binary tests in a single population---which the $MP = 15$ model--prompt raters satisfy."
- **Lead-auditor note:** In Jones et al.'s counting, the "tests" in our design are the $MPR = 45$ model x prompt x run configurations, not the $M = 3$ models. So the four-test requirement is met by a wide margin, and the problem is the attribution, not the design. But parameter counting is only a necessary condition. The manuscript's own finding that the posterior has a merged-class mode (Section 3.4) shows that the random-effect model is weakly identified in practice, so the sentence should not suggest a proof. Suggested alternative: "... without random effects the model is a Dawid--Skene model with $MPR$ raters, locally identified for three or more conditionally independent raters \citep{Jones2009}; for random-effect extensions \citet{Jones2009} give only necessary parameter-counting conditions (at least four tests), which the $MPR = 45$ configurations satisfy, and Section~\ref{sec:ident} shows that identification is nevertheless weak in practice." Adjust the section reference to the actual label.

#### S031 -- Nguyen2023
- **Manuscript:** "The condition of \citet{Nguyen2023}---at least $2K - 1$ conditionally exchangeable noisy labels per item for a $K$-class mixture---is met with room to spare ($MPR = 45$ labels per item for $K = 2$)"
- **Claim attributed:** Nguyen et al. show a K-class mixture is identifiable with at least 2K-1 conditionally exchangeable noisy labels per item, and CRE-LCM meets this with 45 labels.
- **Source passage:** "Identifiability Condition (Corollary of Theorem 1). Any noisy label learning problem where the noisy label distribution is modelled as a multinomial mixture model shown in Eq. (2) is identifiable if and only if there are at least 2C − 1 i.i.d. noisy labels Ŷ of an instance X (i.e., N ≥ 2C − 1)." (p. 3 / pdf p. 3; arXiv:2301.01405v3). Theorem 1 (from Kim 1984; Elmore and Wang 2003): "N-trial C-category multinomial mixture models ... is identifiable (up to label permutation) if and only if N ≥ 2C − 1." (p. 3)
- **Verdict:** NOT SUPPORTED
- **Note:** (1) The wording is wrong. Nguyen requires **i.i.d.** noisy labels, meaning a single class-conditional categorical distribution shared by all N labels (a multinomial mixture). The paper does not say "conditionally exchangeable". Exchangeable labels, which are mixtures of i.i.d. given class, are a weaker condition that Nguyen does not cover. (2) The claim that the condition is met "with room to spare" misapplies it. In CRE-LCM the 45 labels of an item are neither identically distributed given the class (the effects a_mk and b_pk differ by configuration) nor independent given the class (because of θ_i, φ_im, ψ_ip). The multinomial-mixture result therefore does not apply to the 45 labels. The condition only covers the conditional-independence special case, where the R = 3 runs of one model-prompt pair are i.i.d. given the class: 3 = 2K − 1, which is exactly enough and has no room to spare. (3) The result is labelled "Identifiability Condition (Corollary of Theorem 1)" and uses C, not K, for the number of classes. (4) The source is an arXiv preprint (v3, Sep 2025), not peer reviewed.
- **Proposed correction:** "In the conditional-independence special case the $R = 3$ runs of every model--prompt pair are i.i.d.\ given the class, which meets the condition of \citet{Nguyen2023}---at least $2K - 1$ i.i.d.\ noisy labels per item for a $K$-class multinomial mixture---for $K = 2$; the condition does not extend to the random effects, under which the labels are only exchangeable given the class."

#### S032 -- Qu1996
- **Manuscript:** "[an item that every configuration labels 1 can be explained either as an item of class 1 or as an ambiguous item with a large θ_i, so item ambiguity and class membership are partially confounded.] This is the same mechanism that \citet{Qu1996} describe for the shared subject effect in diagnostic testing."
- **Claim attributed:** Qu et al. describe partial confounding, a weak-identification problem, between the subject random effect and latent class membership.
- **Source passage:** "The unequivocally sound x-rays were those that have such a low t in the healthy population that the positive response rates Φ(a_i0 + b_i0 t) were essentially zero for all i. ... Therefore, these two 'quasi-classes' were no longer necessary in the random effects model." (p. 806 / pdf p. 11)
- **Verdict:** PARTLY SUPPORTED
- **Note:** Qu et al. describe a related phenomenon: extreme values of the subject effect absorb response patterns that a conditional-independence model would need extra latent classes for ("unequivocal" quasi-classes in the dentistry example). They present this as a benefit of parsimony. They do **not** describe a confounding or weak-identification problem between the random effect and class membership, and they do not discuss identification of the random-effect scale. Their only identifiability remark is that 2LCR1 needs at least 4 tests (p. 800). Albert and Dodd (2004, Biometrics 60:427-435, cited by Xie2014) show weak identification of the random-effects distribution and would support a confounding claim better.
- **Proposed correction:** "A related substitution between the subject effect and the latent classes appears in \citet{Qu1996}, where extreme values of the subject effect absorb the `unequivocal' quasi-classes that a conditional-independence model would need."

#### S033 -- Qu1996
- **Manuscript:** "A class-specific scale for $\theta_i$, in the spirit of \citet{Qu1996}, makes matters worse: with $M = 3$ the extra scale trades off against the mixing proportion ..."
- **Claim attributed:** Qu et al. use a class-specific scale for the subject effect. The results that follow are the authors' own.
- **Source passage:** "equal variance components in each population (b_id = b_d for all i) ... two more parameters, b_0 for the nondiseased population and b_1 for the diseased population ... For a 2LCR1 model to be identifiable, it is necessary that p ≥ 4." (p. 800 / pdf p. 5; the extraction renders "≥" as ">")
- **Verdict:** SUPPORTED
- **Note:** The attribution is accurate. Qu's own necessary condition that at least 4 tests are needed for the class-specific-scale model (2LCR1) fits the reported failure at M = 3 and could be cited in support.
- **Proposed correction:** none (optional addition: "... consistent with the requirement of at least four tests for this model noted by \citet{Qu1996}")

#### S034 -- Carpenter2017
- **Manuscript:** The continuous parameters are then drawn with the no-U-turn sampler \citep[Stan via cmdstanr;][]{Carpenter2017} ...
- **Claim attributed:** Stan provides the NUTS sampler.
- **Source passage:** "Stan provides full Bayesian inference for continuous-variable models through Markov chain Monte Carlo methods such as the No-U-Turn sampler" (JSS 76(1) abstract, jstatsoft.org)
- **Verdict:** SUPPORTED (abstract-only)
- **Note:** The 2017 paper names cmdstan, rstan and pystan. cmdstanr came later and is not in it, but the citation is for Stan, so this is fine.
- **Proposed correction:** none

#### S035 -- Qu1996
- **Manuscript:** "[...recommend ... treating a gap above 0.15 ... as a merged-class mode, in which case a small labelled subset should be anchored.] This is, in effect, the estimation strategy of \citet{Qu1996} for the shared subject effect, retained here for $\theta_i$ while the crossed effects remain in the sampler."
- **Claim attributed:** Qu et al. estimate by integrating the subject effect out numerically (Gauss--Hermite quadrature).
- **Source passage:** "The integration in equation (2.6) is computed by using the Gauss-Hermite quadrature; that is, the integration is replaced by summation over a finite number of mass points" (p. 799 / pdf p. 4); "The ML estimation of the parameters are obtained by using the EM algorithm ... or the Powell unconstrained multivariate minimization algorithm" (p. 800 / pdf p. 5)
- **Verdict:** PARTLY SUPPORTED
- **Note:** The substance is correct. Qu et al. marginalise T by Gauss--Hermite quadrature and maximise the resulting likelihood by EM or Powell; their approach is ML, not Bayesian, hence "in effect". However, the sentence directly follows the multi-chain diagnostic and anchoring recommendation, so "This" reads as referring to those, which are not Qu's. The sentence belongs after the quadrature statement at the start of the Estimation subsection, or needs an explicit referent. (Qu et al. do recommend trying "different starting values" because of multiple maxima, p. 807, a loose analogue of the multi-chain check.)
- **Proposed correction:** "Integrating $\theta_i$ out by Gauss--Hermite quadrature is, in effect, the estimation strategy of \citet{Qu1996}, who maximised the quadrature-approximated likelihood by EM; we retain it for $\theta_i$ while the crossed effects remain in the sampler." (Place it after the first paragraph of Section~\ref{sec:estimation}, or keep it here with this explicit subject.)

#### S036 -- Vehtari2021
- **Manuscript:** ...convergence is summarised by split-$\widehat{R}$ and bulk and tail effective sample sizes \citep{Vehtari2021}.
- **Claim attributed:** Vehtari et al. define the (rank-normalised) split-R-hat and bulk-ESS and tail-ESS diagnostics.
- **Source passage:** "We will use the term bulk effective sample size (bulk-ESS ...) to refer to the effective sample size based on the rank normalized draws." ; "effective sample sizes of the 5% and 95% quantiles, which we will call tail effective sample size (tail-ESS ...)" (arXiv:1903.08008 full text; the Bayesian Analysis abstract mentions "rank-based diagnostic" and "quantile-based local efficiency measures")
- **Verdict:** SUPPORTED (abstract-only; terms confirmed in arXiv full text)
- **Note:** The printed page numbers of the Bayesian Analysis version were not checked.
- **Proposed correction:** none

#### S037 -- Dawid1979
- **Manuscript:** "the binary Dawid--Skene model with $M P R$ raters fitted by EM \citep{Dawid1979}"
- **Claim attributed:** The Dawid--Skene model is fitted by EM; the binary case is a special case.
- **Source passage:** "The EM algorithm is shown to provide a slow but sure way of obtaining maximum likelihood estimates of the parameters of interest." (p. 20 / pdf p. 2)
- **Verdict:** SUPPORTED
- **Note:** The binary model is the J = 2 case. Dawid--Skene also allows repeated questioning by the same observer: "a clinician may question the same patient more than once" (p. 21), with counts n_il^(k). The R runs could therefore be treated as repeats of M·P raters rather than as MPR separate raters. This is a design choice, not a citation error.
- **Proposed correction:** none

#### S038 -- Jones2025
- **Manuscript:** ...a major-topic code assigned by trained human coders under the Comparative Agendas Project (CAP) codebook \citep{Jones2025}...
- **Claim attributed:** The CAP/PAP codebook defines the major-topic scheme used for the codes.
- **Source passage:** The PAP codebook "provides a series of general coding guidelines for classifying observations, a complete list of all major topics and subtopics" (codebook, via comparativeagendas.net). There are 20-21 major topics and about 220 subtopics.
- **Verdict:** SUPPORTED (abstract-only)
- **Note:** The bib URL points to the "master codebook" page, while the US bills use the US PAP codebook. Both are valid, but the US codebook (Jones et al.) is the more exact match for this author list.
- **Proposed correction:** none

#### S038 -- Wilkerson2025
- **Manuscript:** The Congressional Bills Project \citep{Wilkerson2025} provides the title of every bill introduced in Congress together with a major-topic code assigned by trained human coders under the Comparative Agendas Project (CAP) codebook \citep{Jones2025}, ...
- **Claim attributed:** The dataset contains bill titles and a human-assigned CAP major-topic code for every bill.
- **Source passage:** CAP US datasets page (comparativeagendas.net/project/us/datasets): "information about more than 400,000 bills introduced in the U.S. Congress ... Each bill is coded according to the topic coding system of the Policy Agendas Project." 463,929 observations, 1947-2016. The citation given there matches the bib (Wilkerson, Adler, Jones, ... Little, 2025). On human coding, Dee & Garlick (Sci. Data 2025, PMC12283944) say "coders are trained until they code congressional bills by 21 major topic codes at 90 percent reliability".
- **Verdict:** PARTLY SUPPORTED (abstract-only)
- **Note:** The dataset has titles/descriptions and major topic codes, and the coding is by trained hand-coders, so the substance is correct. Two points to fix. (1) "Every bill introduced in Congress" is too broad: the CAP release covers 1947-2016 (80th-114th Congresses, 463,929 bills). (2) The CAP page itself does not say who does the coding. One web summary said later releases used machine-learning-assisted coding, but this could not be traced to a primary source. Confirm that the Congresses used in the application were hand-coded. Also note that the old project domain congressionalbills.org now redirects to an unrelated site, so do not cite that URL.
- **Proposed correction:** "The Congressional Bills Project \citep{Wilkerson2025} provides the title of every bill introduced in the 80th--114th Congresses (1947--2016) together with a major-topic code assigned by trained human coders under the Comparative Agendas Project (CAP) codebook \citep{Jones2025}, ..."
- **Lead-auditor note:** Confirmed against the downloaded file: v19.3 covers the 80th-114th Congresses (468,437 records in our CSV; the CAP web page quotes 463,929). This also affects our own application, which the manuscript says covers the 111th-116th Congresses. See Section 0. Avoid quoting a record count in the sentence.

#### S039 -- Carlson2025
- **Manuscript:** \citet{Carlson2025} report that such models [the efficiency tier, e.g. Claude Haiku / Gemini Flash] match or approach the larger tiers on binary classification at a fraction of the cost
- **Claim attributed:** Efficiency-tier models perform about as well as the larger models on a binary classification task at much lower cost.
- **Source passage:** "two models optimized for complex reasoning (GPT-4, Claude 3 Opus), two models optimized for efficiency (GPT-4o, Claude 3.5 Haiku), and one lightweight model (GPT-4o-mini)" (p. 710 / pdf p. 12); "GPT-4o-mini was even more cost-effective—at approximately 0.00012 USD per instance—but with significantly weaker performance." (p. 712 / pdf p. 14). Table 4 (p. 713): Claude-3.5-Haiku accuracy 0.432-0.696 vs Claude-3-Opus 0.764-0.880; GPT-4o 0.876-0.940 at about $0.45-0.50 vs GPT-4 0.576-0.796 at about $5.3-5.8.
- **Verdict:** PARTLY SUPPORTED
- **Note:** Results are mixed, and for the direct analogue of Haiku 4.5 / Gemini Flash they are unfavourable. GPT-4o, which Carlson & Burbano class as "optimized for efficiency", beat GPT-4 and Opus at about 1/10 to 1/6 of the cost. However, Claude 3.5 Haiku fell 8-43 points below Claude 3 Opus under every prompt, and GPT-4o-mini had "significantly weaker performance". The only favourable result for the cheapest model is downstream: GPT-4o-mini "produces a similar distribution of coefficients to its more expensive counterpart, albeit with slightly higher dispersion" (p. 717 / pdf p. 19). Carlson & Burbano make no general claim that efficiency-tier models match larger tiers.
- **Proposed correction:** ... \citet{Carlson2025} found that an efficiency-oriented model (GPT-4o) outperformed larger models on binary classification at roughly a tenth of the cost, although the smallest models they tested were markedly less accurate, and cost is what makes the model $\times$ prompt $\times$ run design affordable.

#### S040 -- Barrie2025
- **Manuscript:** ...its weights and digest are archived, so this arm of the ensemble is exactly reproducible, which no API-served model can guarantee once its version is retired \citep{Barrie2025}.
- **Claim attributed:** API-served models cannot be reproduced once retired, and locally stored open-weights models can be re-run reproducibly.
- **Source passage:** "our struggles with this model, its updates and other changes—including whole versions being suddenly retired ... at worst, they may simply cease to exist overnight." (p. 28) ; "our Llama implementation was replicable to a high standard ... local, versioned models are the way to go." (p. 28) ; "using a model which is stored locally and re-coding the same data produces nearly identical coding results." (SI, p. 22)
- **Verdict:** SUPPORTED (abstract-only; working-paper PDF)
- **Note:** The retirement point is directly supported. For local models the source says "nearly identical" / "variance of (or close to) 0", not *exactly* identical. The word "exactly reproducible" is the authors' own claim about their archived Qwen setup, not a claim from Barrie2025, and the citation sits on the API clause, so this is fine. Consider "reproducible" rather than "exactly reproducible" unless bitwise identity was checked. Bib: the latest accessible draft says "First draft: May 15, 2024. This draft: December 17, 2024". Alexis Palmer's research page lists it as "Conditional Accept at AJPS". No DOI or published version was found as of Sept 2026. Suggested bib: @unpublished, note = "Conditionally accepted, American Journal of Political Science", with year 2024 (draft date) or keep 2025 if a 2025 draft was used.
- **Proposed correction:** none (optional: "...so this arm of the ensemble can be re-run reproducibly, which no API-served model can guarantee once its version is retired \citep{Barrie2025}.")

#### S041 -- Carlson2025
- **Manuscript:** Larger or reasoning-oriented models were deliberately excluded: ... their suitability for plain classification is unclear \citep{Carlson2025}
- **Claim attributed:** Carlson & Burbano say it is unclear whether reasoning models suit basic classification/annotation.
- **Source passage:** "While these models excel at tasks requiring extended reasoning, their suitability for basic data annotation remains unclear. These models are optimized for complex problem-solving rather than straightforward classification" (p. 704 / pdf p. 6)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. The statement concerns "reasoning" models (o3, R1), not larger models in general; the manuscript attaches the citation only to the suitability clause, so it is fine.

#### S042 -- Norman2026
- **Manuscript:** "This is the measurement counterpart of the reliability-without-validity finding of \citet{Norman2026}: LLM raters agree with one another more closely than with task-specific human coding, and no model of their agreement alone can recover the difference."
- **Claim attributed:** Norman et al.'s "reliability without validity" finding = LLM raters agree more with each other than with task-specific human coding.
- **Source passage:** "Consistency-bias paradox is the empirical observation that high test-retest reliability (α > 0.95) can coexist with severe position bias in the same judge model, such that the judge is highly reproducible but not valid." (pdf p. 3); "Test–retest reliability measures output stability, not decision-process correctness." (pdf p. 7)
- **Verdict:** NOT SUPPORTED
- **Note:** In Norman et al., "reliability" means a single judge agreeing with ITSELF across re-runs (test-retest). "Not valid" refers to position bias, and to chance-inflated exact-match agreement with human labels. They never compare LLM-LLM agreement with LLM-human agreement, and their human labels are general preference benchmarks, not task-specific coding. The title phrase is used appropriately as a slogan, but the paraphrase after the colon misstates the finding. The analogy still works if it is stated in terms of self-consistency.
- **Proposed correction:** "This is the measurement counterpart of the reliability-without-validity finding of \citet{Norman2026}, who show that LLM judges can be almost perfectly reproducible across runs while remaining systematically biased: here, LLM raters agree with one another more closely than with task-specific human coding, and no model of their agreement alone can recover the difference."

#### S043 -- Chen2026
- **Manuscript:** \citet{Chen2026} show that if the dependence among LLM annotators is left unrestricted, only bounds on prevalence are available.
- **Claim attributed:** Under unrestricted dependence, prevalence is only partially identified.
- **Source passage:** "absent restrictions that separate the latent components, the prevalence θ is completely unidentified, and weak stochastic-ordering restrictions ... leave the identified set at [0, 1]. Identifying power comes instead from externally calibrated scores and events" (Abstract, p. 1 / pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none. Optional precision: without external calibration the "bounds" are the trivial [0, 1]; informative bounds require calibrated scores or events.

#### S044 -- Angelopoulos2023
- **Manuscript:** Design-based methods \citep{Egami2024,Angelopoulos2023} reach validity from the opposite direction, by spending a labelled subsample on a doubly robust correction
- **Claim attributed:** PPI uses a labelled subsample in a doubly robust correction.
- **Source passage:** "Prediction-powered inference uses the gold-standard dataset to quantify and correct for the errors made by the machine-learning algorithm ... The rectifier Δθ is a notion of prediction error that is relevant for the estimand of interest." (p. 669 / pdf p. 1)
- **Verdict:** PARTLY SUPPORTED
- **Note:** The labelled-subsample part is right. "Doubly robust" does not describe PPI as Angelopoulos et al. present it: the terms "doubly robust" and "design-based" never appear in the paper. PPI's correction is a "rectifier", a bias correction estimated on gold-standard data, and its validity holds "without making any assumptions about the machine-learning algorithm". The rectified estimator resembles AIPW, but PPI is not framed as doubly robust (no outcome model / propensity-model double protection). "Doubly robust" fits Egami2024 (DSL) only.
- **Proposed correction:** Design-based methods \citep{Egami2024,Angelopoulos2023} reach validity from the opposite direction, by spending a labelled subsample on a bias correction (a doubly robust one in DSL, a ``rectifier'' in prediction-powered inference); ...

#### S044 -- Egami2024
- **Manuscript:** Design-based methods \citep{Egami2024,Angelopoulos2023} reach validity from the opposite direction, by spending a labelled subsample on a doubly robust correction
- **Claim attributed:** DSL is design-based and uses a labelled (expert-coded) subsample in a doubly robust bias correction.
- **Source passage:** "We propose a framework of design-based supervised learning (DSL) ... DSL employs a doubly robust procedure to combine predicted labels and a smaller number of expert annotations." (Abstract, pdf p. 1)
- **Verdict:** SUPPORTED
- **Note:**
- **Proposed correction:** none

#### S045 -- Carlson2025
- **Manuscript:** \citet{Carlson2025} found that a configuration with 88\% first-stage accuracy produced a downstream coefficient of the wrong sign while one with 56\% accuracy did not, because the direction of error was correlated with the outcome.
- **Claim attributed:** An 88%-accuracy configuration yielded a wrong-signed coefficient; a 56% one did not; the cause was error direction correlated with the outcome.
- **Source passage:** "Claude-3-Opus + CoT has a negative point estimate in the second stage despite achieving 87.6% accuracy in the first stage. By contrast, GPT-4o-mini + role-based prompt reconstructs the positive association in the second stage while achieving only 55.6% accuracy" (pp. 714-715 / pdf pp. 16-17); "Why is this the case? If the direction of the error in the first stage is systematically correlated with the outcome in the second stage, second-stage estimates may be biased." (p. 716 / pdf p. 18)
- **Verdict:** PARTLY SUPPORTED
- **Note:** The numbers are rounded (87.6% and 55.6%), which is acceptable, but 87.6% rounds to 88%, not to an exact 88. "Coefficient of the wrong sign" overstates the finding: it was a negative point estimate, with no claim of significance. The mechanism is offered as a possible explanation ("may be biased", illustrated by a hypothetical false-negative pattern). It was not established for these configurations, so "because" turns a conjecture into a finding.
- **Proposed correction:** \citet{Carlson2025} found that a configuration with 87.6\% first-stage accuracy produced a negative point estimate for a coefficient whose benchmark sign is positive, while one with 55.6\% accuracy recovered the positive association, and attributed such reversals to first-stage error whose direction is correlated with the outcome.
- **Lead-auditor note:** In the text extraction, the name of the configuration with 87.6% accuracy sits in a figure. The accuracy figures (87.6% vs 55.6%) and the wording "despite achieving 87.6% accuracy in the first stage" were confirmed in the text (p. 715). The label "Claude-3-Opus + CoT" comes from the verifying agent's reading of the PDF; please confirm it against the figure before quoting it.

## 4. Proposed corrections (not applied)

Every proposal needs the author's approval. Items are listed by sentence number; the full reasoning is in 3.2. Sentence-level proposals that touch the same sentence (S002, S022, S023, S031, S044) must be merged into one edit.

### 4.1 Application data (Section 0)
- `05_application.tex` l. 11-12: "111th to 116th Congresses (2009--2020)" → "111th to 114th Congresses (2009--2016)"; the same fix in `data/README.md`, `README.md` and the comment in `scripts/01_sample_bills.R`.

### 4.2 Bibliography
- Cite `Vehtari2017` in `03_model.tex` l. 78 (LOO / Pareto-$k$).
- `Camuffo2026`: author order → Camuffo, Gambardella, Kazemi, Malachowski, Pandey.
- `Atil2024`, `Bavaresco2025`, `Xu2026`: replace with the published versions (Section 2.2). Atil's title changes; consider renaming the key to Atil2025.
- `Egami2024`, `Barrie2025`: optionally note "conditionally accepted, AJPS".
- Add the missing issue numbers (Section 2.3).

### 4.3 Text

- **S002 / Barrie2025** (PARTLY SUPPORTED, abstract-only): "...and re-running the same pipeline over several months yields markedly different labels, in part because API-served models are silently updated or retired \citep{Barrie2025}."
- **S003 / Baumann2025** (PARTLY SUPPORTED): "\citet{Baumann2025} replicated 37 annotation tasks from 21 published studies across 18 models and found that the choice of model and prompt alone was enough to change the sign or significance of substantive conclusions---a phenomenon they call LLM hacking."
- **S004 / Camuffo2026** (PARTLY SUPPORTED): \citet{Camuffo2026} report that in their strategy-research setting the choice of model determined the outcome in 90\% of annotations of identical business-model comparisons, with cross-model agreement barely above chance (mean Cohen's $\kappa = 0.026$).
- **S006 / Vacek1985** (PARTLY SUPPORTED): "The conditional-independence latent class model fits such data poorly \citep{Qu1996} and overstates the tests' sensitivities and specificities \citep{Vacek1985}."
- **S007 / Oberski2013** (NOT SUPPORTED): Drop Oberski2013 here: "... and the approach has since been extended, tested and implemented in software \citep{Beath2017,Xu2019}." (Oberski2013 is still cited correctly in S017.)
- **S013 / Salter-Townshend2014** (PARTLY SUPPORTED): "\citet{Salter-Townshend2014} fitted a finite mixture to annotator bias matrices in order to cluster inexpert sentiment annotators, treating annotator heterogeneity itself as a clustering problem;"
- **S014 / Warrens2013** (PARTLY SUPPORTED): "Agreement statistics such as multi-rater and weighted kappas \citep{Warrens2010,Warrens2013} summarise concordance descriptively but do not estimate accuracy against a latent truth." (or: "multi-rater kappas \citep{Warrens2010} and weighted kappas \citep{Warrens2013}")
- **S017 / Oberski2013** (PARTLY SUPPORTED): "The literature since has developed detection methods---\citet{Oberski2013}, in this journal, introduced parametric-bootstrap p-values for the bivariate residual and the score test (modification index) to latent class analysis and showed that both outperform the customary chi-square reference for bivariate residuals---and alternative parameterisations: ..."
- **S018 / Xie2014** (SUPPORTED): optional: "Crossed subject and rater random effects have been used for ordinal ratings without a gold standard, with robustness checks against misspecified random-effect distributions \citep{Xie2014}."
- **S022 / Barrie2024** (PARTLY SUPPORTED): "accuracy varies substantially across meaning-preserving prompt paraphrases \citep{Liu2026}, and so do the labels themselves \citep{Barrie2024}, across decoding runs \citep{Atil2024}, ..." -- or more simply: "outputs and accuracy vary substantially across meaning-preserving prompt paraphrases \citep{Barrie2024,Liu2026}"
- **S022 / Bavaresco2025** (PARTLY SUPPORTED): "large-scale audits of LLM judges find that agreement with human annotation varies widely across tasks and is often limited \citep{Bavaresco2025}, and that high run-to-run reliability can coexist with systematic bias \citep{Norman2026}."
- **S022 / Norman2026** (PARTLY SUPPORTED): see the S022 -- Bavaresco2025 correction (Norman cited for "high test-retest reliability coexisting with bias and chance-inflated agreement with human labels").
- **S023 / Camuffo2026** (PARTLY SUPPORTED): \citet{Egami2024} show, and \citet{Camuffo2026} stress (following Ludwig et al., 2025), that annotation error correlated with covariates yields inconsistent regression estimates regardless of average accuracy. If Ludwig et al. (2025) is in the bib, cite it directly in place of Camuffo2026.
- **S027 / Xu2026** (NOT SUPPORTED): Protocol papers \citep{Camuffo2026} recommend prompt ensembles, replication and noise-aware aggregation but supply no model in which the dependence between configurations is estimated; diagnostic work such as \citet{Xu2026} decomposes annotation error into task-inherent and model-specific components, again without modelling dependence. Alternatively, drop Xu2026 from this sentence.
- **S031 / Jones2009** (NOT SUPPORTED): "... and without random effects the model is a Dawid--Skene model, which is locally identified with three or more conditionally independent raters \citep{Jones2009}; for the random-effect (latent-trait) extension \citet{Jones2009} give only necessary parameter-counting conditions---at least four binary tests in a single population---which the $MP = 15$ model--prompt raters satisfy."
- **S031 / Nguyen2023** (NOT SUPPORTED): "In the conditional-independence special case the $R = 3$ runs of every model--prompt pair are i.i.d.\ given the class, which meets the condition of \citet{Nguyen2023}---at least $2K - 1$ i.i.d.\ noisy labels per item for a $K$-class multinomial mixture---for $K = 2$; the condition does not extend to the random effects, under which the labels are only exchangeable given the class."
- **S032 / Qu1996** (PARTLY SUPPORTED): "A related substitution between the subject effect and the latent classes appears in \citet{Qu1996}, where extreme values of the subject effect absorb the `unequivocal' quasi-classes that a conditional-independence model would need."
- **S035 / Qu1996** (PARTLY SUPPORTED): "Integrating $\theta_i$ out by Gauss--Hermite quadrature is, in effect, the estimation strategy of \citet{Qu1996}, who maximised the quadrature-approximated likelihood by EM; we retain it for $\theta_i$ while the crossed effects remain in the sampler." (Place it after the first paragraph of Section~\ref{sec:estimation}, or keep it here with this explicit subject.)
- **S038 / Wilkerson2025** (PARTLY SUPPORTED, abstract-only): "The Congressional Bills Project \citep{Wilkerson2025} provides the title of every bill introduced in the 80th--114th Congresses (1947--2016) together with a major-topic code assigned by trained human coders under the Comparative Agendas Project (CAP) codebook \citep{Jones2025}, ..."
- **S039 / Carlson2025** (PARTLY SUPPORTED): ... \citet{Carlson2025} found that an efficiency-oriented model (GPT-4o) outperformed larger models on binary classification at roughly a tenth of the cost, although the smallest models they tested were markedly less accurate, and cost is what makes the model $\times$ prompt $\times$ run design affordable.
- **S042 / Norman2026** (NOT SUPPORTED): "This is the measurement counterpart of the reliability-without-validity finding of \citet{Norman2026}, who show that LLM judges can be almost perfectly reproducible across runs while remaining systematically biased: here, LLM raters agree with one another more closely than with task-specific human coding, and no model of their agreement alone can recover the difference."
- **S044 / Angelopoulos2023** (PARTLY SUPPORTED): Design-based methods \citep{Egami2024,Angelopoulos2023} reach validity from the opposite direction, by spending a labelled subsample on a bias correction (a doubly robust one in DSL, a ``rectifier'' in prediction-powered inference); ...
- **S045 / Carlson2025** (PARTLY SUPPORTED): \citet{Carlson2025} found that a configuration with 87.6\% first-stage accuracy produced a negative point estimate for a coefficient whose benchmark sign is positive, while one with 55.6\% accuracy recovered the positive association, and attributed such reversals to first-stage error whose direction is correlated with the outcome.

---
Working files (Crossref/arXiv responses, per-page PDF text, per-group results) are in the session scratchpad and are not part of the repository.


---

## 5. Re-audit after the corrections (26 September 2026)

The author approved the decisions above. They were applied in a single commit, and steps 1–3 were then rerun **on the changed sentences and bib entries only**.

### 5.1 Changes applied

- **Congress range (Section 0):** `05_application.tex` now reads "111th to 114th Congresses (2009--2016), the most recent covered by the dataset". `README.md`, `data/README.md` and the comment and message in `scripts/01_sample_bills.R` were changed to match. The filter in the script is unchanged: it still selects 111–116, which returns 111–114.
- **Text** (sentence numbers as in Section 3): S002, S003, S004, S006, S007, S013, S014, S017, S022, S023, S027, S028, S031, S032, S035 (moved to the first paragraph of Section 3.6), S038, S039, S042, S044, S045; `Vehtari2017` is now cited in the LOO sentence of Section 3.4.
- **Bib:**
  - `Camuffo2026` author order fixed.
  - Issue numbers added to Jones2009, Marbac2016, Oberski2013, Oberski2016, Salter-Townshend2014, Warrens2010 and Warrens2013.
  - `Atil2024` changed to `@inproceedings` in Eval4NLP 2025, with the new title. Its first author is "Atıl", as in the published version, and it now prints as "Atıl et al. (2025)"; the key is unchanged.
  - `Bavaresco2025` changed to ACL 2025 Short Papers, pp. 238–255.
  - `Xu2026` changed to LAK26, pp. 325–335.
  - `Egami2024` and `Barrie2025` kept as working papers.

### 5.2 Step 1 — consistency (rebuilt from the edited sources)

37 keys are cited, the bib has 37 entries, and 37 are printed. None is (a) cited without a bib entry, (b) in the bib but never cited, or (c) printed without being cited. There are no undefined citations or references. The two Overfull hboxes (display equations in Section 3) were already present before these edits.

### 5.3 Step 2 — metadata of the changed entries

Crossref returned the same authors and order, title, venue, year and pages as the new entries for all three published versions:
- `10.18653/v1/2025.eval4nlp-1.12`: Eval4NLP 2025, Mumbai, pp. 135–148.
- `10.18653/v1/2025.acl-short.20`: ACL 2025 vol. 2, Vienna, pp. 238–255.
- `10.1145/3785022.3785070`: LAK26, Bergen, pp. 325–335.

The seven issue numbers are taken from Crossref. The `Camuffo2026` order matches the arXiv v3 PDF and abstract page.

### 5.4 Step 3 — claim verification of the changed sentences

| Sentence | Source | New claim | Evidence | Verdict |
|---|---|---|---|---|
| S002 | Barrie2025 | re-runs over months give markedly different labels, *in part* because API models are updated or retired | working paper (Dec 2024 draft): monthly re-runs differ; the authors do not claim to know the cause | SUPPORTED (abstract-only) |
| S003 | Baumann2025 | choice of model and prompt alone changes conclusions; 37 tasks / 21 studies / 18 models | temperature fixed at 0 ("model temperature to 0 for reproducibility", pdf p. 11); counts confirmed | SUPPORTED |
| S004 | Camuffo2026 | model choice determined the outcome in 90% of annotations; mean κ = 0.026 | "in 90.0% of annotations, the choice of model determined the outcome" (p. 17); "Cohen's κ averaged only 0.026" | SUPPORTED |
| S006 | Qu1996 / Vacek1985 | CI model fits poorly (Qu); overstates sensitivities and specificities (Vacek) | Qu p. 797 "the model generally fits the data poorly"; Vacek p. 959 "error rates for both tests can be substantially underestimated" | SUPPORTED |
| S007 | Beath2017, Xu2019 / Oberski2013 | Qu's approach extended, tested and implemented; detection methods evaluated by Oberski2013 | see S007 and S017 in Section 3.2; Oberski2013 is now cited only for detection | SUPPORTED |
| S013 | Salter-Townshend2014 | finite mixture on bias matrices; heterogeneity *treated as* a clustering problem | as in Section 3.2 | SUPPORTED |
| S014 | Warrens2010 / Warrens2013 | multi-rater kappas / weighted kappas | titles and content | SUPPORTED |
| S017 | Oberski2013 | BVR vs chi-square, plus bootstrap BVR and score test (new to LCA); only the latter two adequate | "the latter two methods perform adequately, while the first method does not" (abstract, p. 267); "novel to the field" | SUPPORTED |
| S022 | Liu2026, Barrie2024, Atil2024, Barrie2025, Bavaresco2025, Norman2026 | accuracy varies across paraphrases (Liu); labels vary (Barrie2024); accuracy varies across runs (Atil) and time (Barrie2025); agreement with humans varies and is often limited (Bavaresco); high reliability coexists with bias (Norman) | Section 3.2 passages; Norman: "high test–retest reliability (≥ 0.95) coexists with severe position bias" | SUPPORTED |
| S023 | Egami2024 / Camuffo2026 | Egami show; Camuffo stress the same point | Egami: DSL motivation and theory; Camuffo p. 4 states the point (crediting Ludwig et al.), and "stress" no longer claims a demonstration | SUPPORTED |
| S027 | Camuffo2026 / Xu2026 | protocol without a dependence model (Camuffo); Xu2026 decomposes error into task-inherent and model-specific components | Xu2026 abstract and Section 3; Camuffo as in Section 3.2 | SUPPORTED |
| S028 | Oberski2013 et al. | ADAC tradition of *detecting and* relaxing local independence | Oberski2013 = detection | SUPPORTED |
| S031 | Jones2009 | CI model locally identified with three tests, one population; for latent-trait extensions only a necessary parameter count, ≥ 4 tests, met by the 45 configurations | Jones §3.2.1 "one population, three independent tests" (p. 859); "With one population, at least four tests are required if any correlations are to be included" (p. 858) | SUPPORTED |
| S031 | Nguyen2023 | in the CI special case, the R = 3 runs are i.i.d. given class and meet 2K − 1 for K = 2 | "at least 2C − 1 i.i.d. noisy labels" (p. 3); in the CI special case the runs of one pair share one Bernoulli probability per class | SUPPORTED |
| S031 | (own statement) | "We give no formal identifiability proof for the full model and rely on the simulation study for empirical support." | — | n/a (the author's statement) |
| S032 | Qu1996 | *related* substitution: extreme subject effects absorb the "unequivocal" quasi-classes | Qu pp. 806–807: the unequivocal x-rays "were included in the random effects model automatically" | SUPPORTED |
| S035 | Qu1996 | Qu integrated the subject effect by Gauss–Hermite quadrature and maximised by EM | Qu p. 799 (EM), p. 800 "computed by using the Gauss-Hermite quadrature" | SUPPORTED |
| S038 | Wilkerson2025 | every bill of the 80th–114th Congresses (1947–2016) | downloaded v19.3 file: min 80, max 114; CAP datasets page "1947–2016" | SUPPORTED (abstract-only for the coding procedure) |
| S039 | Carlson2025 | GPT-4o (efficiency-oriented) beat the larger models at a fraction of their cost; the smallest models were markedly less accurate | "two models optimized for efficiency (GPT-4o, Claude 3.5 Haiku)" (p. 710); "GPT-4o achieved the best performance ... followed by Claude 3 Opus" and GPT-4o-mini "significantly weaker" (p. 712); Table 3 (pp. 712–713) costs $0.45 vs $5.25 / $2.74 | SUPPORTED |
| S042 | Norman2026 | a judge can be almost perfectly consistent across runs while systematically biased, so within-model consistency does not guarantee validity; the cross-model statement is ours | Norman: test–retest ≥ 0.95 with severe position bias ("consistency–bias paradox") | SUPPORTED (the cross-model sentence is the author's own finding, not attributed) |
| S044 | Egami2024 / Angelopoulos2023 | bias correction: doubly robust in DSL, a "rectifier" in PPI | Egami: "design-based supervised learning (DSL)", "doubly robust"; Angelopoulos: "rectifier" (12 occurrences) | SUPPORTED |
| S045 | Carlson2025 | 87.6% (Claude 3 Opus + CoT): negative point estimate against a positive benchmark; 55.6% recovered the positive association; reversals attributed to correlated error | "Claude-3-Opus + CoT has a negative point estimate ... despite achieving 87.6% accuracy"; "GPT-4o-mini + role-based prompt reconstructs the positive association ... 55.6%" (pp. 714–715); Fig. 1 note on correlated error | SUPPORTED |
| LOO | Vehtari2017 | LOO / Pareto-k / p_loo | Vehtari, Gelman & Gabry (2017) define PSIS-LOO, p_loo and the Pareto-k diagnostic | SUPPORTED |

**Result:** all 23 changed claims are SUPPORTED, two of them from the abstract or official page only; none is NOT or PARTLY SUPPORTED.

### 5.5 Deliberately not changed (open for the author)

- **Identification wording elsewhere.** The Introduction ("we characterise the conditions and the remedies under which point identification is recovered") and the Positioning paragraph ("which yields point identification under stated conditions") are unchanged. After the new S031 ("no formal identifiability proof for the full model") they read as stronger than the evidence. Suggested wording: "... under which the parameters are recovered in practice" and "... which yields point estimates under stated conditions, supported by simulation". Not applied, because it was not part of the approved list.
- **Supported sentences with optional wording notes** (Section 3.2) were left as they are: S005 (GLAD estimates expertise rather than an error matrix), S018 ("crossed subject and rater" effects), and S040 (Barrie2025 says local models give "nearly identical" rather than "exactly reproducible" results).

**Update (same commit): the identification wording item is resolved.** Four places were changed.
- **Abstract:** "recovers point identification without a gold standard" → "yields point estimates without a gold standard, with identification supported empirically by simulation". The added words are offset by dropping the unused abbreviation "(LLMs)" and shortening the last sentence, so the abstract stays at 249 words.
- **Introduction:** "under which the model yields point estimates, with identification supported empirically by the simulation study rather than proved".
- **Positioning:** "yields point estimates under stated conditions (with identification supported empirically by simulation)".
- **Conclusion:** "yields point estimates without human labels---identification is supported empirically by the simulation study rather than proved".

No sentence citing a source was changed.

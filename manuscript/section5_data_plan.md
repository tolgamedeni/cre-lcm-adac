# Section 5 — application data plan (drafted 22 Sept 2026, before the grid finished)

## 1. Data: US Congressional bill titles, Comparative Agendas Project (CAP)

Why this corpus
- Human-coded reference labels exist for every record (one major topic per bill), coded by trained
  coders under a published codebook, so the human label is a genuine held-out gold standard.
- Bill titles are short (typically 20–60 words), so API cost is trivial and a local model handles
  them easily; the task is a classic content-analysis task in public policy — Tolga's field.
- Licence: CAP topic-code variables are CC BY-NC-SA 4.0 (https://www.comparativeagendas.net/pages/Copyright-and-Legal);
  the master codebook must be cited as Jones et al. (2025) "Policy Agendas Project: Codebook";
  the bills dataset carries its own citation (Congressional Bills Project, Wilkerson et al.),
  see https://www.comparativeagendas.net/pages/How-to-cite. Redistribution of the derived file
  (bill id, title, CAP major topic, our LLM labels) is permitted under CC BY-NC-SA with attribution.
- Source: Congressional Bills Project (congressionalbills.org), .tsv, 1947–2020; the CAP US page
  points to it. Fields needed: bill id, Congress, title, `majtopic` (CAP major topic).

Alternative worth one sentence in the paper: the Turkish Policy Agendas Project (same codebook,
Turkish texts). Not used in the main analysis — LLM behaviour on Turkish would add a second
research question — but a natural extension for future work and for Tolga's own follow-ups.

## 2. Task definition

Binary first (matches the model in Section 3); multiclass as a robustness/extension.
- Target class: CAP major topic 3, **Health**. Rationale: prevalence in the bills data is in the
  10–20% range (close to the simulation's 0.30 after stratification), the category is well
  defined, and health bills have known boundary cases (veterans' health = 16? social welfare = 13)
  that create genuine item ambiguity — exactly what θ_i is meant to capture.
- Sample: N = 800 bills, stratified: 240 Health (30%), 560 non-Health drawn proportionally from
  the other 20 topics; restrict to the 111th–116th Congress (2009–2020) so titles are modern
  English and outside most LLMs' memorised CAP tables is not a concern (titles are public anyway).
  Seed the sample; keep 200 as a pure validation set never used for anchoring.
- Multiclass check (optional, Section 5.5): the same 800 bills with a 5-way label
  {Health, Macroeconomics, Defense, Environment, Other}.

## 3. Annotation design (model × prompt × run)

Models (M = 3, one per family; pin exact version strings and dates in the data file):
  1. Anthropic: claude-haiku-4-5-20251001 (cheap; the "efficiency" tier). Optional second
     Anthropic run with claude-sonnet-5 as a sensitivity check, not part of the main M = 3.
  2. Google: Gemini Flash (current stable version at run time; record the version id).
  3. Local, open weights via Ollama: qwen2.5:7b-instruct (or llama3.1:8b-instruct). ~5 GB at Q4,
     fits beside the running VM. Run it AFTER the simulation grid finishes so the two jobs do not
     contend for CPU. Record the Ollama model digest for reproducibility.

Prompts (P = 5, semantically equivalent; ordered from bare to structured — see section 4).

Runs: R = 3 at temperature 0.7 (Gemini and Ollama: temperature 0.7; Anthropic: temperature 0.7).
Sensitivity: one extra pass at temperature 0 for prompt 1 only, to show that "deterministic"
settings still disagree across models (Atil2024).

Output constraint: answer must be a single digit "1" or "0". **Revised 25 Sept 2026 (after the dry
runs):** max_tokens = 16 for all three providers and the first digit in the answer is parsed; an answer
without a 0/1 is re-queried once, then recorded as missing (report the rate). Reason: with
max_tokens = 2 the Gemini 3.x Flash models return an empty answer (output tokens are consumed
before a visible token even with thinking disabled); the same rule is applied to every provider so
that the three models are treated identically. Gemini model: gemini-3.5-flash with thinking
disabled (the current stable Flash reachable with the project key; gemini-3.8-flash rejected the key's quota).

Volume and cost: 800 items × 5 prompts × 3 runs = 12,000 calls per model. Inputs ≈ 180 tokens,
outputs 1–2 tokens → ≈ 2.2M input tokens per model. At current Haiku / Flash prices this is in
the order of a few USD per model; the local model is free. Total API cost well under 50 USD
including sensitivity passes.

## 4. Prompt templates (fill {TITLE})

P1 (bare)      Is the following US congressional bill primarily about health? Bill title: "{TITLE}"
               Answer with a single digit: 1 for yes, 0 for no.
P2 (codebook)  You are coding US congressional bills by policy topic using the Comparative Agendas
               Project scheme. The topic "Health" (code 3) covers health care, health insurance,
               drugs and pharmaceuticals, medical facilities, mental health, disease prevention and
               health research. Does the bill below belong to this topic as its main subject?
               Title: "{TITLE}"  Reply 1 (yes) or 0 (no) only.
P3 (contrast)  A bill's main subject can be health, or one of twenty other policy areas such as
               the economy, defence, education, the environment or law. Consider the title and
               decide whether its main subject is health.  "{TITLE}"  Output only 1 or 0.
P4 (role)      As an experienced legislative analyst, classify this bill title. Output 1 if the
               bill's primary purpose concerns health policy, 0 otherwise. Title: "{TITLE}"
P5 (reasoned)  Read the bill title and think about its primary policy purpose, then decide whether
               that purpose falls under health. Do not write your reasoning. Reply with the final
               digit only: 1 = health, 0 = not health. Title: "{TITLE}"
               [Revised 25 Sept 2026 by the author after the dry run: the original wording
               ("identify its primary policy purpose in your own words, then ... give only the
               final digit") made Gemini 3.5 Flash write its reasoning first, so no digit appeared
               within 16 output tokens and the label was recorded as missing.]

Prompt authorship note for the paper: templates written by the author, not generated by a model
(contrast with Carlson2025, who generated 100 variants with Claude). Report all five verbatim in
the appendix.

## 5. Analysis plan (Section 5.3–5.4)

1. Descriptives: agreement matrix across the 45 configurations; Fleiss' κ per model (Warrens2010).
2. Fit Dawid–Skene and CRE-LCM(e) to the 600 non-validation items without any human labels.
3. Fit CRE-LCM(c) with 5% (30) anchored items drawn from the 600.
4. Evaluate all methods against the CAP human label on the 200-item validation set and on the
   non-anchored 570: accuracy, Brier, calibration plot.
5. Report variance shares with 95% intervals; translate into design advice ("adding a fourth
   prompt buys X, a fourth run buys Y").
6. Per-configuration sensitivity/specificity from CRE-LCM vs. computed against human labels —
   this is the direct test of "DS overstates accuracy".
7. Posterior predictive checks: distribution of agreement counts per item.
8. Temperature-0 sensitivity and (optional) multiclass.

## 6. Claude Code prompt for the data stage (use after the grid and step 5 are done)

```
DATA STAGE. Implement scripts/ for the application in Section 5 following
manuscript/section5_data_plan.md exactly. (1) Download the Congressional Bills
Project tsv, filter Congresses 111-116, draw the stratified sample of 800 (seed
2026), write data/bills_sample.csv with bill id, congress, title, cap_majtopic,
health (0/1), split (validation 200 / working 600). Do not include any other
CAP variables. (2) Write annotate.R (or Python) that runs the 5 prompts x 3 runs
at temperature 0.7 against Anthropic (claude-haiku-4-5-20251001), Gemini Flash
and Ollama qwen2.5:7b-instruct, with retries, rate limiting, exact version
strings, timestamps and raw responses saved to data/raw/; parsed labels to
data/labels_long.csv (item, model, prompt, run, label, missing). Keep API keys
in environment variables only; never write them to disk or logs. Run a 20-item
dry run on each provider and stop for my confirmation before the full run.
(3) After the full run, fit DS, CRE-LCM(e) and CRE-LCM(c) as in section 5 of
the plan and write results/application/ with the tables and Fig5-Fig6.
```

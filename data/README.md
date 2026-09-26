# data/ -- application data for Section 5 (policy-topic coding of US congressional bills)

## Source

Comparative Agendas Project (CAP), United States, "Congressional Bills" dataset, version 19.3
(the CAP site serves this dataset as a CSV; the data plan referred to it as a tsv).

- Download URL: https://minio.la.utexas.edu/compagendas/datasetfiles/US-Legislative-congressional_bills_19.3_3_3%20%281%29.csv
  (linked from https://www.comparativeagendas.net/project/us/datasets)
- Downloaded: 2026-09-25 10:33 UTC
- File: `data/source/congressional_bills_19.3.csv` (116,179,619 bytes; 468,436 records; git-ignored)
- SHA-256: 28662e351835aa6c78abee931427f1c5a245f3cfd93fff7d11aadfbd95761230
- Fields used: `bill_id`, `cong`, `description` (bill title), `majortopic` (CAP major topic code).
  No other CAP variable is retained.

## Licence and attribution

The CAP topic-code variables are distributed under the Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International licence (CC BY-NC-SA 4.0,
https://www.comparativeagendas.net/pages/Copyright-and-Legal). The derived file below (bill id,
Congress, title, CAP major topic, our LLM labels) is redistributed under the same licence with
attribution. Please cite:

- Wilkerson, John, E. Scott Adler, Bryan D. Jones, Frank R. Baumgartner, Guy Freedman, Sean M.
  Theriault, Alison Craig, Derek A. Epp, Miranda E. Sullivan, Shruti Khandekar, Daniel Little. 2025.
  Policy Agendas Project: Congressional Bills. Comparative Agendas Project,
  https://www.comparativeagendas.net/us (accessed 25 September 2026).
- Jones, Bryan D., Frank R. Baumgartner, Sean M. Theriault, Derek A. Epp, Shruti Khandekar, Daniel
  Little. 2025. Policy Agendas Project: Codebook. Comparative Agendas Project,
  https://www.comparativeagendas.net/pages/master-codebook.
- Comparative Agendas Project, "How to cite": https://www.comparativeagendas.net/pages/How-to-cite.

## Derived files

- `bills_sample.csv` (`scripts/01_sample_bills.R`): 800 bills from the 111th-114th Congresses (2009-2016; v19.3 ends with the 114th) with a non-missing title and one of the 20 CAP major topics (1-10, 12-21; code 99
  "other" excluded). Stratified sample with seed 2026: 240 bills with major topic 3 (Health) and
  560 drawn from the other 19 topics in proportion to their frequency (largest-remainder rounding).
  Columns: `bill_id`, `congress`, `title`, `cap_majtopic`, `health` (1 if major topic 3),
  `split` (`validation` = 200 bills drawn at random with seed 2027, never used for anchoring;
  `working` = 600). Population: 37,007 eligible bills, 11.6% Health.
- `raw/` (`scripts/annotate.py`): one JSON-lines file per provider with every raw model response
  (timestamp, model id, prompt id, run, temperature, raw text, parse result). Git-ignored raw
  API traffic is archived with the Zenodo release.
- `labels_long.csv`: parsed labels, one row per (bill, model, prompt, run): `bill_id`, `model`,
  `model_id`, `prompt`, `run`, `temperature`, `label` (0/1), `missing` (1 if no 0/1 digit after one retry). All providers: max_tokens 16, first digit parsed (decision of 25 Sept 2026, see the plan).
- `labels_temp0.csv`: the temperature-0 sensitivity pass (prompt 1 only, one run per model).
- `prompts.md`: the five prompt templates verbatim (written by the author).

## Annotation run record (completed 26 Sept 2026)

| provider | model (as served) | calls | missing labels | input / output tokens | dates (UTC) | cost |
|---|---|---|---|---|---|---|
| anthropic | claude-haiku-4-5-20251001 | 12,800 | 0 (0.00 %) | 1,176,994 / 90,493 | 2026-09-25 | USD 1.63 (list: 1.00 / 5.00 per M tokens) |
| gemini | gemini-3.5-flash, thinking disabled | 12,800 (12,819 answered incl. retries) | 10 (0.08 %) | 1,041,922 / 13,150 | 2026-09-25 to 26 | USD 1.68 (list: 1.50 / 9.00 per M tokens, ai.google.dev/gemini-api/docs/pricing, 26 Sept 2026) |
| ollama | qwen2.5:7b-instruct, digest 845dbda0ea48…b697e, Q4_K_M, Ollama 0.34.4 | 12,800 | 0 (0.00 %) | 1,399,416 / 56,036 | 2026-09-25 | 0 (local) |

Calls = 800 bills x 5 prompts x 3 runs at temperature 0.7 plus 800 calls of prompt 1 at temperature 0.
Gemini hit its daily request quota after about 10,000 calls on 25 Sept; the 2,928 remaining calls were made after
the quota reset on 26 Sept (quota failures were retried, never recorded as missing). The 10 Gemini missing labels are
answers that began with prose ("Based on the title ...") and contained no digit within 16 output tokens after one retry.

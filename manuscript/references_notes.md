# references.bib — provenance and open items (2026-09-22)

`references.bib` was generated from the 28 PDFs in `../../refs/` (root, `A/`, `B/`):
title, authors, year, venue and DOI extracted with `pdftotext` and the DOI regex
`10.\d{4,9}/...`; BibTeX key = file stem. Validated with pdflatex + bibtex
(28 entries, 0 warnings). Overrides supplied by the author: Carlson2025 = published
SMJ version (2026, 47(3), 699–725, 10.1002/smj.70023); Egami2024 = working paper
(17 Nov 2024, https://naokiegami.com/paper/dsl_ss.pdf), cited as @unpublished.

## Entries without a DOI (flagged with `note = {DOI not found in PDF}`)

| key | reason | what to do before submission |
|---|---|---|
| Dawid1979 | JSTOR scan, stable URL 2346806 | JSTOR DOIs are 10.2307/<stable id>; add `doi = {10.2307/2346806}` after checking on jstor.org |
| Qu1996 | JSTOR scan, stable URL 2533043 | likewise `10.2307/2533043` |
| Vacek1985 | JSTOR scan, stable URL 2530967 | likewise `10.2307/2530967` |
| Liu2026 | no DOI, arXiv id, date or venue in the PDF (metadata date 2 Apr 2026); entered as @unpublished, year from file stem | locate the paper's arXiv/SSRN record or journal version |

## Key / year mismatches (kept as the PDF states; keys unchanged)

- `Jones2009` is Biometrics 66:855–863, **2010** (the DOI is a 2009 DOI).
- `Xie2014` is Stat. Med. 32(20):3472–3485, **2013** (PDF is the PMC author manuscript).
- `Carlson2025` is **2026** per the override.
- ADAC checklist B requires published/accepted works in the list; the eight arXiv items
  (Atil2024, Barrie2024, Baumann2025, Bavaresco2025, Camuffo2026, Chen2026, Messing2026,
  Nguyen2023, Norman2026, Xu2026, Zhang2025) must be re-checked for journal versions.

## Fields deliberately omitted rather than inferred

- `number` only where printed in the PDF (Springer ADAC papers and Jones2009 print volume:pages only).
- Beath2017 pages `1--25` follow the JSS convention (25-page PDF, not printed).
- arXiv entries: `year` = first-version year (matches file stem); the PDF version and date are in `note`
  (Barrie2024's PDF is v3 dated 15 May 2026).

## Corrections relative to the earlier hand-written draft

- Xu2019 DOI is 10.1214/19-AOAS1256 (draft had ...1254).
- Chen2026 = "Partial identification from LLM prompts" (arXiv:2606.15031); Norman2026 = "Reliability without validity"
  (arXiv:2606.19544); Messing2026 = "Hidden measurement error in LLM pipelines" (arXiv:2604.11581);
  Xu2026 = "Enhancing LLM-based data annotation with error decomposition" (arXiv:2601.11920);
  these replace the placeholder `Anonymous` entries. The manuscript skeleton's citation keys must use these stems.

## Added by hand on 2026-09-22 (no PDF in refs/)

Carpenter2017 (Stan, JSS 76(1)), Whitehill2009 (GLAD, NeurIPS 22, no DOI), Vehtari2017 (PSIS-LOO, Stat. Comput. 27), Vehtari2021 (rank-normalised R-hat, Bayesian Anal. 16), Gilardi2023 (PNAS 120(30)). DOIs entered from the publishers' records; verify once more at submission.

## 2026-09-22, later: applied the author's open items from manuscript_draft_v5.md

- JSTOR DOIs added to Dawid1979, Qu1996, Vacek1985 (values supplied by the author in the v5 key map).
- Liu2026 changed to @misc arXiv:2604.16413 with its DOI (supplied by the author).
- Raykar2012 (JMLR 13:491-518) and Barrie2025 (working paper; URL https://arthurspirling.org/documents/BarriePalmerSpirling_TrustMeBro.pdf found 2026-09-22, no arXiv/SSRN record located; check for a journal version before submission) added because Sections 1-2 cite them.
- Not added (listed in v5 as candidates but not cited in the current text): Stephens2000, Bacci2014, Fibbi2024, Babu2025.

## Note fields removed from references.bib (2026-09-22, so they do not print)

- Dawid1979: DOI from JSTOR stable id, supplied by the author
- Qu1996: DOI from JSTOR stable id, supplied by the author
- Vacek1985: DOI from JSTOR stable id, supplied by the author
- Raykar2012: Added by hand from the v5 key map; verify
- Raykar2012 confirmed by the author as J. Mach. Learn. Res. 13:491-518.

## 2026-09-25: further note fields removed so that they do not print

- Liu2026: "Working paper, Boston University. DOI not found in PDF" (entry is now the arXiv record 2604.16413 supplied by the author).
- Whitehill2009: "No DOI (NeurIPS proceedings)" (NeurIPS 22 proceedings have no DOI).
- Oberski2013: second author corrected to "van Kollenburg, G. H." at the author's request.

## 2026-09-26: data citations added by hand (from data/README.md and the CAP "How to cite" page)

- Wilkerson2025: Policy Agendas Project: Congressional Bills, dataset version 19.3 (citation text as shown on comparativeagendas.net/project/us/datasets).
- Jones2023: Policy Agendas Project: Master Codebook. Author list as given in the plan (section5_data_plan.md); verify against the CAP "How to cite" page before submission.

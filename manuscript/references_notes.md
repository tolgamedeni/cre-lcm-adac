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

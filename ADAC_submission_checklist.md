# ADAC submission checklist (verified 22 Sept 2026 against the journal's Submission Guidelines page)

Submission portal: Editorial Manager — https://www.editorialmanager.com/adac/
Review: double-anonymous, at least 2 reviewers, decision by an Editor.

## A. Files to upload

| # | File | Required? | Notes |
|---|------|-----------|-------|
| 1 | Anonymised manuscript — LaTeX source (.tex, .bib, .cls/.sty, figure files) **and** compiled PDF | Yes | Springer Nature LaTeX template (sn-jnl.cls). Word accepted but LaTeX expected in this journal. No author names, affiliations, acknowledgements, funding, or self-revealing citations anywhere — including figure files and supplementary files. |
| 2 | Title page (separate file) | Yes | Title; all authors; affiliations (institution, department, city, country); corresponding author + active e-mail; ORCIDs; Acknowledgements; **Declarations** section (see C). |
| 3 | Cover letter | Recommended | Fit with ADAC scope; statement that the work is original and not under review elsewhere; suggested reviewers (optional, with institutional e-mails, mixed countries/institutions); any material re-use. |
| 4 | Figures | Inside the manuscript body | Vector: EPS preferred (PDF generally accepted by SN LaTeX); halftone TIFF ≥300 dpi; combination ≥600 dpi. Files named Fig1.eps, Fig2.eps … Widths 84 mm (one column) or 174 mm (full width), max height 234 mm. Lettering Helvetica/Arial 8–12 pt, consistent size; no titles inside figures. Patterns/linetypes in addition to colour (accessibility + B/W print). |
| 5 | Supplementary Information (Online Resource 1, 2 …) | Optional | PDF for text; .csv/.xlsx for tables; .zip for code bundles. Each file must carry title, journal, authors — so for double-blind review submit an **anonymised** SI and add author details after acceptance. Cited in text as "Online Resource n". |
| 6 | Research data / code | Statement required | See section D. |

## B. Manuscript front matter and format

- Abstract 150–250 words, no undefined abbreviations, no citations.
- 4–6 keywords.
- **MSC codes** (Mathematics Subject Classification) — required. Candidates for this paper: 62H30 (classification and discrimination; cluster analysis), 62F15 (Bayesian inference), 62P25 (applications to social sciences), 62J12 (generalized linear models), 68T50 (natural language processing).
- Headings: decimal, max three levels.
- Footnotes only (no endnotes).
- Notation: italic scalars, upright operators/functions, bold vectors and matrices.
- Citations: author–year in parentheses (Thompson 1990; Becker and Seligman 1996).
- Reference list: alphabetical, published or accepted works only, full DOI links, ISSN journal abbreviations. arXiv-only items are acceptable as online documents but each should be checked for a journal version before submission.
- Tables: Arabic numerals, captions above, footnotes with superscript letters.
- Figure captions in the text file, beginning **Fig. n** (bold), no trailing punctuation.
- LLM use must be documented in the Methods section (we use LLMs as the *object* of study, so this is natural; also declare any LLM-assisted code or drafting beyond copy-editing).

## C. Declarations (on the title page)

Every submission is returned as incomplete without these:
- Funding (or "The authors did not receive support from any organization for the submitted work.")
- Competing interests (financial and non-financial) — note: Tolga's ITM Software LLC and Tuulrik should be considered; if unrelated, a blanket "no relevant interests" statement suffices, but consider disclosing that an author operates a software company as a non-financial interest for transparency.
- Ethics approval / Consent — not applicable (no human participants; public text data). State "Not applicable".
- Data availability statement — required.
- Code availability statement — expected.
- Author contributions (CRediT).

## D. Is GitHub required?

No — but a **Data Availability Statement is mandatory** under Springer Nature's research data policy, and reviewers/editors may ask for data and code. For a methods paper in this journal, a public code repository is the practical standard and will be expected by reviewers.

Recommended setup:
1. GitHub repository with the full R/Stan code, simulation seeds, prompt templates, model version strings, and the LLM annotation outputs (the raw labels — these are the "research data").
2. Archive a release on **Zenodo** to obtain a DOI (cite the DOI, not just the GitHub URL, in the Data/Code Availability statements).
3. For double-blind review, provide an **anonymised** link (e.g. an Anonymous GitHub mirror at anonymous.4open.science, or a Zenodo record shared via a reviewer access link) and put the identified repository only on the title page.
4. Comparative Agendas Project data: cite the source and its licence; redistribute only what the licence permits (typically the derived labels plus document IDs, not the full texts).
5. Add a `renv.lock` (or sessionInfo) and a `run_all.R` so the results reproduce from one command.

Suggested statements:
- Data: "The human-coded texts are from the Comparative Agendas Project (URL, accessed DATE). All LLM annotations generated for this study, together with prompt templates and model version identifiers, are archived at Zenodo (DOI)."
- Code: "R and Stan code reproducing all simulations, figures and tables is available at Zenodo (DOI) / GitHub (URL)."

## E. Open access and cost

Hybrid journal. Subscription route: no charge. Open Choice APC ≈ USD 2,990 (list) — covered for Turkish corresponding authors by the TÜBİTAK-ULAKBİM–Springer Nature Read & Publish agreement (2026 quota, first-come first-served, decision based on **acceptance** date; the 2024–2026 agreement's renewal beyond 2026 must be checked). Use the AYBÜ institutional e-mail as corresponding author to be matched to the agreement. Colour is free online; charged only for colour in print.

## F. Pre-submission checks

- [ ] Run Springer's own pre-submission checklist: https://link.springer.com/pre-submission?journalId=11634
- [ ] Anonymisation pass on .tex, .bib (no "our earlier work (Medeni 20xx)"), figures, SI, file metadata (PDF author field, EPS creator tags)
- [ ] All figures cited in order; all tables cited in order; all references cited
- [ ] MSC codes present; abstract word count; keyword count
- [ ] Final literature check for new arXiv/journal versions of the closest competitors (Zhang et al. 2025; Partial Identification 2026)
- [ ] Repository: README, licence (MIT for code; CC-BY for data), Zenodo DOI minted, anonymised mirror created
- [ ] Plagiarism/self-text-recycling check — no reuse of text from Tolga's earlier papers
- [ ] Corresponding author = AYBÜ address; ORCID 0000-0002-0642-7908 on title page

# Systematic Review Mode (PRISMA-Style)

Use this workflow when the deliverable must be reproducible: you need a defensible search strategy, explicit inclusion/exclusion criteria, and traceable screening decisions.

## 1) Define the Research Question

Pick a question framework that matches your field:

- Health/clinical: **PICOS** (Population, Intervention, Comparison, Outcomes, Study design)
- Qualitative social science: **SPIDER** (Sample, Phenomenon of Interest, Design, Evaluation, Research type)
- CS/ML (pragmatic): **TDMM** (Task, Data, Model, Metric)

Write the question in one sentence, then list:
- target time window
- languages
- publication types (journals, conferences, preprints, theses, standards)

## 2) Protocol (What You Will Do, Before You Do It)

Minimum protocol fields:

- Eligibility criteria: inclusion and exclusion
- Databases and sources to search
- Search strings (exact queries)
- Screening procedure (title/abstract then full text)
- Data extraction fields
- Quality appraisal method (domain-specific)
- Synthesis plan (narrative, taxonomy, meta-analysis if applicable)

## 3) Search Log Template (Reproducibility)

Maintain a log like:

| Date | Database | Query | Filters | Results | Notes |
|------|----------|-------|---------|---------|-------|
| YYYY-MM-DD | IEEE Xplore | (`term1` AND `term2`) | 2021-2026, English | 123 | exported CSV |

## 4) Screening Log Template (Traceability)

Track decisions and reasons:

| ID | Citation Key | Stage | Decision | Reason (if excluded) |
|----|--------------|-------|----------|----------------------|
| 17 | smith2023 | Title/Abstract | Exclude | not about target task |

## 5) Extraction Matrix Template (Structured Reading)

Recommended minimum fields (adapt to domain):

| Citation Key | Year | Venue | Type | Research Question | Method | Data/Benchmark | Metrics | Main Results | Baselines | Limitations | Code/Data |
|--------------|------|-------|------|-------------------|--------|----------------|---------|--------------|----------|-------------|----------|

## 6) Quality Appraisal (Lightweight but Explicit)

Pick a rubric and apply it consistently. Example prompts:

- Is the methodology sufficiently described to reproduce?
- Are datasets/splits clearly defined? Any leakage risk?
- Are baselines appropriate and fairly tuned?
- Are results statistically supported (CIs/tests) when needed?
- Are limitations and threats to validity discussed?

## 7) Synthesis

Systematic reviews should synthesize, not summarize:

- Build a taxonomy of approaches (by assumptions, data regime, objective, model family, evaluation protocol).
- Identify consensus and contradictions (and why they differ: datasets, metrics, settings).
- Highlight gaps: missing ablations, missing external validity, missing negative results, missing comparisons.

## 8) Reporting Structure (Suggested)

- Introduction (scope, motivation)
- Methods (databases, search strings, screening, extraction, appraisal)
- Results (PRISMA-style counts + taxonomy + evidence tables)
- Discussion (implications, limitations, threats to validity)
- Conclusion (gaps + future directions)


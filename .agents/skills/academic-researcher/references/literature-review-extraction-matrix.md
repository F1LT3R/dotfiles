# Literature Review Extraction and Synthesis

Use this when writing a narrative literature review or "Related Work" section that must be organized thematically and defensibly.

## Extraction Matrix (Per Paper)

Create a table (spreadsheet or Markdown) with fields like:

| Citation Key | Problem/Task | Core Idea | Assumptions | Data | Metric(s) | Result(s) | Strengths | Limitations | Notes |
|-------------|--------------|-----------|-------------|------|-----------|-----------|-----------|-------------|-------|

Guidance:

- Capture the *claim* the paper makes and the *evidence* it provides (not just a summary).
- Record evaluation details: dataset version, split, preprocessing, baseline tuning, compute budget.
- Record what the paper does **not** evaluate (common gap generator).

## Thematic Synthesis (How to Organize the Review)

Prefer themes that explain *why* work differs:

- objective (accuracy, robustness, fairness, interpretability, efficiency)
- constraints (privacy, on-device, low-data, streaming, real-time)
- supervision regime (fully supervised, self-supervised, weakly supervised)
- evaluation protocol (in-domain, cross-domain, OOD, human evaluation)

## Contradiction Tracking

When results disagree across papers, log:

- datasets/benchmarks differ
- metrics differ
- implementation details differ
- hyperparameter budgets differ
- evaluation scope differs (in-domain vs OOD)

## Evidence Tables (High-Leverage Artifact)

Build at least one table that a reviewer can audit:

| Approach | Key Idea | Data | Metric | Result | Notes/Caveats | Source |
|----------|----------|------|--------|--------|---------------|--------|


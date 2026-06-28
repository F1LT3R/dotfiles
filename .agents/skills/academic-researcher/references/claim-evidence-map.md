# Claim-Evidence Map

A claim-evidence map prevents overclaiming and makes peer review easier. Use it while drafting, then keep a trimmed version as an internal QA artifact.

## Template

| Claim (Your Paper) | Strength | Evidence (What Supports It) | Conditions | Caveats | Citation(s) |
|--------------------|----------|-----------------------------|-----------|---------|-------------|
| "Method X improves accuracy" | Strong/Medium/Weak | Table 2 vs baselines | Dataset A, metric M | limited to in-domain | smith2023, jones2022 |

## How to Use

- Every non-trivial claim should map to a concrete artifact:
  - a cited external source
  - your own result table/figure
  - a formal statement/theorem
- For comparative claims ("better", "faster", "more robust"), write the comparison set explicitly (which baselines? which settings?).
- For generalization claims, specify the evaluation scope (in-domain, cross-domain, OOD, human studies).

## Red Flags

- A claim is supported by a citation that does not actually contain the stated result.
- A claim depends on unstated assumptions (dataset preprocessing, tuning budget, compute).
- A claim uses ambiguous adjectives ("significant", "substantial") without numbers or tests.

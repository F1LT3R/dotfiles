# Statistical Reporting (Practical)

This guide is for common scenarios in empirical papers. It does not replace domain-specific standards.

## Prefer Effect Sizes + Uncertainty

- Report point estimates with uncertainty (confidence intervals, standard errors, or bootstrap intervals).
- For comparisons, report deltas (e.g., +1.8 AUC) and uncertainty, not only raw scores.

## Significance Testing (When Used)

- State the test, assumptions, and whether it is paired/unpaired.
- Correct for multiple comparisons when testing many hypotheses.
- Do not treat `p < 0.05` as the only criterion; discuss practical significance.

## Aggregation and Variance

- If results depend on random initialization or sampling, run multiple seeds and report mean +/- std (or median/IQR).
- For skewed metrics, consider robust summaries (median, trimmed mean).

## Common ML Evaluation Notes

- Use paired tests when comparing methods on the same folds/seeds.
- For small benchmark sets, bootstrap CIs can be more informative than a single test.
- If using human evaluation, describe annotator instructions, agreement, and sample size rationale.

## Minimum Reporting Checklist

- Sample sizes per condition
- Exactly how metrics were computed (including thresholds and averaging)
- Uncertainty estimates or rationale for omitting them
- Any exclusions/outlier handling rules stated upfront

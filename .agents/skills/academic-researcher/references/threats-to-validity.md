# Threats to Validity (Template + Prompts)

Include a threats-to-validity section whenever you make non-trivial empirical claims. Use the prompts below to avoid the most common reviewer objections.

## Internal Validity (Causality / Confounding)

- Could implementation details explain the effect (hyperparameter budget, early stopping, data preprocessing)?
- Are ablations sufficient to attribute gains to the proposed component(s)?

## Construct Validity (Are You Measuring the Right Thing?)

- Do chosen metrics align with the stated goal?
- Are proxies used (e.g., automatic metrics) and what do they miss?

## Statistical Conclusion Validity (Uncertainty / Error)

- Is variance reported (seeds, folds, bootstrap)?
- Are comparisons robust or driven by a small number of cases?
- Any multiple-comparison issues?

## External Validity (Generalization)

- Do results transfer across datasets/domains/languages/hardware?
- Any deployment assumptions that break in real settings?

## Reproducibility Threats (Practical)

- Missing details: data versions, splits, compute, dependencies
- Non-determinism not addressed (random seeds, hardware differences)


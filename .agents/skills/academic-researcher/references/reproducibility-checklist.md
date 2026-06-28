# Reproducibility Checklist

Use this checklist as a pre-submission QA step. It is intentionally cross-domain; adapt as needed.

## Artifacts

- Code repository link (or statement why it cannot be shared)
- Data availability statement (dataset links, licenses, access constraints)
- Environment specification (OS, language/runtime versions, key dependencies)
- Compute description (GPU/CPU types, memory, training/inference time)

## Experimental Design

- Exact dataset version and preprocessing steps
- Train/val/test splits (or cross-validation folds) and how they were created
- Random seed policy (single seed vs multiple seeds) and reporting
- Baseline selection rationale and tuning budget fairness
- Ablations: which components were removed/changed and why

## Reporting

- Metrics are defined formally (including aggregation and thresholds)
- Confidence intervals or statistical tests when appropriate
- Failure cases and limitations are documented (not hidden)
- Threats to validity section included for non-trivial empirical claims

## Common ML-Specific Failure Modes

- Data leakage (train/test contamination, normalization across full dataset, target leakage)
- Benchmark overfitting (tuning against test set)
- Incomparable baselines (different data, compute, or hyperparameter budgets)


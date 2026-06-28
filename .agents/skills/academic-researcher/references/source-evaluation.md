# Source Evaluation and Verification

The skill's output is only as trustworthy as the sources behind it. Use this guide to decide what to include, how to label it, and what to exclude.

## Peer-Reviewed vs Preprint (Label Precisely)

- **Peer-reviewed**: Journal articles and conference proceedings with established review processes.
- **Preprint**: arXiv/SSRN/bioRxiv and similar. These are valuable for recency but **must not** be described as peer-reviewed unless later published.

Recommended practice: track a `status` field per source (peer-reviewed, preprint, standard, dataset/software, policy/position paper).

## Venue and Publisher Sanity Checks

Signals that a venue is likely legitimate:

- Clear editorial board and review policy
- Indexed in field-standard databases (varies by domain)
- Stable publisher page with DOI and metadata

Red flags:

- Unclear or nonexistent peer review description
- Aggressive solicitations and unrealistically fast acceptance promises
- Broken/incomplete metadata and missing editorial information

## Author/Institution Checks (Lightweight)

- Confirm author identities and affiliations from the paper PDF or publisher page.
- Check if the work is a survey/benchmark (often higher leverage for overviews).

## Reproducibility Signals (Prefer These)

- Public code repository with tagged release/commit
- Public dataset and clear preprocessing details
- Explicit experimental setup: seeds, splits, hyperparameters, compute
- Clear limitations and threats to validity

## Practical Verification Steps (Per Source)

1. Locate the canonical record (publisher page or DOI resolver).
2. Confirm: title, authors, year, venue, pages, DOI.
3. Check whether the PDF matches the canonical record (avoid "wrong version" citations).
4. Classify the source: foundational, recent SOTA, survey, benchmark, negative result, position paper.


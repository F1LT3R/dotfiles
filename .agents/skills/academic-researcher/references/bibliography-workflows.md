# Bibliography Workflows (BibTeX/BibLaTeX)

This skill assumes you will keep a single source of truth bibliography file (typically `references.bib`) and cite it from LaTeX. The goal is: reproducible citations, no invented references, and easy verification.

## Recommended Defaults

- IEEE papers (CS/Engineering): **BibTeX** + `IEEEtran.bst`
  - In LaTeX: `\bibliographystyle{IEEEtran}` and `\bibliography{references}`
- APA manuscripts: **BibLaTeX** (`style=apa`) + **biber**
  - In LaTeX: `\usepackage[style=apa,backend=biber,natbib=true]{biblatex}` + `\addbibresource{references.bib}`

## Citation Key Convention (Stable and Searchable)

Pick one convention and keep it consistent:

- `firstauthorYYYYkeyword` (recommended): `smith2023transformers`
- `firstauthorYYYY` if you only cite a few works: `smith2023`

Avoid keys that change when metadata changes (e.g., auto-generated hashes).

## "DOI-First" Policy

For peer-reviewed work, prefer to store a DOI whenever one exists:

- Use the DOI in the `.bib` entry (`doi = {...}`).
- Only add `url = {...}` when a DOI is missing or the URL is the canonical access point (standards, datasets, software, policy docs).

## Minimal `.bib` Entry Rules

- Protect proper nouns and acronyms in titles: `title = {A Study of {NLP} and {BERT}}`
- Prefer full venue names in BibTeX fields; IEEE will abbreviate via style if needed.
- Always include year; include pages when available; include publisher/booktitle for proceedings.

## IEEE (BibTeX) LaTeX Snippet

```latex
% In the preamble:
\usepackage{cite}

% Near the end of the document:
\bibliographystyle{IEEEtran}
\bibliography{references}
```

## APA (BibLaTeX + biber) LaTeX Snippet

```latex
% In the preamble:
\usepackage[style=apa,backend=biber,natbib=true,sortcites=true]{biblatex}
\addbibresource{references.bib}

% Where you want the references list:
\printbibliography
```

## Verification Checklist (Before Submitting)

- Every `\cite{...}` key exists in `references.bib`
- `references.bib` contains: correct author list, year, title, venue, pages
- DOI resolves to the same work you intend to cite
- No "placeholder" entries remain
- Preprints are clearly labeled (e.g., arXiv entries are not described as peer-reviewed)

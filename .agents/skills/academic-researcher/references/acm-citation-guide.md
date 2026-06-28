# ACM Citation Guide

BibTeX entry reference for ACM publications. The rendered reference list is generated automatically by `acmart`'s bibliography style — focus on writing correct BibTeX entries.

## Overview

ACM uses an **author-year** citation style (similar to APA but with ACM-specific formatting). The `acmart` document class handles formatting automatically.

### Key Differences from IEEE

| Feature | IEEE | ACM |
|---------|------|-----|
| In-text style | Numbered `[1]` | Author-year `(Smith, 2023)` |
| Reference list | Numbered, ordered by appearance | Alphabetical by author |
| Document class | `IEEEtran` | `acmart` |
| Bibliography tool | BibTeX | BibTeX or BibLaTeX |

## LaTeX Setup

```latex
\documentclass[sigconf]{acmart}  % or sigplan, sigchi, etc.

% ACM-specific metadata
\acmConference[CONF'24]{Full Conference Name}{Month Year}{City, Country}
\acmBooktitle{Proceedings of CONF'24}
\acmDOI{10.1145/XXXXXXX.XXXXXXX}
\acmISBN{978-1-4503-XXXX-X/XX/XX}
```

### Common `acmart` Format Options

| Option | Use Case |
|--------|----------|
| `sigconf` | Conference proceedings (most common) |
| `sigplan` | SIGPLAN conferences (PLDI, POPL, etc.) |
| `sigchi` | SIGCHI conferences (CHI, UIST, etc.) |
| `acmlarge` | Large-format journals (JACM, TOCS, etc.) |
| `acmsmall` | Small-format journals (TOPLAS, TOSEM, etc.) |

## In-Text Citations

```latex
% Parenthetical
Recent work shows this is effective~\cite{smith2023}.

% Multiple citations
Several studies support this~\cite{smith2023,jones2022}.

% Narrative (with natbib enabled)
\citet{smith2023} demonstrated that...
```

## BibTeX Entry Types

### Journal Article
```bibtex
@article{smith2023,
  author    = {Smith, Alice and Doe, John},
  title     = {Attention Mechanisms for Visual Feature Extraction},
  journal   = {ACM Transactions on Computing Systems},
  year      = {2023},
  volume    = {41},
  number    = {3},
  pages     = {1--25},
  doi       = {10.1145/1234567.1234568},
  publisher = {Association for Computing Machinery},
  address   = {New York, NY, USA}
}
```

### Conference Paper (inproceedings)
```bibtex
@inproceedings{jones2022,
  author    = {Jones, Bob and Smith, Alice},
  title     = {Multi-Modal Learning with Cross-Attention Networks},
  booktitle = {Proceedings of the 2022 ACM Conference on Example},
  year      = {2022},
  pages     = {45--52},
  doi       = {10.1145/9876543.9876544},
  publisher = {Association for Computing Machinery},
  address   = {New York, NY, USA},
  location  = {City, Country}
}
```

### Book
```bibtex
@book{knuth1997,
  author    = {Knuth, Donald E.},
  title     = {The Art of Computer Programming, Volume 1},
  year      = {1997},
  edition   = {3rd},
  publisher = {Addison-Wesley},
  address   = {Reading, MA}
}
```

### Technical Report
```bibtex
@techreport{tr2023,
  author      = {Author, First},
  title       = {Technical Report Title},
  institution = {University of Example},
  year        = {2023},
  number      = {TR-2023-001}
}
```

## Policy

- **DOI-first**: always include DOI — ACM requires them in all entries
- **Citation keys**: use `firstauthorYYYY` or `firstauthorYYYYkeyword`
- **Preprints**: use `@misc` with `note = {Preprint}` and arXiv eprint fields
- **Validate entries**: run `node scripts/validate-bib.js references.bib` to check DOIs against CrossRef

## Tips

1. **Use the official `acmart` class** — it handles formatting, copyright blocks, and CCS concepts automatically.
2. **Include DOIs** in all BibTeX entries where available — ACM requires them.
3. **Add CCS concepts** using the ACM Computing Classification System tool at https://dl.acm.org/ccs.
4. **Check the ACM submission template** for your specific venue — requirements vary between conferences.
5. **Use `\citep` and `\citet`** when `natbib=true` is set for parenthetical and textual citations.

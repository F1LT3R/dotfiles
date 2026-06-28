# APA Citation Guide (7th Edition)

BibTeX entry reference for APA-style papers. The rendered reference list is generated automatically by `biblatex-apa` — focus on writing correct BibTeX entries and using the right in-text citation commands.

## BibTeX Entry Examples

### Journal Article (`@article`)
```bibtex
@article{bandura1977self,
  author  = {Bandura, Albert},
  title   = {Self-Efficacy: Toward a Unifying Theory of Behavioral Change},
  journal = {Psychological Review},
  year    = {1977},
  volume  = {84},
  number  = {2},
  pages   = {191--215},
  doi     = {10.1037/0033-295X.84.2.191}
}
```

### Conference Paper (`@inproceedings`)
```bibtex
@inproceedings{devlin2019bert,
  author    = {Devlin, Jacob and Chang, Ming-Wei and Lee, Kenton and Toutanova, Kristina},
  title     = {{BERT}: Pre-Training of Deep Bidirectional Transformers for Language Understanding},
  booktitle = {Proceedings of the 2019 Conference of the North {A}merican Chapter of the Association for Computational Linguistics},
  year      = {2019},
  pages     = {4171--4186},
  doi       = {10.18653/v1/N19-1423}
}
```

### Book (`@book`)
```bibtex
@book{creswell2018research,
  author    = {Creswell, John W. and Creswell, J. David},
  title     = {Research Design: Qualitative, Quantitative, and Mixed Methods Approaches},
  edition   = {5th},
  publisher = {SAGE Publications},
  year      = {2018}
}
```

### Technical Report (`@techreport`)
```bibtex
@techreport{who2023report,
  author      = {{World Health Organization}},
  title       = {Global Status Report on Road Safety 2023},
  institution = {World Health Organization},
  year        = {2023},
  address     = {Geneva, Switzerland}
}
```

### Thesis (`@phdthesis` / `@mastersthesis`)
```bibtex
@phdthesis{johnson2020phd,
  author = {Johnson, Maria},
  title  = {Exploring User Engagement in Mobile Health Applications},
  school = {Stanford University},
  year   = {2020}
}
```

### Online / Preprint (`@misc`)
```bibtex
@misc{radford2021clip,
  author       = {Radford, Alec and Kim, Jong Wook and Hallacy, Chris and others},
  title        = {Learning Transferable Visual Models From Natural Language Supervision},
  year         = {2021},
  eprint       = {2103.00020},
  archiveprefix= {arXiv},
  primaryclass = {cs.CV},
  note         = {Preprint}
}
```

## BibLaTeX Configuration

```latex
\usepackage[style=apa,backend=biber]{biblatex}
\addbibresource{references.bib}
\DeclareLanguageMapping{english}{english-apa}

% At end of document:
\printbibliography
```

Compile with: `pdflatex → biber → pdflatex → pdflatex`

## In-Text Citations

```latex
% Parenthetical (author-date in parentheses)
Recent work shows this is effective \parencite{bandura1977self}.
Multiple studies support this \parencite{bandura1977self,devlin2019bert}.

% Narrative (author in running text)
\textcite{bandura1977self} argued that self-efficacy is...

% Direct quote — include page number
"The results indicate..." \parencite[p.~45]{bandura1977self}.
```

## Key Differences from IEEE

| Aspect | APA | IEEE |
|--------|-----|------|
| Order | Alphabetical by author | Numbered by appearance |
| Format | Author-Date | [Number] |
| Et al. | 3+ authors in in-text (from first citation) | 6+ authors |
| DOI | Required when available | Preferred |
| Italics | Journal name italicized | Journal name abbreviated |

## APA 7th Edition Notes

1. **DOI format**: use `https://doi.org/` prefix
2. **Retrieved from**: only use when retrieval date matters (unstable sources)
3. **21+ authors**: list first 19, ellipsis, then final author
4. **Software/Apps**: include in references like books

## Policy

- **DOI-first**: always include DOI — `biblatex-apa` formats it automatically
- **Citation keys**: use `firstauthorYYYY` or `firstauthorYYYYkeyword`
- **Preprints**: use `@misc` with `note = {Preprint}` — clearly distinguish from peer-reviewed
- **Validate entries**: run `node scripts/validate-bib.js references.bib` to check DOIs against CrossRef

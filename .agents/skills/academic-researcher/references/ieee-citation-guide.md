# IEEE Citation Guide

BibTeX entry reference for IEEE-style papers. The rendered reference list is generated automatically by `IEEEtran.bst` — focus on writing correct BibTeX entries.

## BibTeX Entry Examples

### Journal Article (`@article`)
```bibtex
@article{vaswani2017attention,
  author  = {Vaswani, Ashish and Shazeer, Noam and Parmar, Niki and Uszkoreit, Jakob and Jones, Llion and Gomez, Aidan N. and Kaiser, {\L}ukasz and Polosukhin, Illia},
  title   = {Attention Is All You Need},
  journal = {Advances in Neural Information Processing Systems},
  year    = {2017},
  volume  = {30},
  pages   = {5998--6008},
  doi     = {10.48550/arXiv.1706.03762}
}
```

### Conference Paper (`@inproceedings`)
```bibtex
@inproceedings{he2016deep,
  author    = {He, Kaiming and Zhang, Xiangyu and Ren, Shaoqing and Sun, Jian},
  title     = {Deep Residual Learning for Image Recognition},
  booktitle = {Proc. IEEE Conf. Comput. Vis. Pattern Recognit. (CVPR)},
  year      = {2016},
  pages     = {770--778},
  doi       = {10.1109/CVPR.2016.90}
}
```

### Book (`@book`)
```bibtex
@book{goodfellow2016deep,
  author    = {Goodfellow, Ian and Bengio, Yoshua and Courville, Aaron},
  title     = {Deep Learning},
  publisher = {MIT Press},
  year      = {2016},
  address   = {Cambridge, MA}
}
```

### Technical Report (`@techreport`)
```bibtex
@techreport{openai2023gpt4,
  author      = {{OpenAI}},
  title       = {{GPT-4} Technical Report},
  institution = {OpenAI},
  year        = {2023},
  number      = {arXiv:2303.08774}
}
```

### Thesis (`@phdthesis` / `@mastersthesis`)
```bibtex
@phdthesis{mikolov2012phd,
  author = {Mikolov, Tom{\'a}{\v{s}}},
  title  = {Statistical Language Models Based on Neural Networks},
  school = {Brno University of Technology},
  year   = {2012}
}
```

### Preprint / Online (`@misc`)
```bibtex
@misc{brown2020gpt3,
  author       = {Brown, Tom and Mann, Benjamin and Ryder, Nick and others},
  title        = {Language Models are Few-Shot Learners},
  year         = {2020},
  eprint       = {2005.14165},
  archiveprefix= {arXiv},
  primaryclass = {cs.CL},
  note         = {Preprint}
}
```

## IEEE Journal Abbreviations

| Abbreviation | Full Name |
|---|---|
| IEEE Trans. Pattern Anal. Mach. Intell. | IEEE Transactions on Pattern Analysis and Machine Intelligence |
| IEEE Trans. Neural Netw. Learn. Syst. | IEEE Transactions on Neural Networks and Learning Systems |
| IEEE Trans. Knowl. Data Eng. | IEEE Transactions on Knowledge and Data Engineering |
| IEEE Trans. Inf. Theory | IEEE Transactions on Information Theory |
| IEEE Trans. Commun. | IEEE Transactions on Communications |
| IEEE Commun. Mag. | IEEE Communications Magazine |
| IEEE Access | IEEE Access |
| Proc. IEEE | Proceedings of the IEEE |

## Key Rules

1. Number references consecutively in order of appearance
2. Use square brackets `[1]`, `[2]`, `[3]`
3. List all authors if ≤6; use "et al." if >6
4. Use initials for first/middle names
5. Abbreviate journal names per IEEE standards (use `booktitle` abbreviation in `@inproceedings`)
6. Include DOI when available
7. Maintain consistent formatting throughout

## Policy

- **DOI-first**: always include DOI when available — `IEEEtran.bst` formats it automatically
- **Citation keys**: use `firstauthorYYYY` or `firstauthorYYYYkeyword` (e.g., `he2016deep`)
- **Preprints**: use `@misc` with `note = {Preprint}` and the arXiv eprint fields; clearly distinguish from peer-reviewed work
- **Validate entries**: run `node scripts/validate-bib.js references.bib` to check DOIs against CrossRef

# Official Publisher LaTeX Templates

For final submission, always use the publisher's official template — they update regularly and reviewers expect the exact format.

## IEEE

- **Conference/Journal**: https://template-selector.ieee.org/
- Document class: `IEEEtran` (CTAN: https://ctan.org/pkg/ieeetran)
- Overleaf: search "IEEE" in Overleaf's template gallery

## ACM

- **All formats**: https://www.acm.org/publications/proceedings-template
- Document class: `acmart` (CTAN: https://ctan.org/pkg/acmart)
- Includes `sigconf`, `sigplan`, `sigchi`, `acmlarge`, `acmsmall` options

## Springer (LNCS)

- **Lecture Notes in Computer Science**: https://www.springer.com/gp/computer-science/lncs/conference-proceedings-guidelines
- Document class: `llncs` (provided in download zip)

## Elsevier

- **Journals**: https://www.elsevier.com/researcher/author/policies-and-guidelines/latex-instructions
- Document class: `elsarticle` (CTAN: https://ctan.org/pkg/elsarticle)

## APA (7th Edition)

- **Official**: https://apastyle.apa.org/style-grammar-guidelines/paper-format
- LaTeX: use `apa7` class (CTAN: https://ctan.org/pkg/apa7) with `biblatex-apa`

## When to Use Official vs Embedded Templates

| Scenario | Use |
|----------|-----|
| Submitting to a venue | Official publisher template |
| Learning paper structure | Embedded templates in `references/templates/` |
| Drafting before venue is chosen | Embedded templates |
| Venue requires specific class file | Official publisher template |

The templates in this skill (`references/templates/`) are scaffolds that demonstrate structure and citation integration. For actual submission, download the official template and apply the writing guidance from this skill.

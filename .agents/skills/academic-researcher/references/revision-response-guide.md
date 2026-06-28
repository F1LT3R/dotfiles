# Revision Response Guide

How to write effective responses to peer reviewer feedback.

## Response Letter Structure

Use a point-by-point format that addresses every reviewer comment:

```
Dear Editor and Reviewers,

We thank the reviewers for their careful reading and constructive
feedback. We have revised the manuscript to address all comments.
Below we provide point-by-point responses.

Changes in the revised manuscript are highlighted in blue.

---

## Reviewer 1

### Comment 1.1
[Paste the reviewer's comment verbatim]

**Response:** We thank the reviewer for this observation. We have
revised Section X (lines Y-Z) to clarify... [explain what you did
and why]

### Comment 1.2
[Paste the reviewer's comment verbatim]

**Response:** ...

---

## Reviewer 2

### Comment 2.1
...
```

## Tone Guidelines

- **Respectful and professional** — never dismissive or defensive
- **Factual** — support responses with evidence, data, or references
- **Grateful** — acknowledge the effort reviewers invest
- **Constructive** — even when disagreeing, frame it positively

## Handling Different Comment Types

### Agreement (implement the change)
> "We agree with the reviewer. We have revised [section/figure/table]
> to address this point. Specifically, we now [describe change]."

### Partial Agreement (implement part, explain the rest)
> "We appreciate this suggestion. We have adopted [part X] and revised
> Section Y accordingly. Regarding [part Z], we respectfully note that
> [justification with evidence or citation]."

### Disagreement (with justification)
> "We thank the reviewer for raising this point. After careful
> consideration, we believe the current approach is appropriate
> because [reason]. [Supporting evidence or citation]. We have added
> a clarification in Section X to make this rationale explicit."

## Marking Changes in the Revised Manuscript

- **Color highlighting:** Use `\textcolor{blue}{revised text}` in LaTeX
- **Change tracking:** Use `latexdiff old.tex new.tex > diff.tex`
- **Margin notes:** Use `\marginpar{R1.3}` to tag which comment a change addresses
- **Summary table:** Include a table mapping each comment to the corresponding change location

### LaTeX Setup for Highlighting Changes

```latex
\usepackage{xcolor}
\newcommand{\rev}[1]{\textcolor{blue}{#1}}      % Revised text
\newcommand{\revdel}[1]{\textcolor{red}{\sout{#1}}} % Deleted text (requires ulem)
```

## Common Response Patterns

| Situation | Opening |
|-----------|---------|
| Thanking | "We thank the reviewer for this insightful comment." |
| Clarifying | "We apologize for the lack of clarity. We have revised..." |
| Adding content | "We agree this is important. We have added a new subsection..." |
| Additional experiments | "We have conducted the suggested experiment. The results..." |
| Explaining a choice | "We chose this approach because... We have added a justification..." |
| Scope limitation | "While this is an excellent suggestion, it is beyond the scope of this work. We have noted it as future work in Section X." |

## Checklist Before Submitting

- [ ] Every reviewer comment is addressed (none skipped)
- [ ] Response letter is numbered consistently (R1.1, R1.2, R2.1, etc.)
- [ ] All promised changes are actually in the revised manuscript
- [ ] Changed text is highlighted or tracked
- [ ] New references (if any) are added to the bibliography
- [ ] Page/line references in the response match the revised manuscript
- [ ] Tone is professional throughout — re-read for any defensive language

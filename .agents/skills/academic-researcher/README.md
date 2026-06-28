# Academic Researcher Skill

<p align="center">
  <a href="https://www.npmjs.com/package/academic-researcher-skill">
    <img src="https://img.shields.io/npm/v/academic-researcher-skill" alt="npm version">
  </a>
  <a href="https://www.npmjs.com/package/academic-researcher-skill">
    <img src="https://img.shields.io/npm/dt/academic-researcher-skill" alt="npm downloads">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/npm/l/academic-researcher-skill" alt="MIT License">
  </a>
</p>

> Expert-level academic research and LaTeX paper writing skill for AI coding assistants

## Overview

`academic-researcher` is a comprehensive skill for AI coding assistants (OpenCode, Claude Code, Gemini CLI, Codex, Cursor, Windsurf) that enables creation of peer-reviewed research papers, literature reviews, and theses with:

- **Source Discovery**: Web search for peer-reviewed academic sources
- **Source Verification**: Peer-reviewed vs preprint labeling + quality signals
- **Systematic Reviews**: PRISMA-style workflow + extraction matrix templates
- **IEEE/APA Citations**: Citation guides + BibTeX/BibLaTeX workflows
- **LaTeX Output**: Professional mathematical typesetting
- **Quality Assurance**: Claim-evidence mapping, reproducibility, threats-to-validity, stats checks
- **Multi-Platform**: Works with 6+ AI coding assistants

## Installation

### Option 1: npm (Recommended)

```bash
# Global installation
npm install -g academic-researcher-skill

# Project-level installation (opt-in; writes into .claude/.codex/... in the repo)
SKILL_INSTALL_SCOPE=project npm install --save-dev academic-researcher-skill
```

Local installs default to a no-op to avoid surprising writes; you can also run `node install-skill.js --project`.

### Option 2: npx skills add (Per Platform)

This skill supports installation via the `npx skills add` command across multiple AI coding platforms:

#### OpenCode
```bash
npx skills add https://github.com/SiluPanda/academic-researcher --skill academic-researcher
```
OpenCode auto-discovers skills from `.opencode/skills/` directory.

#### Claude Code
```bash
npx skills add https://github.com/SiluPanda/academic-researcher --skill academic-researcher
```
Claude Code discovers skills from `.claude/skills/` directory.

#### Gemini CLI
```bash
npx skills add https://github.com/SiluPanda/academic-researcher --skill academic-researcher
```
Gemini CLI supports skills from `.gemini/skills/` directory.

#### Codex
```bash
npx skills add https://github.com/SiluPanda/academic-researcher --skill academic-researcher
```
Codex uses `.codex/skills/` for skill discovery.

#### Cursor
```bash
npx skills add https://github.com/SiluPanda/academic-researcher --skill academic-researcher
```
Cursor discovers skills from `.cursor/skills/` directory.

#### Windsurf
```bash
npx skills add https://github.com/SiluPanda/academic-researcher --skill academic-researcher
```
Windsurf uses `.windsurf/skills/` for skill discovery.

### Option 3: Manual Installation

```bash
# Clone the repository
git clone https://github.com/SiluPanda/academic-researcher.git
cd academic-researcher

# Install globally
npm install -g
```

## Supported Platforms

| Platform | Status | Installation Path | Installation Command |
|----------|--------|-------------------|---------------------|
| OpenCode | ✓ Full | `~/.config/opencode/skills/` | `npx skills add ...` |
| Claude Code | ✓ Full | `~/.claude/skills/` | `npx skills add ...` |
| Gemini CLI | ✓ Full | `~/.gemini/skills/` | `npx skills add ...` |
| Codex | ✓ Full | `~/.codex/skills/` | `npx skills add ...` |
| Cursor | ✓ Full | `~/.cursor/skills/` | `npx skills add ...` |
| Windsurf | ✓ Full | `~/.windsurf/skills/` | `npx skills add ...` |

All platforms use the same skill format and support:
- Global installation (user-wide)
- Project-level installation

## Usage

Once installed, activate the skill in your AI assistant:

```
Use the academic-researcher skill
```

Then provide your research details using this template:

```markdown
## Research Document Request

**Type:** Research Paper / Literature Review / Thesis
**Topic:** [Your research topic]
**Target:** [Conference/Journal name or "General"]
**Length:** [X pages or X words]
**Citation:** [IEEE / APA]
**Deadline:** [Date if applicable]
**Special Requirements:** [Any specific guidelines]
```

The skill will:
1. Ask clarifying questions about your research
2. Research sources using web search
3. Generate a document outline
4. Write LaTeX source code
5. Provide quality assurance checklist

## Features

### Source Discovery
- Academic database search (Google Scholar, IEEE Xplore, arXiv, PubMed)
- Peer-reviewed source verification
- Predatory journal detection

### Citation Formats
- **IEEE** (primary) - Computer Science, Engineering
- **APA** (secondary) - Social Sciences, Humanities

See `references/ieee-citation-guide.md` and `references/apa-citation-guide.md` for complete reference examples.

### LaTeX Output
- Full mathematical typesetting support
- IEEE conference/journal templates
- Thesis/dissertation templates

See `references/latex-math-guide.md` for math typesetting examples.

### Document Types
- Research papers (conference/journal)
- Literature reviews and surveys
- Theses and dissertations
- Research proposals
- Technical reports

### Quality Assurance
- Pre-submission checklist
- Claim-evidence mapping
- Bibliography and citation-key verification
- Reproducibility + threats-to-validity checklists

## File Structure

```
academic-researcher-skill/
├── SKILL.md                    # Main skill definition
├── index.js                    # Package entrypoint (exports canonical paths)
├── package.json                # npm package configuration
├── .claude-skill.json         # Installation configuration
├── install-skill.js           # Installation script
├── uninstall-skill.js         # Uninstallation script
├── scripts/
│   ├── sync-platform-skills.js
│   └── check-citations.js
├── LICENSE                    # MIT License
├── references/
│   ├── bibliography-workflows.md
│   ├── source-evaluation.md
│   ├── systematic-review-prisma.md
│   ├── literature-review-extraction-matrix.md
│   ├── claim-evidence-map.md
│   ├── reproducibility-checklist.md
│   ├── statistical-reporting.md
│   ├── threats-to-validity.md
│   ├── ieee-citation-guide.md
│   ├── apa-citation-guide.md
│   ├── latex-math-guide.md
│   └── templates/
│       ├── ieee-conference.tex
│       ├── apa7-manuscript.tex
│       ├── literature-review.tex
│       ├── systematic-review.tex
│       ├── thesis.tex
│       └── references.bib
└── examples/
    ├── sample-outline.md
    ├── vocabulary-template.md
    ├── systematic-review-protocol-template.md
    ├── extraction-matrix-template.csv
    └── claim-evidence-map-template.md
```

## Output Formats

### Primary: LaTeX (.tex)

The skill generates LaTeX source files that you can compile to PDF:

```bash
# IEEE-style (BibTeX)
pdflatex paper.tex
bibtex paper
pdflatex paper.tex
pdflatex paper.tex

# APA-style (BibLaTeX + biber)
pdflatex paper.tex
biber paper
pdflatex paper.tex
pdflatex paper.tex

# Or use Overleaf (recommended)
# Upload .tex file to overleaf.com
```

### Alternative: Markdown

For quick review or conversion:

```bash
pandoc paper.tex -o paper.md
pandoc paper.tex -o paper.docx
```

## Examples

### Research Paper

```
User: Write a research paper about transformer models for time series forecasting

Skill: [Asks about target venue, length, citation format, then proceeds]
```

### Literature Review

```
User: Create a literature review on federated learning in healthcare

Skill: [Researches sources, structures thematically, writes LaTeX]
```

### Thesis Chapter

```
User: Write the methodology chapter for my PhD thesis on explainable AI

Skill: [Creates structured chapter with proper academic tone]
```

## Development

### Testing Locally

```bash
# Install dependencies
npm install

# Test project installation script
node install-skill.js --project
ls -la .claude/skills/academic-researcher/

# Test global installation script (optional)
node install-skill.js --global
ls -la ~/.claude/skills/academic-researcher/
```

### Publishing to npm

```bash
# Login to npm
npm login

# Publish
npm publish --access public

# Or with a scope
npm publish --access public --scope @your-org
```

## Requirements

- Node.js >= 14.0.0
- AI coding assistant (OpenCode, Claude Code, etc.)
- LaTeX distribution (optional, for PDF generation)
  - [Overleaf](https://overleaf.com) (recommended)
  - [TinyTeX](https://yihui.org/tinytex/)
  - [MacTeX](https://tug.org/mactex/)

## Contributing

Contributions are welcome! Please:

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Built for the AI agent community. Inspired by:
- [academic-research-writer](https://github.com/endigo/claude-skills)
- [research-paper-writer](https://github.com/ailabs-393/ai-labs-claude-skills)
- [research](https://github.com/jwynia/agent-skills)

---

<p align="center">
  Made with ❤️ for academic researchers
</p>

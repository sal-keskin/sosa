# CLAUDE.md

This repository uses **`AGENTS.md`** as its agent guide. Read that file.

Quick orientation:

- **Typesetting an article** from a manuscript → follow `AGENTS.md`. You edit
  `frontmatter.tex`, `body.tex`, `references.tex`, and the artwork list in
  `main.tex`. You do not edit `sosa.cls`.
- **Changing the layout itself** → read `HANDOFF.md` first. It carries the
  measurements taken off the published PDFs, the architecture of `sosa.cls`
  section by section, what a real compile has and has not verified, and the
  traps that have already caused one regression.
- **Using the template as an author** → `README.md`.

There is no test suite. `HANDOFF.md` §10 has the static checks that stand in
for one when no TeX installation is available, and the log-reading recipes for
when a compile happens elsewhere.

---
mode: agent
description: Turn a SoSa manuscript (docx/pdf/text) into a compiling LaTeX article
---

You are preparing a new article for *Sosyal Bilimler ve Sağlık Bülteni* (SoSa)
using the LaTeX class in this repository.

**Read `AGENTS.md` first — it is the full procedure.** This file only summarises
it so you know what you are being asked for.

Given the manuscript the user supplies:

1. Extract the front-matter fields (titles, authors + affiliation numbers +
   ORCIDs, affiliations, Öz, Abstract, keywords, dates, corresponding author,
   handling editor, issue year / season / number / page range).
2. Fill in `frontmatter.tex` — one `\SosaAuthor` and one `\SosaAffiliation`
   line each, in order. Do not type commas, superscripts, ORCID marks or
   affiliation numbers; the class inserts them.
3. Put the article text in `body.tex` with unnumbered `\section{}` headings,
   `sosatabular` tables and `figure` blocks.
4. Put the reference list in `references.tex`, APA 7, one entry per paragraph
   separated by blank lines.
5. Compile twice (`latexmk -pdf main.tex`) and check the log for errors and
   overfull hboxes.

Hard rules:

- Do not edit `sosa.cls`. If something will not fit, say so and propose
  `sosawide` or a smaller table font rather than changing the layout.
- Escape `%` as `\%` in every Turkish percentage — this is the most common
  breakage when pasting from Word, and it fails silently.
- Type Turkish characters directly (ğ İ ı ş ç ö ü â), never as accent macros.
- Use `\SosaPages{first}{last}`, never `\setcounter{page}`.
- Do not add `\usepackage` for anything the class already loads.

Report back: which files you changed, whether it compiled clean, the page
count, and anything in the manuscript you could not express.

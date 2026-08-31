# AGENTS.md — preparing a new SoSa article

Instructions for an AI coding assistant (Claude Code, Copilot, Cursor, Codex,
Gemini CLI …) working in this repository. A human has a manuscript and wants it
turned into a compiling SoSa article. Follow this.

If you are being asked to change the *layout* rather than typeset an article,
stop reading here and open **`HANDOFF.md`** instead — it has the measurements,
the architecture and the reasons behind every design decision.

If you are being asked for the **artwork** — the cover banner and the side
strips — open **`ARTWORK.md`**: exact sizes, the style interview to run before
generating anything, and the prompt templates.

`PROMPT.md` is a different thing: a prompt an editor pastes into a plain chat
window with their manuscript. That assistant cannot compile, and reaches this
repository only by fetching raw URLs — including this file, which it treats as
authoritative. You are not that assistant: you have the files locally, so use
this document directly. If you change the author-facing API, update `PROMPT.md`
as well; it carries a condensed copy for assistants that cannot browse.

---

## What this repository is

A LaTeX class, `sosa.cls`, that reproduces the printed page design of *Sosyal
Bilimler ve Sağlık Bülteni* (SoSa) — a Turkish health / social science journal.
Its distinctive feature is a full-bleed illustration strip down the right edge
of alternating pages.

**You do not need to understand the class to typeset an article.** The class is
finished. Your job is to fill in four files.

---

## The four files

| File | What goes in it |
|---|---|
| `frontmatter.tex` | Everything on page one: journal/issue data, titles, authors, affiliations, both abstracts, the colophon |
| `body.tex` | The article text — sections, tables, figures, quotations |
| `references.tex` | The reference list, APA 7 |
| `main.tex` | Only the ornament artwork list. Leave the rest alone. |

`sosa.cls` is **not yours to edit** when typesetting an article. If something
cannot be expressed with the existing commands, say so rather than patching the
class — a layout change affects every article the journal publishes.

---

## Procedure

### 1. Read the manuscript

It will usually be a `.docx` or a `.pdf`. Extract the text, and extract these
fields specifically, because they map one-to-one onto `frontmatter.tex`:

- Turkish title, English title
- every author, in order, with their affiliation number(s) and ORCID
- every affiliation, in the order the superscripts refer to
- Öz (with its bold sub-headings: Giriş, Gereç-Yöntem, Bulgular, Sonuç-Öneriler)
- Abstract (Introduction, Materials and Methods, Results, Conclusion …)
- both keyword lists
- received / accepted / published dates
- corresponding author and email, handling editor
- the issue: year, season label, issue number, first and last page

For `.docx`, unzip it and read `word/document.xml`, or use `python-docx`.
For `.pdf`, `pymupdf` gives you text with positions:

```python
import pymupdf
d = pymupdf.open('manuscript.pdf')
print(d[0].get_text())
```

### 2. Fill in `frontmatter.tex`

The file is a form with eight numbered blocks and comments in Turkish and
English. Replace what is inside the braces. Key points:

```latex
\SosaJournal{Sosyal Bilimler ve Sağlık Bülteni}
\SosaJournalShort{SoSa}
\SosaYear{2026}
\SosaIssue{Bahar}{18}      % season label, issue number
\SosaPages{60}{70}         % first and last printed page
```

`\SosaPages` also anchors the ornament alternation — **never** replace it with
`\setcounter{page}`.

One line per author and per affiliation, in order:

```latex
\SosaAuthor{Murat Aysin}{1}{0000-0001-0000-0001}
\SosaAuthor{Sultan Eser}{2}{}          % ORCID may be empty
\SosaAuthor{Ali Ceylan}{1,4}{0000-…}   % more than one affiliation

\SosaAffiliation{Dr. Öğr. Üyesi, Balıkesir Üniversitesi, …}
\SosaAffiliation{Prof. Dr., Sağlık Bilimleri Üniversitesi, …}
```

Do **not** type the commas between authors, the superscript numbers, or the
ORCID marks — the class inserts all three. Do not number the affiliations
either.

The masthead, both running-head forms and the suggested citation are derived
from the issue data plus `\SosaCitationAuthors{…}`. Only set `\SosaMasthead`,
`\SosaRunningHead`, `\SosaRunningHeadJournal` or `\SosaCitation` if a derived
version is wrong.

Body pages alternate between the article title and the journal line;
`\SosaRunningHeadMode{title}` puts the title on every body page instead, which
is what the printed sample issues do.

### 3. Fill in `body.tex`

Plain text with `\section{…}` headings. Section headings are unnumbered — do not
add "1.", "2." yourself. Typical Turkish article structure: Giriş,
Gereç-Yöntem, Bulgular, Tartışma, Sonuç ve Öneriler.

**Tables.** Three rules only, no vertical lines. Caption above, bold:

```latex
\begin{table}[!ht]
\caption{Katılımcıların Sosyodemografik Özellikleri}
\label{tab:demog}
\begin{sosatabular}{@{}L{170pt}L{90pt}R{140pt}@{}}
\textbf{Değişkenler} & & \textbf{Sayı (\%)} \\
\midrule
Yaş & 50 yaş altı     & 386 (\%54,0) \\
    & 50 yaş ve üzeri & 329 (\%46,0) \\
\end{sosatabular}
\end{table}
```

`sosatabular` supplies `\toprule` and `\bottomrule`; you add `\midrule` under
the head row. `L{}`, `C{}`, `R{}` are ragged-right / centred / ragged-left
paragraph columns — always give an explicit width in pt.

**The measure is ~409pt.** Column widths must sum to less than that. If a table
genuinely needs more, wrap it in `sosawide`, which reclaims the ornament band
and drops that page's strip:

```latex
\begin{table}[!ht]
\begin{sosawide}
  \caption{…}
  \centering
  \begin{sosatabular}[\sosatablesmall]{@{}L{150pt}L{130pt}R{110pt}@{}}
  …
  \end{sosatabular}
\end{sosawide}
\end{table}
```

`\sosatablesmall` is 9pt, for dense tables; the default is 10pt.

**Figures.** Caption below, centred, no bold:

```latex
\begin{figure}[!ht]
  \centering
  \includegraphics[width=0.62\textwidth]{figures/gorsel-1}
  \caption{Ev içi emekle ilgili yorumların ait olduğu fotoğraflardan örnekler}
\end{figure}
```

Put image files in `figures/`. Never use `width=\textwidth` with a figure that
also needs `sosawide` — pick one.

**Quotations.** Interview excerpts and long quotes use `quote`:

```latex
\begin{quote}
Mesela bir ev temizliyorsunuz\ldots (K14)
\end{quote}
```

### 4. Fill in `references.tex`

APA 7, one entry per paragraph, **separated by blank lines**. The hanging
indent is automatic. Do not sort — keep the manuscript's order (usually
alphabetical already).

```latex
Alum, E. U., \& Ugwu, O. P.-C. (2025). Artificial intelligence in disease
diagnosis and treatment. \textit{Discover Applied Sciences, 7}(3), 193.
\url{https://doi.org/10.1007/s42452-025-06616-y}
```

### 5. Artwork in `main.tex`

`assets/ornaments/` holds ten strips from past issues. Either keep them or, if
the human supplied artwork for this issue, add the new files and list them:

```latex
\SosaOrnamentCycle{assets/ornaments/new-01,assets/ornaments/new-02}
\SosaHero{assets/hero/new-banner}
```

Any tall narrow image works for a strip — it is cropped to fill, so aspect
ratio does not matter. The hero banner is a wide image, roughly 5.5 : 1.

To commission new artwork rather than reuse the old, follow **`ARTWORK.md`**.
Exact sizes are 2480 × 450 px for the banner and 350 × 3331 px per strip at
300 dpi; `python3 tools/crop-artwork.py` crops whatever a generator gives you
down to them.

If the banner is light or busy and the white title becomes hard to read, adjust
the wash rather than the artwork:

```latex
\SosaHeroScrim{0.45}          % 0 = off, 1 = opaque; default 0.35
\SosaHeroScrimColor{black}
\SosaTitleColor{white}        % or sosaink, for a pale banner with no scrim
```

### 6. Compile and check

```sh
latexmk -pdf main.tex
```

**Twice.** `sosawide` records which pages must drop their strip in the `.aux`
file, and that is only read back on the second pass.

Then verify, in this order:

- [ ] `grep -n "^!" main.log` — no errors. Fix the **first** one and recompile;
      a single undefined environment produces a hundred cascading
      "Misplaced alignment tab character &" errors that all vanish at once.
- [ ] `grep -n "Overfull \\\\hbox" main.log` — none. An overfull hbox usually
      means a table is wider than the measure.
- [ ] Page 1: title sits inside the banner, authors and affiliations are in the
      right order, both abstracts are present, the colophon is at the foot.
- [ ] Ornament strips alternate and never overlap text.
- [ ] Page numbers start at the issue's first page.

---

## Turkish text — the traps

- Type Turkish characters **directly**: ğ İ ı ş ç ö ü â. Do not use `\"u`,
  `\c{c}` or similar. The file is UTF-8 and the class handles it.
- The masthead and running head apply **no case mapping** by default — they are
  set exactly as typed. Small caps and all-caps both mangle Turkish `i`/`ı` if
  the mapping is not locale-aware, so write the journal name and title in
  ordinary sentence case and let them through unchanged. `\SosaHeadStyle{uppercase}`
  is available and is locale-correct if the editor wants capitals.
- `%` must be escaped as `\%` — `\%54,0`. This is the single most common
  breakage when pasting from Word, and it silently comments out the rest of the
  line rather than erroring.
- `&` → `\&`, `_` → `\_`, `#` → `\#`, `$` → `\$`.
- Decimal separator is a **comma** in Turkish: 40,3 not 40.3. Leave it as the
  manuscript has it.
- `±` → `$\pm$`, `<` → `${<}$`, `≥` → `$\geq$`.
- Word's curly quotes (" " ' ') paste fine. Word's `…` is fine, but `\ldots`
  sets better.
- Do not "fix" the author's Turkish. Transcribe it.

---

## Command reference

Everything a typesetting job needs. Full documentation in `README.md`.

**Issue and page one**

| Command | Purpose |
|---|---|
| `\SosaJournal{}` `\SosaJournalShort{}` | journal name, short name |
| `\SosaYear{}` `\SosaIssue{label}{num}` `\SosaPages{first}{last}` | issue data; `\SosaPages` also sets the start page |
| `\SosaArticleType{}` | Özgün Makale, Derleme, Olgu Sunumu … |
| `\SosaTitleTR{}` `\SosaTitleEN{}` `\SosaShortTitle{}` | titles |
| `\SosaAuthor{name}{affils}{orcid}` | repeat, one per author |
| `\SosaAffiliation{}` | repeat, one per affiliation |
| `\SosaOz{}` `\SosaKeywordsTR{}` | Turkish abstract |
| `\SosaAbstract{}` `\SosaKeywordsEN{}` | English abstract |
| `\SosaReceived{}` `\SosaAccepted{}` `\SosaPublished{}` | dates |
| `\SosaCorrespondingAuthor{}` `\SosaCorrespondingEmail{}` `\SosaHandlingEditor{}` | colophon |
| `\SosaCitationAuthors{}` | author list for the suggested citation |
| `\SosaNote{}` | optional note under the abstracts |

**Body**

| Command | Purpose |
|---|---|
| `\section{}` `\subsection{}` | unnumbered headings |
| `sosatabular` | table body, optional size argument |
| `sosawide` | full-measure block, drops that page's strip |
| `sosareferences` | the reference list |
| `quote` | block quotation |
| `\orcid{}` | ORCID mark, if hand-building an author line |

**Artwork**

| Command | Purpose |
|---|---|
| `\SosaOrnamentCycle{a,b,c}` | strips, used in turn |
| `\SosaHero{file}` | title-page banner |
| `\SosaOrnament{page}{file}` | pin one file to one page |
| `\SosaNoOrnament{p,…}` `\SosaForceOrnament{p,…}` | per-page override |

---

## Do not

- **Do not edit `sosa.cls`** to make one article fit. Report the problem instead.
- **Do not** add `\usepackage` lines for things the class already loads:
  graphicx, xcolor, booktabs, multirow, array, enumitem, caption, geometry,
  hyperref, tikz, microtype, babel, ragged2e, eso-pic, trimclip.
- **Do not** use `\setcounter{page}{…}` — use `\SosaPages`.
- **Do not** number sections manually or add a table of contents.
- **Do not** replace the artwork in `assets/` unless asked; it belongs to the
  journal and is committed deliberately.
- **Do not** change `\sosaornamentwidth` or `\sosaornamentgutter` — the text
  measure is derived from them at class-load time, so it is a layout change,
  not an article change.

## When something does not fit

Tell the human plainly, with the measurement. Good: "Table 3 needs 520pt but
the measure is 409pt; I wrapped it in `sosawide`, which gives 470pt and removes
that page's ornament — the journal does the same for its own wide tables."
Bad: silently shrinking the font or editing the class.

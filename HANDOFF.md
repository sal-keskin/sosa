# SoSa LaTeX template — handoff

**Read this first in a new session.** It carries everything needed to keep
working on `sosa.cls` without re-deriving anything: what was measured off the
source PDFs, why the class is built the way it is, what a real compile has and
has not proved, and exactly where to touch things for the usual revisions.

State as of commit `HEAD` on branch `claude/journal-article-latex-template-ul5cft`.
Line numbers below are from that commit and will drift — the section numbers in
`sosa.cls` (`% 1.` … `% 19.`) are the stable landmarks.

---

## 1. What this is

A LaTeX document class that reproduces the printed page design of *Sosyal
Bilimler ve Sağlık Bülteni* (SoSa), a Turkish semi-scientific health/social
science journal. The journal is typeset by hand (Word for submission, something
else for layout); this class turns that design into something an author can
compile on Overleaf.

It was reverse-engineered from three inputs:

| Source | What it gave us |
|---|---|
| `2026;BAHAR(18) pp. 60–70` — quantitative article, 11 pages | Body geometry at 11pt, tables, the alternating ornament, the folio-under-strip behaviour |
| `2026;BAHAR(18) pp. 19–35` — qualitative article, 17 pages | The 12pt setting, block quotes, figures, a second ornament rhythm, ornament width variation |
| `say_12.docx` — the journal's Word submission template | Confirmed page margins (2.2cm sides, 2.5cm bottom, 3.5cm top), section order |

The source PDFs and the docx are **not** in the repo. Their artwork is, under
`assets/`. If you need the measurements again they are all transcribed in
§4 below and in `README.md` — you should not need the originals.

---

## 2. Repo map

```
sosa.cls                     the class — everything lives here, 19 numbered sections
main.tex                     thin driver: artwork list + \input of the three parts
frontmatter.tex              page one as a fill-in form (the author's main file)
body.tex                     the article text
references.tex               the reference list
skeleton.tex                 single-file blank starter, same API, no \input split
README.md                    user-facing docs: options, API, measurement tables
AGENTS.md                    instructions for an AI assistant typesetting a manuscript
ARTWORK.md                   how to commission the banner and strips from an image model
CLAUDE.md                    one-screen pointer: AGENTS.md vs ARTWORK.md vs HANDOFF.md
.github/prompts/             Copilot prompt files for both jobs
tools/crop-artwork.py        crops generated art to the exact pixel size
HANDOFF.md                   this file
latexmkrc                    pdflatex, max_repeat 5
docs/layout-spec.svg         the measured page grid drawn to scale, 3 page types
tools/make-layout-spec.py    regenerates that diagram (needs nothing but python3)
assets/ornaments/*.jpg       10 side strips extracted from the two source issues
assets/hero/*.jpg            2 title-page banner images
figures/                     empty, for the author's own figures
```

`assets/` artwork belongs to the journal. It is committed so the template
compiles to something that looks right out of the box; it should be swapped for
the current issue's artwork before publication.

---

## 3. Status board

### Verified by a real compile

An Overleaf run (TeX Live 2026, pdfLaTeX) confirmed:

- `sosa.cls` loads clean — no errors, no class warnings beyond the intended one
- EB Garamond resolves to Type 1 (`EBGaramond-Regular/Bold/Italic.pfb`)
- `babel-turkish` loads with shorthands off
- `geometry` auto-detects pdftex, no complaints about `nohead, nofoot`
- `trimclip` loads and the cover-crop path runs (`tc-pdftex.def`)
- The shipout hooks fire: `hero-01.jpg` on the title page, `ornament-01.jpg`
  and `ornament-02.jpg` on the two strip pages of a 5-page run
- The `.aux` round-trip works — `\SosaNoOrnament{62}` was written by
  `\begin{sosawide}` and read back on the next pass
- **Zero overfull hboxes** across all pages: the measure, the two abstract
  panes and the table widths all fit

Two bugs surfaced and are fixed:

- `\newenvironment{sosatabular}` had been dropped in a rewrite, so every table
  failed with *Environment sosatabular undefined* and the column preamble
  printed as body text.
- Every `\ifx\sosa@x\@empty` test in the class was dead. `\newcommand` defines
  `\long\def`; `\@empty` is a plain `\def`; `\ifx` compares the `\long` prefix
  too, so the tests never matched and every "optional" block always fired. The
  visible symptom was 22pt of dead space plus an empty paragraph under the
  abstracts on page one, from the `\SosaNote` block that no document had set.
  All nine now use etoolbox's `\ifdefempty`, which is prefix-agnostic.

### Not yet verified — do these first if you have a PDF

1. **Page-1 vertical rhythm.** The masthead, hero band, white title and
   colophon are at absolute coordinates and cannot drift. The flowing block
   (English title → authors → affiliations → Öz/Abstract) is spaced by four
   lengths whose defaults were derived from measured baselines but never seen
   rendered. Compare against the source and tune — see §8.1.
2. **A long article.** Only 5 pages have been compiled. The alternation, the
   artwork cycle wrapping, and `\SosaHideFolioOnOrnamentPages` want a 12+ page run.
3. **`fontsize=12`.** The 12pt path sets a different `\sosatopbaseline`
   (103.2pt) and leading (18pt). Never compiled.
4. **`ornament=all` and `ornament=none`.** `none` changes the text measure at
   load time (470.55pt instead of ~409pt); it should be compiled once.
5. **XeLaTeX / LuaLaTeX.** The `fontspec` branch of §3 has never run.
6. **`sosawidekeep`** and **`\SosaStyleBibliography`** with real biblatex-apa.
7. **The Turkish small-caps substitution.** `\.{i}` under `\scshape` should put
   a dot accent over the small capital at the right height; it has not been
   seen rendered. If the dot sits badly, the fallbacks are `\SosaHeadStyle`
   `uppercase` or `asis`. The `\tl_set:Nx` also expands the head string, so a
   head containing a fragile (non-`\protected`) macro would break — none of the
   derived heads do.
8. **`figures=lining`.** Passes the `lining` option to `ebgaramond`. If that
   option name is wrong the compile stops at the class, so try it on its own.

### Found by reading the first rendered page 1

Three fidelity gaps, all now addressed:

1. **Turkish small caps.** `\scshape` turns lower-case `i` into a dotless small
   capital, so *Bilimler* set as BILIMLER. In Turkish that is a different
   letter. A 420 dpi crop of the source masthead shows the journal getting it
   right — BİLİMLER and BÜLTENİ carry the dot, and only `ı` is dotless, as in
   SAĞLIK. Neither font path offers the OpenType `locl` feature that does this,
   so §12 now substitutes each literal `i` for a small capital with a dot
   accent, via an expl3 `\tl_replace_all:Nnn` on the expanded head string.
   `\SosaHeadStyle` switches to `uppercase` (locale-aware `\MakeUppercase`) or
   `asis` if the substitution disappoints.
2. **The white title was unreadable** over a light, busy banner. §12 gains a
   scrim — a tikz rectangle at `\SosaHeroScrim` opacity painted into the
   background between the picture and the title — plus `\SosaTitleColor`.
3. **Digit style.** The source uses lining figures; the `ebgaramond` default is
   oldstyle. Added as the `figures=lining|oldstyle` class option, left at
   `oldstyle` so the default behaviour is unchanged until someone compiles it.
4. **The abstract panes were first-line indented.** `ragged2e` takes its own
   copy of `\parindent` when it loads — which happens in the package block at
   the top of the class, while `\parindent` is still the article default of
   17.5pt — and `\justifying` restores that copy. §6 now zeroes
   `\JustifyingParindent` and its three siblings alongside `\parindent`.
   Setting `\parindent` is not enough on its own once ragged2e is in play.

### Known benign warnings

`LaTeX Font Warning: Size substitutions with differences up to 1.6pt` —
Computer Modern math (`$\pm$`, `\textsuperscript`) called at 8–9pt inside the
abstract panes and the 9pt tables. EB Garamond ships no math companion. Cosmetic
only; fixing it means adding a math font package and accepting the fragility.

---

## 4. The measurements

Everything below was read off the published PDFs with PyMuPDF. A4 is
595.276 × 841.890 pt. **These are the ground truth — do not re-measure, and do
not "correct" them to rounder numbers without a reason.**

### 4.1 Page frame

| | Value | Note |
|---|---|---|
| Header band | 0 → 42.5pt from the top, full bleed | |
| Band colour, body pages | `#F1F9ED` | rendered value; the PDF vector is saturated green through a soft mask |
| Band colour, title page | `#E6E6E6` | |
| Text ink | `#231F20` | rich black, not `#000000` |
| Left margin | 62.36pt (2.2cm) | matches the Word template |
| Right margin, no strip | 62.36pt → measure 470.55pt | |
| Strip left edge | 511.6pt | visible width ≈ 83.7pt, bleeds past the paper edge |
| Text right edge with strip | 470.5pt → measure ≈ 409pt | |
| Bottom margin | 70.87pt (2.5cm) | |
| First body baseline | 96.5pt from the top (11pt) / 103.2pt (12pt) | |
| Running head | small caps 7–8pt, baseline 24.5pt, flush left at x = 45 | **left-aligned, not centred** — it only looks centred because the line is long |
| Folio | bold 10pt, baseline 809.6pt, right edge at 552.8pt (= paper − 42.5) | |

### 4.2 Type

| Element | Size / leading | Detail |
|---|---|---|
| Body | 11/16.5 or 12/18 | Word's "1.5 lines". Justified, `\parindent` 0, `\parskip` 8pt |
| Section heading | body size, bold, flush left | 48.9pt from the last body baseline to the heading baseline = one line + 8pt parskip + 24pt above; 8pt below |
| Block quote | body size | left indent 28.35pt (1cm), **no right indent** |
| Table body | 9pt (dense) or 11pt (sparse) | class defaults to 10pt via `\sosatablesize` |
| Table rules | 0.5pt, three only | top / under head / bottom, no verticals |
| Table caption | body size, bold, above, flush left | one source table centres it; left is the common case |
| Figure caption | body size, regular, below, centred | `Görsel n.` |
| References heading | body size + 1pt, bold | `Kaynaklar` — 12pt in the 11pt setting |
| References | 11/13 (single-spaced) | 36pt hanging indent, 8pt between entries, justified |

### 4.3 Title page — absolute positions

| Element | Position from paper top | Type |
|---|---|---|
| Masthead line | baseline 24.5pt, x = 43.6 | small caps 9pt |
| Article type (`Özgün Makale`) | baseline 63.5pt, x = 43.1 | bold 14pt |
| Hero band | 71 → 179pt, full bleed | image |
| Turkish title | vertically centred in the band, x = 42.5 | bold 22.4/30pt, white |
| English title | baseline 201.5pt | bold 11.2pt |
| Authors | baseline 235.5pt, x = 54.5, leading 20pt | bold 15pt, superscripts 8.7pt |
| Affiliations | baseline 295.5pt, numbers x = 73.7, text x = 91.7, leading 13pt | italic 9.6pt |
| Öz / Abstract heads | flow — position depends on the author block | bold 13pt |
| Abstract panes | x = 62.4 and 318.9, each 216pt wide, gutter 40.5pt | 8pt on a **7.1pt** baseline |
| Colophon rule | y = 704.1, x = 40.3 → 550.5, 1.42pt | fixed regardless of abstract length |
| Colophon text | baseline 721.4pt, x = 90.6, width ≈ 396pt | 8/13pt, ~18.5pt between blocks |

The abstract's 7.1pt leading on 8pt type is genuinely what the source does. The
class defaults to 9pt for readability; `\SosaAbstractLeading{7.1pt}` matches
exactly.

### 4.4 The ornament, page by page

| | pp. 60–70 article | pp. 19–35 article |
|---|---|---|
| Strip pages (PDF) | 2, 4, 6, 8, 10 | 2, 4, 6, 8, 10, 12, 14, 16 |
| Printed page parity | odd (61, 63, …) | even (20, 22, …) |
| Strip widths seen | 85.0, 85.0, 85.0, 85.4, 85.0 | 85.5, 84.4, 78.5, 66.4, 64.0, 64.0, 64.0, 64.0 |
| Folio on strip pages | **absent** | present, overprinted |
| Wide tables | pp. 62, 64 — both strip-free | — |
| Header band on non-strip pages | flat colour | a cropped image band in some issues |

**The rule that unifies both:** the title page never carries a strip, the page
after it always does, and it alternates from there. Parity of the printed page
number differs only because the two articles start on different pages. This is
why `\SosaStartPage` matters — the alternation is measured from it, not from
page 1.

The width variation is hand placement, not a system. The class uses one width
(84pt) and crops the artwork to fill.

---

## 5. How `sosa.cls` is built

Nineteen numbered sections, in load order. The order matters in a few places,
noted below.

| § | What | Why it's there / why it's ordered that way |
|---|---|---|
| 1 | Class options via `kvoptions` | `\LoadClass` is chosen by an `\ifx` on the fontsize string rather than interpolating it into the option list — that interpolation is fragile |
| 2 | Palette | sampled from rendered pixels, not from the PDF's vector colour values |
| 3 | Fonts | pdfTeX → `ebgaramond`; Xe/Lua → `fontspec`. Both degrade to a warning, never an error |
| 4 | Language | babel with `shorthands=off` — Turkish shorthands (`:` `=` `!`) break maths and URLs. Guarded by `\IfFileExists{turkish.ldf}` |
| 5 | Geometry | Values are precomputed into `\newlength`s **before** `\geometry{}` — passing `\dimexpr` straight into geometry keys is not reliably safe |
| 6 | Body type | `\normalsize` is redefined wholesale; `\topskip` is set to the font size so the first baseline lands where §4.1 says |
| 7 | Headings | `\@startsection`, `secnumdepth` 0 (unnumbered) |
| 8 | Block quotes | `quote` redefined, `quotation` `\let` to it |
| 9 | Captions | `Tablo`/`Görsel` set both via `\addto\captionsturkish` and `\AtBeginDocument`, because babel can overwrite one of them |
| 10 | Tables | booktabs rule widths, `sosatabular`, `L/C/R` column types |
| 11 | **Ornament engine** | see §6 below |
| 12 | Page furniture | band, strip, running head, folio — all stamped in eso-pic shipout hooks, **not** fancyhdr |
| 13 | `sosawide` | reclaims the reserve, suppresses that page's strip via the `.aux` |
| 14 | Front-matter data | setters, plus the repeatable `\SosaAuthor` / `\SosaAffiliation` builders and the issue metadata whose `\AtBeginDocument` block derives the masthead, running head and citation |
| 15 | Fixed strings | redefine these for an English-language issue |
| 16 | `\sosaaff`, `\orcid` | ORCID mark is drawn in TikZ, no bitmap |
| 17 | The first page | see §7 below |
| 18 | References | hanging indent, `sosareferences`, optional biblatex heading |
| 19 | tikz → hyperref → bookmark → microtype | must stay last, in this order |

### Why the furniture is stamped, not fancyhdr

The running head sits at x = 45 from the **paper** edge, and the folio's right
edge at paper − 42.5. Neither aligns with the text block, and on strip pages the
text block is 62pt narrower than on plain ones. Doing that with
`\fancyheadoffset` means arithmetic that changes with every option. Drawing them
into the shipout foreground at absolute coordinates makes the geometry exact and
option-independent, and it costs nothing — the page is `\pagestyle{empty}`.

---

## 6. The ornament engine (§11 + §12 of the class)

This is the part the whole exercise exists for. Read this before touching it.

### Placement

The strip is painted in `\AddToShipoutPictureBG` → `\sosa@paintbackground`:

```latex
\put(\LenToUnit{\dimexpr\paperwidth-\sosaornamentwidth\relax},
     \LenToUnit{-\paperheight}){%
  \sosa@placeart{\sosaornamentwidth}
    {\dimexpr\paperheight-\sosabandheight\relax}{\sosa@ornfile}}
```

Inside `\AtPageUpperLeft`, so y is negative going down. The box's reference
point is its bottom-left, depth 0, so it spans −841.89 → −42.5 exactly. Being in
the background means it never interacts with the galley and can run off the
paper edge.

### Which page gets a strip

`\sosa@decideornament` — order matters, overrides win last:

1. `ornament=none` → never
2. page ≤ `\sosa@startpage` → never (the title page)
3. `ornament=all` → yes; `alternate` → yes when `page − startpage` is odd
4. `\ifcsdef{sosa@noorn@<page>}` → force off
5. `\ifcsdef{sosa@yesorn@<page>}` → force on

It is safe to call twice per page — it touches no counters. §12 calls it a
second time in the foreground hook to decide the folio.

### Which artwork

`\sosa@pickornament`. A page pinned with `\SosaOrnament{65}{file}` wins.
Otherwise a counter walks the `\SosaOrnamentCycle` list and wraps. The counter
advances only on pages that actually get a strip, so the cycle stays in step.

Filenames are fetched with `\expandafter\let\expandafter…\csname…\endcsname`,
not `\edef` — `\edef` would break on a filename containing `_`.

### Cover-fit

`\sosacoverbox` scales the artwork to the band height, then crops equal slices
off both sides with `\clipbox*` — CSS `background-size: cover`. The clip
argument is built with `\edef` into `\sosa@clipdo` first, because `\clipbox*`
wants four space-separated lengths in one braced argument and inline `\dimexpr`
there is unreliable. Falls back to a stretch if `trimclip` is absent or the
artwork is already narrower than the band.

### The `.aux` round-trip

`\SosaNoOrnamentHere` is a **deferred** `\write` (not `\immediate`). The whatsit
is expanded during the shipout of whatever page it lands on, so `\the\c@page`
is that page's number. It reaches the next run through the `.aux`. This is the
same mechanism `\label` uses, and it is why `sosawide` needs two passes.
`\AtEndDocument` emits a "compile once more" warning when `sosawide` was used.

Confirmed working: a real run wrote `\SosaNoOrnament{62}` into `output.aux`.

### The one deliberate departure

**The text measure is constant.** The source narrows the column on strip pages
(≈409pt) and widens it elsewhere (≈473pt). This class always reserves the strip
band, whether or not a strip is painted there.

That is not laziness — LaTeX sets paragraphs before it decides page breaks, so
"make this line shorter if it lands on an odd page" is not a question the
paragraph builder can answer. `flowfram` and friends fake it by replacing the
output routine, and they take floats, footnotes and robustness down with them.
A constant measure also keeps facing pages in register, which the hand-made
original does not manage.

The cost is bought back explicitly by `sosawide`, which reclaims the band for a
wide table and drops that page's strip — which is exactly what the journal does
for every wide table in both source articles.

**If a future session is asked to make the measure per-page:** say what it
costs first. It is possible with `flowfram` or a custom output routine, and it
will make the class fragile for the authors who have to compile it.

---

## 7. The first page (§17)

Split into two kinds of content:

**Stamped at absolute coordinates** (`\sosa@painttitle`, `\sosa@paintcolophon`,
added with `\AddToShipoutPictureFG*` so they apply to that page only):
masthead line, article type, hero band, white Turkish title, colophon rule and
colophon text. None of these can drift no matter what the author writes.

**Flowing** (inside `\maketitle`'s `\makebox[\textwidth][l]{\begin{minipage}{\sosafullwidth}…}`):
English title → authors → affiliations → Öz/Abstract → optional note. This block
starts at `\sosafirstblocktop` and its internal gaps are four lengths. Because
it flows, a longer author list pushes the abstract down — matching the source,
where the two articles' abstracts start at different heights (362.6 vs 350.1).

Two details that look odd but are correct:

- The whole block is a `\makebox[\textwidth][l]` around a `\sosafullwidth`
  minipage, because on strip pages `\textwidth` is the narrow measure but the
  title page needs the full one. Left-flush overfull is intentional and silent.
- The author line hangs 7.86pt into the left margin (`\hspace*{-7.86pt}` plus a
  minipage 7.86pt wider), because the source sets authors at x = 54.5 while the
  rest of the block is at 62.36.

---

## 8. Revision cookbook

The likely next edits, with exactly where to go.

### 8.1 Tune the title page

Compile with the `proof` option first — it draws the text block, the strip edge
and the full measure as thin coloured guides:

```latex
\documentclass[ornament=alternate,proof]{sosa}
```

Then, in the document preamble (all four are plain lengths, no class edit needed):

```latex
\setlength{\sosafirstblocktop}{188pt}   % top of the English title block
\setlength{\sosaskipauthors}{14pt}      % English title -> author line
\setlength{\sosaskipaffil}{6pt}         % authors       -> affiliations
\setlength{\sosaskipabstract}{26pt}     % affiliations  -> Öz / Abstract
```

Targets from §4.3: English title baseline 201.5, authors 235.5, affiliations
295.5. The stamped elements above them are already exact, so only these four
need work.

### 8.2 Swap the artwork

To commission a fresh set from an image model, follow `ARTWORK.md` — it carries
the exact pixel sizes, the era / style / artist interview, and the prompt
templates. `tools/crop-artwork.py` crops whatever comes back to
2480 × 450 px (banner) or 350 × 3331 px (strip) at 300 dpi.

To use files you already have, drop them into `assets/ornaments/` and in the
preamble:

```latex
\SosaOrnamentCycle{assets/ornaments/a,assets/ornaments/b,assets/ornaments/c}
\SosaHero{assets/hero/new-banner}
```

Any tall narrow image works — `ornamentfit=cover` crops whatever aspect ratio
you hand it. No class edit.

### 8.3 Change the strip width or gutter

These two **must** be edited in `sosa.cls` §5, not the document, because the
text measure is derived from them at class-load time:

```latex
\newlength{\sosaornamentwidth}  \setlength{\sosaornamentwidth}{84pt}
\newlength{\sosaornamentgutter} \setlength{\sosaornamentgutter}{40pt}
```

`\sosa@reserve` and `\sosa@rightmargin` recompute from them a few lines below.

### 8.4 Change the ornament rule

`\sosa@decideornament`, §11. To put strips on, say, every third page, replace
the `\ifodd\numexpr\c@page-\sosa@startpage\relax` branch with a `\ifnum` test on
the remainder. Everything else in the engine is independent of the rule.

### 8.5 Colours

§2. All six are `\definecolor{…}{HTML}{…}`, and they are the only colour
definitions in the class. `sosaband` and `sosamasthead` are the two bands;
`sosaink` is every piece of text.

### 8.6 An English-language issue

Pass `lang=english` and redefine the strings from §15 in the preamble:

```latex
\renewcommand{\sosaozname}{Abstract}
\renewcommand{\sosareferencesname}{References}
\renewcommand{\sosakeywordstrname}{Keywords:}
% … and the colophon labels
```

The `Tablo`/`Görsel` caption words follow `lang` automatically.

### 8.7 Add a front-matter field

§14 is a flat list of `\newcommand{\sosa@x}{}` + `\newcommand{\SosaX}[1]{…}`
pairs. Add the pair there, then place it in `\maketitle` (§17) or
`\sosa@paintcolophon` depending on whether it flows or is fixed. Guard optional
fields with `\ifdefempty`, never `\ifx …\@empty` — see §9 trap 9.

If the field belongs to the issue rather than the article, add it to the issue
block instead and derive whatever depends on it in the `\AtBeginDocument` hook
at the end of §14, following the pattern used for the masthead line.

### 8.10 Update the agent instructions

`AGENTS.md` is what another LLM reads before typesetting an article. Anything
that changes the author-facing API — a new `\Sosa…` command, a renamed file, a
new trap — belongs in its command reference and its "Do not" list.
`.github/prompts/new-article.prompt.md` is a short summary that defers to it;
`CLAUDE.md` just routes between the three docs.

### 8.8 Change the table look

§10. `\heavyrulewidth`/`\lightrulewidth` are both 0.5pt (the source uses one
weight for all three rules). `\sosatablesize` is 10pt, `\sosatablesmall` 9pt.
`sosatabular` supplies `\toprule` and `\bottomrule`; the author adds `\midrule`.

### 8.9 References via biblatex

Already wired:

```latex
\usepackage[style=apa,backend=biber]{biblatex}
\addbibresource{references.bib}
\SosaStyleBibliography
...
\printbibliography[heading=sosa]
```

Untested against a real biblatex run — check the hanging indent, which biblatex
sets itself and may need `\setlength{\bibhang}{36pt}`.

---

## 9. Traps

Things that will bite an editor who does not know about them.

1. **`\SosaStartPage`, never `\setcounter{page}`.** The class uses the start
   page for two things: detecting the title page (band colour, hero, masthead
   vs running head) and anchoring the alternation. A bare `\setcounter` breaks
   both silently.
2. **`sosawide` needs two passes.** One pass leaves a strip on the wide table's
   page. latexmk and Overleaf handle it; a single manual `pdflatex` does not.
3. **`\normalsize` is redefined but `\small`, `\large` etc. are not.** They
   still carry the standard `article` 11pt-option sizes. If you change the body
   size, those do not follow.
4. **Nested `\put` inside `\AtPageUpperLeft` is intentional and legal.**
   `\AtPageUpperLeft` already wraps its argument in a `\put`, and LaTeX's `\put`
   works in any restricted horizontal mode. Do not "fix" it.
5. **Precompute lengths before `\geometry{}`.** §5 does this deliberately.
   Putting `\dimexpr` back into the geometry keys may work and may not.
6. **Filenames go through `\let`, not `\edef`.** See §6.
7. **The abstract panes use `\hfill`, not a fixed gutter length.** 216 + 40.5 +
   216 = 472.5 > `\sosafullwidth` (470.55); `\hfill` absorbs the 1.95pt rather
   than overfulling. `\sosaabstractgutter` still exists but is unused.
8. **The class file has been broken once by a wholesale rewrite** (`sosatabular`
   vanished). If you rewrite a section, diff the public API afterwards. There is
   a one-liner for it in §10 below.
9. **Never test a `\newcommand`-defined macro with `\ifx …\@empty`.**
   `\newcommand` makes it `\long\def` and `\@empty` is not `\long`, so `\ifx`
   is always false and the "empty" branch is unreachable. This shipped once and
   put dead space on page one. Use `\ifdefempty{\macro}{yes}{no}`. The `\ifx`
   tests against `\sosa@none` / `\sosa@all` / `\sosa@twelve` / `\sosa@stretch`
   / `\sosa@tr` are fine — kvoptions stores option values with plain `\def`, so
   both sides match.
10. **`\SosaAuthor` and `\SosaAffiliation` append; `\author` and
   `\SosaAffiliations` replace.** Mixing them in one document means last-write
   wins in a confusing way. `\appto` also turns the accumulator into a
   non-`\long` macro, so an author name containing `\par` would break — it
   never will.

---

## 10. Working without a TeX installation

The session that built this had no TeX and no way to install one — CTAN,
TinyTeX and the GitHub releases API were all blocked by the egress proxy. If a
future session is in the same position, these substitutes caught real bugs:

**Brace and conditional balance** (catches the majority of class-level breakage):

```bash
python3 - <<'PY'
import re
s=open('sosa.cls',encoding='utf8').read()
lines=[]
for line in s.split('\n'):
    i=0;res=''
    while i<len(line):
        if line[i]=='\\' and i+1<len(line): res+=line[i:i+2]; i+=2; continue
        if line[i]=='%': break
        res+=line[i]; i+=1
    lines.append(res)
t='\n'.join(lines); d=0; j=0
while j<len(t):
    if t[j]=='\\' and j+1<len(t): j+=2; continue
    d += (t[j]=='{') - (t[j]=='}'); j+=1
t2=re.sub(r'\\newif\\if[a-zA-Z@]+','',t)
macros={'ifcsdef','ifdefstring','ifcsundef','ifdef'}
opens=[m for m in re.findall(r'\\(if[a-zA-Z@]*)',t2) if m not in macros]
print('braces',d,'if',len(opens),'fi',len(re.findall(r'\\fi\b',t2)))
PY
```

Expect `braces 0`, and `if` == `fi`.

**Public-API audit** — this is the check that would have caught the
`sosatabular` regression:

```bash
python3 - <<'PY'
import re
cls=open('sosa.cls',encoding='utf8').read()
defined=set()
for pat in [r'\\newcommand\*?\{?\\([A-Za-z@]+)', r'\\renewcommand\*?\{?\\([A-Za-z@]+)',
            r'\\newenvironment\{([A-Za-z@*]+)\}', r'\\renewenvironment\{([A-Za-z@*]+)\}',
            r'\\newlength\{\\([A-Za-z@]+)\}', r'\\newcolumntype\{([A-Za-z])\}',
            r'\\def\\([A-Za-z@]+)', r'\\newif\\if([A-Za-z@]+)',
            r'\\newsavebox\{\\([A-Za-z@]+)\}', r'\\newdimen\\([A-Za-z@]+)']:
    defined |= set(re.findall(pat,cls))
miss=set()
for f in ['main.tex','frontmatter.tex','body.tex','references.tex',
          'skeleton.tex','README.md','AGENTS.md']:
    s=open(f,encoding='utf8').read()
    if f.endswith('.tex'): s=re.sub(r'(?m)^\s*%.*$','',s)
    for env in re.findall(r'\\begin\{([A-Za-z@*]+)\}',s):
        if env.startswith('sosa') and env not in defined: miss.add(f+': env '+env)
    for cmd in re.findall(r'\\([A-Za-z@]+)',s):
        if cmd[:4] in ('Sosa','sosa') and cmd not in defined: miss.add(f+': \\'+cmd)
print('MISSING:', sorted(miss) or 'none')
PY
```

**Reading a compile log from Overleaf.** Ask for the output zip (Overleaf:
Logs → download). `output.log` is the whole story; `output.aux` shows whether
the ornament round-trip fired. Useful greps:

```bash
grep -n "^!" -A 8 output.log          # errors, in order — the first one is the cause
grep -n "Overfull \\\\hbox" output.log # measure problems
grep -o "ornament-[0-9]*\.jpg" output.log | sort | uniq -c  # did strips get placed?
grep -n "Sosa" output.aux             # did \SosaNoOrnamentHere write anything?
```

One trap when reading logs: a single undefined environment produces a hundred
cascading `Misplaced alignment tab character &` errors. Always fix the **first**
error and recompile before reading the rest.

**Rendering the source PDFs for comparison** needs `pip install pymupdf`
(PyPI was reachable when CTAN was not):

```python
import pymupdf
d = pymupdf.open('article.pdf')
d[1].get_pixmap(dpi=110).save('p2.png')          # look at a page
[im['bbox'] for im in d[1].get_image_info()]      # where the strip sits
[(s['bbox'], s['font'], s['size']) for b in d[1].get_text('dict')['blocks']
 if b['type']==0 for l in b['lines'] for s in l['spans']]   # every span, measured
```

---

## 11. Git

```
branch: claude/journal-article-latex-template-ul5cft   (pushed, tracking origin)
8e59d7f  Restore the sosatabular environment, drop the 3.4pt ORCID font shape
b247793  Add sosa.cls: LaTeX/Overleaf class reproducing the SoSa journal layout
```

No PR has been opened. `origin` is `sal-keskin/sosa`; the default branch has no
other work on it. Keep developing on this branch.

---

## 12. Suggested next steps

In the order that gets the most value per compile:

1. Compile `main.tex` and send back page 1 → tune the four front-page lengths
   (§8.1). This is the only remaining gap between the class and the source, and
   the `\ifdefempty` fix should have removed 22pt of dead space under the
   abstracts, so the earlier defaults may now be closer than they look.
2. Compile a 12+ page article → confirm the alternation and the artwork cycle.
3. Compile once with `fontsize=12` and once with `ornament=none`.
4. Replace `assets/` with the current issue's artwork.
5. Optional: a `sosa-en.cls` wrapper or a `lang=english` string block, if the
   journal publishes English-language issues.

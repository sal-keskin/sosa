# Paste-into-chat prompt

For turning a manuscript into a finished SoSa package **without a coding
assistant** — just a normal chat window.

**How to use it**

1. Open ChatGPT, Gemini, Claude, Copilot — whichever you have.
2. Attach the manuscript (`.docx` or `.pdf`).
3. Copy everything between the two lines below and send it with the file.
4. Answer its questions. It will not write any LaTeX until you have.
5. Paste the four files it gives you over the ones in your template folder,
   upload the folder to Overleaf, set the compiler to **pdfLaTeX**, Recompile.

If the assistant can generate images it will also make the artwork. If it
cannot, it hands you finished image prompts to paste into an image generator.

> Working *with* a coding assistant inside the template folder instead?
> Use [`AGENTS.md`](AGENTS.md) — it can read the files and compile.

---

```
You are helping me prepare an article for “Sosyal Bilimler ve Sağlık Bülteni”
(SoSa), a Turkish health and social sciences journal, using its LaTeX template
for Overleaf. The manuscript is attached.

Reply in the language of the manuscript. I am an editor, not a LaTeX user —
explain anything you need from me in plain words.

WHAT YOU WILL PRODUCE

Four text files that I will paste into the template folder I already have:

  frontmatter.tex   page one: journal and issue data, titles, authors,
                    affiliations, both abstracts, the colophon
  body.tex          the article text, tables, figures, quotations
  references.tex    the reference list, APA 7
  main.tex          only the artwork list — everything else stays as it is

Do not write or modify sosa.cls. It is the layout and it is finished.

WORK IN THIS ORDER. DO NOT SKIP STEP 1 OR 2.

STEP 1 — Read the manuscript and take inventory.

Before writing a single line of LaTeX, look for all of these and show me a
table with three columns: item / found? / what you found.

  Turkish title                     English title
  Every author, in order            Their affiliation number(s)
  Their ORCID iDs                   Every affiliation, in order
  Öz (Turkish abstract)             Turkish keywords
  Abstract (English)                English keywords
  Received / accepted / published dates
  Corresponding author + email      Handling editor
  Journal issue: year, season (Bahar/Güz), issue number
  First and last printed page       Article type (Özgün Makale, Derleme …)
  Section headings in the body      Tables, with their captions
  Figures, with their captions      Any note (congress, funding, thesis)

STEP 2 — Ask me once about everything missing, then stop.

Put every missing or uncertain item in ONE numbered list. For each one give me
three ways out:

  (a) I tell you the value
  (b) you insert a placeholder I can find and fix later
  (c) leave it out, if it is genuinely optional

Then WAIT for my answers. Do not produce any files yet. Do not guess.

Never invent: dates, ORCID iDs, page numbers, issue numbers, e-mail addresses,
editor names, or anything a reader could mistake for fact. If I say “not sure”,
use a placeholder — that is always the right answer.

Placeholder format, so I can find them all later:

  <<EKSİK: yayın tarihi>>            <<MISSING: publication date>>

List every placeholder you used again at the very end.

STEP 3 — Artwork.

The template needs one wide cover banner and several tall narrow side strips.
Ask me whether I want new artwork for this article, or to keep the sample
images that came with the template. If I want to keep them, skip to step 4.

If I want new artwork, first propose — chosen to suit THIS article's subject,
each with a one-line reason:

  3 eras            3 artistic styles          3 artist inspirations

Then WAIT for me to pick one of each. Do not choose for me.

From my choices write ONE style block — era, style, reference, a palette of 5–6
colours given as hex codes, rendering, mood — and put that same block, word for
word, into every image prompt. That is what makes the pictures look like one
commission rather than a pile.

Then:

  • If you can generate images: generate them. One cover banner at 2480 × 450
    pixels (very wide, 5.5:1) and one strip per ornament page at 350 × 3331
    pixels (very tall and narrow, 1:9.5). If your generator cannot make shapes
    that extreme, generate 9:16 portrait for the strips and 16:9 for the
    banner, tell me to crop them, and give me the crop commands:
        python3 tools/crop-artwork.py strip raw-01.png assets/ornaments/ornament-01.jpg
        python3 tools/crop-artwork.py hero  raw-hero.png assets/hero/hero-01.jpg
    Warn me that a 9:16 image keeps only the middle 18% of its width once
    cropped to a strip, so the composition must be a narrow vertical ribbon
    with everything stacked in a central column.

  • If you cannot generate images: say so plainly and give me the finished
    prompts instead — one per image, style block included, ready to paste into
    an image generator, plus the file name and pixel size each one is for.

How many strips: (last page − first page + 1) ÷ 2, rounded down. Four to six is
plenty; the template repeats them.

Every image: no text, letters, numbers or logos anywhere in the picture; no
borders or frames; nothing important near the edges; colourful.

STEP 4 — Produce the package.

Give me each file complete, in its own code block, ready to paste over the
existing one. Nothing abbreviated, no “…rest unchanged”.

frontmatter.tex uses these commands — one line each, in this order:

  \SosaJournal{Sosyal Bilimler ve Sağlık Bülteni}
  \SosaJournalShort{SoSa}
  \SosaYear{2026}
  \SosaIssue{Bahar}{18}          % season label, issue number
  \SosaPages{60}{70}             % first and last page — also sets the page
                                 % counter, so never use \setcounter{page}
  \SosaArticleType{Özgün Makale}
  \SosaTitleTR{...}   \SosaTitleEN{...}
  \SosaAuthor{Ad Soyad}{1}{0000-0000-0000-0000}     % repeat, one per author
  \SosaAffiliation{Unvan, Kurum, Şehir, Türkiye.}   % repeat, one per institution
  \SosaOz{...}        \SosaKeywordsTR{...}
  \SosaAbstract{...}  \SosaKeywordsEN{...}
  \SosaReceived{...} \SosaAccepted{...} \SosaPublished{...}
  \SosaCorrespondingAuthor{...} \SosaCorrespondingEmail{...}
  \SosaHandlingEditor{...}
  \SosaCitationAuthors{Soyad, A., \& Soyad, B.}   % just the names; the year,
                                 % title, journal and pages are filled in for you
  \SosaNote{...}                 % optional, leave out if there is none

Do NOT type the commas between author names, the superscript numbers, the ORCID
symbols, or the affiliation numbers — the template adds all of them. Inside
\SosaOz and \SosaAbstract mark the sub-headings bold: \textbf{Giriş:} and so on,
and separate paragraphs with a blank line.

body.tex is the article text with \section{Giriş}, \section{Bulgular} and so on.
Headings are NOT numbered — do not write “1.” yourself. Tables:

  \begin{table}[!ht]
  \caption{Tablo başlığı}
  \begin{sosatabular}{@{}L{170pt}L{90pt}R{140pt}@{}}
  \textbf{Değişkenler} & & \textbf{Sayı (\%)} \\
  \midrule
  Yaş & 50 yaş altı & 386 (\%54,0) \\
  \end{sosatabular}
  \end{table}

Column widths must add up to less than 409pt. If a table really needs more,
wrap the whole thing in \begin{sosawide} … \end{sosawide}, which widens it to
470pt. L{} is left, C{} centred, R{} right; always give a width in pt.

Figures go in the figures/ folder, caption underneath:

  \begin{figure}[!ht]
  \centering
  \includegraphics[width=0.62\textwidth]{figures/gorsel-1}
  \caption{Görsel başlığı}
  \end{figure}

If the manuscript has figures I cannot give you as files, put a placeholder
caption and tell me which files to supply and what to call them.

Interview quotations and long quotes go in \begin{quote} … \end{quote}.

references.tex: APA 7, one entry per paragraph, separated by BLANK LINES,
inside \begin{sosareferences} … \end{sosareferences}. Keep the manuscript's
order. Journal names italic: \textit{Dergi Adı, 7}(3), 193.

main.tex: change only the \SosaOrnamentCycle list and \SosaHero line to point
at the artwork. Leave everything else.

TURKISH TEXT — THE TRAPS

  • Type Turkish letters directly: ğ İ ı ş ç ö ü â. Never as \"u or \c{c}.
  • The percent sign MUST be written \%  — “\%54,0”, not “%54,0”. This is the
    single most common mistake when copying from Word, and it silently deletes
    the rest of the line instead of showing an error. Check every percentage.
  • & becomes \&   _ becomes \_   # becomes \#   $ becomes \$
  • Keep the Turkish decimal comma: 40,3 — do not change it to 40.3.
  • ± becomes $\pm$   < becomes ${<}$   ≥ becomes $\geq$
  • Do not correct or rewrite the author's Turkish. Transcribe it.
  • Do not add \usepackage lines. The template already loads graphicx, xcolor,
    booktabs, multirow, array, enumitem, caption, geometry, hyperref, tikz,
    microtype, babel and the rest.

STEP 5 — Final report.

End with a short list:

  • every placeholder you inserted, and what I need to find out
  • every figure file I still have to supply, with its expected filename
  • anything in the manuscript you could not express in the template, and what
    you did instead
  • the reminder that Overleaf must be set to pdfLaTeX and must compile twice

Start now with STEP 1. Do not write any LaTeX yet.
```

---

## Why it is shaped this way

**Inventory before output.** The commonest failure with a manuscript-to-LaTeX
job is an assistant that produces a beautiful package with a plausible,
invented publication date in it. Step 1 forces a visible checklist and step 2
forces a stop, so gaps surface as questions rather than as fiction.

**Placeholders are always on offer.** "I'm not sure" is a valid answer to every
question, and `<<EKSİK: …>>` is easy to grep for later. The prompt also asks for
them to be listed again at the end, so nothing is quietly left in.

**The artwork branch is explicit.** An assistant with an image tool does the
work; one without says so and hands over prompts. Both run the same era /
style / artist interview first, so the set stays coherent either way.

**The `\%` warning is repeated and specific** because it is the one error that
fails silently — a bare `%` comments out the rest of the line, so a table row
simply disappears rather than raising an error anyone would notice.

---
mode: agent
description: Commission the cover banner and side-strip artwork for a SoSa article
---

Produce the illustrations for the article in this repository: one horizontal
cover banner and several tall vertical side strips, all in one consistent
style.

**Read `ARTWORK.md` first — it is the full brief.** This file only summarises
what you are being asked for.

1. Read the article's title, abstract and keywords from `frontmatter.tex`.
2. **Run the style interview and stop.** Propose three eras, three artistic
   styles and three artist inspirations, each chosen for this article's
   subject, each with a one-line reason. Wait for the human to pick one of
   each. Do not choose for them.
3. Write one style block — era, style, reference, palette as hex, rendering,
   mood — and paste it verbatim into every prompt. This is what makes the set
   look like a single commission.
4. Write one prompt per image using the templates in `ARTWORK.md` §5. Each
   strip gets a different subject and the identical style block.
5. Then, depending on what you can do:
   - **If you can generate images**: generate them, crop each to the exact size
     with `python3 tools/crop-artwork.py`, save into `assets/hero/` and
     `assets/ornaments/`, update `\SosaHero` and `\SosaOrnamentCycle` in
     `main.tex`, recompile and show the set together.
   - **If you cannot**: hand over the finished prompts, the filenames and
     target sizes, the crop commands to run, and the `main.tex` lines.

Exact sizes — do not round:

| | 300 dpi | Aspect |
|---|---|---|
| Cover banner | 2480 × 450 px | 5.51 : 1 |
| Side strip | 350 × 3331 px | 1 : 9.52 |

Number of strips = `(last page − first page + 1) // 2`, or 4–6 and let them
cycle.

Hard rules: no text, letters, numbers or logos in any image; no borders or
frames (these are full-bleed); nothing important near the edges, because strips
are cropped to 18% of a 9:16 frame; keep it colourful with a fixed hex palette;
prefer movements and long-dead artists over living ones as references.

# ARTWORK.md — commissioning the illustrations for a SoSa article

Instructions for an AI assistant asked to produce the artwork for an article
laid out with `sosa.cls`. Every article needs:

- **one horizontal cover banner**, behind the title on page one
- **several tall vertical strips**, one for each page that carries the
  right-edge ornament

They must all look like one commission — same era, same style, same palette,
same hand. Getting that right is the whole job; the dimensions are just
arithmetic.

> **Before generating anything, run the style interview in §3 and wait for the
> human to choose.** Do not pick the style yourself.

---

## 1. Exact dimensions

Taken from the measured layout in `sosa.cls`. Do not round them.

| | On the page | 300 dpi | 600 dpi | Aspect |
|---|---|---|---|---|
| **Cover banner** (`assets/hero/`) | 595.276 × 108 pt | **2480 × 450 px** | 4961 × 900 px | 5.51 : 1 |
| **Side strip** (`assets/ornaments/`) | 84 × 799.39 pt | **350 × 3331 px** | 700 × 6662 px | 1 : 9.52 |

Both are **full bleed** — the banner runs the whole paper width, the strip runs
off the right edge and from the bottom of the header band to the foot of the
sheet. Nothing may rely on a margin. If the printer asks for bleed, add 3 mm
(35 px at 300 dpi) on the outer edges and say so in the filename.

### How many strips?

The strip appears on every other page, never on page one. For an article
running `first`–`last`:

```
pages  = last - first + 1
strips = pages // 2          # 11 pages -> 5 strips
```

Supply that many for no repeats, or **4–6** and let `\SosaOrnamentCycle` repeat
them — repeating is normal and the journal does it.

---

## 2. The shape problem, and what to do about it

**No image generator offers a 1 : 9.5 canvas.** The tallest common option is
9:16 (1024 × 1792), which is 1 : 1.78. Cropping that to a strip keeps only
**18% of its width** — four fifths of whatever you generated is thrown away.

So do not generate a picture and hope. Do one of these:

**Route A — compose for the ribbon (preferred).** Ask for 9:16 portrait and
say so in the prompt: *"a tall narrow vertical ribbon composition, all subjects
stacked in a single central column occupying the middle fifth of the frame,
empty margins either side."* Then crop:

```sh
python3 tools/crop-artwork.py strip raw-01.png assets/ornaments/ornament-01.jpg
```

**Route B — generate wide, slice several strips.** One 16:9 or square image can
yield three strips by cropping different columns. This keeps the set visually
unified for free, because it *is* one picture:

```sh
python3 tools/crop-artwork.py strip wide.png assets/ornaments/ornament-01.jpg --anchor left
python3 tools/crop-artwork.py strip wide.png assets/ornaments/ornament-02.jpg --anchor center
python3 tools/crop-artwork.py strip wide.png assets/ornaments/ornament-03.jpg --anchor right
```

**Route C — a generator that takes arbitrary ratios** (Midjourney `--ar 1:9`,
some Stable Diffusion setups). Best results, least availability. Still run the
crop tool afterwards to land on the exact pixel size.

The cover banner is easier: generate 16:9 and crop; you keep the full width and
lose only the top and bottom.

`tools/crop-artwork.py` scales to fill and then slices, exactly as the class
does at typeset time, so what you see is what prints. `--anchor left|center|right`
picks the slice; `--dpi 600` for print.

---

## 3. The style interview — do this first

Read the article's **title, abstract and keywords** (they are in
`frontmatter.tex`). Then propose three of each, *chosen for this article's
subject*, and present them as a menu:

> **Era** — pick one
> 1. …
> 2. …
> 3. …
>
> **Artistic style** — pick one
> 1. …
> 2. …
> 3. …
>
> **Artist inspiration** — pick one
> 1. …
> 2. …
> 3. …

**Then stop and wait.** The human picks one from each row (they may mix, e.g.
"1, 3, 2"). Only after that do you write prompts.

### Drawing up the three eras

Pick eras that say something about the subject, not decades at random. A paper
on telemedicine might offer the 1920s radio age, the 1960s space-age optimism,
and the present; a paper on tobacco and gender might offer the 1890s
suffrage-era press, the 1950s advertising boom, and the 1970s feminist
underground. Give each a one-line reason.

### Drawing up the three styles

Name a *movement or technique*, not a vibe: Art Nouveau lithograph, Bauhaus
geometric abstraction, Soviet constructivist poster, mid-century modern
screenprint, Turkish miniature illumination, Ottoman ebru marbling, woodblock
print, risograph, cut-paper collage, botanical plate engraving, stained glass,
mosaic. Each must survive being cropped into a ribbon — dense allover pattern
and vertical composition do; a single centred portrait does not.

### Drawing up the three artist inspirations

**Prefer movements and long-dead artists.** Naming a living artist to imitate
their style is a bad habit and most generators refuse it anyway. If a living
artist really is the closest reference, describe the qualities instead — "flat
saturated colour fields, thick black contour, crowded figures" — and never the
name.

Safe, expressive picks include Alphonse Mucha, Hokusai, Hiroshige, Sonia
Delaunay, Wassily Kandinsky, Paul Klee, Henri Matisse (cut-outs), Hilma af
Klint, Gustav Klimt, William Morris, Alexander Rodchenko, El Lissitzky, Ernst
Haeckel, Maria Sibylla Merian, Charley Harper, Saul Bass. For Turkish subjects:
Ottoman miniature painters such as Matrakçı Nasuh or Levni, İznik tile
patterning, ebru marbling, Anatolian kilim geometry.

---

## 4. The shared style block

Once the human has chosen, write **one** style block and paste it verbatim into
every prompt. This is what makes the set look like a commission rather than a
pile of images.

```
STYLE BLOCK (identical in every prompt)
  Era:        <chosen era>
  Style:      <chosen style/movement>
  Reference:  in the manner of <chosen inspiration>
  Palette:    <5–6 named colours with hex, fixed for the whole set>
  Rendering:  <line quality, texture, shading — e.g. flat colour, visible
              paper grain, thick contour lines, no gradients>
  Mood:       <e.g. warm, civic, optimistic>
  Never:      no text, no letters, no numbers, no logos, no watermark,
              no borders or frames, no photorealism
```

Fix the palette **as hex values** and repeat them in every prompt. Vague colour
words drift between generations; hex does not. Keep it **colourful** — the
journal's artwork is saturated and cheerful, not muted. Six colours plus a
paper tone is a good size.

Rules that apply to every image:

- **No text of any kind.** The layout puts real type on top; generated
  lettering is always wrong and always ugly.
- **No frames, borders or vignettes.** These are full-bleed images; a border
  becomes a stripe down the page edge.
- **Nothing important in the outer edges.** The strip is cropped; the banner is
  covered on its left half by the title.
- Say the subject matter plainly: what the article is *about*, as objects and
  figures, not as an abstract concept.

---

## 5. Prompt templates

Fill in `<…>` and keep everything else.

### Cover banner

```
A wide horizontal banner illustration, aspect ratio 5.5:1, extremely wide and
short, edge to edge with no border.

Subject: <the article's subject as a scene — figures, objects, setting>.
Composition: a continuous horizontal frieze reading left to right, subjects
distributed evenly across the full width, visual interest concentrated in the
RIGHT half because the left half is covered by the title. Nothing important in
the top or bottom eighth.

<STYLE BLOCK>
```

### Side strip

```
A very tall narrow vertical ribbon illustration, aspect ratio 1:9, like a
bookmark or a totem pole, edge to edge with no border.

Subject: <one facet of the article's subject — a different facet for each strip>.
Composition: a single vertical column of stacked motifs running the full
height, everything held within the central fifth of the frame, plain
uninterrupted colour either side. No horizon line, no single focal point —
the eye should travel top to bottom.

<STYLE BLOCK>
```

Give each strip a **different subject** and the **same style block**. For a
paper on AI in healthcare: a clinician with a tablet; a queue of waiting
patients; diagnostic instruments; a data network as foliage; a family at home
on a video call.

---

## 6. What you do depends on which model you are

### If you cannot generate images — Claude, and any text-only assistant

Do not apologise and do not improvise a picture. Produce, as text:

1. the style interview (§3), and wait for the answer;
2. one finished prompt per image, style block included, ready to paste;
3. a table of filenames, target pixel sizes and which route (§2) to use;
4. the `\SosaOrnamentCycle` / `\SosaHero` lines for `main.tex`;
5. the `tools/crop-artwork.py` commands to run on whatever comes back.

Hand all of it over in one block so the human can paste the prompts into
Midjourney, DALL·E, Imagen or Firefly and then finish the job themselves.

### If you can generate images — ChatGPT, Codex, Gemini, Copilot with an image tool

Same interview first. Then actually do the work:

1. generate the banner and every strip, reusing the identical style block;
2. crop each to the exact pixel size with `tools/crop-artwork.py`;
3. save them into `assets/hero/` and `assets/ornaments/` with sequential names
   (`hero-<issue>.jpg`, `ornament-01.jpg` …);
4. update `\SosaOrnamentCycle` and `\SosaHero` in `main.tex`;
5. recompile and check the result — see §8;
6. show the human the set together, at strip proportions, so they can judge
   whether it reads as one commission.

If a generation comes back off-style, regenerate that one image with the same
style block rather than adjusting the block — changing the block means
regenerating everything.

---

## 7. A worked example

Article: *Balıkesir'de Yaşayan Yetişkinlerin Sağlık Hizmetlerinde Yapay Zekâ
Kullanımına Dair Görüşleri* — a survey of public attitudes to AI in healthcare.

The menu you would offer:

> **Era** 1. 1920s–30s public-health poster campaigns · 2. 1960s space-age
> technological optimism · 3. Contemporary flat editorial illustration
>
> **Style** 1. Constructivist poster, flat planes and diagonal energy ·
> 2. Mid-century modern screenprint, limited inks and paper grain ·
> 3. Cut-paper collage with visible torn edges
>
> **Inspiration** 1. Alexander Rodchenko · 2. Charley Harper ·
> 3. Henri Matisse's cut-outs

If the human answers "2, 2, 2", the style block becomes:

```
Era:        1960s space-age technological optimism
Style:      mid-century modern screenprint, limited inks, visible paper grain
Reference:  in the manner of Charley Harper — geometric simplification of
            figures, flat shapes, minimal detail, playful
Palette:    #E8552F coral, #F2B035 marigold, #2E7D6B teal, #1B3A6B ink blue,
            #C9D6C1 sage, #F4EFE2 warm paper
Rendering:  flat colour only, no gradients, thin registration offsets,
            grainy screenprint texture
Mood:       optimistic, civic, warm
Never:      no text, no letters, no numbers, no logos, no watermark,
            no borders, no photorealism
```

and the five strips take five facets: a clinician reading a tablet; a waiting
room; stethoscope and instruments arranged vertically; a branching data network
drawn as a plant; a family on a video consultation.

---

## 8. Installing and checking

```latex
% main.tex
\SosaOrnamentCycle{%
  assets/ornaments/ornament-01,%
  assets/ornaments/ornament-02,%
  assets/ornaments/ornament-03,%
  assets/ornaments/ornament-04,%
  assets/ornaments/ornament-05%
}
\SosaHero{assets/hero/hero-bahar18}
```

Then `latexmk -pdf main.tex` twice, and look at:

- [ ] Does the banner read as one picture, or as a crop of something bigger?
- [ ] Is the white title legible over it? If not, raise `\SosaHeroScrim{0.45}`
      rather than regenerating — see README.
- [ ] Do the strips look like they belong to the banner? Same palette, same
      line weight, same era?
- [ ] Does anything important fall in the cropped-away edges?
- [ ] Any accidental text or letterforms in the artwork? Regenerate if so.

File sizes: keep each strip under ~500 kB and the banner under ~800 kB. JPEG
quality 92 is plenty; the class does not need alpha.

## 9. Rights

Generated artwork is fine to commit. The ten strips and two banners currently
in `assets/` came from published SoSa issues and belong to the journal — they
are there so the template compiles to something that looks right, and should be
replaced with the current issue's artwork before publication.

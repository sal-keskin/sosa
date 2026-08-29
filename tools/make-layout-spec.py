#!/usr/bin/env python3
"""Regenerate docs/layout-spec.svg -- the measured page grid for sosa.cls."""
W, H = 595.276, 841.89
S = 0.60
PW, PH = W * S, H * S
GAP, MARGL, TOP = 104, 76, 92
LEFT = [MARGL, MARGL + PW + GAP, MARGL + 2 * (PW + GAP)]
CW = MARGL * 2 + 3 * PW + 2 * GAP
LEGEND_TOP = TOP + PH + 112
ROWS = [
    ('Body',        '11 / 16.5 pt (or 12 / 18 pt), justified, parindent 0, parskip 8 pt'),
    ('Headings',    'bold at body size, flush left, 24 pt above / 8 pt below, unnumbered'),
    ('Block quote', 'body size, 28.35 pt left indent, no right indent'),
    ('Tables',      '9–11 pt · three 0.5 pt rules, no verticals · caption above, bold, flush left'),
    ('Figures',     'caption below, centred, regular weight — “Görsel n.”'),
    ('References',  '11 / 13 pt, 36 pt hanging indent, 8 pt between entries; heading body + 1 pt bold'),
    ('Ornament',    'every other page: never on the title page, always on the next, alternating from there'),
    ('Folio',       'bold 10 pt, right edge 42.5 pt in, baseline 809.6 — one source article omits it on strip pages'),
    ('Colour',      'band #F1F9ED (body) · #E6E6E6 (title page) · ink #231F20 · accent #74C043'),
]
CH = LEGEND_TOP + 30 + len(ROWS) * 18 + 24

def x(px, i): return LEFT[i] + px * S
def y(py):    return TOP + py * S

LBL  = 'font-size:9px;fill:#5f5f5a'
DIM  = 'font-size:9.5px;fill:#a8402b'
TICK = 'stroke="#a8402b" stroke-width="0.8"'
P = []
add = P.append

add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{CW:.0f}" height="{CH:.0f}" '
    f'viewBox="0 0 {CW:.0f} {CH:.0f}" font-family="Georgia, Times New Roman, serif">')
add(f'<rect x="0" y="0" width="{CW:.0f}" height="{CH:.0f}" fill="#faf9f5"/>')
add(f'<text x="{MARGL}" y="34" style="font-size:16px;fill:#231f20;font-weight:bold">'
    'SoSa page grid — measured from the published PDFs</text>')
add(f'<text x="{MARGL}" y="56" style="font-size:11.5px;fill:#6a6a64">'
    'A4, 595.276 × 841.890 pt. All values in points.</text>')

for i, t in enumerate(['1 · Title page', '2 · Body page + ornament', '3 · Body page, plain']):
    add(f'<text x="{LEFT[i]:.1f}" y="{TOP-16:.1f}" style="font-size:11.5px;fill:#231f20;font-weight:bold">{t}</text>')
    add(f'<rect x="{LEFT[i]:.1f}" y="{TOP:.1f}" width="{PW:.1f}" height="{PH:.1f}" '
        'fill="#ffffff" stroke="#9a9a94" stroke-width="0.9"/>')

add(f'<rect x="{LEFT[0]:.1f}" y="{y(0):.1f}" width="{PW:.1f}" height="{42.5*S:.1f}" fill="#E6E6E6"/>')
for i in (1, 2):
    add(f'<rect x="{LEFT[i]:.1f}" y="{y(0):.1f}" width="{PW:.1f}" height="{42.5*S:.1f}" fill="#F1F9ED"/>')

# ---------------------------------------------------------------- title page
add(f'<rect x="{LEFT[0]:.1f}" y="{y(71):.1f}" width="{PW:.1f}" height="{108*S:.1f}" fill="#6E7F63"/>')
add(f'<text x="{x(42.5,0):.1f}" y="{y(125):.1f}" fill="#ffffff" dominant-baseline="middle" '
    'style="font-size:12px;font-weight:bold">Başlık · 22.4 / 30 pt · white</text>')
add(f'<text x="{x(43.6,0):.1f}" y="{y(21):.1f}" dominant-baseline="middle" '
    'style="font-size:6.5px;fill:#5f5f5a">MASTHEAD · 9 pt SMALL CAPS · x = 43.6</text>')
add(f'<text x="{x(43.1,0):.1f}" y="{y(58):.1f}" dominant-baseline="middle" '
    'style="font-size:9px;fill:#231f20;font-weight:bold">Özgün Makale · 14 pt</text>')
add(f'<text x="{x(42.5,0):.1f}" y="{y(197):.1f}" dominant-baseline="middle" '
    f'style="{LBL};font-size:8px">English title · 11.2 pt bold · baseline 201.5</text>')
add(f'<text x="{x(54.5,0):.1f}" y="{y(231):.1f}" dominant-baseline="middle" '
    'style="font-size:9px;fill:#231f20">Authors · 15 / 20 pt bold · x = 54.5</text>')
for k in range(4):
    add(f'<text x="{x(73.7,0):.1f}" y="{y(291+k*13):.1f}" dominant-baseline="middle" '
        f'style="{LBL};font-size:6.5px">{k+1}.  Affiliation · 9.6 / 13 pt italic · text at x = 91.7</text>')
for px, nm in ((62.4, 'Öz'), (318.9, 'Abstract')):
    add(f'<rect x="{x(px,0):.1f}" y="{y(358):.1f}" width="{216*S:.1f}" height="{326*S:.1f}" '
        'fill="#f2f2ee" stroke="#cfcfc9" stroke-width="0.6"/>')
    add(f'<text x="{x(px+5,0):.1f}" y="{y(372):.1f}" dominant-baseline="middle" '
        f'style="font-size:8.5px;fill:#231f20;font-weight:bold">{nm} · 13 pt</text>')
    add(f'<text x="{x(px+5,0):.1f}" y="{y(388):.1f}" dominant-baseline="middle" '
        f'style="{LBL};font-size:6.5px">216 pt wide · 8 pt on 7.1 pt</text>')
add(f'<line x1="{x(40.3,0):.1f}" y1="{y(704):.1f}" x2="{x(550.5,0):.1f}" y2="{y(704):.1f}" '
    'stroke="#231f20" stroke-width="1.3"/>')
add(f'<text x="{x(90.6,0):.1f}" y="{y(722):.1f}" dominant-baseline="middle" '
    f'style="{LBL};font-size:6.5px">Colophon · 8 / 13 pt · x = 90.6 · rule at y = 704.1, x = 40.3 → 550.5</text>')

# --------------------------------------------------------------- body pages
for i, orn in ((1, True), (2, False)):
    tl, tw = 62.36, (408.9 if orn else 470.55)
    add(f'<rect x="{x(tl,i):.1f}" y="{y(85.5):.1f}" width="{tw*S:.1f}" '
        f'height="{(771-85.5)*S:.1f}" fill="#f5f5f1" stroke="#cfcfc9" stroke-width="0.6"/>')
    yy = 96.5
    while yy <= 765:
        add(f'<line x1="{x(tl,i):.1f}" y1="{y(yy):.1f}" x2="{x(tl+tw,i):.1f}" y2="{y(yy):.1f}" '
            'stroke="#dcdcd5" stroke-width="0.5"/>')
        yy += 16.5
    add(f'<text x="{x(45,i):.1f}" y="{y(21):.1f}" dominant-baseline="middle" '
        f'style="{LBL};font-size:6px">RUNNING HEAD · 7–8 pt SMALL CAPS · FLUSH LEFT AT x = 45</text>')
    add(f'<text x="{x(tl+8,i):.1f}" y="{y(300):.1f}" dominant-baseline="middle" '
        f'style="{LBL};font-size:8px">body 11 / 16.5 pt · justified · parskip 8 pt</text>')
    add(f'<text x="{x(tl+8,i):.1f}" y="{y(320):.1f}" dominant-baseline="middle" '
        f'style="{LBL};font-size:8px">first baseline y = 96.5 · text foot y = 771</text>')
    if orn:
        add(f'<rect x="{x(511.28,i):.1f}" y="{y(42.5):.1f}" width="{84*S:.1f}" '
            f'height="{(841.89-42.5)*S:.1f}" fill="#8FA6C4"/>')
        cx, cy = x(553, i), y(430)
        add(f'<text x="{cx:.1f}" y="{cy:.1f}" fill="#ffffff" dominant-baseline="middle" '
            f'text-anchor="middle" style="font-size:8.5px" transform="rotate(-90 {cx:.1f} {cy:.1f})">'
            'ornament · full bleed · y 42.5 → 841.89</text>')
        add(f'<text x="{x(tl+8,i):.1f}" y="{y(790):.1f}" dominant-baseline="middle" '
            f'style="{LBL};font-size:7px">folio falls under the strip here</text>')
    else:
        add(f'<text x="{x(552.8,i):.1f}" y="{y(806):.1f}" text-anchor="end" '
            'dominant-baseline="middle" style="font-size:9px;fill:#231f20;font-weight:bold">61</text>')

def hdim(i, p0, p1, row, txt):
    yy = TOP + PH + 18 + row * 24
    x0, x1 = x(p0, i), x(p1, i)
    add(f'<line x1="{x0:.1f}" y1="{yy:.1f}" x2="{x1:.1f}" y2="{yy:.1f}" {TICK}/>')
    for xx in (x0, x1):
        add(f'<line x1="{xx:.1f}" y1="{yy-4:.1f}" x2="{xx:.1f}" y2="{yy+4:.1f}" {TICK}/>')
    add(f'<text x="{(x0+x1)/2:.1f}" y="{yy-12:.1f}" dominant-baseline="middle" '
        f'text-anchor="middle" style="{DIM}">{txt}</text>')

hdim(0, 62.4, 278.4, 0, '216');  hdim(0, 318.9, 534.9, 0, '216')
hdim(0, 278.4, 318.9, 1, '40.5 gutter')
hdim(1, 0, 62.36, 0, '62.36');   hdim(1, 62.36, 471.3, 0, '409 measure')
hdim(1, 511.28, 595.276, 0, '84'); hdim(1, 471.3, 511.28, 1, '40 gutter')
hdim(2, 0, 62.36, 0, '62.36');   hdim(2, 62.36, 532.9, 0, '470.55 measure')
hdim(2, 532.9, 595.276, 0, '62.36')

def vdim(i, p0, p1, txt):
    xx = LEFT[i] - 18
    y0, y1 = y(p0), y(p1)
    add(f'<line x1="{xx:.1f}" y1="{y0:.1f}" x2="{xx:.1f}" y2="{y1:.1f}" {TICK}/>')
    for yy in (y0, y1):
        add(f'<line x1="{xx-4:.1f}" y1="{yy:.1f}" x2="{xx+4:.1f}" y2="{yy:.1f}" {TICK}/>')
    add(f'<text x="{xx-7:.1f}" y="{(y0+y1)/2:.1f}" dominant-baseline="middle" '
        f'text-anchor="end" style="{DIM}">{txt}</text>')

vdim(0, 71, 179, '108'); vdim(1, 0, 42.5, '42.5'); vdim(2, 771, 841.89, '70.87')

add(f'<text x="{MARGL}" y="{LEGEND_TOP}" style="font-size:12.5px;fill:#231f20;font-weight:bold">'
    'Type &amp; colour</text>')
for k, (a, b) in enumerate(ROWS):
    add(f'<text x="{MARGL}" y="{LEGEND_TOP+24+k*18}" dominant-baseline="middle" '
        f'style="font-size:10px;fill:#231f20">{a}</text>')
    add(f'<text x="{MARGL+100}" y="{LEGEND_TOP+24+k*18}" dominant-baseline="middle" '
        f'style="{LBL};font-size:10px">{b}</text>')
add('</svg>')

open('docs/layout-spec.svg', 'w', encoding='utf8').write('\n'.join(P))
print('docs/layout-spec.svg written')

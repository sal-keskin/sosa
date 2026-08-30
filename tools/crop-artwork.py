#!/usr/bin/env python3
"""
Crop any image to the exact pixel size the SoSa layout wants.

Image generators do not offer a 1 : 9.5 canvas, so artwork for the side strips
arrives as a 9:16 portrait or a square.  This crops it the way the class would
at typeset time -- scale to fill, then take a slice -- but does it up front, so
you can see the result and pick which slice you keep.

    python3 tools/crop-artwork.py strip raw.png assets/ornaments/ornament-01.jpg
    python3 tools/crop-artwork.py hero  raw.png assets/hero/hero-01.jpg

    --anchor left|center|right   which slice to keep (default center)
    --dpi 300|600                output resolution (default 300)

Targets, from the measured layout:

    strip   84 x 799.39 pt on the page  ->  350 x 3331 px at 300 dpi
    hero    595.276 x 108 pt            -> 2480 x  450 px at 300 dpi

Needs Pillow:  pip install pillow
"""
import argparse
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is not installed.  pip install pillow")

# on-page size in PostScript points, straight from sosa.cls
TARGETS_PT = {
    "strip": (84.0, 799.39),
    "hero": (595.276, 108.0),
}


def target_px(kind: str, dpi: int) -> tuple[int, int]:
    w_pt, h_pt = TARGETS_PT[kind]
    return round(w_pt / 72 * dpi), round(h_pt / 72 * dpi)


def cover_crop(im: Image.Image, tw: int, th: int, anchor: str) -> Image.Image:
    """Scale to fill tw x th without distorting, then crop the overflow."""
    scale = max(tw / im.width, th / im.height)
    new = (max(tw, round(im.width * scale)), max(th, round(im.height * scale)))
    im = im.resize(new, Image.LANCZOS)

    over_x, over_y = im.width - tw, im.height - th
    if anchor == "left":
        x = 0
    elif anchor == "right":
        x = over_x
    else:
        x = over_x // 2
    y = over_y // 2  # vertical slice is always centred
    return im.crop((x, y, x + tw, y + th))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("kind", choices=sorted(TARGETS_PT))
    ap.add_argument("source")
    ap.add_argument("dest")
    ap.add_argument("--anchor", choices=["left", "center", "right"], default="center")
    ap.add_argument("--dpi", type=int, default=300)
    ap.add_argument("--quality", type=int, default=92)
    args = ap.parse_args()

    tw, th = target_px(args.kind, args.dpi)
    im = Image.open(args.source).convert("RGB")
    out = cover_crop(im, tw, th, args.anchor)

    if args.dest.lower().endswith((".jpg", ".jpeg")):
        out.save(args.dest, quality=args.quality, dpi=(args.dpi, args.dpi))
    else:
        out.save(args.dest, dpi=(args.dpi, args.dpi))

    kept = tw / (im.width * max(tw / im.width, th / im.height)) * 100
    print(f"{args.source} {im.size} -> {args.dest} {out.size} "
          f"({args.kind}, {args.dpi} dpi, kept {kept:.0f}% of the width, "
          f"anchor {args.anchor})")


if __name__ == "__main__":
    main()

# -*- coding: utf-8 -*-
"""Debug the Arabic text rendering pipeline to ensure NO placeholder boxes."""
import os
import sys

sys.path.insert(0, r"tools")

from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont

import arabic_reshaper
from bidi.algorithm import get_display

WORD = "\u0630\u0650\u0643\u0652\u0631"          # ذِكْر
TAGLINE = "\u0645\u0639\u064a\u0646\u0643 \u0639\u0644\u0649 \u0627\u0644\u0630\u0650\u0643\u0652\u0631"  # معينك على الذِكْر

FONT_CALLI = r"tools/fonts/Amiri-Bold.ttf"
FONT_TAG = r"tools/fonts/Tajawal-Regular.ttf"

OUT = r"tools/debug_arabic_render.txt"
lines = []


def check_font_glyphs(font_path, text, label):
    """Verify the font contains all needed glyphs (no tofu boxes)."""
    lines.append("=" * 60)
    lines.append("FONT CHECK: %s (%s)" % (label, font_path))
    if not os.path.exists(font_path):
        lines.append("  FATAL: Font file not found!")
        return False
    font = TTFont(font_path)
    cmap = font.getBestCmap()
    missing = []
    for ch in text:
        cp = ord(ch)
        if cp not in cmap:
            missing.append("U+%04X (%s)" % (cp, ch))
    if missing:
        lines.append("  FATAL: Missing glyphs -> %s" % ", ".join(missing))
        return False
    lines.append("  OK: All %d unique codepoints present in font" % len(set(ord(c) for c in text)))
    return True


def render_and_measure(text, font_path, font_size, label):
    """Render text and measure actual ink coverage (pixels)."""
    lines.append("")
    lines.append("RENDER CHECK: %s" % label)
    # Shape the Arabic
    reshaped = arabic_reshaper.reshape(text)
    display = get_display(reshaped)
    lines.append("  Original codepoints: %s" % " ".join("U+%04X" % ord(c) for c in text))
    lines.append("  Reshaped codepoints : %s" % " ".join("U+%04X" % ord(c) for c in reshaped))
    lines.append("  Display codepoints  : %s" % " ".join("U+%04X" % ord(c) for c in display))

    font = ImageFont.truetype(font_path, font_size)
    temp = Image.new("L", (10, 10), 0)
    d = ImageDraw.Draw(temp)
    bbox = d.textbbox((0, 0), display, font=font, stroke_width=0)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    pad = int(font_size * 0.5)
    img = Image.new("L", (w + pad * 2, h + pad * 2), 0)
    d = ImageDraw.Draw(img)
    d.text((pad - bbox[0], pad - bbox[1]), display, font=font, fill=255)

    # Count ink pixels
    px = img.load()
    ink = 0
    for y in range(img.height):
        for x in range(img.width):
            if px[x, y] > 128:
                ink += 1
    total = img.width * img.height
    lines.append("  Canvas: %dx%d, Ink pixels: %d (%.2f%% coverage)" % (img.width, img.height, ink, 100.0 * ink / total))
    if ink < 100:
        lines.append("  FATAL: Too few ink pixels - likely rendering empty boxes!")
        return False
    lines.append("  OK: Substantial ink coverage - text rendered correctly")
    return True


def main():
    ok = True
    # 1. Font glyph checks
    ok &= check_font_glyphs(FONT_CALLI, WORD, "Calligraphy font (Amiri Bold)")
    ok &= check_font_glyphs(FONT_TAG, TAGLINE, "Tagline font (Tajawal)")

    # 2. Render & measure
    ok &= render_and_measure(WORD, FONT_CALLI, 200, "Word ذِكْر")
    ok &= render_and_measure(TAGLINE, FONT_TAG, 100, "Tagline معينك على الذِكْر")

    lines.append("")
    lines.append("OVERALL: %s" % ("PASS - Arabic renders correctly" if ok else "FAIL - placeholders detected"))

    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    os.write(1, b"Debug written to " + OUT.encode("utf-8") + b"\n")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
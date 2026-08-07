# -*- coding: utf-8 -*-
"""Render the Arabic word and output ASCII art visualization for structural verification."""
import os
import sys

sys.path.insert(0, r"tools")
from test_arabic_render import render_arabic_mask, FONT

import arabic_reshaper
from bidi.algorithm import get_display
from PIL import Image, ImageDraw, ImageFont

OUT = r"tools/word_ascii.txt"


def render_lowres_ascii(text, font_path, font_size=160, scale=4, threshold=128):
    mask = render_arabic_mask(text, font_path, font_size)
    # Crop to content
    bbox = mask.getbbox()
    if bbox:
        mask = mask.crop(bbox)
    w, h = mask.size
    pw = max(w // scale, 20)
    ph = pw * h // (w * 2)  # approximate square aspect for terminal
    small = mask.resize((pw, ph))
    px = small.load()
    lines = []
    for y in range(ph):
        row = "".join("#" if px[x, y] > threshold else " " for x in range(pw))
        lines.append(row)
    return "\n".join(lines)


def main():
    lines = []
    for label, word in [
        ("FULL WORD (Dhal+kasra Kaf+sukun Ra): \u0630\u0650\u0643\u0652\u0631", "\u0630\u0650\u0643\u0652\u0631"),
        ("DHAL ONLY + kasra: \u0630\u0650", "\u0630\u0650"),
        ("KAF ONLY + sukun: \u0643\u0652", "\u0643\u0652"),
        ("RA ONLY: \u0631", "\u0631"),
    ]:
        lines.append("=" * 60)
        lines.append(label)
        lines.append("=" * 60)
        lines.append(render_lowres_ascii(word, FONT))
        lines.append("")
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    os.write(1, b"ASCII art written to " + OUT.encode("utf-8") + b"\n")


if __name__ == "__main__":
    main()
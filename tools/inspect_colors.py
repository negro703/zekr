# -*- coding: utf-8 -*-
"""Inspect actual pixel colors in key regions to verify gold rendering."""
import os
import sys

sys.path.insert(0, r"tools")
from PIL import Image
from collections import Counter

OUT_DIR = r"assets/brand"


def sample_region(img, x0, y0, x1, y1, label, step=3):
    rgba = img.convert("RGBA")
    px = rgba.load()
    counter = Counter()
    for y in range(y0, y1, step):
        for x in range(x0, x1, step):
            r, g, b, a = px[x, y]
            if a > 100:
                counter[(r // 16 * 16, g // 16 * 16, b // 16 * 16)] += 1
    print("  %s region (%d,%d)-(%d,%d):" % (label, x0, y0, x1, y1))
    for color, count in counter.most_common(8):
        print("    RGB~%s : %d" % (color, count))


def main():
    # App icon
    icon = Image.open(os.path.join(OUT_DIR, "app_icon_1024.png"))
    w, h = icon.size
    cx, cy = w // 2, h // 2
    print("APP ICON:")
    sample_region(icon, cx - 200, cy - 100, cx + 200, cy + 100, "center-calligraphy")
    sample_region(icon, 40, 40, 200, 200, "top-left-border")

    # Splash portrait
    splash = Image.open(os.path.join(OUT_DIR, "splash_portrait_1080x1920.png"))
    w, h = splash.size
    cx, cy = w // 2, h // 2
    print("\nSPLASH PORTRAIT:")
    sample_region(splash, cx - 200, cy - 100, cx + 200, cy + 100, "center-calligraphy")
    sample_region(splash, cx - 200, cy + 200, cx + 200, cy + 400, "tagline")
    sample_region(splash, cx - 50, h - 100, cx + 50, h - 30, "spinner")


if __name__ == "__main__":
    main()
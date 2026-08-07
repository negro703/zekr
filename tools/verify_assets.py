# -*- coding: utf-8 -*-
"""Verify generated brand assets: dimensions, colors, and element placement."""
import os
import sys

sys.path.insert(0, r"tools")
from PIL import Image

OUT_DIR = r"assets/brand"

GREEN_DARK = (26, 77, 58)
GOLD = (197, 160, 89)


def analyze(img: Image.Image, label: str):
    print("=" * 60)
    print(label, "->", img.size, img.mode)
    rgba = img.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size

    # Sample background color (corner, away from border)
    corner = px[5, 5]
    print("  corner pixel (5,5):", corner)

    # Count gold-ish pixels (high R, mid G, low B, high alpha)
    gold_count = 0
    green_count = 0
    for y in range(0, h, 4):
        for x in range(0, w, 4):
            r, g, b, a = px[x, y]
            if a > 200:
                if r > 150 and 100 < g < 200 and b < 130:
                    gold_count += 1
                elif g > r and g > b and r < 100:
                    green_count += 1
    total = (w // 4) * (h // 4)
    print("  gold-ish sampled px: %d (%.2f%%)" % (gold_count, 100.0 * gold_count / total))
    print("  green-ish sampled px: %d (%.2f%%)" % (green_count, 100.0 * green_count / total))

    # Check center region has content (calligraphy)
    cx, cy = w // 2, h // 2
    center_alpha = 0
    for y in range(cy - h // 8, cy + h // 8, 2):
        for x in range(cx - w // 8, cx + w // 8, 2):
            center_alpha += px[x, y][3]
    print("  center region alpha sum (calligraphy present):", center_alpha)

    # Check bottom region for spinner (splash only)
    bottom_alpha = 0
    for y in range(h - h // 10, h - h // 20, 2):
        for x in range(cx - w // 20, cx + w // 20, 2):
            bottom_alpha += px[x, y][3]
    print("  bottom-center alpha sum (spinner present):", bottom_alpha)

    # Check tagline region (between center and bottom) for splash
    tag_alpha = 0
    for y in range(cy + h // 6, cy + h // 3, 2):
        for x in range(cx - w // 6, cx + w // 6, 2):
            tag_alpha += px[x, y][3]
    print("  tagline region alpha sum:", tag_alpha)


def main():
    files = [
        "app_icon_1024.png",
        "splash_portrait_1080x1920.png",
        "splash_landscape_1920x1080.png",
    ]
    for f in files:
        path = os.path.join(OUT_DIR, f)
        if not os.path.exists(path):
            print("MISSING:", path)
            continue
        img = Image.open(path)
        analyze(img, f)


if __name__ == "__main__":
    main()
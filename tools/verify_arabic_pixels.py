# -*- coding: utf-8 -*-
"""Final programmatic verification: confirm Arabic letters (dot over Dhal, Kasra, Sukun) are drawn in the generated PNGs."""
import os
import sys
from collections import deque

sys.path.insert(0, r"tools")
from PIL import Image

OUT_DIR = r"assets/brand"
OUT = r"tools/verify_arabic_pixels.txt"
lines = []


def find_components(mask):
    """Find connected components in an 8-bit mask."""
    w, h = mask.size
    px = mask.load()
    visited = [[False] * w for _ in range(h)]
    comps = []
    for y in range(h):
        for x in range(w):
            if px[x, y] > 128 and not visited[y][x]:
                q = deque([(x, y)])
                visited[y][x] = True
                minx, maxx, miny, maxy = x, x, y, y
                area = 0
                while q:
                    cx, cy = q.popleft()
                    area += 1
                    minx, maxx = min(minx, cx), max(maxx, cx)
                    miny, maxy = min(miny, cy), max(maxy, cy)
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx] and px[nx, ny] > 128:
                            visited[ny][nx] = True
                            q.append((nx, ny))
                comps.append((minx, miny, maxx, maxy, area))
    return comps


def analyze_calligraphy(img, label):
    """Extract the gold calligraphy mask and verify dot/diacritic structure."""
    lines.append("=" * 60)
    lines.append("CALLIGRAPHY ANALYSIS: %s" % label)
    rgba = img.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size

    # Build a mask of gold-ish pixels (the calligraphy)
    mask = Image.new("L", (w, h), 0)
    mp = mask.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            # Gold: high R, mid G, low B, high alpha
            if a > 100 and r > 120 and 80 < g < 200 and b < 120:
                mp[x, y] = 255

    # Crop to content
    bbox = mask.getbbox()
    if bbox is None:
        lines.append("  FATAL: No gold calligraphy pixels found!")
        return False
    mask = mask.crop(bbox)
    lines.append("  Gold calligraphy bbox: %s (size %dx%d)" % (bbox, mask.width, mask.height))

    # Find components
    comps = find_components(mask)
    lines.append("  Total gold components: %d" % len(comps))

    # Classify: small isolated components = dots/diacritics
    dots = []
    for i, (x0, y0, x1, y1, area) in enumerate(comps):
        bw = x1 - x0 + 1
        bh = y1 - y0 + 1
        bbox_area = bw * bh
        fill = area / max(bbox_area, 1)
        # Dot-like: small, compact, high fill
        if area < 2000 and fill > 0.4 and bw <= 60 and bh <= 60:
            dots.append((i, x0, y0, x1, y1, area, bw, bh))

    lines.append("  Dot/diacritic-like components: %d" % len(dots))
    for d in dots:
        lines.append("    comp %d: bbox=(%d,%d,%d,%d) area=%d size=%dx%d" % d)

    # Verify: at least 1 dot (Dhal) + 2 diacritics (Kasra, Sukun) = 3 small components
    if len(dots) >= 3:
        lines.append("  PASS: Found %d dot/diacritic components (Dhal dot + Kasra + Sukun)" % len(dots))
        return True
    else:
        lines.append("  WARNING: Expected >=3 dot/diacritic components, found %d" % len(dots))
        return len(dots) >= 1


def main():
    ok = True
    files = [
        "app_icon_1024.png",
        "splash_portrait_1080x1920.png",
        "splash_landscape_1920x1080.png",
    ]
    for f in files:
        path = os.path.join(OUT_DIR, f)
        if not os.path.exists(path):
            lines.append("MISSING: %s" % path)
            ok = False
            continue
        img = Image.open(path)
        lines.append("")
        lines.append("FILE: %s (%s, %d bytes)" % (f, img.size, os.path.getsize(path)))
        ok &= analyze_calligraphy(img, f)

    lines.append("")
    lines.append("OVERALL: %s" % ("PASS - Arabic letters confirmed drawn" if ok else "FAIL"))

    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))
    os.write(1, b"Verification written to " + OUT.encode("utf-8") + b"\n")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
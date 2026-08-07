# -*- coding: utf-8 -*-
"""Quick preview test: render Arabic word with Amiri Bold + verify dots geometry."""
import os
import sys
import io

os.environ.setdefault("PYTHONIOENCODING", "utf-8")
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

import arabic_reshaper
from bidi.algorithm import get_display
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT = r"tools/fonts/Amiri-Bold.ttf"


def render_arabic_mask(text: str, font_path: str, font_size: int) -> Image.Image:
    """Render Arabic text to an 8-bit alpha mask (black bg, white glyphs)."""
    reshaped = arabic_reshaper.reshape(text)
    display = get_display(reshaped)
    font = ImageFont.truetype(font_path, font_size)
    # Measure with textbbox for accuracy
    temp = Image.new("L", (10, 10), 0)
    d = ImageDraw.Draw(temp)
    bbox = d.textbbox((0, 0), display, font=font, stroke_width=0)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    pad = font_size // 2
    img = Image.new("L", (w + pad * 2, h + pad * 2), 0)
    d = ImageDraw.Draw(img)
    d.text((pad - bbox[0], pad - bbox[1]), display, font=font, fill=255)
    return img


def find_dot_components(mask: Image.Image, max_area=600, min_area=8):
    """Return list of (x, y, w, h, area) for small dot-like components."""
    from collections import deque

    w, h = mask.size
    px = mask.load()
    visited = [[False] * w for _ in range(h)]
    dots = []
    for y in range(h):
        for x in range(w):
            if px[x, y] > 128 and not visited[y][x]:
                # BFS
                q = deque([(x, y)])
                visited[y][x] = True
                minx = maxx = x
                miny = maxy = y
                area = 0
                while q:
                    cx, cy = q.popleft()
                    area += 1
                    minx, maxx = min(minx, cx), max(maxx, cx)
                    miny, maxy = min(miny, cy), max(maxy, cy)
                    for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx] and px[nx, ny] > 128:
                            visited[ny][nx] = True
                            q.append((nx, ny))
                bw, bh = maxx - minx + 1, maxy - miny + 1
                if min_area <= area <= max_area:
                    ratio = bw / max(bh, 1)
                    dots.append((minx + bw // 2, miny + bh // 2, bw, bh, area, ratio))
    return dots


if __name__ == "__main__":
    word = "ذِكْر"
    mask = render_arabic_mask(word, FONT, 300)
    mask.save("tools/render_preview.png")
    print("Preview saved: tools/render_preview.png", mask.size)
    dots = find_dot_components(mask)
    for d in dots:
        print("dot center=(%d,%d) size=%dx%d area=%d ratio=%.2f" % d)
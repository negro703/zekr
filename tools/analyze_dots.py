# -*- coding: utf-8 -*-
"""Analyze the rendered Arabic word: component/dot geometry analysis."""
import os
import sys
from collections import deque

sys.path.insert(0, r"tools")

from test_arabic_render import render_arabic_mask, FONT

OUT = r"tools/dot_analysis.txt"


def find_all_components(mask):
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


def main():
    word = "\u0630\u0650\u0643\u0652\u0631"  # ذِكْر
    mask = render_arabic_mask(word, FONT, 300)
    comps = find_all_components(mask)

    # Estimate baseline: the lowest row with a significant horizontal run of pixels
    w, h = mask.size
    px = mask.load()
    baseline_y = None
    for y in range(h - 1, -1, -1):
        run = 0
        max_run = 0
        for x in range(w):
            if px[x, y] > 128:
                run += 1
                max_run = max(max_run, run)
            else:
                run = 0
        if max_run > w * 0.3:
            baseline_y = y
            break

    lines = []
    lines.append("Word codepoints: " + " ".join("U+%04X" % ord(c) for c in word))
    lines.append("Mask size: %dx%d" % mask.size)
    lines.append("Estimated baseline y: %s" % baseline_y)
    lines.append("Total components: %d" % len(comps))
    lines.append("")
    lines.append("idx | x0, y0, x1, y1, area | class")
    lines.append("----|---------------------------|------")

    # Heuristic dot classification
    dot_like = []
    for i, (x0, y0, x1, y1, area) in enumerate(comps):
        bw = x1 - x0 + 1
        bh = y1 - y0 + 1
        bbox_area = bw * bh
        fill = area / max(bbox_area, 1)
        is_dot = area < 500 and fill > 0.5 and bw <= 40 and bh <= 40
        cls = "DOT" if is_dot else "body"
        if is_dot:
            center_y = (y0 + y1) // 2
            rel = "above" if baseline_y is not None and center_y < baseline_y else "below/at-baseline"
            dot_like.append((i, x0, y0, x1, y1, area, rel))
        lines.append(
            "%3d | %3d, %3d, %3d, %3d, %5d | %s"
            % (i, x0, y0, x1, y1, area, cls)
        )

    lines.append("")
    lines.append("Dot-like components:")
    for d in dot_like:
        lines.append(
            "  comp %d: bbox=(%d,%d,%d,%d) area=%d -> %s"
            % (d[0], d[1], d[2], d[3], d[4], d[5], d[6])
        )
    lines.append("")
    lines.append("Dots above: %d" % sum(1 for d in dot_like if d[6] == "above"))
    lines.append("Dots at/below baseline: %d" % sum(1 for d in dot_like if d[6] == "below/at-baseline"))

    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    os.write(1, b"Analysis written to " + OUT.encode("utf-8") + b"\n")


if __name__ == "__main__":
    main()
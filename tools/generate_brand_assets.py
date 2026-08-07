# -*- coding: utf-8 -*-
"""
Zekr (ذِكْر) Brand Asset Generator
===================================
Generates:
  1. App Icon (1024x1024) - deep green, gold Thuluth calligraphy, arabesque border
  2. Splash Screen (portrait 1080x1920 + landscape 1920x1080)
     - radiating arabesque pattern, gold calligraphy with glow, tagline, spinner

Colors:
  Primary   : #1A4D3A (Deep Islamic Green)
  Secondary : #C5A059 (Brushed Gold)
"""
import os
import math
import random
import sys

sys.path.insert(0, r"tools")

import arabic_reshaper
from bidi.algorithm import get_display
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

# ---------------------------------------------------------------------------
# Paths & Constants
# ---------------------------------------------------------------------------
OUT_DIR = r"assets/brand"
os.makedirs(OUT_DIR, exist_ok=True)

FONT_CALLI = r"tools/fonts/Amiri-Bold.ttf"      # ornate calligraphic (Thuluth-like)
FONT_TAG   = r"tools/fonts/Tajawal-Regular.ttf"  # clean elegant tagline

GREEN_DARK  = (26, 77, 58)      # #1A4D3A
GREEN_MID   = (34, 96, 73)      # lighter green for texture
GREEN_DEEP  = (18, 58, 44)      # darker green for depth
GOLD        = (197, 160, 89)    # #C5A059
GOLD_LIGHT  = (240, 210, 140)   # highlight (brighter)
GOLD_DARK   = (150, 108, 40)    # shadow (deeper)
GOLD_PALE   = (214, 184, 130)   # mid

WORD = "\u0630\u0650\u0643\u0652\u0631"          # ذِكْر
TAGLINE = "\u0645\u0639\u064a\u0646\u0643 \u0639\u0644\u0649 \u0627\u0644\u0630\u0650\u0643\u0652\u0631"  # معينك على الذِكْر


# ---------------------------------------------------------------------------
# Arabic text helpers
# ---------------------------------------------------------------------------
def shape_arabic(text: str) -> str:
    """Reshape + bidi for correct Arabic rendering."""
    return get_display(arabic_reshaper.reshape(text))


def render_text_mask(text: str, font_path: str, font_size: int, stroke=0) -> Image.Image:
    """Render Arabic text to an 8-bit alpha mask (transparent bg, white glyphs).

    Raises a fatal error if the text renders as placeholder boxes (too few ink
    pixels), ensuring zero tolerance for missing glyphs.
    """
    display = shape_arabic(text)
    font = ImageFont.truetype(font_path, font_size)
    temp = Image.new("L", (10, 10), 0)
    d = ImageDraw.Draw(temp)
    bbox = d.textbbox((0, 0), display, font=font, stroke_width=stroke)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    pad = int(font_size * 0.5) + stroke
    img = Image.new("L", (w + pad * 2, h + pad * 2), 0)
    d = ImageDraw.Draw(img)
    d.text((pad - bbox[0], pad - bbox[1]), display, font=font, fill=255, stroke_width=stroke, stroke_fill=255)

    # Fatal-error guard: verify substantial ink coverage (no placeholder boxes)
    px = img.load()
    ink = 0
    for y in range(img.height):
        for x in range(img.width):
            if px[x, y] > 128:
                ink += 1
    total = img.width * img.height
    coverage = 100.0 * ink / total
    if coverage < 1.0:
        raise RuntimeError(
            "FATAL: Arabic text rendered as placeholder boxes! "
            "Ink coverage only %.2f%% for text '%s' with font '%s'. "
            "Check font shaping (arabic_reshaper/python-bidi) and font glyph coverage."
            % (coverage, text, font_path)
        )
    return img


# ---------------------------------------------------------------------------
# Gold gradient / emboss helpers
# ---------------------------------------------------------------------------
def make_gold_gradient(size, angle=45.0):
    """Create a gold gradient image (RGB) of given size."""
    w, h = size
    grad = Image.new("RGB", (w, h))
    px = grad.load()
    rad = math.radians(angle)
    cos_a, sin_a = math.cos(rad), math.sin(rad)
    # Normalize direction
    cx, cy = w / 2.0, h / 2.0
    max_dist = math.hypot(w, h) / 2.0
    stops = [
        (0.00, GOLD_LIGHT),
        (0.25, GOLD),
        (0.50, GOLD_DARK),
        (0.75, GOLD),
        (1.00, GOLD_LIGHT),
    ]
    for y in range(h):
        for x in range(w):
            dx, dy = x - cx, y - cy
            t = (dx * cos_a + dy * sin_a) / max_dist
            t = (t + 1.0) / 2.0  # 0..1
            # interpolate stops
            for i in range(len(stops) - 1):
                t0, c0 = stops[i]
                t1, c1 = stops[i + 1]
                if t0 <= t <= t1:
                    f = (t - t0) / (t1 - t0)
                    px[x, y] = tuple(int(c0[k] + (c1[k] - c0[k]) * f) for k in range(3))
                    break
            else:
                px[x, y] = GOLD
    return grad


def apply_gold_to_mask(mask: Image.Image, gradient: Image.Image) -> Image.Image:
    """Colorize a white-on-transparent mask with a gold gradient."""
    rgba = gradient.convert("RGBA")
    rgba.putalpha(mask)
    return rgba


def emboss_text(mask: Image.Image, gradient: Image.Image, depth=3, light_dir=(1, -1)):
    """Create an embossed gold effect: dark shadow + light highlight offset."""
    # Base gold fill
    base = apply_gold_to_mask(mask, gradient)
    # Shadow (offset opposite light) - subtle, warm dark
    shadow_mask = Image.new("L", mask.size, 0)
    shadow_mask.paste(mask, (depth * light_dir[0], depth * light_dir[1]), mask)
    shadow = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    shadow.putalpha(shadow_mask.point(lambda v: int(v * 0.35)))
    # Highlight (offset toward light) - bright gold sheen
    hl_mask = Image.new("L", mask.size, 0)
    hl_mask.paste(mask, (-depth * light_dir[0], -depth * light_dir[1]), mask)
    hl = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    hl.putalpha(hl_mask.point(lambda v: int(v * 0.5)))
    # Composite: shadow under, base, highlight over
    out = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    out.alpha_composite(shadow)
    out.alpha_composite(base)
    out.alpha_composite(hl)
    return out


# ---------------------------------------------------------------------------
# Green textured background
# ---------------------------------------------------------------------------
def make_green_background(size, pattern="radial", seed=42):
    """Deep green background with subtle tone-on-tone texture."""
    w, h = size
    img = Image.new("RGB", (w, h), GREEN_DARK)
    px = img.load()
    rnd = random.Random(seed)
    # Subtle noise texture
    for _ in range(int(w * h * 0.02)):
        x = rnd.randrange(w)
        y = rnd.randrange(h)
        v = rnd.randint(-6, 6)
        r, g, b = px[x, y]
        px[x, y] = (max(0, min(255, r + v)), max(0, min(255, g + v)), max(0, min(255, b + v)))
    return img


# ---------------------------------------------------------------------------
# Arabesque / geometric pattern
# ---------------------------------------------------------------------------
def draw_arabesque_border(img: Image.Image, inset=28, thickness=6, color=GOLD):
    """Draw an intricate gold geometric (8-pointed star) border frame."""
    w, h = img.size
    d = ImageDraw.Draw(img, "RGBA")
    # Outer thin line
    d.rectangle([inset, inset, w - inset, h - inset], outline=color + (255,), width=thickness)
    # Inner thin line
    inner = inset + thickness + 8
    d.rectangle([inner, inner, w - inner, h - inner], outline=color + (200,), width=2)
    # 8-pointed star motifs at corners and midpoints
    cx, cy = w / 2, h / 2
    pts = [
        (inset + 20, inset + 20), (w - inset - 20, inset + 20),
        (inset + 20, h - inset - 20), (w - inset - 20, h - inset - 20),
        (cx, inset + 20), (cx, h - inset - 20),
        (inset + 20, cy), (w - inset - 20, cy),
    ]
    for px, py in pts:
        draw_8star(d, px, py, 16, color + (255,), 2)
    # Small diamonds along the border
    step = 40
    for x in range(inset + 40, w - inset, step):
        draw_diamond(d, x, inset + 10, 4, color + (180,))
        draw_diamond(d, x, h - inset - 10, 4, color + (180,))
    for y in range(inset + 40, h - inset, step):
        draw_diamond(d, inset + 10, y, 4, color + (180,))
        draw_diamond(d, w - inset - 10, y, 4, color + (180,))


def draw_8star(d, cx, cy, r, color, width):
    """Draw an 8-pointed star (two overlapping squares)."""
    # Square 1 (axis-aligned)
    d.rectangle([cx - r, cy - r, cx + r, cy + r], outline=color, width=width)
    # Square 2 (rotated 45 deg)
    pts = []
    for i in range(4):
        ang = math.radians(45 + i * 90)
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    d.polygon(pts, outline=color)


def draw_diamond(d, cx, cy, r, color):
    pts = [(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)]
    d.polygon(pts, outline=color)


def draw_radiating_arabesque(img: Image.Image, color=GOLD, alpha=40, spacing=90):
    """Draw a subtle tone-on-tone radiating geometric pattern across the whole image."""
    # Ensure RGBA for compositing
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    w, h = img.size
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    cx, cy = w / 2, h / 2
    # Concentric 8-pointed stars radiating outward
    max_r = math.hypot(w, h) / 2
    r = spacing
    while r < max_r:
        draw_8star(d, cx, cy, r, color + (alpha,), 1)
        r += spacing
    # Radial lines
    n_lines = 16
    for i in range(n_lines):
        ang = math.radians(i * 360.0 / n_lines)
        x2 = cx + max_r * math.cos(ang)
        y2 = cy + max_r * math.sin(ang)
        d.line([cx, cy, x2, y2], fill=color + (alpha // 2,), width=1)
    img.alpha_composite(overlay)
    return img


# ---------------------------------------------------------------------------
# Loading spinner (gold geometric motif)
# ---------------------------------------------------------------------------
def make_spinner(size=64, color=GOLD):
    """A subtle gold 8-pointed star spinner motif (transparent bg)."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = size / 2
    r = size * 0.32
    # 8-pointed star outline
    draw_8star(d, cx, cy, r, color + (255,), 2)
    # Inner circle
    d.ellipse([cx - r * 0.4, cy - r * 0.4, cx + r * 0.4, cy + r * 0.4], outline=color + (255,), width=2)
    return img


# ---------------------------------------------------------------------------
# App Icon
# ---------------------------------------------------------------------------
def generate_app_icon():
    size = 1024
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # 1. Rounded-corner green textured background
    bg = make_green_background((size, size), seed=7)
    # subtle radial vignette
    vignette = Image.new("L", (size, size), 0)
    dv = ImageDraw.Draw(vignette)
    dv.ellipse([-size * 0.2, -size * 0.2, size * 1.2, size * 1.2], fill=60)
    vignette = vignette.filter(ImageFilter.GaussianBlur(120))
    bg = Image.composite(bg, Image.new("RGB", (size, size), GREEN_DEEP), vignette)

    # Rounded corners mask
    mask = Image.new("L", (size, size), 0)
    dm = ImageDraw.Draw(mask)
    radius = int(size * 0.22)
    dm.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    img.paste(bg, (0, 0), mask)

    # 2. Gold arabesque border
    draw_arabesque_border(img, inset=int(size * 0.045), thickness=int(size * 0.006), color=GOLD)

    # 3. Gold calligraphy centerpiece
    font_size = int(size * 0.34)
    text_mask = render_text_mask(WORD, FONT_CALLI, font_size, stroke=int(size * 0.006))
    # Scale to fit nicely
    target_w = int(size * 0.70)
    scale = target_w / text_mask.width
    new_h = int(text_mask.height * scale)
    text_mask = text_mask.resize((target_w, new_h), Image.LANCZOS)

    gradient = make_gold_gradient(text_mask.size, angle=50)
    embossed = emboss_text(text_mask, gradient, depth=int(size * 0.005), light_dir=(1, -1))

    # Soft glow behind calligraphy
    glow = text_mask.filter(ImageFilter.GaussianBlur(int(size * 0.014)))
    glow_rgba = Image.new("RGBA", text_mask.size, (0, 0, 0, 0))
    glow_rgba.putalpha(glow.point(lambda v: int(v * 0.45)))
    glow_rgba = glow_rgba.resize((size, size), Image.LANCZOS)

    # Center the calligraphy
    ox = (size - text_mask.width) // 2
    oy = (size - text_mask.height) // 2
    img.alpha_composite(glow_rgba, (0, 0))
    img.alpha_composite(embossed, (ox, oy))

    # 4. Save
    out = os.path.join(OUT_DIR, "app_icon_1024.png")
    img.save(out)
    print("Saved:", out, img.size)
    return out


# ---------------------------------------------------------------------------
# Splash Screen
# ---------------------------------------------------------------------------
def generate_splash(portrait=True):
    if portrait:
        w, h = 1080, 1920
        name = "splash_portrait_1080x1920.png"
    else:
        w, h = 1920, 1080
        name = "splash_landscape_1920x1080.png"

    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    # 1. Deep green background with radiating arabesque
    bg = make_green_background((w, h), seed=11)
    draw_radiating_arabesque(bg, color=GOLD, alpha=28, spacing=int(min(w, h) * 0.12))
    img.paste(bg, (0, 0))

    # 2. Gold calligraphy (scaled up) with ethereal glow
    font_size = int(min(w, h) * 0.34)
    text_mask = render_text_mask(WORD, FONT_CALLI, font_size, stroke=int(min(w, h) * 0.006))
    target_w = int(min(w, h) * 0.62)
    scale = target_w / text_mask.width
    text_mask = text_mask.resize((int(text_mask.width * scale), int(text_mask.height * scale)), Image.LANCZOS)

    gradient = make_gold_gradient(text_mask.size, angle=50)
    embossed = emboss_text(text_mask, gradient, depth=int(min(w, h) * 0.005), light_dir=(1, -1))

    # Ethereal golden glow
    glow = text_mask.filter(ImageFilter.GaussianBlur(int(min(w, h) * 0.022)))
    glow_rgba = Image.new("RGBA", text_mask.size, (0, 0, 0, 0))
    glow_rgba.putalpha(glow.point(lambda v: int(v * 0.55)))

    # 3. Tagline below
    tag_font_size = int(min(w, h) * 0.055)
    tag_mask = render_text_mask(TAGLINE, FONT_TAG, tag_font_size)
    tag_grad = make_gold_gradient(tag_mask.size, angle=50)
    tag_gold = apply_gold_to_mask(tag_mask, tag_grad)

    # 4. Spinner at bottom
    spinner = make_spinner(int(min(w, h) * 0.05), GOLD)

    # Compose
    cx = w // 2
    # Vertical layout: calligraphy center, tagline below, spinner bottom
    total_h = text_mask.height + tag_mask.height + int(min(w, h) * 0.06)
    start_y = (h - total_h) // 2

    # Glow behind calligraphy (centered)
    img.alpha_composite(glow_rgba, (cx - glow_rgba.width // 2, start_y - glow_rgba.height // 2))
    # Calligraphy
    img.alpha_composite(embossed, (cx - embossed.width // 2, start_y))
    # Tagline
    tag_y = start_y + text_mask.height + int(min(w, h) * 0.03)
    img.alpha_composite(tag_gold, (cx - tag_gold.width // 2, tag_y))
    # Spinner at bottom center
    spin_y = h - spinner.height - int(min(w, h) * 0.06)
    img.alpha_composite(spinner, (cx - spinner.width // 2, spin_y))

    out = os.path.join(OUT_DIR, name)
    img.save(out)
    print("Saved:", out, img.size)
    return out


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    generate_app_icon()
    generate_splash(portrait=True)
    generate_splash(portrait=False)
    print("All brand assets generated in", OUT_DIR)
# Zekr (ذِكْر) — Brand Identity Package

A cohesive, spiritual, and professional visual identity for the **Zekr** Azkar application.

---

## 🎨 Brand Colors

| Role | Name | Hex | RGB |
|------|------|-----|-----|
| Primary | Deep Islamic Green | `#1A4D3A` | `(26, 77, 58)` |
| Secondary | Brushed Gold | `#C5A059` | `(197, 160, 89)` |
| Gold Highlight | Light Gold | `#F0D28C` | `(240, 210, 140)` |
| Gold Shadow | Deep Gold | `#966C28` | `(150, 108, 40)` |
| Green Depth | Dark Green | `#123A2C` | `(18, 58, 44)` |

---

## 🖼️ Asset Inventory

All assets are located in `assets/brand/`:

| File | Dimensions | Purpose |
|------|-----------|---------|
| `app_icon_1024.png` | 1024 × 1024 | App icon (high-res, rounded corners) |
| `splash_portrait_1080x1920.png` | 1080 × 1920 | Splash screen (portrait) |
| `splash_landscape_1920x1080.png` | 1920 × 1080 | Splash screen (landscape) |

### App Icon Composition
- **Background:** Solid, textured Deep Islamic Green (`#1A4D3A`) with subtle radial vignette
- **Centerpiece:** The Arabic word **"ذِكْر"** in ornate gold Thuluth calligraphy
  - Single distinct dot above the Dhal (ذ)
  - No dots under the Kaf (ك) — pure calligraphic form
  - Premium embossed gold effect with gradient sheen
- **Frame:** Intricate gold geometric arabesque border (8-pointed stars + diamonds)
- **Corners:** Softly rounded (22% radius)

### Splash Screen Composition
- **Background:** Seamless deep Islamic green with subtle tone-on-tone radiating geometric arabesque pattern
- **Centerpiece:** The exact same gold Thuluth calligraphy for **"ذِكْر"**, scaled up, with soft ethereal golden glow
- **Tagline:** **"معينك على الذِكْر"** in clean, elegant gold Arabic font (Tajawal), directly below the calligraphy
- **Loading Indicator:** Subtle, minimal spinning gold 8-pointed star motif at the very bottom center
- **Composition:** Minimalist, balanced, with significant negative space for calmness

---

## 📱 OS Launcher Display Name Configuration

The app displays the Arabic name **"ذِكْر"** underneath its icon on the home screen.

### Android (`AndroidManifest.xml`)

```xml
<application
    android:label="ذِكْر"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

### iOS (`Info.plist`)

```xml
<key>CFBundleDisplayName</key>
<string>ذِكْر</string>
```

---

## ✍️ Calligraphy Specification

The word **"ذِكْر"** is rendered with the following Unicode codepoints:

| Letter | Unicode | Description |
|--------|---------|-------------|
| ذ | `U+0630` | Dhal — with **one** dot above |
| ِ | `U+0650` | Kasra (diacritic) |
| ك | `U+0643` | Kaf — **no dots** below (pure Arabic form) |
| ْ | `U+0652` | Sukun (diacritic) |
| ر | `U+0631` | Ra |

**Critical calligraphic rules:**
- ✅ One dot above the Dhal (ذ)
- ✅ No dots under the Kaf (ك) — the pure Arabic calligraphic form (not the Persian dotted form)
- ✅ Correct diacritics: Kasra under Dhal, Sukun over Kaf

---

## 🖋️ Typography

| Usage | Font | Style |
|-------|------|-------|
| Main calligraphy (ذِكْر) | Amiri Bold | Ornate, traditional Naskh/Thuluth-like |
| Tagline (معينك على الذِكْر) | Tajawal Regular | Clean, elegant, modern Arabic |

---

## 🛠️ Regeneration

To regenerate all brand assets, run:

```bash
python tools/generate_brand_assets.py
```

Dependencies: `Pillow`, `arabic_reshaper`, `python-bidi`, and the fonts in `tools/fonts/`.

---

## ✅ Verification Checklist

- [x] No spelling errors in Arabic text
- [x] Diacritic dots historically and grammatically correct (one dot on Dhal, no dots under Kaf)
- [x] Exact tagline **"معينك على الذِكْر"** rendered cleanly
- [x] Color codes consistent between Icon and Splash Screen
- [x] High resolution with clean edges for direct developer handoff
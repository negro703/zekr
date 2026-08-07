# -*- coding: utf-8 -*-
"""Verify the complete brand integration pipeline acceptance criteria."""
import os
import sys

sys.path.insert(0, r"tools")
from PIL import Image

OUT = r"tools/integration_verify.txt"
lines = []

# 1. Verify Android launcher icons generated
mipmap_dir = r"android/app/src/main/res"
icons = []
for root, dirs, files in os.walk(mipmap_dir):
    for f in files:
        if "ic_launcher" in f and f.endswith(".png"):
            icons.append(os.path.join(root, f))
lines.append("Android launcher icons found: %d" % len(icons))
for i in sorted(icons)[:8]:
    img = Image.open(i)
    lines.append("  %s -> %s" % (os.path.relpath(i, mipmap_dir), img.size))

# 2. Verify iOS AppIcon
ios_dir = r"ios/Runner/Assets.xcassets/AppIcon.appiconset"
ios_icons = []
if os.path.exists(ios_dir):
    for f in sorted(os.listdir(ios_dir)):
        if f.endswith(".png"):
            ios_icons.append(f)
lines.append("iOS AppIcon images found: %d" % len(ios_icons))
for f in ios_icons[:5]:
    lines.append("  %s" % f)

# 3. Verify Android splash launch_background updated
for lb_path in [
    r"android/app/src/main/res/drawable/launch_background.xml",
    r"android/app/src/main/res/drawable-v21/launch_background.xml",
]:
    if os.path.exists(lb_path):
        lb = open(lb_path, encoding="utf-8").read()
        has_bitmap = "bitmap" in lb
        lines.append(
            "  %s references bitmap splash: %s"
            % (os.path.basename(lb_path), has_bitmap)
        )

# 4. Verify Android 12 splash styles created
for st_path in [
    r"android/app/src/main/res/values-v31/styles.xml",
    r"android/app/src/main/res/values-night-v31/styles.xml",
]:
    lines.append("  %s exists: %s" % (os.path.basename(st_path), os.path.exists(st_path)))

# 5. Verify app label still Arabic
android = open(r"android/app/src/main/AndroidManifest.xml", encoding="utf-8").read()
ios = open(r"ios/Runner/Info.plist", encoding="utf-8").read()
word = "\u0630\u0650\u0643\u0652\u0631"
lines.append("Android label still Arabic: %s" % (word in android))
lines.append("iOS CFBundleDisplayName still Arabic: %s" % (word in ios))

# 6. Verify iOS launch screen images
ios_launch_dir = r"ios/Runner/Assets.xcassets/LaunchImage.imageset"
if os.path.exists(ios_launch_dir):
    files = [f for f in os.listdir(ios_launch_dir) if f.endswith(".png")]
    lines.append("iOS LaunchImage images: %d" % len(files))
else:
    lines.append("iOS LaunchImage.imageset not found (checking Android style instead)")

# 7. Verify pubspec config exists
pubspec = open(r"pubspec.yaml", encoding="utf-8").read()
lines.append("flutter_launcher_icons configured: %s" % ("flutter_launcher_icons:" in pubspec))
lines.append("flutter_native_splash configured: %s" % ("flutter_native_splash:" in pubspec))

with open(OUT, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
os.write(1, b"Integration verification written to " + OUT.encode("utf-8") + b"\n")
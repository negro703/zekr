# -*- coding: utf-8 -*-
"""Final verification of all brand deliverables."""
import os
import sys

sys.path.insert(0, r"tools")
from PIL import Image

OUT = r"tools/final_verify.txt"
lines = []

# Verify config files contain correct Arabic
android = open(r"android/app/src/main/AndroidManifest.xml", encoding="utf-8").read()
ios = open(r"ios/Runner/Info.plist", encoding="utf-8").read()
word = "\u0630\u0650\u0643\u0652\u0631"  # ذِكْر

lines.append("Android label has Arabic word: %s" % (word in android))
lines.append("iOS CFBundleDisplayName has Arabic word: %s" % (word in ios))

# Verify assets
for f in ["app_icon_1024.png", "splash_portrait_1080x1920.png", "splash_landscape_1920x1080.png"]:
    p = os.path.join(r"assets/brand", f)
    if os.path.exists(p):
        img = Image.open(p)
        lines.append("%s -> %s %s %d bytes" % (f, img.size, img.mode, os.path.getsize(p)))
    else:
        lines.append("%s -> MISSING" % f)

# Verify documentation exists
doc = os.path.join(r"assets/brand", "BRAND_IDENTITY.md")
lines.append("BRAND_IDENTITY.md exists: %s" % os.path.exists(doc))

with open(OUT, "w", encoding="utf-8") as fh:
    fh.write("\n".join(lines))
os.write(1, b"Verification written to " + OUT.encode("utf-8") + b"\n")
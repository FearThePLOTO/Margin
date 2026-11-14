#!/usr/bin/env python3
"""Margin: pixel-art game logo + app icon. Original art.

Usage: python gen_logo.py <godot-project-root>
Writes:
  src/assets/ui/logo.png   (232x60)  the proposal title card: bold cream
                                     "MARGIN", wide spacing, drop shadow and a
                                     dithered warm glow. Prints the letter cut
                                     columns used by main_menu.tscn to reveal
                                     the letters one by one.
  src/assets/ui/icon.png   (64x64)   app icon: Max's portrait on a Mars badge
"""
import math
import os
import sys

import numpy as np
from PIL import Image

INK = (26, 15, 31, 255)
MARS, MARS_SH, MARS_HI = (214, 96, 52, 255), (150, 56, 36, 255), (240, 150, 96, 255)

GLYPHS = {
    "M": ["XX.....XX", "XXX...XXX", "XXXX.XXXX", "XX.XXX.XX", "XX..X..XX",
          "XX.....XX", "XX.....XX", "XX.....XX", "XX.....XX", "XX.....XX"],
    "A": ["..XXXXX..", ".XXXXXXX.", "XXX...XXX", "XX.....XX", "XX.....XX",
          "XXXXXXXXX", "XXXXXXXXX", "XX.....XX", "XX.....XX", "XX.....XX"],
    "R": ["XXXXXXX..", "XXXXXXXX.", "XX....XXX", "XX.....XX", "XX....XXX",
          "XXXXXXXX.", "XXXXXXX..", "XX...XXX.", "XX....XXX", "XX.....XX"],
    "G": ["..XXXXXX.", ".XXXXXXXX", "XXX......", "XX.......", "XX...XXXX",
          "XX...XXXX", "XX.....XX", "XXX...XXX", ".XXXXXXXX", "..XXXXXX."],
    "I": ["XXXXXX", "XXXXXX", "..XX..", "..XX..", "..XX..",
          "..XX..", "..XX..", "..XX..", "XXXXXX", "XXXXXX"],
    "N": ["XX.....XX", "XXX....XX", "XXXX...XX", "XX.XX..XX", "XX..XX.XX",
          "XX...XXXX", "XX....XXX", "XX.....XX", "XX.....XX", "XX.....XX"],
}
SCALE = 3
GAP = 3          # glyph columns between letters (wide, like the proposal title)
W, H = 232, 60
CREAM, CREAM_SH = (251, 239, 223, 255), (231, 199, 164, 255)
GLOW = (255, 160, 90)


def dilate(m, r=1):
    out = m.copy()
    for _ in range(r):
        e = out.copy()
        e[1:, :] |= out[:-1, :]; e[:-1, :] |= out[1:, :]
        e[:, 1:] |= out[:, :-1]; e[:, :-1] |= out[:, 1:]
        out = e
    return out


def logo():
    """The proposal's title card: bold cream MARGIN, wide spacing, dark drop
    shadow and a soft warm glow (dithered so it stays pixel art).
    Returns (image, letter cut columns) for the one-by-one reveal."""
    widths = [len(GLYPHS[c][0]) * SCALE for c in "MARGIN"]
    tw = sum(widths) + GAP * SCALE * 5
    x = (W - tw) // 2
    y0 = (H - 10 * SCALE) // 2 - 1
    m = np.zeros((H, W), bool)
    spans = []
    for ch, w in zip("MARGIN", widths):
        for gy, row in enumerate(GLYPHS[ch]):
            for gx, c in enumerate(row):
                if c == "X":
                    m[y0 + gy * SCALE:y0 + (gy + 1) * SCALE, x + gx * SCALE:x + (gx + 1) * SCALE] = True
        spans.append((x, x + w))
        x += w + GAP * SCALE
    a = np.zeros((H, W, 4), np.uint8)
    # warm glow: 3 dithered rings of decreasing strength
    for r, strength in ((9, 0.10), (6, 0.18), (3, 0.28)):
        ring = dilate(m, r)
        for yy, xx in zip(*np.where(ring)):
            if strength * 4 > BAYER[yy % 4, xx % 4] or strength > 0.25:
                a[yy, xx] = (*GLOW, int(255 * strength * 1.6))
    sh = np.zeros_like(m); sh[3:, :] = m[:-3, :]
    a[sh] = (12, 7, 6, 150)
    a[dilate(m, 1) & ~m & ~sh] = (40, 22, 18, 200)
    rows = np.where(m.any(axis=1))[0]
    bot = rows.max()
    for yy, xx in zip(*np.where(m)):
        a[yy, xx] = CREAM_SH if yy > bot - SCALE else CREAM
    cuts = [0] + [(spans[i][1] + spans[i + 1][0]) // 2 for i in range(5)] + [W]
    return a, cuts


BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0


def icon(root):
    s = 64
    a = np.zeros((s, s, 4), np.uint8)
    for y in range(s):
        for x in range(s):
            d = math.hypot(x + 0.5 - 32, y + 0.5 - 32)
            if d <= 30:
                lit = ((x - 32) * -0.6 + (y - 32) * -0.7) / 30
                a[y, x] = MARS_HI if lit > 0.6 else MARS if lit > -0.3 else MARS_SH
            elif d <= 32:
                a[y, x] = INK
    por = np.array(Image.open(os.path.join(root, "src/assets/char/portraits_64.png")).convert("RGBA"))[:, 0:64]
    m = por[..., 3] > 0
    circle = np.fromfunction(lambda y, x: np.hypot(x + 0.5 - 32, y + 0.5 - 32) <= 30, (s, s))
    a[m & circle] = por[m & circle]
    return a


def main():
    root = os.path.abspath(sys.argv[1])
    out = os.path.join(root, "src/assets/ui")
    os.makedirs(out, exist_ok=True)
    img, cuts = logo()
    Image.fromarray(img, "RGBA").save(os.path.join(out, "logo.png"), optimize=True)
    print("letter cuts:", cuts)
    Image.fromarray(icon(root), "RGBA").save(os.path.join(out, "icon.png"), optimize=True)
    print("OK logo.png %dx%d, icon.png 64x64" % (W, H))


if __name__ == "__main__":
    main()

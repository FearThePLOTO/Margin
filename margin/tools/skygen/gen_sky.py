#!/usr/bin/env python3
"""Margin — Mars sky parallax layers (pixel art, dithered bands, no blur).

Usage: python gen_sky.py <godot-project-root>
Writes src/assets/sky/: sky.png (static), stars.png, moons.png (Phobos +
Deimos), far.png, mid.png, near.png. Layers are 640x180 and tile horizontally.
"""
import math
import os
import sys

import numpy as np
from PIL import Image

W, H = 640, 180
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0
rng = np.random.default_rng(42)


def hexc(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def save(a, root, name):
    out = os.path.join(root, "src/assets/sky")
    os.makedirs(out, exist_ok=True)
    Image.fromarray(a, "RGBA").save(os.path.join(out, name), optimize=True)
    print("OK", name, a.shape[1], "x", a.shape[0])


def sky():
    bands = ["#0a0918", "#120f26", "#1d1634", "#2c1c3c", "#43233f", "#64303e", "#8a4436", "#b0603a", "#cf8448"]
    stops = [0, 34, 62, 84, 102, 118, 132, 146, 160]
    a = np.zeros((H, 320, 4), np.uint8)
    for y in range(H):
        for i in range(len(stops) - 1):
            if stops[i] <= y < stops[i + 1] or i == len(stops) - 2:
                t = (y - stops[i]) / max(1, stops[i + 1] - stops[i])
                break
        t = min(max(t, 0), 1)
        for x in range(320):
            k = i + (1 if t > BAYER[y % 4, x % 4] else 0)
            a[y, x] = hexc(bands[min(k, len(bands) - 1)])
    return a


def stars():
    a = np.zeros((H, W, 4), np.uint8)
    cols = [hexc("#f4f6fa"), hexc("#c4ecfa"), hexc("#fff07a"), hexc("#9aa0b5")]
    for _ in range(260):
        x, y = int(rng.integers(0, W)), int(abs(rng.normal(0, 55)))
        if y >= 125:
            continue
        c = cols[int(rng.integers(0, 4))] if y < 90 else cols[3]
        a[y, x] = c
    for _ in range(9):  # bright sparkle stars
        x, y = int(rng.integers(4, W - 4)), int(rng.integers(6, 70))
        a[y, x] = cols[0]
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            a[y + dy, x + dx] = cols[1]
    return a


def moon(a, cx, cy, rx, ry, seed, craters):
    """Lumpy shaded moon (Phobos/Deimos are potato-shaped)."""
    r2 = np.random.default_rng(seed)
    ramp = [hexc("#2a1f24"), hexc("#5a4640"), hexc("#86705f"), hexc("#b39c84"), hexc("#d8c6a8")]
    bumps = [(r2.uniform(0, 2 * math.pi), r2.uniform(0.04, 0.12)) for _ in range(4)]
    for y in range(int(cy - ry - 3), int(cy + ry + 4)):
        for x in range(int(cx - rx - 3), int(cx + rx + 4)):
            u, v = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            ang = math.atan2(v, u)
            lump = 1 + sum(m * math.cos(3 * ang + p) for p, m in bumps)
            d = math.hypot(u, v) / lump
            if d > 1:
                continue
            nz = math.sqrt(max(0, 1 - d * d))
            light = 0.55 * (-u * -0.7 + -v * -0.4) + 0.65 * nz   # lit from the upper left (the Sun)
            lvl = min(4, max(0, int(light * 4.2 + BAYER[y % 4, x % 4] - 0.3)))
            a[y, x] = ramp[1] if d > 0.93 else ramp[lvl]
    for _ in range(craters):
        ux, uy = r2.uniform(-0.55, 0.55), r2.uniform(-0.5, 0.5)
        cr = r2.uniform(0.12, 0.25)
        for y in range(int(cy - ry), int(cy + ry) + 1):
            for x in range(int(cx - rx), int(cx + rx) + 1):
                u, v = (x + 0.5 - cx) / rx - ux, (y + 0.5 - cy) / ry - uy
                if a[y, x, 3] and u * u + v * v < cr * cr:
                    a[y, x] = ramp[1] if (u + v) < 0 else ramp[3]


def moons():
    a = np.zeros((H, W, 4), np.uint8)
    moon(a, 110, 42, 13, 9, 1, 4)    # Phobos: bigger, closer
    moon(a, 262, 24, 5, 4, 2, 1)     # Deimos: tiny
    return a


def ridge_layer(base_y, amps, body, rim, seed, flat=False):
    a = np.zeros((H, W, 4), np.uint8)
    r2 = np.random.default_rng(seed)
    ph = [r2.uniform(0, 2 * math.pi) for _ in amps]
    for x in range(W):
        h = base_y
        for (k, amp), p in zip(amps, ph):
            h += amp * math.sin(2 * math.pi * k * x / W + p)
        if flat:  # mesas: quantize into plateaus with steep cliffs
            h = base_y + round((h - base_y) / 9) * 9
        h = int(h)
        for y in range(max(0, h), H):
            a[y, x] = rim if y < h + 1 + (1 if (x // 3) % 2 else 0) else body
    return a


def main():
    root = os.path.abspath(sys.argv[1])
    save(sky(), root, "sky.png")
    save(stars(), root, "stars.png")
    save(moons(), root, "moons.png")
    save(ridge_layer(112, [(2, 9), (5, 5), (11, 2)], hexc("#2a1626"), hexc("#4b2333"), 3), root, "far.png")
    save(ridge_layer(128, [(3, 12), (7, 6), (13, 2)], hexc("#4a1e24"), hexc("#7a3027"), 5, flat=True), root, "mid.png")
    save(ridge_layer(150, [(4, 6), (9, 3), (19, 1)], hexc("#76291f"), hexc("#b84a28"), 9), root, "near.png")
    streak = np.zeros((1, 6, 4), np.uint8)
    for x, c in enumerate(["#c98a52", "#e2ad6e", "#f3cf96", "#f3cf96", "#e2ad6e", "#c98a52"]):
        streak[0, x] = hexc(c)
    save(streak, root, "dust_streak.png")


if __name__ == "__main__":
    main()

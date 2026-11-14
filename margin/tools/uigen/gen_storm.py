#!/usr/bin/env python3
"""Margin: dust-storm layers for the main menu (after the proposal's opening,
slide 5, made denser). Original art.

Usage: python gen_storm.py <godot-project-root>   -> src/assets/ui/storm/
  storm_base.png   320x180  night dust sky gradient + faint buried ridges
  storm_cloud.png  320x180  billowing dust cloud (tiles horizontally)
  storm_dash_a.png 160x160  light dust dashes (tiles)
  storm_dash_b.png 160x160  dark dust dashes (tiles)
  storm_vignette.png 320x180 dark dithered edges
"""
import math
import os
import random
import sys

import numpy as np
from PIL import Image

W, H = 320, 180
BAYER8 = np.array([[0, 32, 8, 40, 2, 34, 10, 42], [48, 16, 56, 24, 50, 18, 58, 26],
                   [12, 44, 4, 36, 14, 46, 6, 38], [60, 28, 52, 20, 62, 30, 54, 22],
                   [3, 35, 11, 43, 1, 33, 9, 41], [51, 19, 59, 27, 49, 17, 57, 25],
                   [15, 47, 7, 39, 13, 45, 5, 37], [63, 31, 55, 23, 61, 29, 53, 21]]) / 64.0


def hx(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def periodic_noise(w, h, cells_x, cells_y, seed):
    """Value noise that wraps on both axes (so layers tile seamlessly)."""
    rng = np.random.default_rng(seed)
    g = rng.random((cells_y, cells_x))
    ys = np.arange(h) / h * cells_y
    xs = np.arange(w) / w * cells_x
    y0 = np.floor(ys).astype(int); x0 = np.floor(xs).astype(int)
    fy = ys - y0; fx = xs - x0
    fy = fy * fy * (3 - 2 * fy); fx = fx * fx * (3 - 2 * fx)
    y1 = (y0 + 1) % cells_y; x1 = (x0 + 1) % cells_x
    a = g[y0][:, x0]; b = g[y0][:, x1]; c = g[y1][:, x0]; d = g[y1][:, x1]
    top = a + (b - a) * fx[None, :]
    bot = c + (d - c) * fx[None, :]
    return top + (bot - top) * fy[:, None]


def base(root):
    a = np.zeros((H, W, 4), np.uint8)
    stops = [(0.0, hx("#2e1f2a")), (0.5, hx("#6b4438")), (1.0, hx("#2b2029"))]
    for y in range(H):
        t = y / (H - 1)
        for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
            if t0 <= t <= t1:
                k = (t - t0) / (t1 - t0)
                c = [c0[i] + (c1[i] - c0[i]) * k for i in range(3)]
        for x in range(W):
            j = (BAYER8[y % 8, x % 8] - 0.5) * 6
            a[y, x] = (*(int(max(0, min(255, v + j))) for v in c), 255)
    # faint ridges buried in dust, from the game's own Mars layers
    for name, alpha, tint in (("far", 0.18, hx("#3a2630")), ("mid", 0.32, hx("#2a1c24"))):
        lay = np.array(Image.open(os.path.join(root, "src/assets/sky", name + ".png")).convert("RGBA"))[:, :W]
        m = lay[..., 3] > 0
        for i in range(3):
            a[..., i] = np.where(m, (a[..., i] * (1 - alpha) + tint[i] * alpha).astype(np.uint8), a[..., i])
    return a


def cloud():
    n = periodic_noise(W, H, 6, 4, 1) * 0.55 + periodic_noise(W, H, 12, 7, 2) * 0.30 + periodic_noise(W, H, 28, 14, 3) * 0.15
    a = np.zeros((H, W, 4), np.uint8)
    v = np.clip((n - 0.34) / 0.46, 0, 1) ** 1.3      # lower threshold than the proposal: denser
    for y in range(H):
        for x in range(W):
            k = v[y, x]
            if k <= 0:
                continue
            q = round(k * 4) / 4                      # banded alpha, pixel-art friendly
            if q == 0 and k > BAYER8[y % 8, x % 8] * 0.25:
                q = 0.25
            if q == 0:
                continue
            c = n[y, x]
            a[y, x] = (int(110 + 80 * c), int(66 + 46 * c), int(48 + 34 * c), int(q * 210))
    return a


def dashes(col, density, seed):
    r = random.Random(seed)
    a = np.zeros((160, 160, 4), np.uint8)
    c = hx(col)
    for _ in range(int(160 * 160 * density / 14)):
        x, y, w = r.randrange(160), r.randrange(160), 5 + r.randrange(14)
        for i in range(w):
            a[y, (x + i) % 160] = (*c, 255)
    return a


def vignette():
    a = np.zeros((H, W, 4), np.uint8)
    for y in range(H):
        for x in range(W):
            dx, dy = (x - W / 2) / (W / 2), (y - H / 2) / (H / 2)
            d = math.sqrt(dx * dx * 0.8 + dy * dy)
            k = max(0.0, (d - 0.55) / 0.6)
            q = min(1.0, k) * 0.75
            q = math.floor(q * 4 + BAYER8[y % 8, x % 8]) / 4
            if q > 0:
                a[y, x] = (12, 6, 10, int(min(1.0, q) * 220))
    return a


def main():
    root = os.path.abspath(sys.argv[1])
    out = os.path.join(root, "src/assets/ui/storm")
    os.makedirs(out, exist_ok=True)
    for name, img in (("storm_base", base(root)), ("storm_cloud", cloud()),
                      ("storm_dash_a", dashes("#d9a06a", 0.34, 7)), ("storm_dash_b", dashes("#a86a45", 0.40, 9)),
                      ("storm_vignette", vignette())):
        Image.fromarray(img, "RGBA").save(os.path.join(out, name + ".png"), optimize=True)
    print("OK storm layers ->", out)


if __name__ == "__main__":
    main()

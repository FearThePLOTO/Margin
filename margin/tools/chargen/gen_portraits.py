#!/usr/bin/env python3
"""Margin — 64x64 dialogue portraits in a bold cel-shaded illustration style
(thick outlines, flat 2-tone shading, big expressive eyes). Original art.

Usage: python gen_portraits.py <godot-project-root>
Writes src/assets/char/portraits_64.png, frames left->right:
  0 max_normal 1 max_happy 2 max_scared 3 max_annoyed 4 max_surprised
  5 og_smug    6 og_laugh  7 og_talk    8 og_grin
"""
import math
import os
import sys

import numpy as np
from PIL import Image

S = 64
INK = "#1a0f1f"


def hx(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


class P:
    def __init__(self):
        self.a = np.zeros((S, S, 4), np.uint8)

    def set(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < S and 0 <= y < S:
            self.a[y, x] = hx(c)

    def fill(self, inside, color_fn):
        for y in range(S):
            for x in range(S):
                if inside(x + 0.5, y + 0.5):
                    c = color_fn(x + 0.5, y + 0.5)
                    if c:
                        self.set(x, y, c)

    def ink_edges(self, inside, width=1):
        """Dark line along the inside edge of a shape (bold illustration outline)."""
        for y in range(S):
            for x in range(S):
                px, py = x + 0.5, y + 0.5
                if inside(px, py):
                    for dx, dy in ((width, 0), (-width, 0), (0, width), (0, -width)):
                        if not inside(px + dx, py + dy):
                            self.set(x, y, INK)
                            break

    def outline(self):
        m = self.a[..., 3] > 0
        e = np.zeros_like(m)
        e[1:, :] |= m[:-1, :]; e[:-1, :] |= m[1:, :]; e[:, 1:] |= m[:, :-1]; e[:, :-1] |= m[:, 1:]
        self.a[e & ~m] = hx(INK)

    def line(self, pts, c, thick=1):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
            for i in range(n + 1):
                t = i / max(1, n)
                x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
                for dx in range(thick):
                    for dy in range(thick):
                        self.set(x + dx - thick // 2, y + dy - thick // 2, c)


def ell(cx, cy, rx, ry):
    return lambda x, y: ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1


def union(*fs):
    return lambda x, y: any(f(x, y) for f in fs)


def poly(pts):
    def inside(px, py):
        r = False
        for i in range(len(pts)):
            (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % len(pts)]
            if (y0 <= py < y1) or (y1 <= py < y0):
                if px < x0 + (py - y0) * (x1 - x0) / (y1 - y0):
                    r = not r
        return r
    return inside


def cel(base, shadow, cx, cy, r, light=(-0.6, -0.7), cut=0.15):
    """Flat 2-tone: shadow where the surface faces away from the light."""
    def f(x, y):
        u, v = (x - cx) / r, (y - cy) / r
        return shadow if (u * light[0] + v * light[1]) < -cut else base
    return f


# ------------------------------------------------------------------ MAX ---
# Bust: round helmet bubble fully in frame, face behind a clear visor,
# white suit shoulders with a NASA-blue collar ring at the bottom.
SUIT, SUIT_SH, SUIT_DK = "#f4f6fa", "#c3c9da", "#8d94ab"
SKIN, SKIN_SH = "#f7cfa8", "#dc9d7a"
HAIR, HAIR_SH, HAIR_HI = "#6b3f2a", "#45281b", "#94603f"
GLASS = "#33405f"


def max_portrait(expr):
    p = P()
    lean = {"scared": 1, "surprised": -1}.get(expr, 0)
    # shoulders (bust, cut by the frame bottom)
    body = union(ell(32, 66, 30, 14), poly([(4, 64), (8, 54), (56, 54), (60, 64)]))
    p.fill(body, cel(SUIT, SUIT_SH, 32, 60, 30, light=(-0.8, -0.5), cut=0.3))
    p.ink_edges(body, 2)
    p.fill(ell(14, 59, 4, 3), lambda x, y: "#c8323c")       # mission patch
    p.ink_edges(ell(14, 59, 4, 3), 1)
    collar = ell(32, 53, 17, 5)
    p.fill(collar, lambda x, y: "#2c62c8" if y < 53 else "#1d4594"); p.ink_edges(collar, 1)
    # helmet bubble
    cy = 29 + lean
    helm = ell(32, cy, 25, 25)
    p.fill(helm, cel(SUIT, SUIT_SH, 32, cy, 25, cut=0.5))
    p.ink_edges(helm, 2)
    rim = ell(32, cy + 2, 20, 19)
    p.fill(rim, lambda x, y: "#e8c22a" if y < cy + 2 else "#b98f17")
    glass = ell(32, cy + 2, 17.5, 16.5)
    p.fill(glass, lambda x, y: GLASS)
    p.ink_edges(rim, 1)
    clip = lambda f: (lambda x, y: f(x, y) and glass(x, y))
    fy = cy + 6
    face = ell(32, fy, 13.5, 13)
    p.fill(clip(face), cel(SKIN, SKIN_SH, 32, fy, 13.5, light=(-0.9, -0.3), cut=0.6))
    p.ink_edges(clip(face), 1)
    o = cy - 29
    cap = poly([(16, 31 + o), (19, 21 + o), (27, 15 + o), (38, 15 + o), (46, 21 + o), (48, 31 + o),
                (43, 26 + o), (40, 31 + o), (36, 25 + o), (32, 31 + o), (28, 25 + o), (23, 31 + o), (20, 27 + o)])
    p.fill(clip(cap), lambda x, y: HAIR_SH if x < 22 else HAIR)
    p.ink_edges(clip(cap), 1)
    p.line([(30, 18 + o), (33, 23 + o)], HAIR_HI); p.line([(39, 18 + o), (41, 23 + o)], HAIR_HI)
    for cx in (22, 42):
        p.fill(clip(ell(cx, fy + 5, 2.4, 1.5)), lambda x, y: "#f08f8f")
    ey = fy - 1

    def eye(cx, kind):
        if kind == "closed":
            p.line([(cx - 3, ey + 1), (cx, ey - 2), (cx + 3, ey + 1)], INK, 1)
            return
        ry = {"half": 2.2, "wide": 4.2, "surprised": 4.4}.get(kind, 3.8)
        yy = ey + (1.5 if kind == "half" else 0)
        e = ell(cx, yy, 3.0, ry)
        p.fill(e, lambda x, y: "#ffffff")
        if kind == "wide":
            p.fill(ell(cx, yy + 0.5, 1.0, 1.2), lambda x, y: INK)
        else:
            p.fill(lambda x, y: e(x, y) and ell(cx + 0.5, yy + 0.8, 2.2, 3.0)(x, y),
                   lambda x, y: "#24519b" if y < yy else "#3b7ad9")
            p.fill(ell(cx + 0.6, yy + 0.8, 1.0, 1.5), lambda x, y: INK)
            p.set(cx - 0.8, yy - 1.4, "#ffffff")
        p.ink_edges(e, 1)

    kind = {"normal": "open", "happy": "closed", "scared": "wide", "annoyed": "half", "surprised": "surprised"}[expr]
    eye(26, kind); eye(38, kind)
    b = {"normal": (0, 0), "happy": (-1, -2), "scared": (1, -2), "annoyed": (-1, 2), "surprised": (-3, -3)}[expr]
    by = ey - 6
    p.line([(22, by + b[0]), (29, by + b[1])], HAIR_SH, 1); p.line([(35, by + b[1]), (42, by + b[0])], HAIR_SH, 1)
    my = fy + 7
    if expr == "normal":
        p.line([(29, my), (32, my + 1), (35, my)], INK)
    elif expr == "happy":
        m = poly([(28, my - 1), (37, my - 1), (34.5, my + 3), (30.5, my + 3)])
        p.fill(clip(m), lambda x, y: "#e05a5a" if y > my + 1 else "#7a2230"); p.ink_edges(clip(m), 1)
    elif expr == "scared":
        p.line([(28, my + 1), (30, my - 1), (32, my + 1), (34, my - 1), (36, my + 1)], INK)
        sd = ell(48, cy - 4, 1.8, 2.8); p.fill(sd, lambda x, y: "#a8e4f5"); p.ink_edges(sd, 1)
    elif expr == "annoyed":
        p.line([(29, my + 1), (35, my)], INK)
    else:
        m = ell(32, my + 1, 2, 2.6); p.fill(m, lambda x, y: "#7a2230"); p.ink_edges(m, 1)
    # visor glare
    p.line([(18, cy - 2), (22, cy - 9), (27, cy - 12)], "#dff3ff")
    p.line([(19, cy + 2), (20, cy)], "#dff3ff")
    # helmet shine
    p.line([(13, cy - 8), (18, cy - 17)], "#ffffff", 2)
    return p


# ------------------------------------------------------------------- OG ---
OSK, OSK_SH, OSK_HI = "#eab38c", "#c47f5d", "#f8d5b6"
HAIRW, HAIRW_SH = "#f6f1e4", "#c7bea9"
ROBE, ROBE_SH = "#6a46ad", "#45297a"
GOLDC = "#e8c22a"


def og_portrait(expr):
    """Bust: bald dome, side tufts, cloud brows, round nose, huge beard over a purple robe."""
    p = P()
    lau = expr == "laugh"
    t = -2 if lau else 0
    # robe shoulders
    robe = union(ell(32, 68, 31, 16), poly([(3, 64), (8, 55), (56, 55), (61, 64)]))
    p.fill(robe, lambda x, y: ROBE_SH if x < 22 else ROBE)
    p.ink_edges(robe, 2)
    p.line([(18, 56), (24, 63)], GOLDC, 2); p.line([(46, 56), (40, 63)], GOLDC, 2)
    p.set(9, 60, GOLDC); p.set(55, 60, GOLDC)
    # ears, head, then wispy side hair hugging the head
    for sx in (16, 48):
        ear = ell(sx, 32 + t, 3.4, 4.4)
        p.fill(ear, lambda x, y: OSK_SH); p.ink_edges(ear, 1)
    hcx, hcy = 32, 27 + t
    head = ell(hcx, hcy, 16, 18)
    p.fill(head, cel(OSK, OSK_SH, hcx, hcy, 16, cut=0.5))
    p.ink_edges(head, 2)
    for sx in (18, 46):
        tuft = union(ell(sx, 35 + t, 3.4, 4.6), ell(sx + (-2 if sx < 32 else 2), 31 + t, 2.4, 3))
        p.fill(tuft, lambda x, y: HAIRW_SH if y > 37 + t else HAIRW); p.ink_edges(tuft, 1)
    p.line([(23, 15 + t), (28, 12 + t)], OSK_HI, 2)
    for wy in (17, 20):
        p.line([(29, wy + t), (32, wy - 1 + t), (35, wy + t)], OSK_SH)
    # beard (big, flowing over the robe)
    beard = union(ell(32, 45 + t, 15, 9), ell(32, 53, 12, 9), poly([(24, 56), (40, 56), (32, 63)]))
    p.fill(beard, lambda x, y: HAIRW_SH if x < 25 or y > 58 else HAIRW)
    p.ink_edges(beard, 2)
    for sx, sy in ((27, 52), (32, 55), (37, 52), (30, 59), (34, 59)):
        p.line([(sx, sy), (sx, sy + 2)], HAIRW_SH)
    # mouth
    if lau:
        m = ell(32, 46 + t, 5.5, 4.5)
        p.fill(m, lambda x, y: "#e05a5a" if y > 47 + t else "#5a1a1a"); p.ink_edges(m, 1)
        p.fill(poly([(31, 42.5 + t), (34, 42.5 + t), (34, 44.5 + t), (31, 44.5 + t)]), lambda x, y: "#fffaf0")
    elif expr == "talk":
        m = ell(32, 46, 3.5, 2.6)
        p.fill(m, lambda x, y: "#5a1a1a"); p.ink_edges(m, 1)
    else:
        w = 6 if expr == "grin" else 4
        p.line([(32 - w, 45), (32, 47), (32 + w, 44)], INK)
        if expr == "grin":
            p.fill(poly([(32, 45), (35, 45), (35, 46.5), (32, 46.5)]), lambda x, y: "#fffaf0")
    # moustache
    mous = union(ell(26, 41 + t, 6.5, 3), ell(38, 41 + t, 6.5, 3))
    p.fill(mous, lambda x, y: HAIRW_SH if y > 42 + t else HAIRW); p.ink_edges(mous, 1)
    # nose (centred, below the eyes)
    nose = ell(32, 35 + t, 4, 3.6)
    p.fill(nose, lambda x, y: "#e08f6c" if (x - 32) + (y - 35 - t) > 1.5 else OSK)
    p.ink_edges(nose, 1)
    p.set(31, 34 + t, OSK_HI)
    ey = 29 + t

    def eye(cx):
        if expr in ("laugh", "grin"):
            p.line([(cx - 3, ey + 1), (cx, ey - 2), (cx + 3, ey + 1)], INK)
            if lau:
                te = ell(cx + (4 if cx > 32 else -4), ey + 3, 1.2, 2)
                p.fill(te, lambda x, y: "#9fe0ee"); p.ink_edges(te, 1)
            return
        e = ell(cx, ey, 2.6, 3.2 if expr == "talk" else 2.4)
        p.fill(e, lambda x, y: "#fffaf0")
        p.fill(ell(cx + 0.5, ey + 0.4, 1.3, 1.7), lambda x, y: INK)
        p.ink_edges(e, 1)
        if expr == "smug":   # heavy half-closed lids
            p.line([(cx - 3, ey - 1), (cx + 3, ey - 1)], OSK_SH)
            p.line([(cx - 3, ey - 2), (cx + 3, ey - 2)], INK)
    eye(26); eye(38)
    lift = -2 if expr in ("laugh", "talk") else 0
    for cx, d in ((25, -1), (39, 1)):
        by = 23 + t + lift + (1 if expr == "smug" and d < 0 else 0)
        b = union(ell(cx - 3, by + 1, 3.6, 2.4), ell(cx, by, 3.8, 2.8), ell(cx + 3, by + 1, 3.6, 2.4))
        p.fill(b, lambda x, y: HAIRW_SH if y > by + 1 else HAIRW); p.ink_edges(b, 1)
    # magic sparkles
    for i, (sx, sy) in enumerate(((56, 9), (8, 12), (58, 24))):
        if lau or expr == "grin" or i == 0:
            p.set(sx, sy, "#e9fff9")
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1), (2, 0), (-2, 0), (0, 2), (0, -2)):
                p.set(sx + dx, sy + dy, "#66d9c0" if abs(dx) + abs(dy) == 2 else "#b5f5e4")
    return p


def main():
    root = os.path.abspath(sys.argv[1])
    frames = [max_portrait(e).a for e in ("normal", "happy", "scared", "annoyed", "surprised")] + \
             [og_portrait(e).a for e in ("smug", "laugh", "talk", "grin")]
    strip = np.concatenate(frames, axis=1)
    Image.fromarray(strip, "RGBA").save(os.path.join(root, "src/assets/char/portraits_64.png"), optimize=True)
    print("OK portraits_64.png", strip.shape[1], "x", strip.shape[0])


if __name__ == "__main__":
    main()

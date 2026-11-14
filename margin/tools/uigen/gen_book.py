#!/usr/bin/env python3
"""Margin — pixel-art open book for the Book of Books (304x168).

Usage: python gen_book.py <godot-project-root>  -> src/assets/ui/book.png, book_page.png
Page content rects (used by book_screen.tscn):
  left page  x 16..146, y 12..156     right page x 158..288, y 12..156
"""
import os
import sys

import numpy as np
from PIL import Image

W, H = 304, 168
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0


def hx(h):
    h = h.lstrip("#")
    return np.array([int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255], np.uint8)


INK, LEATHER, LEATHER_SH, LEATHER_HI = hx("#1a0f1f"), hx("#6b2d1f"), hx("#45190f"), hx("#8e4129")
GOLD, GOLD_SH = hx("#e8c22a"), hx("#a8841a")
PAGE, PAGE_SH, PAGE_DK, EDGE = hx("#f1e6c8"), hx("#dccb9f"), hx("#c2ad7c"), hx("#e3d4ab")
RIBBON, RIBBON_SH = hx("#c8323c"), hx("#8a1f28")


def book():
    a = np.zeros((H, W, 4), np.uint8)
    # leather cover with rounded corners
    for y in range(H):
        for x in range(W):
            corner = min(x, W - 1 - x) < 4 and min(y, H - 1 - y) < 4 and (min(x, W - 1 - x) + min(y, H - 1 - y)) < 4
            if corner:
                continue
            edge = x in (0, W - 1) or y in (0, H - 1)
            a[y, x] = INK if edge else (LEATHER_HI if y < 3 else LEATHER_SH if y > H - 4 else LEATHER)
    # page stacks (outer edges) then pages
    for side in (0, 1):
        x0, x1 = (8, 151) if side == 0 else (153, 296)
        for y in range(6, H - 6):
            for x in range(x0, x1):
                a[y, x] = EDGE if (y % 2 == 0) else PAGE_SH
        px0, px1 = (11, 151) if side == 0 else (153, 293)
        for y in range(8, H - 9):
            for x in range(px0, px1):
                d = (151 - x) if side == 0 else (x - 153)   # distance from the spine
                t = 1.0 - min(d, 14) / 14.0
                c = PAGE
                if t > BAYER[y % 4, x % 4] * 0.9 + 0.1:
                    c = PAGE_SH if t < 0.7 else PAGE_DK
                a[y, x] = c
        for y in range(8, H - 9):
            a[y, px0 - 1] = INK if side == 0 else a[y, px0 - 1]
            a[y, px1] = INK if side == 1 else a[y, px1]
        for x in range(px0, px1):
            a[7, x] = INK
            a[H - 9, x] = INK
    for y in range(6, H - 6):   # spine
        a[y, 151] = INK
        a[y, 152] = PAGE_DK
    # gold corner pieces
    for cx, cy, sx, sy in ((1, 1, 1, 1), (W - 2, 1, -1, 1), (1, H - 2, 1, -1), (W - 2, H - 2, -1, -1)):
        for i in range(7):
            for j in range(7 - i):
                a[cy + sy * j, cx + sx * i] = GOLD if (i + j) < 5 else GOLD_SH
    # ribbon bookmark hanging from the right page
    for y in range(5, H + 0):
        for x in range(240, 245):
            if y < H - 1 or x in (241, 242, 243):
                a[min(y, H - 1), x] = RIBBON_SH if x == 244 else RIBBON
    a[H - 1, 240] = 0; a[H - 1, 244] = 0
    return a


def page():
    """A single blank page, used for the page-turn animation."""
    p = np.zeros((H - 16, 141, 4), np.uint8)
    p[:] = PAGE
    p[:, 0] = INK
    p[0, :] = INK
    p[-1, :] = INK
    p[:, -1] = INK
    for y in range(1, p.shape[0] - 1):
        for x in range(1, 12):
            if (1 - x / 12) > BAYER[y % 4, x % 4] * 0.9 + 0.1:
                p[y, x] = PAGE_SH
    return p


def main():
    root = os.path.abspath(sys.argv[1])
    out = os.path.join(root, "src/assets/ui")
    os.makedirs(out, exist_ok=True)
    Image.fromarray(book(), "RGBA").save(os.path.join(out, "book.png"), optimize=True)
    Image.fromarray(page(), "RGBA").save(os.path.join(out, "book_page.png"), optimize=True)
    print("OK book.png 304x168, book_page.png")


if __name__ == "__main__":
    main()

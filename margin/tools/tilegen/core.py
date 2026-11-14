"""Canvas, hashing and the distance-field terrain renderer."""
import math
import numpy as np
from PIL import Image
from palette import IDX, RGBA, LEGEND

T = 16


def H(*a):
    """Deterministic 32-bit hash."""
    x = 0x9E3779B9
    for v in a:
        x = ((x ^ (int(v) & 0xFFFFFFFF)) * 0x85EBCA6B) & 0xFFFFFFFF
        x ^= x >> 13
    x = (x * 0xC2B2AE35) & 0xFFFFFFFF
    x ^= x >> 16
    return x


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.a = np.zeros((h, w), np.uint8)

    # -- primitives ------------------------------------------------------
    def set(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.a[y, x] = 0 if c is None else IDX[c]

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.a[y, x]
        return 0

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.set(xx, yy, c)

    def hline(self, x0, x1, y, c):
        for x in range(x0, x1 + 1):
            self.set(x, y, c)

    def vline(self, x, y0, y1, c):
        for y in range(y0, y1 + 1):
            self.set(x, y, c)

    def line(self, x0, y0, x1, y1, c):
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            self.set(x0, y0, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def ascii(self, ox, oy, rows, legend=LEGEND, subs=None):
        w = len(rows[0])
        for r, row in enumerate(rows):
            assert len(row) == w, f"ascii row {r} has len {len(row)} != {w}: {row!r}"
            for c, ch in enumerate(row):
                if subs and ch in subs:
                    name = subs[ch]
                else:
                    name = legend[ch]
                if name is not None:
                    self.set(ox + c, oy + r, name)

    def paste(self, other, ox, oy):
        h, w = other.a.shape
        sx0, sy0 = max(0, -ox), max(0, -oy)
        sx1, sy1 = min(w, self.w - ox), min(h, self.h - oy)
        if sx0 >= sx1 or sy0 >= sy1:
            return
        src = other.a[sy0:sy1, sx0:sx1]
        sub = self.a[oy + sy0:oy + sy1, ox + sx0:ox + sx1]
        m = src > 0
        sub[m] = src[m]

    def crop(self, x, y, w, h):
        c = Canvas(w, h)
        c.a = self.a[y:y + h, x:x + w].copy()
        return c

    def flip_h(self):
        c = Canvas(self.w, self.h)
        c.a = self.a[:, ::-1].copy()
        return c

    def flip_v(self):
        c = Canvas(self.w, self.h)
        c.a = self.a[::-1, :].copy()
        return c

    def shade(self, mask, ox, oy, ramp, light=(-1, -1)):
        """Shade a boolean mask: ramp = [outline, dark, mid, light, highlight].
        Light comes from `light` direction (default top-left)."""
        h, w = mask.shape
        lx, ly = light

        def m(x, y):
            return 0 <= x < w and 0 <= y < h and mask[y, x]

        for y in range(h):
            for x in range(w):
                if not mask[y, x]:
                    continue
                if not (m(x - 1, y) and m(x + 1, y) and m(x, y - 1) and m(x, y + 1)):
                    c = ramp[0]
                elif not m(x + lx, y + ly):
                    c = ramp[4]
                elif not m(x + 2 * lx, y + 2 * ly) or not m(x + lx, y):
                    c = ramp[3]
                elif not m(x - lx, y - ly) or not m(x - 2 * lx, y - 2 * ly):
                    c = ramp[1]
                else:
                    c = ramp[2]
                if c is not None:
                    self.set(ox + x, oy + y, c)

    def to_image(self):
        return Image.fromarray(RGBA[self.a], "RGBA")


def ellipse_mask(w, h, cx=None, cy=None, rx=None, ry=None):
    cx = (w - 1) / 2 if cx is None else cx
    cy = (h - 1) / 2 if cy is None else cy
    rx = w / 2 if rx is None else rx
    ry = h / 2 if ry is None else ry
    yy, xx = np.mgrid[0:h, 0:w]
    return ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1.0


def poly_mask(w, h, pts):
    """Even-odd polygon fill sampled at pixel centers."""
    m = np.zeros((h, w), bool)
    n = len(pts)
    for y in range(h):
        py = y + 0.5
        xs = []
        for i in range(n):
            x0, y0 = pts[i]
            x1, y1 = pts[(i + 1) % n]
            if (y0 <= py < y1) or (y1 <= py < y0):
                xs.append(x0 + (py - y0) * (x1 - x0) / (y1 - y0))
        xs.sort()
        for i in range(0, len(xs) - 1, 2):
            for x in range(w):
                if xs[i] <= x + 0.5 < xs[i + 1]:
                    m[y, x] = True
    return m


# ---------------------------------------------------------------------------
# Terrain renderer: every solid pixel is coloured by its distance to the
# nearest empty pixel and by which way that empty pixel faces (top/side/bottom).
# ---------------------------------------------------------------------------
_OFFS = []
for _dy in range(-7, 8):
    for _dx in range(-7, 8):
        if _dx == 0 and _dy == 0:
            continue
        _d = math.hypot(_dx, _dy)
        if _d > 7.0:
            continue
        if _dy < 0 and -_dy >= abs(_dx):
            _f, _p = "top", 0
        elif _dy > 0 and _dy >= abs(_dx):
            _f, _p = "bottom", 2
        else:
            _f, _p = ("left" if _dx < 0 else "right"), 1
        _OFFS.append((_d, _p, _dx, _dy, _f))
_OFFS.sort()


def render_terrain(occ, terrain, x0, y0, w, h, variant=0):
    """occ: bool array (solid). Renders region [x0:x0+w, y0:y0+h] of occ.
    Outside occ counts as solid. Returns Canvas(w, h)."""
    oh, ow = occ.shape
    cv = Canvas(w, h)
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            if not occ[y, x]:
                continue
            face, depth = None, 99
            for d, _p, dx, dy, f in _OFFS:
                xx, yy = x + dx, y + dy
                if 0 <= xx < ow and 0 <= yy < oh and not occ[yy, xx]:
                    face, depth = f, int(round(d))
                    break
            c = terrain.color(face, depth, (x - x0) % T, (y - y0) % T, x - x0, variant)
            cv.set(x - x0, y - y0, c)
    return cv

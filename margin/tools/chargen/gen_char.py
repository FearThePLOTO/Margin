#!/usr/bin/env python3
"""Margin — astronaut + OG NPC sprite sheets (24x24 canvas, 16px body, faces RIGHT).

Usage: python gen_char.py <godot-project-root>

Canvas follows Eris Esra's Character Template 4.1 convention (16x16 sprites on a
24x24 canvas so squash/stretch and limbs have room). Feet rest on row 23.
Rows = animations, columns = frames. Clean atlas has NO labels; the labelled
copy lives in Previews/.
"""
import json
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

C = 24  # cell size

PAL = {
    "K": "#0e0912",  # outline
    "W": "#f4f6fa", "w": "#d4d8e3", "g": "#9aa0b5", "G": "#62677e",
    "B": "#3d6fd1", "b": "#26408f",          # suit blue
    "V": "#123a40", "v": "#0a2026",          # visor
    "c": "#66d9c0", "x": "#b5f5e4",          # visor highlights
    "O": "#f2731f", "o": "#b5521a",          # orange accents
    # OG palette
    "R": "#c7782e", "r": "#8f4f1f", "Y": "#e8c22a", "y": "#a8841a", "H": "#ece4d0",
    # classic-suit + wizard additions
    "U": "#6e4f10", "D": "#c8323c", "F": "#e9b48f", "f": "#b97a5c", "h": "#c4bcaa",
    "P": "#5c3d99", "p": "#3b2668", "T": "#7a4b26", "t": "#4e2f17", "M": "#5a1a1a",
}
IDX = {k: i + 1 for i, k in enumerate(PAL)}
RGBA = np.zeros((len(PAL) + 1, 4), np.uint8)
for k, i in IDX.items():
    h = PAL[k][1:]
    RGBA[i] = [int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255]

SUITS = {
    "astro": dict(helm="W", helm_sh="w", helm_dk="g", body="W", body_sh="w", band="w", band_dk="g",
                  leg="W", leg_back="w", boot="g", boot_back="G", arm="W", arm_back="w", glove="w",
                  pack="w", pack_dk="g", light="D", visor="Y", visor_dk="y", vis_hi="W", vis_hi2="U"),
    "og": dict(helm="w", helm_sh="g", helm_dk="G", body="R", body_sh="r", band="o", band_dk="r",
               leg="r", leg_back="o", boot="G", boot_back="K", arm="R", arm_back="r", glove="w",
               pack="G", pack_dk="K", light="Y", visor="Y", visor_dk="y", vis_hi="H", vis_hi2="W"),
}


class Cel:
    def __init__(self):
        self.a = np.zeros((C, C), np.uint8)

    def set(self, x, y, k):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < C and 0 <= y < C:
            self.a[y, x] = IDX[k]

    def get(self, x, y):
        return self.a[y, x] if 0 <= x < C and 0 <= y < C else 0

    def rect(self, x, y, w, h, k):
        for yy in range(int(y), int(y + h)):
            for xx in range(int(x), int(x + w)):
                self.set(xx, yy, k)

    def limb(self, a, b, k, tip=None, tip_len=1):
        """2-px thick limb from a to b; last `tip_len` steps coloured `tip`."""
        x0, y0 = int(round(a[0])), int(round(a[1]))
        x1, y1 = int(round(b[0])), int(round(b[1]))
        pts = []
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            pts.append((x0, y0))
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy
        vertical = abs(b[1] - a[1]) >= abs(b[0] - a[0])
        for i, (x, y) in enumerate(pts):
            kk = tip if (tip and i >= len(pts) - tip_len) else k
            self.set(x, y, kk)
            if vertical:
                self.set(x + 1, y, kk)
            else:
                self.set(x, y + 1, kk)

    def outline(self):
        m = self.a > 0
        out = np.zeros_like(m)
        out[1:, :] |= m[:-1, :]
        out[:-1, :] |= m[1:, :]
        out[:, 1:] |= m[:, :-1]
        out[:, :-1] |= m[:, 1:]
        self.a[out & ~m] = IDX["K"]


def helmet(cel, cx, cy, s, sq=0.0, og=False):
    """Classic EVA helmet: round white shell, big gold visor facing right."""
    rx, ry = 4.8, 4.5 + sq
    for y in range(C):
        for x in range(C):
            u, v = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            if u * u + v * v <= 1.0:
                k = s["helm"]
                if (u < -0.4 and v > 0.0) or v > 0.75:
                    k = s["helm_sh"]
                if u < -0.75 and v > 0.35:
                    k = s["helm_dk"]
                cel.set(x, y, k)
    # visor: ellipse pushed forward (right)
    vcx, vcy, vrx, vry = cx + 1.7, cy + 0.2 + sq * 0.3, 3.0, 2.7 + sq * 0.5
    for y in range(C):
        for x in range(C):
            u, v = (x + 0.5 - vcx) / vrx, (y + 0.5 - vcy) / vry
            d = u * u + v * v
            if d <= 1.0:
                k = s["visor"]
                if v > 0.25 or u > 0.55:
                    k = s["visor_dk"]
                if d > 0.72 and (v > 0.2 or u < -0.6):
                    k = s["vis_hi2"]
                cel.set(x, y, k)
    cel.set(vcx - 1.2, vcy - 1.2, s["vis_hi"])  # glint
    cel.set(vcx - 0.2, vcy - 1.6, s["vis_hi"])
    # neck ring
    for x in range(int(cx - 2), int(cx + 3)):
        cel.set(x, cy + ry - 0.3, s["helm_dk"])


def draw(p, suit="astro"):
    """p: dict pose. Coordinates for a right-facing character, feet on row 23."""
    s = SUITS[suit]
    cel = Cel()
    dy = p.get("dy", 0)        # body drop (crouch +, stretch -)
    hdy = p.get("hdy", 0)      # extra head offset
    lean = p.get("lean", 0)    # upper body x shift
    sq = p.get("sq", 0.0)      # helmet squash (-) / stretch (+)
    tx, ty = 9 + lean, 16 + dy  # torso top-left (6x4)
    hip_b, hip_f = (tx + 1, ty + 4), (tx + 3, ty + 4)
    sh_b, sh_f = (tx + 0, ty + 0), (tx + 4, ty + 0)

    # back arm, back leg
    bh = p["bh"]
    cel.limb(sh_b, (sh_b[0] + bh[0], sh_b[1] + bh[1]), s["arm_back"], s["glove"] if suit == "og" else "w")
    bf = p["bf"]
    cel.limb(hip_b, bf, s["leg_back"], s["boot_back"], 2 if p.get("boots", True) else 1)
    # backpack
    px = tx - 3 + p.get("pack_dx", 0)
    cel.rect(px, ty - 3, 3, 6, s["pack"])
    cel.rect(px, ty + 2, 3, 1, s["pack_dk"])
    cel.set(px + 1, ty - 2, s["light"])
    # torso
    cel.rect(tx, ty, 6, 4, s["body"])
    cel.rect(tx, ty + 3, 6, 1, s["body_sh"])
    cel.rect(tx + 2, ty + 1, 3, 2, s["band_dk"])   # chest control box
    cel.set(tx + 2, ty + 1, s["light"])
    cel.set(tx + 4, ty + 1, "B")
    # front leg
    ff = p["ff"]
    cel.limb(hip_f, ff, s["leg"], s["boot"], 2 if p.get("boots", True) else 1)
    cel.outline()
    # helmet and front arm get their own outline so they read against the white suit
    head = Cel()
    helmet(head, tx + 3.5 + p.get("hdx", 0), ty - 4.2 + hdy, s, sq, og=(suit == "og"))
    head.outline()
    _over(cel, head)
    arm = Cel()
    fh = p["fh"]
    arm.limb(sh_f, (sh_f[0] + fh[0], sh_f[1] + fh[1]), s["arm"], s["glove"])
    arm.outline()
    # the arm's outline only matters where it crosses the body: keep inner edges
    _over(cel, arm)
    return cel


def _over(dst, src):
    m = src.a > 0
    dst.a[m] = src.a[m]


# ------------------------------------------------------------------ poses
def stand(**k):
    p = dict(dy=0, bf=(10, 22), ff=(13, 22), bh=(-1, 3), fh=(1, 3))
    p.update(k)
    return p


def walk_frame(i):
    a = 2 * math.pi * i / 6
    fx = 11.5 + 2.6 * math.cos(a)
    bx = 11.5 - 2.6 * math.cos(a)
    fy = 22 - (1 if math.sin(a) > 0.4 else 0)
    by = 22 - (1 if math.sin(a) < -0.4 else 0)
    bob = 1 if abs(math.cos(a)) < 0.6 else 0
    return stand(dy=-bob + 0, hdy=0, bf=(round(bx), by), ff=(round(fx), fy),
                 fh=(round(-1.6 * math.cos(a)) + 1, 3), bh=(round(1.6 * math.cos(a)) - 1, 3))


ASTRO_ANIMS = [
    ("idle", [stand(), stand(hdy=0), stand(dy=1, sq=-0.3), stand(dy=1, sq=-0.3)], 6, True),
    ("walk", [walk_frame(i) for i in range(6)], 12, True),
    # Celeste-style airborne reactions: streamlined going up, flailing coming down
    ("takeoff", [stand(dy=2, sq=-0.6, bh=(-2, 2), fh=(1, 3), bf=(9, 22), ff=(14, 22)),
                 stand(dy=0, sq=0.0, bh=(-2, 3), fh=(0, 4), bf=(10, 22), ff=(13, 22)),
                 stand(dy=-2, sq=0.5, bh=(-1, 4), fh=(0, 4), bf=(11, 22), ff=(12, 22))], 16, False),
    ("rise", [stand(dy=-2, sq=0.5, bh=(-1, 4), fh=(0, 4), bf=(11, 22), ff=(12, 22)),
              stand(dy=-2, sq=0.4, bh=(-2, 4), fh=(0, 4), bf=(10, 22), ff=(12, 21)),
              stand(dy=-2, sq=0.4, bh=(-1, 4), fh=(1, 4), bf=(11, 21), ff=(12, 22))], 10, True),
    ("apex", [stand(dy=-1, bh=(-3, 1), fh=(3, 1), bf=(10, 20), ff=(14, 20)),
              stand(dy=-1, hdy=-1, bh=(-3, 0), fh=(3, 0), bf=(10, 20), ff=(14, 21))], 8, True),
    ("fall", [stand(dy=-1, sq=0.2, bh=(-3, -3), fh=(3, -3), bf=(9, 22), ff=(15, 22)),
              stand(dy=-1, sq=0.2, bh=(-3, -2), fh=(3, -4), bf=(9, 22), ff=(15, 21)),
              stand(dy=-1, sq=0.2, bh=(-3, -4), fh=(3, -2), bf=(10, 22), ff=(14, 22))], 10, True),
    ("land", [stand(dy=3, sq=-0.8, bh=(-3, 2), fh=(3, 2), bf=(9, 22), ff=(15, 22)),
              stand(dy=1, sq=-0.4, bh=(-2, 3), fh=(2, 3), bf=(10, 22), ff=(14, 22)),
              stand(dy=0)], 16, False),
    ("thrust", [stand(dy=1, sq=-0.4, bh=(-2, 2), fh=(1, 3), bf=(10, 21), ff=(13, 21)),
                stand(dy=-2, sq=0.6, bh=(-2, 3), fh=(0, 4), bf=(11, 22), ff=(12, 22), pack_dx=-1),
                stand(dy=-2, sq=0.6, bh=(-3, 3), fh=(-1, 4), bf=(11, 22), ff=(12, 21), pack_dx=-1),
                stand(dy=-2, sq=0.5, bh=(-2, 3), fh=(0, 4), bf=(11, 21), ff=(12, 22), pack_dx=-1),
                stand(dy=-1, sq=0.3, bh=(-3, 2), fh=(1, 3), bf=(10, 22), ff=(13, 21))], 14, True),
    ("slide", [stand(dy=2, lean=-1, bh=(-3, 2), fh=(3, 1), bf=(9, 22), ff=(15, 22)),
               stand(dy=3, lean=-3, hdx=-1, bh=(-3, 4), fh=(4, -1), bf=(9, 22), ff=(18, 22)),
               stand(dy=3, lean=-3, hdx=-1, hdy=1, bh=(-3, 4), fh=(4, -2), bf=(9, 22), ff=(19, 22)),
               stand(dy=3, lean=-3, hdx=-1, bh=(-3, 4), fh=(4, -1), bf=(9, 22), ff=(18, 22)),
               stand(dy=2, lean=-1, bh=(-3, 2), fh=(3, 1), bf=(10, 22), ff=(15, 22))], 14, False),
]


def og_laugh(i):
    shake = [0, 1, 0, 1][i]
    return stand(dy=1 + shake, sq=-0.3 * shake, lean=-1 + (i % 2), hdy=-shake,
                 bh=(1, 2), fh=(-1, 2 + shake),  # hand slapping belly
                 bf=(10, 22), ff=(13, 22))


OG_ANIMS = [
    ("idle", [stand(dy=1, lean=-1, bh=(-1, 3), fh=(2, 3)), stand(dy=1, lean=-1, hdy=1, bh=(-1, 3), fh=(2, 3)),
              stand(dy=1, lean=-1, hdy=1, bh=(-1, 3), fh=(2, 3)), stand(dy=1, lean=-1, bh=(-1, 3), fh=(2, 3))], 4, True),
    ("laugh", [og_laugh(i) for i in range(4)], 10, True),
    ("point", [stand(dy=1, lean=-1, bh=(-1, 3), fh=(4, -1)), stand(dy=1, lean=-1, hdy=-1, bh=(-1, 3), fh=(4, -2))], 6, True),
]


def build(anims, suit):
    cols = max(len(f) for _, f, _, _ in anims)
    sheet = np.zeros((len(anims) * C, cols * C), np.uint8)
    meta = []
    for r, (name, frames, fps, loop) in enumerate(anims):
        for c, p in enumerate(frames):
            sheet[r * C:(r + 1) * C, c * C:(c + 1) * C] = draw(p, suit).a
        meta.append({"name": name, "row": r, "frames": len(frames), "fps": fps, "loop": loop})
    return sheet, meta


def to_img(a):
    return Image.fromarray(RGBA[a], "RGBA")


def labelled(a, meta, title, path, scale=6):
    img = to_img(a).resize((a.shape[1] * scale, a.shape[0] * scale), Image.NEAREST)
    lab = 14
    out = Image.new("RGBA", (img.width + 120, img.height + len(meta) * lab + 30), (34, 30, 44, 255))
    d = ImageDraw.Draw(out)
    d.text((8, 6), title, fill=(102, 217, 192, 255))
    for m in meta:
        oy = 26 + m["row"] * (C * scale + lab)
        d.text((8, oy), f'{m["name"]}  ({m["frames"]}f @ {m["fps"]}fps{" loop" if m["loop"] else ""})',
               fill=(242, 115, 31, 255))
        row = img.crop((0, m["row"] * C * scale, img.width, (m["row"] + 1) * C * scale))
        for c in range(m["frames"]):
            d.rectangle([8 + c * C * scale, oy + lab, 8 + (c + 1) * C * scale - 1, oy + lab + C * scale - 1],
                        fill=(46, 40, 58, 255), outline=(80, 70, 96, 255))
        out.alpha_composite(row, (8, oy + lab))
    out.save(path)


def validate(path, cols, rows):
    im = Image.open(path)
    a = np.asarray(im)
    assert im.mode == "RGBA" and im.size == (cols * C, rows * C), im.size
    assert set(np.unique(a[..., 3]).tolist()) <= {0, 255}
    opaque = {tuple(c) for c in a[a[..., 3] == 255][:, :3].tolist()}
    allowed = {tuple(RGBA[i][:3]) for i in range(1, len(RGBA))}
    assert opaque <= allowed, opaque - allowed
    return f"OK {os.path.basename(path)} {im.size[0]}x{im.size[1]} = {cols}x{rows} cells of {C}x{C}"


def main():
    root = os.path.abspath(sys.argv[1])
    out = os.path.join(root, "src/assets/char")
    prev = os.path.join(out, "Previews")
    os.makedirs(prev, exist_ok=True)
    open(os.path.join(prev, ".gdignore"), "w").close()
    index = {}
    for key, anims, suit, title in (("astronaut", ASTRO_ANIMS, "astro", "Astronaut (faces right, flip_h for left)"),
                                    ("og_npc", OG_ANIMS, "og", "OG - the Old Geologist")):
        a, meta = build(anims, suit)
        path = os.path.join(out, f"{key}_24.png")
        to_img(a).save(path, optimize=True)
        print(validate(path, a.shape[1] // C, a.shape[0] // C))
        labelled(a, meta, title, os.path.join(prev, f"{key}_labelled.png"))
        index[key] = {"png": f"res://src/assets/char/{key}_24.png", "cell": C, "animations": meta}
    with open(os.path.join(prev, "char_index.json"), "w") as f:
        json.dump(index, f, indent=1)
    return index


if __name__ == "__main__":
    main()


# ------------------------------------------------------------ extras ------
class Canvas2(Cel):
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.a = np.zeros((h, w), np.uint8)

    def set(self, x, y, k):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            self.a[y, x] = IDX[k]

    def line(self, x0, y0, x1, y1, k):
        n = max(abs(x1 - x0), abs(y1 - y0)) + 1
        for i in range(n):
            t = i / max(1, n - 1)
            self.set(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, k)

    def outline(self):
        m = self.a > 0
        out = np.zeros_like(m)
        out[1:, :] |= m[:-1, :]
        out[:-1, :] |= m[1:, :]
        out[:, 1:] |= m[:, :-1]
        out[:, :-1] |= m[:, 1:]
        self.a[out & ~m] = IDX["K"]


def lander():
    c = Canvas2(48, 40)
    for dx in (0, 1):  # legs
        c.line(14 + dx, 26, 6 + dx, 36, "G")
        c.line(33 - dx, 26, 41 - dx, 36, "G")
    c.rect(3, 37, 7, 2, "g"); c.rect(38, 37, 7, 2, "g")
    c.rect(20, 29, 8, 2, "G"); c.rect(19, 31, 10, 2, "g")      # nozzle
    for y in range(2, 9):                                        # nose cone
        half = 4 + (y - 2) * 7 // 6
        c.rect(24 - half, y, half * 2, 1, "W" if y > 3 else "w")
    c.rect(12, 9, 24, 20, "W")                                   # body
    c.rect(30, 9, 6, 20, "w"); c.rect(34, 9, 2, 20, "g")
    c.rect(12, 22, 24, 2, "O"); c.rect(12, 24, 24, 1, "o")       # stripe
    c.rect(15, 12, 6, 5, "V"); c.set(16, 12, "x"); c.set(17, 13, "c")  # window
    c.rect(26, 14, 7, 14, "v"); c.rect(27, 15, 5, 12, "K")       # open hatch
    c.rect(26, 14, 7, 1, "O"); c.rect(26, 14, 1, 14, "O")
    c.rect(13, 26, 2, 1, "B"); c.rect(16, 26, 2, 1, "B")         # mission marks
    c.set(24, 0, "O"); c.set(24, 1, "g")                         # antenna
    for y in range(29, 39, 2):                                   # ladder
        c.rect(33, y, 3, 1, "g")
    c.line(33, 28, 33, 38, "G"); c.line(36, 28, 36, 38, "G")
    c.outline()
    return c


def mission_control_portrait():
    c = Canvas2(24, 24)
    c.rect(2, 3, 20, 16, "G"); c.rect(3, 4, 18, 14, "v")         # monitor
    for r, k in ((7, "c"), (5, "V"), (3, "c")):                   # radio waves
        for a in range(-60, 61, 6):
            x = 12 + r * math.sin(math.radians(a))
            y = 14 - r * math.cos(math.radians(a))
            c.set(x, y, k)
    c.rect(11, 13, 2, 3, "x"); c.rect(10, 16, 4, 1, "w")         # antenna mast
    c.rect(9, 19, 6, 2, "g"); c.rect(6, 21, 12, 1, "G")          # stand
    c.set(5, 6, "O"); c.set(18, 6, "B")
    c.outline()
    return c


def portraits():
    """24x24 bust portraits; shown at 2x in the 48x48 dialogue portrait slot."""
    out = {}
    astro, _ = build(ASTRO_ANIMS, "astro")
    og, _ = build(OG_ANIMS, "og")
    def bust(sheet, row, col):
        cell = sheet[row * C:(row + 1) * C, col * C:(col + 1) * C]
        p = np.zeros((C, C), np.uint8)
        p[:C - 3, :] = cell[3:, :]   # centre the 16 px figure in the frame
        return p
    out["max"] = bust(astro, 0, 0)
    out["max_scared"] = bust(astro, 5, 1)      # fall pose: arms up
    out["og"] = bust(og, 0, 0)
    out["og_laugh"] = bust(og, 1, 1)
    out["mission_control"] = mission_control_portrait().a
    return out


def extras(root):
    out = os.path.join(root, "src/assets/char")
    l = lander()
    to_img(l.a).save(os.path.join(out, "lander.png"), optimize=True)
    # Dialogue portraits now come from gen_portraits.py (portraits_64.png).
    print("OK lander.png 48x40")


if __name__ == "__main__" and len(sys.argv) > 1:
    extras(os.path.abspath(sys.argv[1]))


def info_sign():
    c = Canvas2(16, 16)
    c.rect(3, 2, 10, 8, "V"); c.rect(4, 3, 8, 6, "c")
    c.rect(7, 4, 2, 1, "W"); c.rect(7, 6, 2, 2, "W")   # "i"
    c.rect(7, 10, 2, 6, "g"); c.rect(8, 10, 1, 6, "G")  # post
    c.outline()
    return c


if __name__ == "__main__" and len(sys.argv) > 1:
    to_img(info_sign().a).save(os.path.join(os.path.abspath(sys.argv[1]), "src/assets/char/info_sign.png"), optimize=True)
    print("OK info_sign.png 16x16")

# ------------------------------------------------------------- OG wizard --
def _poly(cel, pts, k):
    xs = [x for x, _ in pts]; ys = [y for _, y in pts]
    for y in range(int(min(ys)), int(max(ys)) + 1):
        for x in range(int(min(xs)), int(max(xs)) + 1):
            px, py, inside = x + 0.5, y + 0.5, False
            for i in range(len(pts)):
                (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % len(pts)]
                if (y0 <= py < y1) or (y1 <= py < y0):
                    if px < x0 + (py - y0) * (x1 - x0) / (y1 - y0):
                        inside = not inside
            if inside:
                cel.set(x, y, k)


def wizard(bob=0, tilt=0, mouth=0, eyes="open", arm="staff", sparkle=0):
    """OG: old, bald, bearded hermit-wizard in a robe, floating. Faces right."""
    c = Cel()
    b, t = bob, tilt
    staff_x = 18 if arm == "staff" else 19
    # staff (behind)
    for y in range(3 + b, 23):
        c.set(staff_x, y, "T"); c.set(staff_x + 1, y, "t")
    for dx, dy, k in ((0, 0, "c"), (1, 0, "x"), (0, 1, "c"), (1, 1, "c"), (0, -1, "x"), (1, -1, "c"), (0, 2, "V"), (1, 2, "V")):
        c.set(staff_x + dx, 1 + b + dy, k)
    # back arm
    _poly(c, [(8.5, 12.5 + b), (10.5, 12.5 + b), (9.5, 17.5 + b), (7, 17.5 + b)], "p")
    c.rect(7, 17 + b, 2, 2, "f")
    # robe
    _poly(c, [(8.5, 12 + b), (15.5, 12 + b), (17.6, 22.6), (6.0, 22.6)], "P")
    _poly(c, [(8.5, 12 + b), (10.5, 12 + b), (9.6, 22.6), (6.0, 22.6)], "p")
    for x in range(6, 18):
        c.set(x, 22, "Y" if x % 3 else "U")       # gold hem
    for x in range(9, 16):
        c.set(x, 16 + b, "Y" if x % 2 else "U")   # rope belt
    c.set(13, 18 + b, "Y"); c.set(14, 20 + b, "Y")  # star trim
    # head (bald)
    hx, hy = 12.5 + t, 8.2 + b
    for y in range(C):
        for x in range(C):
            u, v = (x + 0.5 - hx) / 3.8, (y + 0.5 - hy) / 3.7
            if u * u + v * v <= 1.0:
                c.set(x, y, "f" if u < -0.45 else "F")
    c.set(hx - 1.2, hy - 2.6, "W")                 # bald shine
    c.set(hx - 3.2, hy, "f")                       # ear
    c.set(hx + 3.6, hy + 0.6, "F"); c.set(hx + 3.6, hy + 1.4, "f")  # nose
    # beard + brows
    bx, by = t, b
    _poly(c, [(9.6 + bx, 9.6 + by), (16.4 + bx, 9.6 + by), (16.6 + bx, 12.4 + by),
              (14.8 + bx, 16.4 + by), (12.6 + bx, 18.0 + by), (10.4 + bx, 14.6 + by)], "H")
    _poly(c, [(9.6 + bx, 9.6 + by), (11.6 + bx, 9.6 + by), (11.4 + bx, 16.0 + by), (10.4 + bx, 14.6 + by)], "h")
    c.rect(12 + bx, 6 + by, 4, 1, "H")            # bushy brow
    c.set(16 + bx, 7 + by, "H")
    if eyes == "open":
        c.set(14 + bx, 7 + by, "K")
    else:
        c.set(13 + bx, 7 + by, "f"); c.set(14 + bx, 6 + by, "f"); c.set(15 + bx, 7 + by, "f")
    if mouth >= 1:
        c.rect(13 + bx, 11 + by, 3, 1, "M")
    if mouth >= 2:
        c.rect(13 + bx, 12 + by, 3, 1, "D"); c.set(16 + bx, 11 + by, "M")
    # front arm
    if arm == "staff":
        _poly(c, [(13.5, 12.5 + b), (16.5, 12.5 + b), (17.5, 14.5 + b), (14, 15.5 + b)], "P")
        c.rect(17, 12 + b, 2, 2, "F")
    elif arm == "belly":
        _poly(c, [(13.5, 12.5 + b), (15.5, 12.5 + b), (15.5, 16.5 + b), (13, 16.5 + b)], "P")
        c.rect(12, 16 + b, 2, 2, "F")
    else:  # point
        _poly(c, [(13.5, 12 + b), (16.5, 11 + b), (20.5, 10.5 + b), (20.5, 12 + b), (14, 15 + b)], "P")
        c.rect(20, 10 + b, 2, 2, "F"); c.set(22, 10 + b, "F")
    c.outline()
    for i, (sx, sy) in enumerate(((4, 6), (21, 15), (3, 16), (22, 4))):  # magic sparkles
        if (i + sparkle) % 2 == 0:
            c.set(sx, sy + b, "x" if i % 2 else "c")
    return c


WIZ_ANIMS = [
    ("idle", [dict(bob=0, sparkle=0), dict(bob=-1, sparkle=1), dict(bob=-1, sparkle=0), dict(bob=0, sparkle=1)], 4, True),
    ("laugh", [dict(bob=0, tilt=-1, mouth=2, eyes="shut", arm="belly", sparkle=0),
               dict(bob=1, tilt=0, mouth=1, eyes="shut", arm="belly", sparkle=1),
               dict(bob=0, tilt=-1, mouth=2, eyes="shut", arm="belly", sparkle=0),
               dict(bob=1, tilt=0, mouth=2, eyes="shut", arm="belly", sparkle=1)], 10, True),
    ("point", [dict(bob=0, mouth=1, arm="point"), dict(bob=-1, mouth=1, arm="point", sparkle=1)], 6, True),
]


def build_wizard():
    cols = max(len(f) for _, f, _, _ in WIZ_ANIMS)
    sheet = np.zeros((len(WIZ_ANIMS) * C, cols * C), np.uint8)
    meta = []
    for r, (name, frames, fps, loop) in enumerate(WIZ_ANIMS):
        for col, p in enumerate(frames):
            sheet[r * C:(r + 1) * C, col * C:(col + 1) * C] = wizard(**p).a
        meta.append({"name": name, "row": r, "frames": len(frames), "fps": fps, "loop": loop})
    return sheet, meta


# --------------------------------------------------- face-close portraits --
def max_portrait(scared=False):
    c = Canvas2(24, 24)
    oy = 1 if scared else 0
    c.rect(3, 20, 18, 4, "W"); c.rect(3, 22, 18, 2, "w")           # shoulders
    c.rect(9, 20, 6, 3, "g"); c.set(10, 21, "D"); c.set(13, 21, "B")  # chest box
    for y in range(24):
        for x in range(24):
            u, v = (x + 0.5 - 12) / 8.6, (y + 0.5 - 11 - oy) / 8.4
            if u * u + v * v <= 1.0:
                c.set(x, y, "w" if (u < -0.5 and v > 0.1) or v > 0.8 else "W")
            u2, v2 = (x + 0.5 - 13.2) / 6.0, (y + 0.5 - 11.4 - oy) / 5.2
            d = u2 * u2 + v2 * v2
            if d <= 1.0:
                c.set(x, y, "U" if d > 0.75 else ("y" if v2 > 0.2 or u2 > 0.5 else "Y"))
    for gx, gy in ((10, 8), (11, 8), (10, 9), (13, 7)):
        c.set(gx, gy + oy, "W")
    c.rect(8, 19 + oy, 9, 1, "g")                                    # neck ring
    if scared:
        c.set(21, 4, "c"); c.set(21, 5, "c"); c.set(20, 6, "x")      # sweat drop
    c.outline()
    return c


def og_portrait(laugh=False):
    c = Canvas2(24, 24)
    t = -1 if laugh else 0
    _poly(c, [(1, 24), (5, 17), (19, 17), (23, 24)], "P")             # robe shoulders
    _poly(c, [(1, 24), (5, 17), (8, 17), (6, 24)], "p")
    for y in range(24):
        for x in range(24):
            u, v = (x + 0.5 - 11.5 - t) / 7.0, (y + 0.5 - 9.0) / 7.2
            if u * u + v * v <= 1.0:
                c.set(x, y, "f" if u < -0.55 else "F")
    c.rect(8 + t, 3, 2, 1, "W"); c.set(9 + t, 2, "W")                 # shine
    c.set(4 + t, 9, "f"); c.set(4 + t, 10, "f")                       # ear
    _poly(c, [(19 + t, 9), (21.5 + t, 10), (21.5 + t, 12), (19 + t, 12.5)], "F")  # nose
    c.set(21 + t, 12, "f")
    _poly(c, [(6 + t, 11), (20 + t, 11), (20.5 + t, 15), (16 + t, 21), (12 + t, 23.5), (8 + t, 19), (6 + t, 14)], "H")
    _poly(c, [(6 + t, 11), (9 + t, 11), (9.5 + t, 20), (8 + t, 19), (6 + t, 14)], "h")
    c.rect(12 + t, 6, 6, 2, "H"); c.rect(17 + t, 5, 2, 1, "H")       # bushy brows
    if laugh:
        c.set(14 + t, 9, "f"); c.set(15 + t, 8, "f"); c.set(16 + t, 9, "f")   # ^ eye
        c.rect(14 + t, 13, 5, 3, "M"); c.rect(15 + t, 15, 3, 1, "D")        # big open mouth
    else:
        c.rect(15 + t, 8, 2, 2, "K"); c.set(15 + t, 8, "W")                  # eye
        c.rect(15 + t, 14, 4, 1, "M")                                         # smirk
    c.outline()
    return c


def ui_icons():
    """8x8 HUD icons: air, rad, storm, shield, lamp, sample, cell_on, cell_off."""
    c = Canvas2(64, 8)
    art = [
        ["..cccc..", ".c....c.", "c..cc..c", "c.c..c.c", "c.c..c.c", "c..cc..c", ".c....c.", "..cccc.."],  # air O2
        ["...YY...", "..YKKY..", ".Y.KK.Y.", "YKK..KKY", "YKK..KKY", ".Y....Y.", "..YKKY..", "...YY..."],  # rad
        ["O..O..O.", ".O.OO.O.", "..OOOO..", "OOOYYOOO", "OOOYYOOO", "..OOOO..", ".O.OO.O.", "O..O..O."],  # storm sun
        [".BBBBBB.", "BxxxxxxB", "BxBBBBxB", "BxBBBBxB", ".BxBBxB.", ".BxBBxB.", "..BxxB..", "...BB..."],  # shield
        ["..YYYY..", ".YWWWWY.", ".YWWWWY.", "..YYYY..", "...gg...", "...gg...", "..gggg..", "........"],  # lamp
        [".ff..ff.", "fHHHHHHf", ".HhHHhH.", ".HHhhHH.", ".DDDDDD.", ".HHHHHH.", "fHHHHHHf", ".ff..ff."],  # scroll
        [".KKKKK..", ".KcccKK.", ".KcccKK.", ".KcccKK.", ".KcccKK.", ".KKKKK..", "........", "........"],  # cell on
        [".KKKKK..", ".KGGGKK.", ".KGGGKK.", ".KGGGKK.", ".KGGGKK.", ".KKKKK..", "........", "........"],  # cell off
    ]
    for i, rows in enumerate(art):
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch != ".":
                    c.set(i * 8 + x, y, ch)
    return c


def wizard_extras(root):
    out = os.path.join(root, "src/assets/char")
    a, meta = build_wizard()
    to_img(a).save(os.path.join(out, "og_npc_24.png"), optimize=True)
    labelled(a, meta, "OG - the Old Geologist (hermit wizard)", os.path.join(out, "Previews", "og_npc_labelled.png"))
    import json as _j
    idx_p = os.path.join(out, "Previews", "char_index.json")
    idx = _j.load(open(idx_p))
    idx["og_npc"] = {"png": "res://src/assets/char/og_npc_24.png", "cell": C, "animations": meta}
    _j.dump(idx, open(idx_p, "w"), indent=1)
    to_img(ui_icons().a).save(os.path.join(out, "ui_icons.png"), optimize=True)
    print("OK og_npc_24.png (wizard), ui_icons.png")


if __name__ == "__main__" and len(sys.argv) > 1:
    wizard_extras(os.path.abspath(sys.argv[1]))


def scroll_sprite():
    """16x16 Book of Books scroll: parchment with rolled ends and a red ribbon."""
    c = Canvas2(16, 16)
    rows = [
        "................",
        "..ffff....ffff..",
        ".fhHHf....fHHhf.",
        ".fHHHHHHHHHHHHf.",
        "..fHHHHHHHHHHf..",
        "..fHhhhhhhhHHf..",
        "..fHHHHHHHHHHf..",
        "..fHhhhhhhHHHf..",
        "..DDDDDDDDDDDD..",
        "..fHHHHHHHHHHf..",
        "..fHhhhhhhhHHf..",
        "..fHHHHHHHHHHf..",
        ".fHHHHHHHHHHHHf.",
        ".fhHHf....fHHhf.",
        "..ffff....ffff..",
        "................",
    ]
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                c.set(x, y, ch)
    c.set(7, 9, "Y"); c.set(8, 9, "Y")   # wax seal
    c.outline()
    return c


if __name__ == "__main__" and len(sys.argv) > 1:
    to_img(scroll_sprite().a).save(os.path.join(os.path.abspath(sys.argv[1]), "src/assets/char/scroll.png"), optimize=True)
    print("OK scroll.png 16x16")


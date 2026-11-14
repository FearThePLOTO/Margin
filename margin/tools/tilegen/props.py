"""Hand-built and procedural props. Every item registers metadata used by the
Godot TileSet writer (size in cells, animation frames, collision, hazard tag)."""
import math
import numpy as np
from core import Canvas, H, T, ellipse_mask, poly_mask
from terrain import TERRAINS, render_shape, heightmap_poly

SQUARE = [(-8, -8), (8, -8), (8, 8), (-8, 8)]
ONE_WAY_TOP = [(-8, -8), (8, -8), (8, -3), (-8, -3)]


class Item:
    def __init__(self, name, cv, w=1, h=1, frames=1, collision=None, one_way=False,
                 hazard=None, duration=0.15, anchor="bottom", note=""):
        assert cv.w == w * T * frames and cv.h == h * T, f"{name}: {cv.w}x{cv.h} vs {w}x{h}x{frames}"
        self.name, self.cv, self.w, self.h, self.frames = name, cv, w, h, frames
        self.collision, self.one_way, self.hazard = collision, one_way, hazard
        self.duration, self.anchor, self.note = duration, anchor, note


ROCK_RAMP = ["B0", "B1", "R0", "R1", "R2"]
CAVE_RAMP = ["K1", "P0", "P1", "P2", "P3"]
METAL_RAMP = ["M0", "M1", "M2", "M3", "M4"]


def frames(*cvs):
    out = Canvas(sum(c.w for c in cvs), cvs[0].h)
    x = 0
    for c in cvs:
        out.paste(c, x, 0)
        x += c.w
    return out


def art(rows, w=16, h=16, pad_top=True, subs=None):
    cv = Canvas(w, h)
    oy = h - len(rows) if pad_top else 0
    cv.ascii(0, oy, rows, subs=subs)
    return cv


# =========================================================================
# PLATFORMS
# =========================================================================
def ledge_pieces(tkey):
    t = TERRAINS[tkey]

    def run(x, y, w):
        th = 6 if 1 < x < w - 2 else 5
        if y < th:
            return not ((x == 0 or x == w - 1) and y in (0, th - 1))
        return y == th and 2 < x < w - 3 and H(x, 7) % 3 == 0

    cv3, _ = render_shape(lambda x, y: run(x, y, 48), 48, 16, t)
    cv1, _ = render_shape(lambda x, y: run(x, y, 16), 16, 16, t)
    out = []
    for i, nm in enumerate(("L", "M", "R")):
        out.append(Item(f"ledge_{tkey}_{nm}", cv3.crop(i * 16, 0, 16, 16), collision=ONE_WAY_TOP, one_way=True))
    out.append(Item(f"ledge_{tkey}_single", cv1, collision=ONE_WAY_TOP, one_way=True))
    return out


def grate_pieces():
    out = []
    for nm in ("L", "M", "R", "single"):
        cv = Canvas(16, 16)
        cv.rect(0, 0, 16, 5, "M2")
        cv.hline(0, 15, 0, "M4")
        cv.hline(0, 15, 1, "M3")
        cv.hline(0, 15, 4, "M0")
        for x in range(1, 16, 3):
            cv.set(x, 2, "M0")
            cv.set(x + 1, 2, "M1")
            cv.set(x, 3, "M1")
        lo = nm in ("L", "single")
        ro = nm in ("R", "single")
        if lo:
            cv.vline(0, 0, 4, "M0")
            cv.set(1, 0, "M3")
        if ro:
            cv.vline(15, 0, 4, "M0")
        # support bracket + hazard stripe on caps
        for bx in ([3] if lo else []) + ([11] if ro else []) + ([7] if nm == "M" else []):
            cv.vline(bx, 5, 7, "M1")
            cv.vline(bx + 1, 5, 6, "M0")
            cv.set(bx + 1, 7, "M0")
        if lo:
            cv.set(2, 2, "O1"); cv.set(2, 3, "O1")
        if ro:
            cv.set(13, 2, "O1"); cv.set(13, 3, "O1")
        out.append(Item(f"grate_{nm}", cv, collision=ONE_WAY_TOP, one_way=True))
    return out


def island(tkey, wcells):
    t = TERRAINS[tkey]
    W, Hh = wcells * 16, 32
    cx = (W - 1) / 2

    def fn(x, y):
        u = abs(x - cx) / (W / 2)
        depth = 9 + (Hh - 9) * max(0.0, 1 - u ** 1.6) - (H(x // 2, wcells) % 3)
        return y < depth

    cv, occ = render_shape(fn, W, Hh, t)
    items = []
    for cy in range(2):
        for cxi in range(wcells):
            tile = cv.crop(cxi * 16, cy * 16, 16, 16)
            col = SQUARE if cy == 0 else None
            if cy == 0 and not occ[15, cxi * 16:(cxi + 1) * 16].all():
                col = [(-8, -8), (8, -8), (8, 1), (-8, 1)]
            items.append(Item(f"island_{tkey}_{wcells}w_r{cy}c{cxi}", tile, collision=col))
    return items


def float_rock(tkey):
    t = TERRAINS[tkey]

    def fn(x, y):
        u = abs(x - 7.5) / 8
        return y < 7 + 8 * max(0, 1 - u ** 1.5) - (H(x, 3) % 2) and not (y == 0 and x in (0, 15))

    cv, _ = render_shape(fn, 16, 16, t)
    return Item(f"float_rock_{tkey}", cv, collision=[(-8, -8), (8, -8), (8, -2), (-8, -2)])


def crumble_platform(tkey):
    """4x1 collapsing platform, 3 states stacked as separate items (intact/cracked/crumbling)."""
    t = TERRAINS[tkey]

    def fn(x, y):
        return 1 <= y < 12 + (H(x // 3, 9) % 3) and not ((x < 2 or x > 61) and y in (1, 2))

    base, _ = render_shape(fn, 64, 16, t)
    states = []
    for st in range(3):
        cv = Canvas(64, 16)
        cv.a = base.a.copy()
        if st >= 1:
            for sx in (13, 30, 47):
                x, y = sx, 1
                while y < 13:
                    cv.set(x, y, "K1")
                    y += 1
                    x += (H(sx, y) % 3) - 1
        if st == 2:
            for sx, sy in ((5, 9), (22, 11), (38, 10), (55, 9), (60, 4), (28, 2)):
                for dy in range(3):
                    for dx in range(3):
                        if (dx + dy) < 4:
                            cv.set(sx + dx, sy + dy, None)
            for i in range(10):
                cv.set(3 + (H(i, 1) % 58), 13 + (H(i, 2) % 3), "R1" if i % 2 else "B1")
        states.append(cv)
    names = ("intact", "cracked", "crumbling")
    return [Item(f"crumble_{tkey}_{names[st]}", cv, 4, 1, collision=[(-32, -7), (32, -7), (32, 4), (-32, 4)],
                 note="64x16 strip, matches falling_platform_64.tscn")
            for st, cv in enumerate(states)]


def platform_items():
    items = []
    for k in ("rock", "cave"):
        items += ledge_pieces(k)
    items += grate_pieces()
    for k in ("rock", "cave"):
        items.append(float_rock(k))
        items += island(k, 2)
        items += island(k, 3)
    items += crumble_platform("rock")
    items += crumble_platform("cave")
    return items


# =========================================================================
# GEOLOGY
# =========================================================================
def boulder(w, h, ew, eh, ramp, cracks=0, seed=0, extra=None):
    cv = Canvas(w, h)
    m = ellipse_mask(ew, eh)
    m[-1, :] |= ellipse_mask(ew, eh)[-2, :]  # flat-ish bottom
    ox, oy = (w - ew) // 2, h - eh
    if extra:
        ew2, eh2, dx = extra
        m2 = ellipse_mask(ew2, eh2)
        cv.shade(m2, ox + dx, h - eh2, ramp)
    cv.shade(m, ox, oy, ramp)
    for c in range(cracks):
        x = ox + 2 + H(seed, c) % max(1, ew - 4)
        y = oy + 1 + H(seed, c, 1) % max(1, eh // 2)
        for _ in range(3 + H(seed, c, 2) % 3):
            if m[min(eh - 1, y - oy), min(ew - 1, max(0, x - ox))]:
                cv.set(x, y, ramp[0])
            y += 1
            x += (H(seed, c, y) % 3) - 1
    return cv


def pebbles(seed, ramp):
    cv = Canvas(16, 16)
    for i in range(5):
        w = 2 + H(seed, i) % 3
        h = 2 if w < 4 else 3
        x = H(seed, i, 1) % (16 - w)
        cv.shade(ellipse_mask(w, h, rx=w / 2 + 0.2, ry=h / 2 + 0.2), x, 16 - h, [ramp[0], ramp[1], ramp[2], ramp[3], ramp[3]])
    return cv


def crack_decal(seed):
    cv = Canvas(16, 16)
    x, y = 2 + H(seed) % 12, 0
    while y < 16:
        cv.set(x, y, "K1")
        if H(seed, y, 4) % 3 == 0:
            cv.set(x + 1, y, "B0")
        if H(seed, y, 9) % 5 == 0:  # branch
            bx, by = x, y
            for _ in range(3):
                bx += 1 if seed % 2 else -1
                by += 1
                cv.set(bx, by, "B0")
        y += 1
        x = max(1, min(14, x + (H(seed, y) % 3) - 1))
    return cv


def mineral(kind, seed):
    cv = Canvas(16, 16)
    if kind == "hematite":  # Mars "blueberries"
        for i in range(6):
            x, y = H(seed, i) % 14, H(seed, i, 1) % 14
            cv.set(x, y, "M1"); cv.set(x + 1, y, "M2"); cv.set(x, y + 1, "M0"); cv.set(x + 1, y + 1, "M1")
            cv.set(x, y, "M3")
    elif kind == "sulfate":  # white gypsum veins
        x = H(seed) % 6
        for y in range(16):
            cv.set(x, y, "S3")
            if y % 3 == 0:
                cv.set(x + 1, y, "W")
            x = (x + (1 if H(seed, y) % 3 else 0)) % 16
    elif kind == "iron":
        for i in range(14):
            cv.set(H(seed, i) % 16, H(seed, i, 2) % 16, "O0" if i % 3 else "O2")
    elif kind == "ore":  # teal vein of interest (science objective)
        pts = [(1, 12), (5, 9), (8, 10), (12, 5), (15, 3)]
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            cv.line(x0, y0, x1, y1, "T1")
        for x, y in pts[1:-1]:
            cv.set(x, y - 1, "T2"); cv.set(x, y, "T3")
    return cv


def spike_shape(w, h, ramp, down=False, base_w=None):
    """Single cone (stalactite/stalagmite)."""
    cv = Canvas(w, h)
    bw = base_w or w - 2
    cx = (w - 1) / 2
    pts = [(cx - bw / 2 + 0.5, h), (cx + 0.5, 0), (cx + bw / 2 + 0.5, h)]
    m = poly_mask(w, h, pts)
    if down:
        m = m[::-1]
    cv.shade(m, 0, 0, ramp, light=(-1, 0))
    return cv


def stal(kind, big, ramp):
    h = 32 if big else 16
    cv = Canvas(16, h)
    specs = [(16, h, 12), (10, int(h * 0.6), 6)] if big else [(12, 13, 8), (8, 8, 5)]
    offs = [2, 9] if big else [1, 8]
    for (w, hh, bw), ox in zip(specs, offs):
        piece = spike_shape(min(w, 16 - ox), hh, ramp, down=(kind == "tite"), base_w=bw)
        cv.paste(piece, ox if ox + piece.w <= 16 else 16 - piece.w, 0 if kind == "tite" else h - hh)
    return cv


def crystal(cv, bx, by, w, h, tilt, pal):
    """pal = [outline, dark, mid, light, highlight]."""
    pts = [(bx - w / 2, by), (bx - w / 2 + tilt, by - h + w / 2), (bx + tilt, by - h),
           (bx + w / 2 + tilt, by - h + w / 2), (bx + w / 2, by)]
    m = poly_mask(cv.w, cv.h, pts)

    def ins(x, y):
        return 0 <= x < cv.w and 0 <= y < cv.h and m[y, x]

    for y in range(cv.h):
        for x in range(cv.w):
            if not m[y, x]:
                continue
            frac = (by - (y + 0.5)) / h
            axis = bx + tilt * frac
            if not (ins(x - 1, y) and ins(x + 1, y) and ins(x, y - 1)):
                c = pal[0]
            elif x + 0.5 < axis - 0.5:
                c = pal[4] if not ins(x - 2, y) else pal[3]
            elif x + 0.5 < axis + 0.5:
                c = pal[2]
            else:
                c = pal[1]
            cv.set(x, y, c)


MAGENTA = ["C0", "C1", "C2", "C2", "C3"]
TEALC = ["T0", "T1", "T2", "T2", "T3"]
ICE = ["F0", "F1", "F2", "F3", "F4"]
RAD = ["G0", "G0", "G1", "G2", "G3"]


def crystal_cluster(h, pal, layout):
    cv = Canvas(16, h)
    for bx, ch, cw, tilt in layout:
        crystal(cv, bx, h, cw, ch, tilt, pal)
    return cv


def crater(wcells, hcells, depth, rim):
    t = TERRAINS["rock"]
    W, Hh = wcells * 16, hcells * 16
    ground = 10 if hcells == 2 else 6

    def surf(x):
        u = (x + 0.5) / W * 2 - 1  # -1..1
        bowl = depth * max(0.0, 1 - (u / 0.62) ** 2)
        rims = rim * math.exp(-((abs(u) - 0.7) / 0.13) ** 2)
        return ground - rims + bowl

    cv, occ = render_shape(lambda x, y: y >= surf(x), W, Hh, t, side_ground=ground)
    items = []
    for cy in range(hcells):
        for cxi in range(wcells):
            tile_occ = occ[cy * 16:(cy + 1) * 16, cxi * 16:(cxi + 1) * 16]
            items.append(Item(f"crater_{wcells}x{hcells}_r{cy}c{cxi}", cv.crop(cxi * 16, cy * 16, 16, 16),
                              collision=heightmap_poly(tile_occ)))
    return items


def geology_items():
    it = []
    it.append(Item("boulder_small", boulder(16, 16, 10, 7, ROCK_RAMP, 1, 1)))
    it.append(Item("boulder_medium", boulder(16, 16, 15, 11, ROCK_RAMP, 2, 2)))
    it.append(Item("boulder_large", boulder(32, 32, 28, 22, ROCK_RAMP, 4, 3, extra=(12, 10, 18)), 2, 2))
    it.append(Item("boulder_cave", boulder(16, 16, 14, 10, CAVE_RAMP, 2, 4)))
    it.append(Item("boulder_cave_large", boulder(32, 32, 28, 20, CAVE_RAMP, 3, 5, extra=(11, 9, 2)), 2, 2))
    cl = Canvas(16, 16)
    cl.paste(boulder(16, 16, 8, 6, ROCK_RAMP), -4, 0)
    cl.paste(boulder(16, 16, 9, 8, ROCK_RAMP, 1, 7), 3, 0)
    cl.paste(boulder(16, 16, 5, 4, ROCK_RAMP), -1, 0)
    it.append(Item("rock_cluster", cl))
    it.append(Item("pebbles_a", pebbles(1, ROCK_RAMP)))
    it.append(Item("pebbles_b", pebbles(2, ROCK_RAMP)))
    it.append(Item("pebbles_cave", pebbles(3, CAVE_RAMP)))
    for s in range(3):
        it.append(Item(f"crack_decal_{s}", crack_decal(s + 1), note="overlay on terrain"))
    for k in ("hematite", "sulfate", "iron", "ore"):
        it.append(Item(f"mineral_{k}", mineral(k, 5), note="overlay on terrain"))
    it.append(Item("stalactite_small", stal("tite", False, CAVE_RAMP), anchor="top"))
    it.append(Item("stalactite_large", stal("tite", True, CAVE_RAMP), 1, 2, anchor="top"))
    it.append(Item("stalagmite_small", stal("mite", False, CAVE_RAMP)))
    it.append(Item("stalagmite_large", stal("mite", True, CAVE_RAMP), 1, 2))
    it.append(Item("crystal_magenta_small", crystal_cluster(16, MAGENTA, [(5, 9, 4, -1), (9, 13, 5, 0), (12, 7, 3, 1)])))
    it.append(Item("crystal_magenta_large", crystal_cluster(32, MAGENTA, [(4, 16, 5, -2), (8, 28, 7, 0), (12, 18, 5, 2), (14, 9, 3, 1)]), 1, 2))
    it.append(Item("crystal_teal", crystal_cluster(16, TEALC, [(4, 8, 4, -1), (8, 12, 5, 0), (12, 10, 4, 1)])))
    it.append(Item("crystal_magenta_ceiling", crystal_cluster(16, MAGENTA, [(5, 9, 4, -1), (9, 13, 5, 0), (12, 7, 3, 1)]).flip_v(), anchor="top"))
    it += crater(4, 2, 13, 4)
    it += crater(2, 1, 6, 2)
    return it


# =========================================================================
# VEGETATION (alien)
# =========================================================================
def vegetation_items():
    it = []
    # lichen patch
    it.append(Item("lichen_patch", art([
        "....u...........",
        "...uvu.....u....",
        ".utuvtu...uvu.u.",
        "tuttutttutuvtuvu",
    ])))
    # glow stalks
    it.append(Item("glow_stalks", art([
        "......x.........",
        ".....xvx........",
        "..x...u....x....",
        ".xvx..u...xvx...",
        "..u...u....u....",
        "..u..tu....u....",
        "..ut..u...tu....",
        "..u...ut...u....",
        ".tu...u....ut...",
        "..u..tu....u....",
        "ttuttuuttttutt..",
    ])))
    it.append(Item("fungus_caps", art([
        "....0000........",
        "...0PPqP0.......",
        "..0PpPPqP0......",
        "..0QpppPp0.0000.",
        "...00SS00.0PPqP0",
        ".....SS..0QppPP0",
        ".....SZ...00SS0.",
        "....zSS.....SS..",
        "...zzSSz...zSZz.",
    ])))
    it.append(Item("spore_pod", art([
        "......00........",
        ".....0pq0.......",
        "....0pPqP0......",
        "....0pqPP0......",
        "....0QpPp0......",
        ".....0Qp0.......",
        "......uu........",
        "....t.ut..t.....",
        "...tutuuttu.....",
    ])))
    it.append(Item("tube_worms", art([
        "...v......v.....",
        "..0x0....0x0..v.",
        "..0R0..v.0R0.0x0",
        "..0R0.0x00R0.0R0",
        "..0R0.0R00o0.0R0",
        "..0o0.0R00R0.0o0",
        "..0R0.0o00R0.0R0",
        ".m0R0m0R00R0m0R0",
    ])))
    it.append(Item("dry_shrub", art([
        ".....N....N.....",
        "...N..n..n..N...",
        "....n..nn..n....",
        "..N..n.nn.n..N..",
        "...nn..mm..nn...",
        ".....nnmmnn.....",
        "......CmmC......",
        ".....CCmmCC.....",
    ])))
    vine = Canvas(16, 32)
    for vx, ln, ph in ((3, 26, 0), (8, 18, 1), (12, 30, 2)):
        x = vx
        for y in range(ln):
            vine.set(x, y, "T0" if y % 4 == 3 else "T1")
            if y % 5 == 2:
                vine.set(x + (1 if (y + ph) % 2 else -1), y, "T2")
            if (y + ph) % 9 == 0:
                x = x + (1 if ph % 2 else -1)
        vine.set(x, ln, "T3"); vine.set(x, ln - 1, "T2")
    it.append(Item("hanging_vines", vine, 1, 2, anchor="top"))
    it.append(Item("crystal_moss", art([
        "..q......P......",
        ".PpP....pqp..q..",
        "QpQpk.kQpQpQpPp.",
        "kQkkkkkkkQkkkQkk",
    ])))
    return it


# =========================================================================
# PARKOUR
# =========================================================================
def anchor_frames():
    base = [
        "................",
        "......0000......",
        ".....0deed0.....",
        "....0d0000d0....",
        "....0e0..0e0....",
        "....0d0..0d0....",
        "....0c0..0c0....",
        ".....0dccd0.....",
        "......0dc0......",
        "......0dc0......",
        "....00000000....",
        "...0eddddddc0...",
        "...0c$cccc$b0...",
        "...0bbbbbbbb0...",
        "..0aaaaaaaaaa0..",
        "..000000000000..",
    ]
    off = art(base, subs={"$": "O0"})
    on = art(base, subs={"$": "T2"})
    on.set(7, 2, "T3"); on.set(8, 2, "T3")
    return frames(off, on)


def jump_pad_frames():
    def pad(plate_y, coil):
        cv = Canvas(16, 16)
        cv.rect(1, 13, 14, 3, "M1")
        cv.hline(1, 14, 13, "M3")
        cv.hline(1, 14, 15, "M0")
        cv.set(3, 14, "O1"); cv.set(12, 14, "O1")
        for y in range(plate_y + 2, 13):
            cv.set(5 if (y + coil) % 2 else 6, y, "M3")
            cv.set(10 if (y + coil) % 2 else 9, y, "M3")
        cv.rect(2, plate_y, 12, 2, "Y0")
        cv.hline(2, 13, plate_y, "Y1")
        cv.set(1, plate_y, "K0"); cv.set(1, plate_y + 1, "K0")
        cv.set(14, plate_y, "K0"); cv.set(14, plate_y + 1, "K0")
        for x in range(3, 13, 3):
            cv.set(x, plate_y + 1, "K1")
        return cv
    return frames(pad(9, 0), pad(11, 1), pad(5, 0))


def climb_wall(kind):
    cv = Canvas(16, 16)
    if kind == "rock":
        t = TERRAINS["rock"]
        for y in range(16):
            for x in range(16):
                cv.set(x, y, t.body(x, y, 0))
        for hx, hy in ((3, 3), (11, 8), (4, 12)):
            cv.rect(hx, hy, 3, 1, "R2"); cv.set(hx, hy, "S1")
            cv.rect(hx, hy + 1, 3, 1, "K1")
    else:  # loose regolith: crumbly, pitons slip
        for y in range(16):
            for x in range(16):
                hh = H(x, y, 77)
                cv.set(x, y, "S0" if hh % 3 else ("R2" if hh % 2 else "S1"))
        for i in range(6):
            x, y = H(i, 1) % 15, H(i, 2) % 15
            cv.set(x, y, "B1"); cv.set(x + 1, y, "R1")
    return cv


def grip_overlay(natural):
    if natural:
        return art([
            "................",
            "..1.............",
            ".1Rs1...........",
            "..11........1...",
            "...........1Rs1.",
            "............11..",
            "................",
            "....1...........",
            "...1Rs1.........",
            "....11..........",
        ], pad_top=False)
    return art([
        "................",
        "...0000.........",
        "..0deed0........",
        "..0c00c0........",
        "..0b..b0........",
        "..rr..rr........",
        "................",
        "................",
        "...........0000.",
        "..........0deed0",
        "..........0c00c0",
        "..........0b..b0",
        "..........rr..rr",
    ], pad_top=False)


def parkour_items():
    return [
        Item("tether_anchor", anchor_frames(), frames=2, duration=0.5, note="frame0 idle, frame1 hooked"),
        Item("tether_anchor_ceiling", anchor_frames().flip_v(), frames=2, duration=0.5, anchor="top"),
        Item("jump_pad", jump_pad_frames(), frames=3, collision=[(-7, 1), (7, 1), (7, 8), (-7, 8)], duration=0.08),
        Item("climb_wall_rock", climb_wall("rock"), collision=SQUARE, note="spikes grip"),
        Item("climb_wall_regolith", climb_wall("regolith"), collision=SQUARE, hazard="LooseRegolith"),
        Item("grip_metal", grip_overlay(False), note="overlay on wall"),
        Item("grip_natural", grip_overlay(True), note="overlay on wall"),
    ]


# =========================================================================
# INFRASTRUCTURE
# =========================================================================
def solar_panel():
    cv = Canvas(32, 16)
    # tilted panel: top edge rises to the right
    for x in range(1, 31):
        top = 2 + (30 - x) // 10
        cv.set(x, top, "M4")
        for y in range(top + 1, 9):
            cell = ((x - 1) % 5 == 0) or ((y - top) % 3 == 0)
            cv.set(x, y, "M0" if cell else ("T1" if (x + y) % 7 else "T2"))
        cv.set(x, 9, "M1")
    cv.vline(0, 4, 9, "M0"); cv.vline(31, 2, 9, "M0")
    cv.rect(15, 10, 2, 4, "M2"); cv.vline(16, 10, 13, "M1")
    cv.rect(11, 14, 10, 2, "M1"); cv.hline(11, 20, 14, "M3"); cv.hline(10, 21, 15, "M0")
    cv.set(17, 11, "O1")
    return cv


def o2_station_frames():
    rows = [
        "..000000000000..",
        ".0eeeeeeeeeeee0.",
        ".0dccccccccccd0.",
        ".0dc00000000cd0.",
        ".0dc0tttttt0cd0.",
        ".0dc0t$$tt$0cd0.",
        ".0dc0t$t$t$0cd0.",
        ".0dc0t$$t$$0cd0.",
        ".0dc0tttttt0cd0.",
        ".0dc00000000cd0.",
        ".0dccccccccccd0.",
        ".0drrrrrrrrrrd0.",
        ".0dccccccccccd0.",
        ".0dcc000000ccd0.",
        ".0dc0weeeed0cd0.",
        ".0dc0vvvvvu0cd0.",
        ".0dc0weeeed0cd0.",
        ".0dc0weeeed0cd0.",
        ".0dc0vvvvvu0cd0.",
        ".0dc0weeeed0cd0.",
        ".0dcc000000ccd0.",
        ".0dccccc00cccd0.",
        ".0dcccc0dc0ccd0.",
        ".0dcccc0c00ccd0.",
        ".0dccccc0cccc00.",
        ".0dccccc0ccc0d0.",
        ".0dcccccc00c0c0.",
        ".0dccccccccc0b0.",
        ".0bbbbbbbbbbbb0.",
        "0aaaaaaaaaaaaaa0",
        "0aaaaaaaaaaaaaa0",
        "0000000000000000",
    ]
    return frames(art(rows, 16, 32, subs={"$": "T2"}), art(rows, 16, 32, subs={"$": "T0"}))


def checkpoint_frames():
    rows = [
        "......0000......",
        ".....0$$$$0.....",
        "....0$##$$$0....",
        "....0$#$$$$0....",
        "....0$$$$$$0....",
        "....00000000....",
        "....0deeeed0....",
        "....0caaaac0....",
        "......0dc0......",
        "......0dc0000...",
        "......0dc0rrr0..",
        "......0dc0rRrr0.",
        "......0dc0rrr0..",
        "......0dc0000...",
        "......0dc0......",
        "......0dc0......",
        "......0rR0......",
        "......0dc0......",
        "......0dc0......",
        "......0dc0......",
        "......0rR0......",
        "......0dc0......",
        "......0dc0......",
        "......0dc0......",
        "......0dc0......",
        ".....00dc00.....",
        "....0bcddcb0....",
        "...0bccccccb0...",
        "...0aaaaaaaa0...",
        "....00000000....",
    ]
    off = art(rows, 16, 32, subs={"$": "L0", "#": "L1"})
    on = art(rows, 16, 32, subs={"$": "T1", "#": "T3"})
    return frames(off, on)


def o2_tank():
    return art([
        "......0000......",
        ".....0ddcc0.....",
        "......0cb0......",
        ".....000000.....",
        "....0weeeed0....",
        "....0weeeed0....",
        "....0vvvvvu0....",
        "....0xv00vu0....",
        "....0v0vv0u0....",
        "....0xv00vu0....",
        "....0vvvvvu0....",
        "....0weeeed0....",
        "....0weeeed0....",
        "....0deeedc0....",
        ".....000000.....",
    ])


def antenna():
    cv = Canvas(16, 32)
    dish = ellipse_mask(13, 7)
    cv.shade(dish, 1, 2, ["M0", "M2", "M3", "M4", "W"])
    cv.hline(3, 11, 6, "M1")
    cv.vline(7, 0, 4, "M2"); cv.set(7, 0, "O1")
    # lattice mast
    for y in range(9, 28):
        cv.set(6, y, "M2"); cv.set(9, y, "M1")
        cv.set(7 if y % 4 < 2 else 8, y, "M3")
    cv.rect(4, 28, 8, 2, "M1"); cv.hline(4, 11, 28, "M3")
    cv.hline(3, 12, 30, "M0"); cv.hline(3, 12, 31, "M0")
    cv.set(10, 20, "T2"); cv.set(10, 21, "T1")
    return cv


def weather_sensor():
    return art([
        "...0......0.....",
        "..0d0....0d0....",
        "...0.0000.0.....",
        "......0d0.......",
        "......0d0.......",
        "....00000.......",
        "....0tvt0.......",
        "....0ttt0.......",
        "....00000.......",
        "......0d0.......",
        "......0c0.......",
        "......0d0.......",
        "......0c0.......",
        "....0bdcdb0.....",
        "...0aaaaaaa0....",
    ])


def drill_rig():
    cv = Canvas(16, 32)
    cv.line(2, 31, 7, 2, "M2"); cv.line(13, 31, 8, 2, "M1")
    cv.line(3, 31, 7, 3, "M3")
    for y in (10, 18, 25):
        x0 = 2 + (31 - y) * 5 // 29
        cv.hline(x0 + 1, 15 - x0 - 2, y, "M1")
    cv.rect(6, 1, 4, 3, "Y0"); cv.hline(6, 9, 1, "Y1"); cv.set(9, 3, "R2")
    cv.vline(7, 4, 30, "M3"); cv.vline(8, 4, 30, "M2")
    for y in range(6, 30, 3):
        cv.set(7, y, "M1")
    cv.rect(4, 22, 8, 4, "M1"); cv.hline(4, 11, 22, "M3"); cv.set(10, 23, "O1"); cv.set(5, 24, "T2")
    cv.hline(1, 14, 31, "M0")
    return cv


def crate():
    return art([
        "0000000000000000",
        "0eeeeeeeeeeeeed0",
        "0dccccccccccccb0",
        "0dc0000000000cb0",
        "0dc0rrrrrrrr0cb0",
        "0dc0rRRRRRRr0cb0",
        "0dc0000000000cb0",
        "0dccccccccccccb0",
        "0dcc0cccccc0ccb0",
        "0dccc0cccc0cccb0",
        "0dcccc0cc0ccccb0",
        "0dccccc00cccccb0",
        "0dcvvcccccccccb0",
        "0dccccccccccccb0",
        "0bbbbbbbbbbbbbb0",
        "0000000000000000",
    ])


def canister():
    return art([
        ".....0000.......",
        "....0ddcc0......",
        "....000000......",
        "....0weed0......",
        "....0wttd0......",
        "....0wvtd0......",
        "....0wttd0......",
        "....0weed0......",
        "....0deec0......",
        "....000000......",
    ])


def pipe(kind):
    cv = Canvas(16, 16)
    ramp = ["K0", "M3", "M4", "M2", "M1", "K0"]
    if kind in ("h", "v"):
        for i, c in enumerate(ramp):
            for s in range(16):
                if kind == "h":
                    cv.set(s, 5 + i, c)
                else:
                    cv.set(5 + i, s, c)
        for i in range(-1, 7):  # flange
            c = "M2" if 0 <= i < 6 else "K0"
            if kind == "h":
                cv.set(14, 5 + i, c); cv.set(15, 5 + i, "K0" if c == "K0" else "M1")
            else:
                cv.set(5 + i, 14, c); cv.set(5 + i, 15, "K0" if c == "K0" else "M1")
        return cv
    # elbows: kind = "ne","nw","se","sw" -> connects those two sides
    cx = 15.5 if "e" in kind else -0.5
    cy = -0.5 if "n" in kind else 15.5
    for y in range(16):
        for x in range(16):
            r = math.hypot(x + 0.5 - (cx + 0.5), y + 0.5 - (cy + 0.5))
            k = int(math.floor(r - 4.5))
            if 0 <= k < 6:
                cv.set(x, y, ramp[k])
    return cv


def truss(kind):
    cv = Canvas(16, 16)
    if kind == "x":
        cv.rect(0, 0, 2, 16, "M2"); cv.vline(0, 0, 15, "M3")
        cv.rect(14, 0, 2, 16, "M1"); cv.vline(15, 0, 15, "M0")
        cv.line(2, 1, 13, 14, "M2"); cv.line(2, 2, 12, 14, "M1")
        cv.line(13, 1, 2, 14, "M3"); cv.line(13, 2, 3, 14, "M2")
        cv.hline(0, 15, 0, "M3"); cv.hline(0, 15, 15, "M0")
    elif kind == "v":
        cv.rect(5, 0, 6, 16, "M2"); cv.vline(5, 0, 15, "M0"); cv.vline(10, 0, 15, "M0")
        cv.vline(6, 0, 15, "M3"); cv.vline(9, 0, 15, "M1")
        for y in (3, 11):
            cv.set(7, y, "M0"); cv.set(8, y, "M4")
    else:
        cv.rect(0, 5, 16, 6, "M2"); cv.hline(0, 15, 5, "M0"); cv.hline(0, 15, 10, "M0")
        cv.hline(0, 15, 6, "M3"); cv.hline(0, 15, 9, "M1")
        for x in (3, 11):
            cv.set(x, 7, "M0"); cv.set(x, 8, "M4")
    return cv


def lamp():
    cv = Canvas(16, 32)
    cv.ascii(0, 0, [
        "....00000000....",
        "...0bccccccb0...",
        "...0dddddddd0...",
        "....0YYYYYY0....",
        ".....0yyyy0.....",
        "......0dc0......",
    ])
    for y in range(6, 28):
        cv.set(6, y, "K0"); cv.set(7, y, "M3"); cv.set(8, y, "M2"); cv.set(9, y, "K0")
    cv.ascii(0, 28, [
        ".....00dc00.....",
        "....0bcddcb0....",
        "...0aaaaaaaa0...",
        "....00000000....",
    ])
    return cv


def door_frames():
    def door(openness):
        cv = Canvas(32, 48)
        cv.rect(0, 0, 32, 48, "M1")
        cv.rect(0, 0, 32, 1, "K0"); cv.rect(0, 0, 1, 48, "K0"); cv.rect(31, 0, 1, 48, "K0")
        cv.hline(1, 30, 1, "M3"); cv.vline(1, 1, 47, "M3"); cv.vline(30, 1, 47, "M0")
        cv.rect(4, 3, 24, 3, "M0"); cv.rect(13, 4, 6, 1, "T2" if openness else "O1")
        cv.rect(4, 7, 24, 41, "K0")  # opening
        gap = openness
        for side in (0, 1):
            x0 = 4 if side == 0 else 16 + gap
            w = 12 - gap
            if w <= 0:
                continue
            cv.rect(x0, 7, w, 41, "M2")
            cv.vline(x0, 7, 47, "M3")
            cv.vline(x0 + w - 1, 7, 47, "M0")
            for y in range(40, 47, 2):
                for x in range(x0 + 1, x0 + w - 1):
                    cv.set(x, y, "Y0" if (x + y) % 4 < 2 else "K1")
            cv.hline(x0 + 1, x0 + w - 2, 20, "M1")
            if w > 4:
                cv.rect(x0 + 2, 10, w - 4, 6, "T0")
                cv.hline(x0 + 2, x0 + w - 3, 10, "T1")
        if openness:
            cv.rect(4 + 12 - gap, 7, 2 * gap, 41, "K1")
            cv.vline(15 - gap + 1, 8, 47, "K0")
        return cv
    return frames(door(0), door(10))


def lever_frames():
    def lever(on):
        cv = Canvas(16, 16)
        base = [
            "...0000000000...",
            "..0dccccccccb0..",
            "..0caaaaaaaab0..",
            "..0bbbbbbbbbb0..",
            "..000000000000..",
        ]
        cv.ascii(0, 11, base)
        if on:
            cv.line(8, 11, 12, 5, "M3"); cv.line(9, 11, 13, 5, "M2")
            cv.rect(12, 3, 3, 3, "T2"); cv.set(12, 3, "T3"); cv.set(14, 5, "T1")
            cv.set(4, 12, "T2")
        else:
            cv.line(7, 11, 3, 5, "M3"); cv.line(8, 11, 4, 5, "M2")
            cv.rect(1, 3, 3, 3, "L1"); cv.set(1, 3, "L2"); cv.set(3, 5, "L0")
            cv.set(11, 12, "L1")
        return cv
    return frames(lever(False), lever(True))


def metal_panel(kind):
    cv = Canvas(16, 16)
    cv.rect(0, 0, 16, 16, "M1")
    cv.hline(0, 15, 0, "M3"); cv.vline(0, 0, 15, "M2")
    cv.hline(0, 15, 15, "M0"); cv.vline(15, 0, 15, "M0")
    for x, y in ((2, 2), (13, 2), (2, 13), (13, 13)):
        cv.set(x, y, "M3")
    if kind == "vent":
        for y in range(5, 12, 2):
            cv.hline(4, 11, y, "M0"); cv.hline(4, 11, y + 1, "M2")
    elif kind == "stripe":
        for y in range(5, 11):
            for x in range(1, 15):
                cv.set(x, y, "Y0" if (x + y) % 6 < 3 else "K1")
    elif kind == "window":
        cv.rect(4, 4, 8, 7, "K0")
        cv.rect(5, 5, 6, 5, "T0")
        cv.line(6, 9, 9, 6, "T1"); cv.set(9, 5, "T2")
    elif kind == "light":
        cv.rect(5, 5, 6, 6, "M0"); cv.rect(6, 6, 4, 4, "T2"); cv.set(6, 6, "T3")
    return cv


def infrastructure_items():
    it = [
        Item("solar_panel", solar_panel(), 2, 1),
        Item("o2_station", o2_station_frames(), 1, 2, frames=2, duration=0.6),
        Item("checkpoint", checkpoint_frames(), 1, 2, frames=2, duration=1.0, note="frame0 inactive, frame1 active (do not loop)"),
        Item("o2_tank", o2_tank(), note="matches o2_tank.tscn pickup"),
        Item("antenna", antenna(), 1, 2),
        Item("weather_sensor", weather_sensor()),
        Item("drill_rig", drill_rig(), 1, 2),
        Item("supply_crate", crate(), collision=SQUARE),
        Item("sample_canister", canister()),
        Item("lamp_post", lamp(), 1, 2),
        Item("airlock_door", door_frames(), 2, 3, frames=2, duration=1.0, note="frame0 closed, frame1 open"),
        Item("lever", lever_frames(), frames=2, duration=1.0, note="frame0 off, frame1 on"),
    ]
    for k in ("h", "v", "ne", "nw", "se", "sw"):
        it.append(Item(f"pipe_{k}", pipe(k)))
    for k in ("x", "v", "h"):
        it.append(Item(f"truss_{k}", truss(k)))
    for k in ("plain", "vent", "stripe", "window", "light"):
        it.append(Item(f"panel_{k}", metal_panel(k), collision=SQUARE))
    return it


# =========================================================================
# HAZARDS
# =========================================================================
LIQ_SEEDS = [(2, 3), (9, 1), (14, 6), (5, 9), (11, 12), (1, 14)]


def _plate(x, y):
    ds = []
    for sx, sy in LIQ_SEEDS:
        dx = (x - sx + 8) % 16 - 8
        dy = (y - sy + 8) % 16 - 8
        ds.append(math.hypot(dx, dy * 1.4))
    ds.sort()
    return ds[1] - ds[0], ds[0]


def liquid_frames(pal, top):
    """pal = [deep, mid, bright, crest, spark]. 4 frames, seamless horizontally and vertically."""
    out = []
    for f in range(4):
        cv = Canvas(16, 16)
        for y in range(16):
            for x in range(16):
                if top:
                    ph = 2 * math.pi * (x + 4 * f) / 16
                    surf = 3 + 1.2 * math.sin(ph) + 0.6 * math.sin(2 * ph + 1)
                    if y < surf:
                        continue
                    if y < surf + 1:
                        cv.set(x, y, pal[3]); continue
                    if y < surf + 2:
                        cv.set(x, y, pal[2]); continue
                gap, d0 = _plate((x - 4 * f) % 16, y)
                if gap < 0.9:
                    c = pal[3]
                elif gap < 2.0:
                    c = pal[2]
                elif gap < 3.6:
                    c = pal[1]
                else:
                    c = pal[0]
                cv.set(x, y, c)
        if top:
            sx = (5 + 4 * f) % 16
            if f % 2 == 0:
                cv.set(sx, 1, pal[4])
        out.append(cv)
    return frames(*out)


def spikes(ramp, kind):
    cv = Canvas(16, 16)
    if kind == "metal":
        for i in range(4):
            cv.paste(spike_shape(5, 9, ramp, base_w=5), i * 4 - 1 if i else 0, 5)
        cv.rect(0, 13, 16, 3, "M1"); cv.hline(0, 15, 13, "M3"); cv.hline(0, 15, 15, "M0")
    else:
        for ox, h in ((-1, 10), (5, 13), (11, 9)):
            cv.paste(spike_shape(7, h, ramp, base_w=7), ox, 16 - h)
    return cv


def vent_frames(pal, grate_light):
    out = []
    for f in range(3):
        cv = Canvas(16, 16)
        cv.rect(2, 12, 12, 4, "M1"); cv.hline(2, 13, 12, "M3"); cv.hline(2, 13, 15, "M0")
        cv.vline(1, 12, 15, "K0"); cv.vline(14, 12, 15, "K0")
        for x in range(4, 12, 2):
            cv.set(x, 13, grate_light); cv.set(x, 14, pal[0])
        for i in range(9):
            x = 4 + (H(i, f) % 8)
            y = 11 - ((i * 3 + f * 4) % 11)
            c = pal[1] if y > 7 else pal[2] if y > 3 else pal[3]
            cv.set(x, y, c)
            if y > 6:
                cv.set(x, y + 1, pal[1])
        out.append(cv)
    return frames(*out)


def sign(icon, fill="Y0"):
    cv = Canvas(16, 16)
    for r in range(10):
        hw = r * 0.65 + 0.6
        for x in range(16):
            if abs(x + 0.5 - 8) <= hw:
                edge = abs(x + 0.5 - 8) > hw - 1 or r == 9
                cv.set(x, 1 + r, "K0" if edge else fill)
    cv.ascii(6, 5, icon, legend={".": None, "0": "K0"})
    cv.rect(7, 11, 2, 5, "M2"); cv.vline(8, 11, 15, "M1")
    return cv


ICONS = {
    "heat": ["..0..", ".00..", ".000.", "00000", ".000."],
    "cold": ["0.0.0", ".000.", "00000", ".000.", "0.0.0"],
    "radiation": ["00.00", "00.00", "..0..", ".000.", "....."],
}


def o2_sign():
    return art([
        "..000000000000..",
        "..0vvvvvvvvvv0..",
        "..0vv00vvvvvv0..",
        "..0v0vv0vvvvv0..",
        "..0v0vv0v00vv0..",
        "..0vv00vvvv0v0..",
        "..0vvvvvvv0vv0..",
        "..0vvvvvv000v0..",
        "..0uuuuuuuuuu0..",
        "..000000000000..",
        ".......dc.......",
        ".......dc.......",
        ".......dc.......",
        ".......dc.......",
        ".......dc.......",
    ])


def barrel():
    return art([
        "....00000000....",
        "...0YYYYYYYy0...",
        "...0yyyyyyyy0...",
        "...0hhhhhhhh0...",
        "...0YYY0YYYy0...",
        "...0YY000Yyy0...",
        "...0Y0Y0Y0yy0...",
        "...0Y00000yy0...",
        "...0YYY0YYyy0...",
        "...0hhhhhhhh0...",
        "...0yyyyyyyy0...",
        "...0YYYYYYyy0...",
        "...0yyyyyyyy0...",
        "...G0000000g....",
        "..gGg......gG...",
    ])


def magma_rock_frames():
    t = TERRAINS["rock"]
    out = []
    veins = [(1, 3), (4, 5), (6, 4), (9, 7), (11, 6), (14, 9), (6, 10), (4, 13), (8, 12), (12, 14)]
    for f in range(2):
        cv = Canvas(16, 16)
        for y in range(16):
            for x in range(16):
                cv.set(x, y, t.body(x, y, 0))
        for (x0, y0), (x1, y1) in zip(veins, veins[1:]):
            if abs(x1 - x0) + abs(y1 - y0) < 8:
                cv.line(x0, y0, x1, y1, "L1" if f == 0 else "L2")
        for x, y in veins[::3]:
            cv.set(x, y, "L3" if f == 0 else "L4")
        out.append(cv)
    return frames(*out)


def hazard_items():
    lava = ["L0", "L1", "L2", "L3", "L4"]
    sludge = ["G0", "G1", "G2", "G3", "W"]
    it = [
        Item("lava_top", liquid_frames(lava, True), frames=4, hazard="LavaZone", duration=0.18),
        Item("lava_body", liquid_frames(lava, False), frames=4, hazard="LavaZone", duration=0.18),
        Item("sludge_top", liquid_frames(sludge, True), frames=4, hazard="radiation", duration=0.22),
        Item("sludge_body", liquid_frames(sludge, False), frames=4, hazard="radiation", duration=0.22),
        Item("magma_rock", magma_rock_frames(), frames=2, collision=SQUARE, hazard="heat", duration=0.5),
        Item("heat_vent", vent_frames(["L1", "L2", "L3", "L4"], "L2"), frames=3, hazard="heat", duration=0.12),
        Item("cryo_vent", vent_frames(["F1", "F2", "F3", "F4"], "F2"), frames=3, hazard="chill", duration=0.14),
    ]
    rs = spikes(["B0", "R0", "R1", "R2", "S1"], "rock")
    ms = spikes(["K0", "M1", "M2", "M3", "M4"], "metal")
    it += [
        Item("spikes_rock_up", rs, hazard="Spikes"),
        Item("spikes_rock_down", rs.flip_v(), hazard="Spikes", anchor="top"),
        Item("spikes_metal_up", ms, hazard="Spikes"),
        Item("spikes_metal_down", ms.flip_v(), hazard="Spikes", anchor="top"),
    ]
    ml = Canvas(16, 16); ml.a = np.rot90(ms.a, -1).copy()
    mr = Canvas(16, 16); mr.a = np.rot90(ms.a, 1).copy()
    it += [Item("spikes_metal_left_wall", ml, hazard="Spikes"), Item("spikes_metal_right_wall", mr, hazard="Spikes")]
    it += [
        Item("ice_crystals", crystal_cluster(16, ICE, [(4, 8, 4, -1), (8, 13, 5, 0), (12, 9, 4, 1)]), hazard="chill"),
        Item("frost_rime", art([
            ".E....E...E..E..",
            "EIE..EIE.EIEEIE.",
            "IFIEEIFIEIFIIFIE",
        ], pad_top=False), note="overlay on terrain top"),
        Item("radiation_ore", crystal_cluster(16, RAD, [(5, 9, 4, -1), (9, 12, 5, 1), (12, 6, 3, 1)]), hazard="radiation"),
        Item("radioactive_barrel", barrel(), hazard="radiation"),
        Item("sign_heat", sign(ICONS["heat"])),
        Item("sign_cold", sign(ICONS["cold"], "F3")),
        Item("sign_radiation", sign(ICONS["radiation"])),
        Item("sign_o2", o2_sign()),
    ]
    return it


# =========================================================================
# SAND DECALS / TRANSITIONS
# =========================================================================
def sand_items():
    it = []
    # drifts sitting in the empty cell ABOVE a rock top
    def drift(fn):
        cv = Canvas(16, 16)
        for x in range(16):
            h = fn(x)
            for k in range(h):
                y = 15 - k
                c = "S3" if k == h - 1 else "S2" if k == h - 2 else "S1"
                cv.set(x, y, c)
        return cv
    it.append(Item("sand_drift_L", drift(lambda x: max(0, (x - 2) // 3))))
    it.append(Item("sand_drift_M", drift(lambda x: 4 + int(round(math.sin(x / 16 * 2 * math.pi))))))
    it.append(Item("sand_drift_R", drift(lambda x: max(0, (13 - x) // 3))))
    it.append(Item("sand_mound", drift(lambda x: max(0, int(5 - abs(x - 7.5) * 0.8)))))
    # covers drawn ON TOP of a rock top tile, hiding the crust
    def cover(lo, hi):
        cv = Canvas(16, 16)
        for x in range(lo, hi):
            d = 4 + int(round(math.sin(x / 16 * 2 * math.pi) * 0.8))
            if x - lo < 3:
                d = min(d, x - lo + 2)
            if hi - x <= 3:
                d = min(d, hi - x + 1)
            for y in range(d):
                cv.set(x, y, "S3" if y == 0 else "S2" if y == 1 else "S1" if y < d - 1 else "S0")
        return cv
    it.append(Item("sand_cover_L", cover(4, 16), note="overlay on rock top"))
    it.append(Item("sand_cover_M", cover(0, 16), note="overlay on rock top"))
    it.append(Item("sand_cover_R", cover(0, 12), note="overlay on rock top"))
    spill = Canvas(16, 16)
    for y in range(16):
        w = max(0, 5 - y // 3 - (H(y, 4) % 2))
        for x in range(w):
            spill.set(x, y, "S2" if x == w - 1 else "S1")
    it.append(Item("sand_spill_edge", spill, note="overlay on left wall top; flip_h for right"))
    rip = Canvas(16, 16)
    for y in (3, 8, 13):
        for x in range(16):
            yy = y + int(round(math.sin((x + y) / 16 * 2 * math.pi)))
            if (x + y) % 7 != 0:
                rip.set(x, yy, "S3")
    it.append(Item("sand_ripples", rip, note="overlay on sand body"))
    return it

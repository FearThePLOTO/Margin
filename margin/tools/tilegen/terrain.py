"""Terrain materials, 47-tile blob autotile sheets, slopes, and shape-rendered pieces."""
import math
import numpy as np
from core import Canvas, H, T, render_terrain

# blob neighbour bits
N, NE, E, SE, S, SW, W, NW = 1, 2, 4, 8, 16, 32, 64, 128
NEIGH = [(N, 1, 0), (NE, 2, 0), (E, 2, 1), (SE, 2, 2), (S, 1, 2), (SW, 0, 2), (W, 0, 1), (NW, 0, 0)]
PEERING = {N: "top_side", NE: "top_right_corner", E: "right_side", SE: "bottom_right_corner",
           S: "bottom_side", SW: "bottom_left_corner", W: "left_side", NW: "top_left_corner"}


def canon(m):
    if not (m & N and m & E):
        m &= ~NE
    if not (m & S and m & E):
        m &= ~SE
    if not (m & S and m & W):
        m &= ~SW
    if not (m & N and m & W):
        m &= ~NW
    return m


def _blob_order():
    masks = sorted(set(canon(m) for m in range(256)))
    assert len(masks) == 47

    # human-friendly order: group by which orthogonal sides are open
    def key(m):
        ortho = (m & N > 0, m & E > 0, m & S > 0, m & W > 0)
        return (-sum(ortho), ortho, -bin(m).count("1"), m)
    return sorted(masks, key=key)


BLOB_MASKS = _blob_order()
TOP_ONLY = canon(E | SE | S | SW | W)


class Terrain:
    def __init__(self, key, name, body, crust, crust_line, outline, rim_l, rim_r, under,
                 top_speck, specks, seed, tex, icicles=False):
        self.key, self.name = key, name
        self.crust, self.crust_line = crust, crust_line
        self.outline, self.rim_l, self.rim_r, self.under = outline, rim_l, rim_r, under
        self.top_speck, self.specks, self.seed = top_speck, specks, seed
        self.tex = tex
        self.icicles = icicles

    def body(self, lx, ly, variant):
        c = self.tex[ly][lx]
        if variant and H(lx, ly, variant, self.seed, 5) % 19 == 0:
            c = self.specks[H(lx, ly, variant) % len(self.specks)]
        return c

    def color(self, face, d, lx, ly, gx, variant):
        col = gx % T
        if face == "top":
            n = len(self.crust)
            extra = H(col, self.seed, 1) % 2
            if d <= n:
                c = self.crust[d - 1]
                if d == 1 and H(col, self.seed, variant, 2) % 5 == 0:
                    c = self.top_speck
                return c
            if d <= n + extra:
                return self.crust[-1]
            if d == n + extra + 1 and self.crust_line:
                return self.crust_line
        elif face in ("left", "right"):
            if d == 1:
                return self.outline
            if d == 2:
                return self.rim_l if face == "left" else self.rim_r
        elif face == "bottom":
            if self.icicles:
                L = [0, 3, 1, 0, 2, 4, 0, 1, 3, 0, 0, 2, 5, 1, 0, 2][(col + self.seed) % 16]
                if d <= L:
                    return "F3" if d == 1 else "F2"
            if d == 1:
                return self.outline
            if d == 2:
                return self.under
        return self.body(lx, ly, variant)


# -- body textures (16x16, periodic so tiles repeat seamlessly) -------------
def tex_strata(line, hi, fill, speck, seed):
    t = []
    for y in range(T):
        row = []
        for x in range(T):
            wv = int(round(1.4 * math.sin(2 * math.pi * x / T + seed)))
            b = (y + wv) % 8
            c = line if b == 0 else hi if b == 1 else fill
            if c == fill and H(x, y, seed) % 17 == 0:
                c = speck
            row.append(c)
        t.append(row)
    return t


def tex_voronoi(crack, hi, fill, shadow, seeds):
    t = []
    for y in range(T):
        row = []
        for x in range(T):
            ds = []
            for sx, sy in seeds:
                dx = (x - sx + 8) % 16 - 8
                dy = (y - sy + 8) % 16 - 8
                ds.append((math.hypot(dx, dy), dx, dy))
            ds.sort()
            gap = ds[1][0] - ds[0][0]
            _, vx, vy = ds[0]
            if gap < 1.0:
                c = crack
            elif gap < 2.2 and vx + vy < 0:
                c = hi
            elif gap < 2.0 and vx + vy > 0:
                c = shadow
            else:
                c = fill
            row.append(c)
        t.append(row)
    return t


def tex_ripple(fill, ripple, specks, seed):
    t = []
    for y in range(T):
        row = []
        for x in range(T):
            wv = int(round(1.2 * math.sin(4 * math.pi * x / T + seed)))
            c = ripple if (y + wv) % 5 == 0 else fill
            hh = H(x, y, seed)
            if hh % 37 == 0:
                c = specks[0]
            elif hh % 41 == 0:
                c = specks[1]
            row.append(c)
        t.append(row)
    return t


TERRAINS = {
    "rock": Terrain(
        "rock", "Mars Rock", None, ["S2", "O0", "R2", "R1"], "B1", "B0", "R2", "B1", "B1",
        "S3", ["R1", "B0", "R0"], 3, tex_strata("B0", "R0", "B1", "R0", 0.0)),
    "cave": Terrain(
        "cave", "Cave Rock", None, ["O2", "O0", "R2", "R1"], "B0", "K1", "R0", "P0", "P0",
        "S2", ["P3", "R0", "K2"], 7,
        tex_voronoi("K1", "P2", "P1", "P0", [(3, 3), (11, 2), (7, 9), (14, 12), (1, 13)])),
    "sand": Terrain(
        "sand", "Regolith Sand", None, ["S3", "S2", "S1"], None, "R1", "S1", "R2", "R2",
        "S0", ["R2", "S2"], 11, tex_ripple("S0", "S1", ["R2", "S2"], 1.0)),
    "sandy_rock": Terrain(
        "sandy_rock", "Sand-Topped Rock", None, ["S3", "S2", "S1", "S1", "S0"], "R1", "B0", "R2",
        "B1", "B1", "S1", ["R1", "B0", "R0"], 5, tex_strata("B0", "R0", "B1", "R0", 2.0)),
    "frost": Terrain(
        "frost", "Frost Rock", None, ["F4", "F3", "F2", "F1"], "K2", "K1", "F1", "K2", "K2",
        "W", ["F2", "K2", "F1"], 13,
        tex_voronoi("K1", "F1", "F0", "K2", [(2, 4), (10, 1), (6, 10), (13, 9), (15, 15)]),
        icicles=True),
}


# -- blob tiles -------------------------------------------------------------
def blob_occ(mask, variant, seed):
    occ = np.zeros((48, 48), bool)
    occ[16:32, 16:32] = True
    for bit, cx, cy in NEIGH:
        if mask & bit:
            occ[cy * 16:(cy + 1) * 16, cx * 16:(cx + 1) * 16] = True
    o = 16
    if not mask & N:
        for x in range(2, 14):
            if H(x, seed, variant, 11) % 5 == 0:
                occ[o, o + x] = False
    if not mask & S:
        for x in range(2, 14):
            if H(x, seed, variant, 14) % 6 == 0:
                occ[o + 15, o + x] = False
    if not mask & W:
        for y in range(3, 13):
            if H(y, seed, variant, 12) % 6 == 0:
                occ[o + y, o] = False
    if not mask & E:
        for y in range(3, 13):
            if H(y, seed, variant, 13) % 6 == 0:
                occ[o + y, o + 15] = False
    # rounded outer corners
    corners = [(N, W, [(0, 0), (1, 0), (0, 1)]), (N, E, [(15, 0), (14, 0), (15, 1)]),
               (S, W, [(0, 15), (1, 15), (0, 14)]), (S, E, [(15, 15), (14, 15), (15, 14)])]
    for a, b, px in corners:
        if not mask & a and not mask & b:
            for x, y in px:
                occ[o + y, o + x] = False
    return occ


def render_blob(terrain, mask, variant=0):
    occ = blob_occ(mask, variant, terrain.seed)
    return render_terrain(occ, terrain, 16, 16, 16, 16, variant)


BLOB_COLS = 12


def blob_sheet(terrain):
    """Returns (Canvas, tiles) where tiles = [(col,row,mask,probability)]."""
    rows = 5
    cv = Canvas(BLOB_COLS * T, rows * T)
    tiles = []
    for i, m in enumerate(BLOB_MASKS):
        c, r = i % BLOB_COLS, i // BLOB_COLS
        cv.paste(render_blob(terrain, m), c * T, r * T)
        tiles.append((c, r, m, 1.0))
    extras = [(255, 1), (255, 2), (255, 3), (TOP_ONLY, 1), (TOP_ONLY, 2)]
    for j, (m, v) in enumerate(extras):
        c, r = j, 4
        cv.paste(render_blob(terrain, m, v), c * T, r * T)
        tiles.append((c, r, m, 0.35))
    return cv, tiles


# -- slopes -----------------------------------------------------------------
def _slope_occ(kind):
    """Floor slopes rising to the right. Returns (occ, x0, y0, ntiles)."""
    if kind == "45":
        occ = np.zeros((48, 48), bool)
        occ[32:, :] = True
        occ[16:32, 32:] = True
        for y in range(16):
            for x in range(16):
                if y + 0.5 >= 16 - (x + 0.5):
                    occ[16 + y, 16 + x] = True
        return occ, 16, 16, 1
    occ = np.zeros((48, 64), bool)
    occ[32:, :] = True
    occ[16:32, 48:] = True
    for y in range(16):
        for gx in range(32):
            if y + 0.5 >= 16 - (gx + 0.5) / 2:
                occ[16 + y, 16 + gx] = True
    return occ, 16, 16, 2


SLOPE_POLYS = {
    "45": [[(-8, 8), (8, -8), (8, 8)]],
    "22": [[(-8, 8), (8, 0), (8, 8)], [(-8, 0), (8, -8), (8, 8), (-8, 8)]],
}


def slope_row(terrain):
    """12 tiles: floor 45 R, floor 45 L, floor 22 R (2), floor 22 L (2), then ceilings."""
    tiles = []  # (Canvas, polygon, name)
    for ceiling in (False, True):
        for kind in ("45", "22"):
            for mirror in (False, True):
                occ, x0, y0, n = _slope_occ(kind)
                if mirror:
                    occ = occ[:, ::-1].copy()
                if ceiling:
                    occ = occ[::-1, :].copy()
                ow = occ.shape[1]
                rx0 = x0 if not mirror else ow - x0 - n * T
                cv = render_terrain(occ, terrain, rx0, y0, n * T, T)
                for i in range(n):
                    poly = SLOPE_POLYS[kind][i if not mirror else n - 1 - i]
                    if mirror:
                        poly = [(-x, y) for x, y in poly]
                    if ceiling:
                        poly = [(x, -y) for x, y in poly]
                    nm = f"{'ceil' if ceiling else 'floor'}_{kind}_{'L' if mirror else 'R'}_{i}"
                    tiles.append((cv.crop(i * T, 0, T, T), poly, nm))
    return tiles


# -- generic occupancy pieces (islands, ledges, craters, slabs) -------------
def render_shape(occ_fn, w, h, terrain, pad=8, side_ground=None, variant=0):
    """occ_fn(x, y) -> solid for x in [0,w), y in [0,h).
    side_ground: if set, the padding left/right is solid below this y."""
    occ = np.zeros((h + 2 * pad, w + 2 * pad), bool)
    for y in range(h):
        for x in range(w):
            occ[pad + y, pad + x] = occ_fn(x, y)
    if side_ground is not None:
        occ[pad + side_ground:, :pad] = True
        occ[pad + side_ground:, pad + w:] = True
        occ[pad + h:, :] = True
    return render_terrain(occ, terrain, pad, pad, w, h, variant), occ[pad:pad + h, pad:pad + w]


def _rdp(pts, eps):
    if len(pts) < 3:
        return pts
    (x0, y0), (x1, y1) = pts[0], pts[-1]
    dmax, idx = 0, 0
    L = math.hypot(x1 - x0, y1 - y0) or 1
    for i in range(1, len(pts) - 1):
        x, y = pts[i]
        d = abs((y1 - y0) * x - (x1 - x0) * y + x1 * y0 - y1 * x0) / L
        if d > dmax:
            dmax, idx = d, i
    if dmax > eps:
        return _rdp(pts[:idx + 1], eps)[:-1] + _rdp(pts[idx:], eps)
    return [pts[0], pts[-1]]


def heightmap_poly(tile_occ):
    """Collision polygon (tile-centred coords) for a bottom-anchored solid tile."""
    tops = []
    for x in range(T):
        col = np.where(tile_occ[:, x])[0]
        tops.append(col[0] if len(col) else T)
    if all(t >= T for t in tops):
        return None
    if all(t == 0 for t in tops):
        return [(-8, -8), (8, -8), (8, 8), (-8, 8)]
    pts = [(0, tops[0])] + [(x + 0.5, tops[x]) for x in range(T)] + [(16, tops[-1])]
    pts = _rdp(pts, 0.8)
    poly = [(round(x - 8, 1), round(y - 8, 1)) for x, y in pts] + [(8, 8), (-8, 8)]
    return poly

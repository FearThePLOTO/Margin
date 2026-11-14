"""Autotile a char map with the blob sheets (same rules Godot's terrain painter uses)."""
from core import Canvas, T
from terrain import TERRAINS, render_blob, canon, NEIGH, N, E, S, W, TOP_ONLY
from core import H

_cache = {}


def blob_tile(tkey, mask, variant):
    k = (tkey, mask, variant)
    if k not in _cache:
        _cache[k] = render_blob(TERRAINS[tkey], mask, variant)
    return _cache[k]


def paint(cv, grid, legend, ox=0, oy=0):
    """grid: list of strings; legend: char -> terrain key."""
    h, w = len(grid), len(grid[0])

    def solid(x, y, key):
        if x < 0 or x >= w or y < 0 or y >= h:
            return True  # map continues off-screen
        return legend.get(grid[y][x]) == key

    for y in range(h):
        for x in range(w):
            key = legend.get(grid[y][x])
            if not key:
                continue
            m = 0
            for bit, cx, cy in NEIGH:
                if solid(x + cx - 1, y + cy - 1, key):
                    m |= bit
            m = canon(m)
            v = 0
            if m == 255:
                v = [0, 0, 1, 2, 3, 0][H(x, y) % 6]
            elif m == TOP_ONLY:
                v = [0, 1, 2][H(x, y, 3) % 3]
            cv.paste(blob_tile(key, m, v), ox + x * T, oy + y * T)

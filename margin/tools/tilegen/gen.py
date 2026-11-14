#!/usr/bin/env python3
"""Margin — Mars Surface tileset generator.

Usage:  python gen.py <godot-project-root>

Regenerates every PNG under src/assets/Margin_Mars_Surface/, the Godot TileSet
src/features/level_design/tilesets/mars_tileset.tres, previews and docs.
Deterministic: same code -> byte-identical output.
"""
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

from core import Canvas, T
from palette import PAL, RGBA
from terrain import TERRAINS, BLOB_COLS, blob_sheet, slope_row, PEERING, NEIGH
import props
from props import Item, SQUARE

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "../..")
ASSET_DIR = "src/assets/Margin_Mars_Surface"
OUT = os.path.join(ROOT, ASSET_DIR)
TRES = os.path.join(ROOT, "src/features/level_design/tilesets/mars_tileset.tres")
SHEET_COLS = 16


def res(path):
    return "res://" + os.path.relpath(path, ROOT).replace(os.sep, "/")


def save(cv, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    cv.to_image().save(path, optimize=True)


# ---------------------------------------------------------------------------
# shelf packer for prop sheets
# ---------------------------------------------------------------------------
def pack(items, cols=SHEET_COLS):
    placed, x, y, shelf_h = [], 0, 0, 0
    for it in items:
        w = it.w * it.frames
        if x + w > cols:
            x, y, shelf_h = 0, y + shelf_h, 0
        placed.append((it, x, y))
        x += w
        shelf_h = max(shelf_h, it.h)
    rows = y + shelf_h
    cv = Canvas(cols * T, rows * T)
    for it, cx, cy in placed:
        cv.paste(it.cv, cx * T, cy * T)
    return cv, placed


# ---------------------------------------------------------------------------
# Godot .tres writer
# ---------------------------------------------------------------------------
def vec_arr(poly):
    return "PackedVector2Array(" + ", ".join(f"{_n(x)}, {_n(y)}" for x, y in poly) + ")"


def _n(v):
    return str(int(v)) if float(v).is_integer() else str(v)


class TresWriter:
    def __init__(self):
        self.ext, self.subs, self.sources = [], [], []
        self.terrain_sets = []

    def texture(self, path):
        i = len(self.ext) + 1
        self.ext.append(f'[ext_resource type="Texture2D" path="{res(path)}" id="{i}_tex"]')
        return f"{i}_tex"

    def source(self, sid, tex_id, lines):
        body = [f'[sub_resource type="TileSetAtlasSource" id="{sid}"]',
                f'texture = ExtResource("{tex_id}")',
                "texture_region_size = Vector2i(16, 16)"] + lines
        self.subs.append("\n".join(body))
        self.sources.append(sid)

    def write(self, path):
        out = ['[gd_resource type="TileSet" format=3]', ""]
        out += self.ext + [""]
        for s in self.subs:
            out += [s, ""]
        out += ["[resource]", "tile_size = Vector2i(16, 16)",
                "physics_layer_0/collision_layer = 1",
                "physics_layer_0/collision_mask = 1"]
        for i, (name, color) in enumerate(self.terrain_sets):
            out += [f"terrain_set_{i}/mode = 0",
                    f'terrain_set_{i}/terrain_0/name = "{name}"',
                    f"terrain_set_{i}/terrain_0/color = {color}"]
        out += ['custom_data_layer_0/name = "hazard"', "custom_data_layer_0/type = 21"]
        for i, sid in enumerate(self.sources):
            out.append(f'sources/{i} = SubResource("{sid}")')
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write("\n".join(out) + "\n")


def tile_lines(c, r, alt=None, poly=None, one_way=False, size=None, frames=1, duration=0.15,
               hazard=None, origin=None, probability=None):
    k = f"{c}:{r}"
    L = []
    if size and size != (1, 1):
        L.append(f"{k}/size_in_atlas = Vector2i({size[0]}, {size[1]})")
    if frames > 1:
        L.append(f"{k}/animation_frames_count = {frames}")
        for f in range(frames):
            L.append(f"{k}/animation_frame_{f}/duration = {duration}")
    L.append(f"{k}/0 = 0")
    if origin:
        L.append(f"{k}/0/texture_origin = Vector2i({origin[0]}, {origin[1]})")
    if probability is not None and probability != 1.0:
        L.append(f"{k}/0/probability = {probability}")
    if alt:
        L += [f"{k}/0/{a}" for a in alt]
    if poly:
        L.append(f"{k}/0/physics_layer_0/polygon_0/points = {vec_arr(poly)}")
        if one_way:
            L.append(f"{k}/0/physics_layer_0/polygon_0/one_way = true")
    if hazard:
        L.append(f'{k}/0/custom_data_0 = &"{hazard}"')
    return L


def origin_for(it):
    if it.w == 1 and it.h == 1:
        return None
    if it.anchor == "top":
        return (8 - 8 * it.w, 8 - 8 * it.h)
    return (8 - 8 * it.w, 8 * it.h - 8)


TERRAIN_COLORS = {"rock": "Color(0.72, 0.29, 0.16, 1)", "cave": "Color(0.34, 0.2, 0.34, 1)",
                  "sand": "Color(0.89, 0.68, 0.43, 1)", "sandy_rock": "Color(0.95, 0.81, 0.59, 1)",
                  "frost": "Color(0.5, 0.69, 0.84, 1)"}


# ---------------------------------------------------------------------------
# previews
# ---------------------------------------------------------------------------
def checker(w, h, s=4):
    img = Image.new("RGBA", (w, h), (34, 30, 44, 255))
    d = ImageDraw.Draw(img)
    for y in range(0, h, s * 4):
        for x in range(0, w, s * 4):
            if (x // (s * 4) + y // (s * 4)) % 2:
                d.rectangle([x, y, x + s * 4 - 1, y + s * 4 - 1], fill=(44, 38, 56, 255))
    return img


def labeled_preview(cv, placed, title, path, scale=4):
    """Upscaled sheet on a checkerboard with grid + item labels (labels live ONLY here)."""
    img = cv.to_image().resize((cv.w * scale, cv.h * scale), Image.NEAREST)
    pad_top = 28
    rows_px = cv.h * scale
    label_h = 12
    # make room for a label strip under every shelf
    shelves = sorted(set(cy for _, _, cy in placed)) if placed else []
    out_h = pad_top + rows_px + label_h * (len(shelves) + 1) + 8
    out = checker(cv.w * scale + 16, out_h)
    d = ImageDraw.Draw(out)
    d.text((8, 8), title, fill=(102, 217, 192, 255))
    shelf_shift = {cy: i for i, cy in enumerate(shelves)}
    # paste shelf by shelf so labels can sit between shelves
    if placed:
        bounds = []
        for i, cy in enumerate(shelves):
            nxt = shelves[i + 1] if i + 1 < len(shelves) else cv.h // T
            bounds.append((cy, nxt))
        for i, (a, b) in enumerate(bounds):
            strip = img.crop((0, a * T * scale, img.width, b * T * scale))
            oy = pad_top + a * T * scale + i * label_h
            out.alpha_composite(strip, (8, oy))
            for gx in range(0, img.width + 1, T * scale):
                d.line([(8 + gx, oy), (8 + gx, oy + strip.height - 1)], fill=(80, 70, 96, 255))
            for gy in range(0, strip.height + 1, T * scale):
                d.line([(8, oy + gy), (8 + img.width, oy + gy)], fill=(80, 70, 96, 255))
        for it, cx, cy in placed:
            i = shelf_shift[cy]
            ly = pad_top + (cy + it.h) * T * scale + i * label_h + 1
            # label sits right below the item, inside next strip gap if item is shorter than shelf
            shelf_end = bounds[i][1]
            ly = pad_top + shelf_end * T * scale + i * label_h + 1
            txt = it.name if it.frames == 1 else f"{it.name} x{it.frames}"
            d.text((8 + cx * T * scale + 2, ly), txt[: max(6, it.w * it.frames * 10)], fill=(242, 115, 31, 255))
    else:
        out.alpha_composite(img, (8, pad_top))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out.save(path)


# ---------------------------------------------------------------------------
# validation
# ---------------------------------------------------------------------------
PAL_SET = {tuple(int(v.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)) for v in PAL.values()}


def validate_png(path):
    im = Image.open(path)
    errs = []
    if im.mode != "RGBA":
        errs.append(f"mode {im.mode}")
    w, h = im.size
    if w % T or h % T:
        errs.append(f"size {w}x{h} not a multiple of 16")
    a = np.asarray(im.convert("RGBA"))
    alpha = set(np.unique(a[..., 3]).tolist())
    if not alpha <= {0, 255}:
        errs.append(f"semi-transparent alpha values {sorted(alpha - {0, 255})[:5]}")
    opaque = a[a[..., 3] == 255][:, :3]
    cols = {tuple(c) for c in np.unique(opaque, axis=0).tolist()} if len(opaque) else set()
    off = cols - PAL_SET
    if off:
        errs.append(f"{len(off)} off-palette colours")
    return (w, h, len(cols)), errs


# ---------------------------------------------------------------------------
def main():
    tw = TresWriter()
    manifest = {}
    report = []

    # ---- terrains --------------------------------------------------------
    terrain_paths = {}
    for i, (key, t) in enumerate(TERRAINS.items()):
        cv, tiles = blob_sheet(t)
        folder = "Sand" if key == "sand" else "Terrain"
        path = os.path.join(OUT, folder, f"terrain_{key}.png")
        save(cv, path)
        terrain_paths[key] = path
        tw.terrain_sets.append((t.name, TERRAIN_COLORS[key]))
        tex = tw.texture(path)
        lines = []
        for c, r, mask, prob in tiles:
            alt = [f"terrain_set = {i}", "terrain = 0"]
            for bit, _, _ in NEIGH:
                if mask & bit:
                    alt.append(f"terrains_peering_bit/{PEERING[bit]} = 0")
            lines += tile_lines(c, r, alt=alt, poly=SQUARE, probability=prob)
        tw.source(f"terrain_{key}", tex, lines)
        manifest[f"terrain_{key}"] = {"png": res(path), "terrain_set": i,
                                      "tiles": [{"coords": [c, r], "mask": m, "probability": p}
                                                for c, r, m, p in tiles]}
        labeled_preview(cv, [], f"{t.name}  (terrain set {i}: 47-tile blob + 5 random variants, row 5)",
                        os.path.join(OUT, "Previews", f"terrain_{key}.png"))

    # ---- slopes ----------------------------------------------------------
    slope_keys = ["rock", "cave", "sand", "sandy_rock", "frost"]
    scv = Canvas(12 * T, len(slope_keys) * T)
    slope_lines, slope_man = [], []
    for r, key in enumerate(slope_keys):
        for c, (tile, poly, nm) in enumerate(slope_row(TERRAINS[key])):
            scv.paste(tile, c * T, r * T)
            slope_lines += tile_lines(c, r, poly=poly)
            slope_man.append({"name": f"{key}_{nm}", "coords": [c, r]})
    spath = os.path.join(OUT, "Terrain", "slopes.png")
    save(scv, spath)
    tw.source("slopes", tw.texture(spath), slope_lines)
    manifest["slopes"] = {"png": res(spath), "tiles": slope_man}
    labeled_preview(scv, [], "Slopes  rows: rock, cave, sand, sandy rock, frost | cols: floor45 R/L, floor22 R(2)/L(2), ceil45 R/L, ceil22 R(2)/L(2)",
                    os.path.join(OUT, "Previews", "slopes.png"))

    # ---- prop sheets -----------------------------------------------------
    sheets = [
        ("Platforms", "platforms", props.platform_items()),
        ("Geological", "geology", props.geology_items()),
        ("Vegetation", "vegetation", props.vegetation_items()),
        ("Parkour", "parkour", props.parkour_items()),
        ("Infrastructure", "infrastructure", props.infrastructure_items()),
        ("Hazards", "hazards", props.hazard_items()),
        ("Sand", "sand_decals", props.sand_items()),
    ]
    all_placed = {}
    for folder, key, items in sheets:
        cv, placed = pack(items)
        path = os.path.join(OUT, folder, f"{key}.png")
        save(cv, path)
        tex = tw.texture(path)
        lines, man = [], []
        used = {}
        for it, cx, cy in placed:
            for f in range(it.frames):
                for yy in range(it.h):
                    for xx in range(it.w):
                        cell = (cx + f * it.w + xx, cy + yy)
                        assert cell not in used, f"overlap {it.name} vs {used[cell]}"
                        used[cell] = it.name
            lines += tile_lines(cx, cy, poly=it.collision, one_way=it.one_way, size=(it.w, it.h),
                                frames=it.frames, duration=it.duration, hazard=it.hazard,
                                origin=origin_for(it))
            man.append({"name": it.name, "coords": [cx, cy], "size": [it.w, it.h], "frames": it.frames,
                        "collision": bool(it.collision), "one_way": it.one_way, "hazard": it.hazard,
                        "anchor": it.anchor, "note": it.note})
        tw.source(key, tex, lines)
        manifest[key] = {"png": res(path), "tiles": man}
        all_placed[key] = (cv, placed)
        labeled_preview(cv, placed, f"{key}.png  ({len(items)} items)", os.path.join(OUT, "Previews", f"{key}.png"))

    tw.write(TRES)

    # ---- validation ------------------------------------------------------
    ok = True
    for dirpath, _, files in os.walk(OUT):
        if "Previews" in dirpath:
            continue
        for fn in sorted(files):
            if fn.endswith(".png"):
                p = os.path.join(dirpath, fn)
                (w, h, ncol), errs = validate_png(p)
                status = "OK " if not errs else "ERR"
                ok &= not errs
                report.append(f"{status} {os.path.relpath(p, OUT):42s} {w:4d}x{h:<4d} {w // T:2d}x{h // T:<2d} cells  {ncol:2d} colours  {'; '.join(errs)}")

    os.makedirs(os.path.join(OUT, "Documentation"), exist_ok=True)
    with open(os.path.join(OUT, "Documentation", "atlas_index.json"), "w") as f:
        json.dump(manifest, f, indent=1)
    with open(os.path.join(OUT, "Documentation", "validation.txt"), "w") as f:
        f.write("\n".join(report) + "\n")
    # keep previews/docs out of Godot's importer
    for sub in ("Previews", "Documentation"):
        open(os.path.join(OUT, sub, ".gdignore"), "w").close()

    print("\n".join(report))
    print("ALL VALID" if ok else "VALIDATION FAILED")
    return all_placed, terrain_paths


if __name__ == "__main__":
    main()
    import preview_scene  # noqa: F401  (renders Previews/scene_*.png)

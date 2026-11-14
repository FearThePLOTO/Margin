"""Compose mock 320x180 screenshots from the generated pieces (Previews/scene_*.png)."""
import os, sys
from PIL import Image
from core import Canvas, T
from scene_test import paint
import props
from terrain import TERRAINS, slope_row

ROOT = os.path.abspath(sys.argv[1])
OUT = os.path.join(ROOT, "src/assets/Margin_Mars_Surface/Previews")
items = {}
for fn in (props.platform_items, props.geology_items, props.vegetation_items, props.parkour_items,
           props.infrastructure_items, props.hazard_items, props.sand_items):
    for it in fn():
        items[it.name] = it


def put(cv, name, cx, cy, frame=0):
    """cx, cy = cell of the item's bottom-left (or top-left if anchor=top)."""
    it = items[name]
    piece = it.cv.crop(frame * it.w * T, 0, it.w * T, it.h * T)
    y = cy * T if it.anchor == "top" else (cy + 1) * T - it.h * T
    cv.paste(piece, cx * T, y)


def slope(cv, tkey, idx, cx, cy):
    cv.paste(slope_row(TERRAINS[tkey])[idx][0], cx * T, cy * T)


def finish(cv, bg, path, darken=0.55):
    img = bg.copy()
    if darken:
        ov = Image.new("RGBA", img.size, (14, 9, 18, int(255 * darken)))
        img.alpha_composite(ov)
    img.alpha_composite(cv.to_image().crop((0, 0, 320, 180)))
    img.resize((1280, 720), Image.NEAREST).save(path)


mars = Image.open(os.path.join(ROOT, "src/assets/The Cave/Mars.jpg")).convert("RGBA")
mars = mars.resize((322, 180), Image.NEAREST).crop((0, 0, 320, 180))

# ---------------- surface ----------------
def clear(cv, cx, cy):
    cv.a[cy * T:(cy + 1) * T, cx * T:(cx + 1) * T] = 0


def tile(cv, piece, cx, cy):
    clear(cv, cx, cy)
    cv.paste(piece, cx * T, cy * T)


g = [
    "....................",
    "....................",
    "....................",
    "....................",
    "...............rrrrr",
    "..............rrrrrr",
    "rrrrr.......ssrrrrrr",
    "rrrrr.....rrssrrrrrr",
    "rrrrrrrrrrrrrrrrrrrr",
    "rrrrrrrrrrrrrrrrrrrr",
    "rrrrrrrrrrrrrrrrrrrr",
    "rrrrrrrrrrrrrrrrrrrr",
]
cv = Canvas(320, 192)
paint(cv, g, {"r": "rock", "s": "sandy_rock"})
rk = slope_row(TERRAINS["rock"])
sr = slope_row(TERRAINS["sandy_rock"])
tile(cv, rk[2][0], 8, 7); tile(cv, rk[3][0], 9, 7)      # 22deg ramp
tile(cv, sr[0][0], 11, 6)                                # 45deg sandy
tile(cv, rk[0][0], 13, 5)                                # 45deg up to mesa
tile(cv, rk[0][0], 14, 4)
for r in range(2):                                       # crater
    for c in range(4):
        tile(cv, items[f"crater_4x2_r{r}c{c}"].cv, c + 4, 7 + r)
put(cv, "solar_panel", 0, 5); put(cv, "antenna", 2, 5); put(cv, "checkpoint", 3, 5, 1)
put(cv, "boulder_large", 16, 3); put(cv, "pebbles_a", 18, 3); put(cv, "weather_sensor", 19, 3)
put(cv, "sand_drift_M", 12, 5); put(cv, "sand_drift_R", 13, 5)
put(cv, "dry_shrub", 10, 6); put(cv, "boulder_small", 6, 7); put(cv, "rock_cluster", 15, 3)
for i, n in enumerate(("ledge_rock_L", "ledge_rock_M", "ledge_rock_R")):
    put(cv, n, 5 + i, 3)
put(cv, "tether_anchor_ceiling", 11, 1, 0)
for c in range(3):
    put(cv, f"island_rock_3w_r0c{c}", 10 + c, 2)
    put(cv, f"island_rock_3w_r1c{c}", 10 + c, 3)
put(cv, "sign_radiation", 17, 3)
put(cv, "sand_cover_M", 1, 6); put(cv, "sand_cover_R", 2, 6)
finish(cv, mars, os.path.join(OUT, "scene_surface.png"), darken=0.25)

# ---------------- cave ----------------
g = [
    "cccccccccccccccccccc",
    "cccccccccccccccccccc",
    "ccc.........ccc....c",
    "cc...........c.....c",
    "c..................c",
    "c..................c",
    "c........cc........c",
    "ccc.....cccc.......c",
    "cccc...ccccc..fffffc",
    "cccc...ccccc..fffffc",
    "cccc...ccccccfffffff",
    "cccccccccccccccccccc",
]
cv = Canvas(320, 192)
cvbg = Canvas(320, 192)
paint(cv, g, {"c": "cave", "f": "frost"})
for c in range(4, 7):
    put(cv, "lava_body", c, 10, 0)
    put(cv, "lava_top", c, 9, 0)
put(cv, "stalactite_large", 4, 2); put(cv, "stalactite_small", 8, 2); put(cv, "crystal_magenta_ceiling", 10, 2)
put(cv, "hanging_vines", 15, 2); put(cv, "stalactite_small", 17, 2)
put(cv, "crystal_magenta_large", 1, 3)
put(cv, "o2_station", 2, 6, 0); put(cv, "o2_tank", 10, 5)
put(cv, "glow_stalks", 11, 6); put(cv, "fungus_caps", 9, 5)
put(cv, "tether_anchor_ceiling", 6, 4 - 2, 1)
for i, n in enumerate(("grate_L", "grate_M", "grate_R")):
    put(cv, n, 13 + i, 5)
put(cv, "cryo_vent", 16, 7, 1); put(cv, "ice_crystals", 18, 7); put(cv, "sign_cold", 14, 7)
put(cv, "spikes_rock_up", 12, 9); put(cv, "radioactive_barrel", 3, 6)
put(cv, "crumble_cave_cracked", 13, 3)
put(cv, "airlock_door", 17, 4 - 0, 0)
put(cv, "lever", 12, 5, 1)
dark = Image.new("RGBA", (320, 180), (22, 14, 30, 255))
finish(cv, dark, os.path.join(OUT, "scene_cave.png"), darken=0)
print("scenes ok")

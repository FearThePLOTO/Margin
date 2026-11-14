"""Margin — locked Mars palette. Every generated pixel uses exactly one of these."""
import numpy as np

PAL = {
    # shadows / outlines
    "K0": "#0e0912", "K1": "#1a0f1f", "K2": "#2a1630",
    # burgundy
    "B0": "#3a1a2c", "B1": "#55212d",
    # rust
    "R0": "#76291f", "R1": "#963823", "R2": "#b84a28",
    # mars orange
    "O0": "#d9652b", "O1": "#f2731f", "O2": "#f59a45",
    # sandstone
    "S0": "#c98a52", "S1": "#e2ad6e", "S2": "#f3cf96", "S3": "#fbe8c4",
    # cave purple (from Cave.jpg)
    "P0": "#2b1b36", "P1": "#3e2649", "P2": "#573257", "P3": "#744262",
    # frost / cold
    "F0": "#25304f", "F1": "#3f5a85", "F2": "#7fb0d6", "F3": "#c4ecfa", "F4": "#f0fbff",
    # metal
    "M0": "#20222e", "M1": "#3b3f52", "M2": "#62677e", "M3": "#9aa0b5", "M4": "#d4d8e3",
    "W": "#f4f6fa",
    # UI teal
    "T0": "#1c4a4c", "T1": "#2f8f86", "T2": "#66d9c0", "T3": "#b5f5e4",
    # lava / heat
    "L0": "#7a1414", "L1": "#d4361c", "L2": "#ff8a1f", "L3": "#ffd25a", "L4": "#fff3b0",
    # radiation
    "G0": "#2d5a18", "G1": "#5fae22", "G2": "#b6f23e", "G3": "#efffa0",
    # crystal magenta
    "C0": "#4a1766", "C1": "#9a2fc4", "C2": "#e05ae8", "C3": "#ffb3f5",
    # warning yellow
    "Y0": "#e8c22a", "Y1": "#fff07a",
}

NAMES = list(PAL)
IDX = {n: i + 1 for i, n in enumerate(NAMES)}  # 0 = transparent
RGBA = np.zeros((len(NAMES) + 1, 4), np.uint8)
for n, i in IDX.items():
    h = PAL[n].lstrip("#")
    RGBA[i] = [int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255]

# single-char legend for hand-drawn ASCII sprites
LEGEND = {
    ".": None,
    "0": "K0", "1": "K1", "2": "K2",
    "a": "M0", "b": "M1", "c": "M2", "d": "M3", "e": "M4", "w": "W",
    "t": "T0", "u": "T1", "v": "T2", "x": "T3",
    "R": "O0", "r": "O1", "o": "O2",
    "y": "Y0", "Y": "Y1",
    "h": "G0", "g": "G1", "G": "G2", "H": "G3",
    "i": "L0", "l": "L1", "L": "L2", "j": "L3", "J": "L4",
    "f": "F1", "F": "F2", "I": "F3", "E": "F4",
    "Q": "C0", "p": "C1", "P": "C2", "q": "C3",
    "z": "S0", "s": "S1", "S": "S2", "Z": "S3",
    "m": "R0", "n": "R1", "N": "R2",
    "D": "B0", "C": "B1",
    "k": "P0", "K": "P1", "A": "P2", "T": "P3",
}

#!/usr/bin/env python3
"""Margin — original synthesized SFX (no sampled or third-party audio).

Usage: python gen_sfx.py <godot-project-root>

Formant voice model: a jittery glottal pulse train + breath noise pushed
through three resonant band-pass filters (vowel formants). Produces:
  og_laugh.wav   wheezy old-man cackle ("heh-heh-heh-HAH-hahh")
  og_voice.wav   OG dialogue blip (low, raspy)
  max_voice.wav  Max dialogue blip (bright, clean)
  mc_voice.wav   Mission Control blip (radio chirp)
  sample.wav     science-sample scan chime
  station.wav    power-station confirm
"""
import math
import os
import struct
import sys
import wave

import numpy as np

SR = 22050
rng = np.random.default_rng(7)


def biquad_bp(x, f, q):
    w = 2 * math.pi * f / SR
    alpha = math.sin(w) / (2 * q)
    b0, b1, b2 = alpha, 0.0, -alpha
    a0, a1, a2 = 1 + alpha, -2 * math.cos(w), 1 - alpha
    b0, b1, b2, a1, a2 = b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0
    y = np.zeros_like(x)
    x1 = x2 = y1 = y2 = 0.0
    for i, xi in enumerate(x):
        yi = b0 * xi + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        y[i] = yi
        x2, x1, y2, y1 = x1, xi, y1, yi
    return y


def glottal(f0_curve, jitter=0.02, shimmer=0.1):
    """Pulse train following an f0 curve (array, Hz)."""
    out = np.zeros(len(f0_curve))
    phase = 0.0
    for i, f in enumerate(f0_curve):
        f *= 1 + jitter * rng.standard_normal()
        phase += f / SR
        if phase >= 1.0:
            phase -= 1.0
            out[i] = 1.0 + shimmer * rng.standard_normal()
    # soften each pulse into a glottal-ish shape
    k = np.exp(-np.arange(40) / 6.0)
    return np.convolve(out, k)[: len(out)]


def vowel(n, f0_start, f0_end, formants, breath=0.25, jitter=0.02):
    f0 = np.linspace(f0_start, f0_end, n)
    src = glottal(f0, jitter) + breath * rng.standard_normal(n) * 0.6
    y = np.zeros(n)
    for f, q, g in formants:
        y += g * biquad_bp(src, f, q)
    return y


def env(n, attack=0.08, release=0.5):
    a = max(1, int(n * attack))
    r = max(1, int(n * release))
    e = np.ones(n)
    e[:a] = np.linspace(0, 1, a)
    e[-r:] = np.linspace(1, 0, r) ** 1.5
    return e


EH = [(560, 6, 1.0), (1750, 9, 0.6), (2550, 10, 0.3)]   # "heh"
AH = [(750, 6, 1.0), (1200, 8, 0.6), (2500, 10, 0.25)]  # "hah"
UH = [(450, 5, 1.0), (1100, 7, 0.4), (2300, 9, 0.2)]


def syllable(dur, f0a, f0b, formants, breath, aspir=0.035):
    n = int(dur * SR)
    h = int(aspir * SR)  # leading "h" = noise burst
    noise = biquad_bp(rng.standard_normal(h), formants[1][0], 2) * np.linspace(0.2, 1, h) * 0.5
    v = vowel(n, f0a, f0b, formants, breath) * env(n, 0.05, 0.6)
    return np.concatenate([noise, v])


def silence(d):
    return np.zeros(int(d * SR))


def og_laugh():
    parts = []
    # accelerating wheezy cackle, rising, then a big HAH and a wheeze tail
    timing = [(0.11, 0.07), (0.10, 0.06), (0.09, 0.05), (0.09, 0.05), (0.08, 0.05), (0.09, 0.06)]
    f0 = [230, 245, 255, 265, 275, 285]
    for (d, gap), f in zip(timing, f0):
        parts += [syllable(d, f * 1.05, f * 0.9, EH, 0.55), silence(gap)]
    parts += [syllable(0.26, 320, 210, AH, 0.6), silence(0.05)]
    # wheeze: breathy inhaled noise
    n = int(0.35 * SR)
    wz = biquad_bp(rng.standard_normal(n), 2400, 3) * env(n, 0.3, 0.6) * 0.5
    parts += [wz, silence(0.04), syllable(0.12, 260, 230, EH, 0.6), silence(0.05), syllable(0.1, 240, 200, EH, 0.7)]
    return np.concatenate(parts)


def blip(f0, formants, dur=0.055, breath=0.15, jitter=0.01):
    n = int(dur * SR)
    return vowel(n, f0, f0 * 0.95, formants, breath, jitter) * env(n, 0.1, 0.55)


def radio_chirp():
    n = int(0.05 * SR)
    t = np.arange(n) / SR
    tone = np.sin(2 * math.pi * (1400 + 300 * t / t[-1]) * t)
    noise = biquad_bp(rng.standard_normal(n), 1800, 2) * 0.35
    return (np.sign(tone) * 0.35 + noise) * env(n, 0.05, 0.5)


def chime(freqs, dur=0.5):
    n = int(dur * SR)
    t = np.arange(n) / SR
    y = np.zeros(n)
    for i, f in enumerate(freqs):
        start = int(i * 0.07 * SR)
        tt = t[: n - start]
        y[start:] += np.sin(2 * math.pi * f * tt) * np.exp(-tt * 7) * 0.4
    return y


def write(path, y, gain=0.85):
    y = y / (np.max(np.abs(y)) + 1e-9) * gain
    data = (y * 32767).astype(np.int16)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print(f"{os.path.basename(path)}: {len(y) / SR:.2f}s")


def main():
    root = os.path.abspath(sys.argv[1])
    out = os.path.join(root, "src/features/audio/sfx")
    os.makedirs(out, exist_ok=True)
    write(os.path.join(out, "og_laugh.wav"), og_laugh())
    write(os.path.join(out, "og_voice.wav"), blip(150, UH, 0.07, 0.45, 0.04))
    write(os.path.join(out, "max_voice.wav"), blip(330, EH, 0.05, 0.1))
    write(os.path.join(out, "mc_voice.wav"), radio_chirp(), 0.5)
    write(os.path.join(out, "sample.wav"), chime([880, 1175, 1568]), 0.6)
    write(os.path.join(out, "station.wav"), chime([523, 659, 784, 1047], 0.7), 0.6)


if __name__ == "__main__":
    main()

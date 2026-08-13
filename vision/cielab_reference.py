"""True CIELAB D65 2° — canonical converter for VYTRA.

algorithm_version: alg-1.1.0

Port this file to Dart. Do not substitute OpenCV uint8 Lab.
A port is accepted only if every row in golden_cielab.json matches
to ±0.05 on L*, a*, and b*.
"""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Iterable, Sequence

XN = 0.95047
YN = 1.00000
ZN = 1.08883
DELTA = 6.0 / 29.0
DELTA3 = DELTA ** 3

# IEC 61966-2-1
M_RGB_TO_XYZ = (
    (0.4124564, 0.3575761, 0.1804375),
    (0.2126729, 0.7151522, 0.0721750),
    (0.0193339, 0.1191920, 0.9503041),
)


def srgb_to_linear(c: float) -> float:
    if c <= 0.04045:
        return c / 12.92
    return ((c + 0.055) / 1.055) ** 2.4


def _f(t: float) -> float:
    if t > DELTA3:
        return t ** (1.0 / 3.0)
    return t / (3.0 * DELTA * DELTA) + 4.0 / 29.0


def rgb01_to_lab(r: float, g: float, b: float) -> tuple[float, float, float]:
    """sRGB gamma-encoded channels in [0, 1] → true Lab."""
    rl, gl, bl = srgb_to_linear(r), srgb_to_linear(g), srgb_to_linear(b)
    x = M_RGB_TO_XYZ[0][0] * rl + M_RGB_TO_XYZ[0][1] * gl + M_RGB_TO_XYZ[0][2] * bl
    y = M_RGB_TO_XYZ[1][0] * rl + M_RGB_TO_XYZ[1][1] * gl + M_RGB_TO_XYZ[1][2] * bl
    z = M_RGB_TO_XYZ[2][0] * rl + M_RGB_TO_XYZ[2][1] * gl + M_RGB_TO_XYZ[2][2] * bl
    fy = _f(y / YN)
    l = 116.0 * fy - 16.0
    a = 500.0 * (_f(x / XN) - fy)
    b_star = 200.0 * (fy - _f(z / ZN))
    return (l, a, b_star)


def rgb255_to_lab(r: float, g: float, b: float) -> tuple[float, float, float]:
    return rgb01_to_lab(r / 255.0, g / 255.0, b / 255.0)


def mean_rgb255(pixels: Sequence[Sequence[float]]) -> tuple[float, float, float]:
    if not pixels:
        raise ValueError("mean_rgb255 requires at least one pixel")
    n = len(pixels)
    sr = sg = sb = 0.0
    for p in pixels:
        sr += p[0]
        sg += p[1]
        sb += p[2]
    return (sr / n, sg / n, sb / n)


def apply_white_patch(
    r255: float, g255: float, b255: float, gain_r: float, gain_g: float, gain_b: float
) -> tuple[float, float, float]:
    """Return corrected sRGB in [0, 1]. Rejects near-zero gains."""
    if min(gain_r, gain_g, gain_b) < 0.05:
        raise ValueError("white-patch gain < 0.05 — treat reference as invalid")
    return (
        max(0.0, min(1.0, (r255 / 255.0) / gain_r)),
        max(0.0, min(1.0, (g255 / 255.0) / gain_g)),
        max(0.0, min(1.0, (b255 / 255.0) / gain_b)),
    )


def white_ref_accept(
    mean_r: float, mean_g: float, mean_b: float, clip_fractions: Iterable[float]
) -> bool:
    means = (mean_r, mean_g, mean_b)
    if any(m < 180.0 for m in means):
        return False
    mu = sum(means) / 3.0
    var = sum((m - mu) ** 2 for m in means) / 3.0
    if math.sqrt(var) > 15.0:
        return False
    if any(c > 0.05 for c in clip_fractions):
        return False
    return True


def load_goldens(path: Path | None = None) -> dict:
    p = path or Path(__file__).with_name("golden_cielab.json")
    return json.loads(p.read_text(encoding="utf-8"))


def max_delta(got: tuple[float, float, float], sample: dict) -> float:
    return max(
        abs(got[0] - sample["L"]),
        abs(got[1] - sample["a"]),
        abs(got[2] - sample["b"]),
    )


if __name__ == "__main__":
    data = load_goldens()
    worst = 0.0
    for row in data["samples"]:
        lab = rgb255_to_lab(*row["rgb255"])
        d = max_delta(lab, row)
        worst = max(worst, d)
        status = "ok" if d <= 0.05 else "FAIL"
        print(f"{status:4} {row['name']:28} Δ={d:.4f}  L={lab[0]:.4f} a={lab[1]:.4f} b={lab[2]:.4f}")
    print(f"worst Δ = {worst:.4f}  (limit 0.05)")
    raise SystemExit(0 if worst <= 0.05 else 1)

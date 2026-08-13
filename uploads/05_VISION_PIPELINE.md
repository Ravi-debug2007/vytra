# 05 — Vision Pipeline

`algorithm_version = alg-1.1.0`  
`threshold_version = th-1.0.0`

Any change to a formula, index list, filter, or bin in this file requires bumping the matching version and a pack MINOR or MAJOR.

Canonical Lab converter: [`vision/cielab_reference.py`](vision/cielab_reference.py)  
Oracles: [`vision/golden_cielab.json`](vision/golden_cielab.json)

---

## 1. Pipeline overview

```
camera frame (sRGB bytes)
        │
        ├─ quality gates on a 100×100 grayscale crop of the guide
        │     blur (Laplacian var > 100)
        │     exposure (mean ∈ [40, 200], 5-frame roll)
        │     EAR > 0.2          ← jaundice series only
        │
        ▼  (only the passing frame is kept)
white-patch gains applied to RGB in the ROI
        │
        ▼
pixel filters (tissue-specific)
        │
        ▼
if surviving pixels < Nmin → invalid capture
        │
        ▼
mean R, G, B of survivors  →  true CIELAB
        │
        ▼
store L*, a*, b* on the capture row
        │
        ▼
after the series closes:
    valid a* or b* list → median → classify
```

All Lab work runs in a Dart isolate via `compute`. The UI thread only ships a compact RGB ROI (max 256×256) plus the three gains.

---

## 2. Colour conversion (normative)

Input: three floats `R, G, B` in **[0, 1]**, sRGB, gamma-encoded, already white-patch corrected.

### 2.1 sRGB inverse transfer

```
linear(c) =
    c / 12.92                         if c <= 0.04045
    ((c + 0.055) / 1.055) ^ 2.4       otherwise
```

### 2.2 Linear sRGB → XYZ (D65, IEC 61966-2-1)

```
X = 0.4124564 R + 0.3575761 G + 0.1804375 B
Y = 0.2126729 R + 0.7151522 G + 0.0721750 B
Z = 0.0193339 R + 0.1191920 G + 0.9503041 B
```

### 2.3 XYZ → Lab (D65, 2°)

```
Xn = 0.95047
Yn = 1.00000
Zn = 1.08883
δ  = 6 / 29

f(t) =
    t ^ (1/3)                         if t > δ^3
    t / (3 δ^2) + 4/29                otherwise

L* = 116 f(Y/Yn) - 16
a* = 500 ( f(X/Xn) - f(Y/Yn) )
b* = 200 ( f(Y/Yn) - f(Z/Zn) )
```

### 2.4 Forbidden implementations

| Implementation | Why it is wrong here |
|---|---|
| OpenCV `cvtColor(RGB2LAB)` | Stores `L' = L* × 255/100`, `a' = a*+128`, `b' = b*+128`. Bins 5 / 10 / 15 become meaningless. |
| `image` package `Color.lab` without checking the white point | Verify against goldens before using. |
| Averaging Lab of every pixel | Slower and not what `th-1.0.0` is defined on. Average **RGB**, convert once. |
| Assuming the JPEG is already linear | Phone JPEGs are sRGB gamma-encoded. |

### 2.5 Acceptance

`test/cielab_test.dart` loads `golden_cielab.json` and asserts `|ΔL|, |Δa|, |Δb| ≤ 0.05` for every row. A port that fails this test must not be merged.

---

## 3. White-patch gains

On the accepted reference image (full frame, or the dashed-rectangle crop if the worker used the guide):

```
meanR, meanG, meanB     // 0–255
accept if
    meanR ≥ 180 and meanG ≥ 180 and meanB ≥ 180
    sd(meanR, meanG, meanB) ≤ 15
    count(channel == 255) / count(pixels) ≤ 0.05  for each channel

gR = meanR / 255
gG = meanG / 255
gB = meanB / 255
```

Apply to each ROI pixel (0–255) before converting to 0–1:

```
r' = clamp((r / 255) / gR, 0, 1)
g' = clamp((g / 255) / gG, 0, 1)
b' = clamp((b / 255) / gB, 0, 1)
```

Gains of 0 are impossible if the accept rule held. Still guard: if any `g < 0.05`, treat the reference as invalid (`whiteRefFailDark`).

---

## 4. Quality gates

Computed every preview frame on a **100×100** box filtered from the guide ellipse’s axis-aligned bounding box, converted to grayscale

```
Y = 0.2126 R + 0.7152 G + 0.0722 B     // 0–255, gamma-encoded is fine here
```

### 4.1 Blur — Laplacian variance

Kernel (4-neighbour):

```
[ 0  1  0 ]
[ 1 -4  1 ]
[ 0  1  0 ]
```

`var = mean(L²) − mean(L)²` over the 100×100 response.  
**Pass: `var > 100`.**

This threshold is defined on the **downsampled crop**, not the full sensor frame. Do not compute Laplacian on the 1920-wide image and keep 100.

### 4.2 Exposure

`μ = mean(Y)` on the same crop.  
**Pass: `40 ≤ μ ≤ 200`.**

Lamp state uses a rolling mean of the last 5 `μ` values so auto-exposure flicker does not strobe the lamp.

### 4.3 Eye aspect ratio (jaundice series only)

Left eye:

```
EAR_L = dist(159, 145) / dist(33, 133)
```

Right eye:

```
EAR_R = dist(386, 374) / dist(362, 263)
```

`dist` is Euclidean in **image pixels**, not normalised mesh units.

Use the eye whose temporal sclera is the target. Default: the eye closer to the guide ellipse centre. If mesh is missing, EAR is undefined → gate fail, unless the 15 s ellipse-only fallback in `02` E6 has armed (`mesh_used = 0`, EAR gate off).

**Pass: `EAR > 0.2`.**

This is a 4-point simplification of Soukupova–Cech EAR. It is good enough to reject a blink. It is not a clinical blink detector.

### 4.4 Conjunction

The shutter enables only when every gate for that series is true on **one** evaluated frame. That frame’s RGB is the capture. Do not grab the next camera buffer after the tap.

---

## 5. Region of interest

### 5.1 Anemia — everted lower lid

Face Mesh will often fail. **Do not depend on it.**

1. Take every pixel inside the guide ellipse.
2. Inset the ellipse by 8 % on each axis (drop the stroke and neighbouring skin).
3. Convert inset pixels to true Lab (per-pixel is allowed **only** for filtering; the reported a\* still comes from the mean RGB of survivors).
4. Keep a pixel if **all** of:
   - `L* ∈ [35, 85]` (drop lashes and specular glaze)
   - `b* ∈ [-5, 30]` (drop obvious cloth)
   - Do **not** apply a lower bound on `a*`. Pale conjunctiva (low `a*`) is the anemia signal. A floor of `a* ≥ 4` would delete HIGH-tier pixels (`a* < 5`) and bias the mean toward LOW.
5. If survivors < **300**, reject (`ROI_TOO_SMALL`).
6. Mean RGB of survivors → Lab → store `anemia_a_star = a*`, also store `l_star`.

Coaching, not geometry, is what makes this conjunctiva rather than cheek. The filter is a seatbelt, not a segmenter.

### 5.2 Jaundice — temporal sclera

Prefer mesh when present.

**Eye opening polygons** (MediaPipe / ML Kit 468 topology):

```
LEFT_EYE = [
  33, 7, 163, 144, 145, 153, 154, 155, 133,
  173, 157, 158, 159, 160, 161, 246
]
RIGHT_EYE = [
  263, 249, 390, 373, 374, 380, 381, 382, 362,
  398, 384, 385, 386, 387, 388, 466
]
```

Iris is **not** assumed available (ML Kit Face Mesh 0.5.0 does not document iris indices 468–477). Approximate the iris as a circle:

```
centre = midpoint(inner canthus, outer canthus)
     left:  midpoint(133, 33)
     right: midpoint(362, 263)
radius = 0.28 * dist(inner, outer)
```

**Temporal half:** the half of the eye polygon **away from the nose**.

Do **not** use raw image `x`. A tilted head flips “left of centre.” Use the inner→outer axis only:

```
axis = outer - inner
keep if dot(p - centre, axis) > 0     // toward outer canthus (temporal)
```

Then:

1. Start from eye-polygon ∩ temporal half, minus the iris circle, minus an extra 2 px dilation of the iris.
2. Keep pixels with `L* ≥ 70` and `hypot(a*, b*) ≤ 25` (bright, low-chroma).
3. Drop pixels with `a* > 12` (vascular / conjunctival red).
4. If survivors < **200**, reject (`ROI_TOO_SMALL`).
5. Mean RGB → Lab → `jaundice_b_star = b*`.

**Ellipse-only fallback** (E6): use the guide ellipse inset 10 %, same L*/chroma filters, same 200 minimum, `mesh_used = 0`.

### 5.3 Index orientation note for implementers

ML Kit Face Mesh points are a list of 468 `FaceMeshPoint` with `x, y, z`. Indices above match the MediaPipe canonical face. Write a debug overlay (dev flavour only) that numbers 33, 133, 362, 263 so a human can confirm left/right on the reference device before Day 4 ends.

---

## 6. Aggregation and classification

Per series, after the series closes:

```
values = [capture.signal for capture in series if capture.valid == 1]
if len(values) < 2:
    risk = UNABLE_TO_ASSESS
    series_signal = null
else:
    series_signal = median(values)      // for even n=2, arithmetic mean of the two
    risk = classify(series_signal)
```

`median` of two values is the mean. Documented here so two implementations do not disagree.

### 6.1 Bins (`th-1.0.0`)

Anemia, signal = a\*:

| Predicate | Risk |
|---|---|
| `signal < 5` | HIGH |
| `5 ≤ signal < 10` | MODERATE |
| `signal ≥ 10` | LOW |

Jaundice, signal = b\*:

| Predicate | Risk |
|---|---|
| `signal ≥ 15` | HIGH |
| `10 ≤ signal < 15` | MODERATE |
| `signal < 10` | LOW |

Boundaries are closed on the milder side for anemia (`5` is MODERATE) and closed on the more severe side for jaundice (`15` is HIGH, `10` is MODERATE). Write unit tests for `4.999`, `5.0`, `9.999`, `10.0`, `14.999`, `15.0`.

### 6.2 Quality score (research only)

```
final_quality_score = mean(valid capture.roi_quality_score)   // 0–100
```

`roi_quality_score` = min(100, 100 × survivors / (2 × Nmin)).  
**Never** show this as “confidence” or a percent on ASHA screens. If shown at all in ASHA mode, use the phrase “photo quality” and three words: Poor / Fair / Good at 0–40 / 40–70 / 70–100.

---

## 7. What is not computed

- No RITnet, no U-Net, no cloud model.
- No iris millimetre scale.
- No blink-rate, no pupil reflex (those exist in Skinopathy; they are not this product).
- No per-device CCM.
- No hemoglobin regression.

---

## 8. Performance budget (reference device)

| Step | Budget |
|---|---|
| Mesh (jaundice preview) | ≤ 25 ms |
| Laplacian 100×100 | ≤ 3 ms |
| Isolate Lab on ≤ 20k pixels | ≤ 40 ms |
| Total analysis after tap | ≤ 500 ms typical, 3 s hard limit |

If mesh alone blows the 20 FPS budget, drop mesh drawing first, then drop mesh inference to every other frame. Quality gates still run every frame on the ellipse crop.

---

## 9. Debug (dev flavour only)

When `DEBUG_LAB=true`:

- Draw survivor pixels as a translucent mask after capture, 800 ms.
- Log mean RGB, L*, a*, b*, survivor count to `debugPrint`.
- Do not write those logs to a file.

Study flavour: this code path is compiled out or gated so it cannot open.

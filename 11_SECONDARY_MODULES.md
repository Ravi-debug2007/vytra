# 11 — Secondary modules: Skin and Teeth

**Status:** v1.2.0 — secondary, optional, **not** part of the ASHA core demo.  
**Cut first** if the 14-day clock slips. The airplane-mode anemia/jaundice flow must still ship.

These two tools sit behind a **More tools** entry on the home screen. They must never appear as the primary CTA. They must never write into the `screenings` / `captures` tables. They **require internet**. They send a photograph to a **third-party API**. That is a different product, with a different consent.

---

## 1. Why they are secondary

| Core ASHA screening | Skin / Teeth tools |
|---|---|
| Offline | Online only |
| Photo never leaves the phone | Photo is posted to Hugging Face or Roboflow, then discarded locally |
| Colour maths we can unit-test | Unvalidated third-party models |
| Household visit, Telugu-first | Demo / camp extras |
| Risk class + referral PDF | Experimental label + educational copy |

If a jury asks “does VYTRA diagnose melanoma?” the answer is **no**. The skin tool is an experimental classifier with a disclaimer. Same for teeth grades.

---

## 2. Product rules (closed)

1. Home primary button remains **New screening** (anemia + jaundice). Skin and Teeth are a second row, smaller.
2. Each tool has its **own consent** that says, in the active language:
   - this photo will be sent to a named third-party server
   - it is not a diagnosis
   - it is not stored in the VYTRA health database
   - the person may refuse
3. Decline → back to More tools. No image captured.
4. No network → do not open the camera. Show `secondaryNeedInternet`. The core screening still works.
5. Never show “You have melanoma”, “You need braces”, a hemoglobin-style number, or a treatment prescription.
6. Confidence % is **model softmax**, labelled “model score”, never “medical confidence.”
7. ABCDE is a **static educational page**, not computed from the photo in v1.
8. API keys via `--dart-define` only (`HF_TOKEN`, `ROBOFLOW_API_KEY`, `ROBOFLOW_MODEL`, `ROBOFLOW_VERSION`). Never commit keys.
9. If the named Hugging Face model 404s or the Roboflow model is unset, the tool shows a configuration error — it does not invent labels.
10. **Default is off.** Study and demo APKs ship `--dart-define=SECONDARY_TOOLS=false` until a live HF model and a Roboflow model id are written into this file. Dev may turn them on.

---

## 3. Navigation

```
S02 Home
  └─ More tools          S13
        ├─ Skin scan     S14 consent → S15 capture → S16 result
        │                   └─ ABCDE guide S20
        └─ Teeth scan    S17 consent → S18 capture → S19 result
```

Discard on S15/S18: same pattern as core — “Nothing will be saved.” The third-party may already have received the bytes if the tap happened; say so only after a successful POST.

---

## 4. Skin disease scanner

### 4.1 Model

| Key | Value |
|---|---|
| Provider | Hugging Face Inference API |
| Configured id | **unset by default.** Set `HF_MODEL` to a **live** Hub id after you verify it with `curl`. The previously cited `dima806/skin_diseases_classification` returned **404** on 2026-08-12 — do not ship that string. |
| Endpoint | `POST https://api-inference.huggingface.co/models/{HF_MODEL}` |
| Auth | `Authorization: Bearer {HF_TOKEN}` |
| Body | raw JPEG bytes, `Content-Type: image/jpeg` |
| Expected response | JSON array of `{ "label": string, "score": number }` sorted by score desc |

**Known risk:** that exact repo id may not exist or may change labels. The app **maps whatever labels come back**. It does not assume seven names. The display table below is the **preferred** mapping when the label string matches (case-insensitive, ignore `_` vs space). Unmapped labels are shown as returned, with urgency `CHECK`.

### 4.2 Preferred label map (7)

Use these when the model label fuzzy-matches. If the live model is HAM10000-style, map `mel` → Melanoma, `bcc` → Basal cell carcinoma, etc.

| Canonical id | Display (en) | Referral urgency | Colour token |
|---|---|---|---|
| `melanoma` | Melanoma (possible) | **URGENT** — dermatologist / PHC today | `risk.high` |
| `bcc` | Basal cell carcinoma (possible) | **URGENT** | `risk.high` |
| `eczema` | Eczema-like | SOON — clinic this week | `risk.moderate` |
| `psoriasis` | Psoriasis-like | SOON | `risk.moderate` |
| `acne` | Acne-like | ROUTINE | `risk.low` |
| `ringworm` | Ringworm-like | SOON | `risk.moderate` |
| `vitiligo` | Vitiligo-like | ROUTINE | `risk.low` |
| `other` / unmapped | As returned by the model | CHECK | `risk.unable` |

Urgency is **when to see a clinician**, not “how bad the cancer is.” UI heading: “Suggested check”, not “Severity.”

### 4.3 What S16 shows

1. Top-1 display name + urgency chip (shape + colour, same system as core).
2. Model score as `Model score: 72%` — never “72% sure you have X.”
3. Next two labels as smaller “also considered” rows (label + %).
4. Static 2–3 bullet **general** symptoms for the canonical id (from the table in `l10n`, not from the model).
5. Recommendation = the urgency sentence only. No drug names.
6. Button: **ABCDE guide** (S20, static).
7. Full core disclaimer **plus** `secondaryThirdPartyNote`.
8. No PDF in v1 for skin (cut). Share as text is NICE TO HAVE.

### 4.4 Capture (S15)

- Request camera permission here if it was not already granted on S05.
- Rear camera, single still. Fill a square guide with the lesion. Good light. No flash if it blows out.
- Quality: blur + exposure only (reuse core gates). One shot.
- Compress JPEG quality 85, longest side 512 px, before upload.
- Timeout 20 s. On 503 (“model loading”) retry once after 3 s, then fail with `secondaryModelBusy`.
- Image bytes dropped after the response is parsed.

### 4.5 ABCDE (S20) — educational only

Static cards, not measured from the photo:

| Letter | Meaning |
|---|---|
| A | Asymmetry |
| B | Border irregularity |
| C | Colour variation |
| D | Diameter larger than about 6 mm |
| E | Evolving (changing) |

Footer: “This guide is for awareness. Only a clinician can assess a mole.”

---

## 5. Teeth alignment scanner

### 5.1 Model

| Key | Value |
|---|---|
| Provider | Roboflow Hosted Inference |
| Endpoint | `POST https://detect.roboflow.com/{ROBOFLOW_MODEL}/{ROBOFLOW_VERSION}` |
| Query | `api_key={ROBOFLOW_API_KEY}&format=json` |
| Body | JPEG, `Content-Type: application/x-www-form-urlencoded` **or** multipart as per current Roboflow docs |
| Expected | `predictions[]` with `x, y, width, height, confidence, class` |

`ROBOFLOW_MODEL` and `ROBOFLOW_VERSION` are required. If empty, S17 does not open.

Any class name that looks like a tooth (`tooth`, `teeth`, `incisor`, …) is kept. Other classes are ignored for scoring but may be drawn.

### 5.2 Geometry (on-device, after boxes return)

Let boxes be axis-aligned, sorted by centre-x.

```
n = count of boxes with confidence ≥ 0.35
widths = [w for w in box_widths if w > 0]
if n < 4 or not widths:  UNABLE_TO_ASSESS
med_w = median(widths)
if med_w <= 0:  UNABLE_TO_ASSESS

overlap_i = IoU(box_i, box_{i+1})
crowding  = mean of overlap_i that are > 0.05     // 0 if none

gap_i     = max(0, left(box_{i+1}) - right(box_i))
med_w     = median(widths)
spacing   = mean(gap_i) / med_w                   // large → spaced

# centres y
ys = [cy_i]
symmetry = 1 - (stdev(ys) / med_w).clamp(0, 1)

# score 0–100 (heuristic, not clinical)
score = 100
score -= (crowding * 120).clamp(0, 40)
score -= ((spacing - 0.15).clamp(0, 1) * 40)
score -= ((1 - symmetry) * 20)
score = score.clamp(0, 100)
```

**Grade** (demo only, always with disclaimer):

| Score | Grade | Plain phrase |
|---|---|---|
| ≥ 85 | A | Looks evenly spaced |
| 70–84 | B | Mostly even |
| 55–69 | C | Some crowding or gaps |
| 40–54 | D | Clear crowding or gaps |
| < 40 | F | Very uneven — clinical check |

Never say “you need braces.” Recommendation: “An orthodontist or dentist can say if treatment is needed.”

### 5.3 What S19 shows

1. Score as a number 0–100 labelled **Alignment score (estimate)**.
2. Grade letter + plain phrase.
3. Three chips: Crowding / Spacing / Symmetry as Low–High bars (not medical).
4. Overlay thumbnail with boxes (optional; skip if it costs a day).
5. Disclaimer + third-party note.
6. No PDF in v1.

### 5.4 Capture (S18)

- Front-on smile, lips retracted if possible. Guide: wide rectangle.
- One shot. Same JPEG compress as skin.
- Offline / missing key → block before camera.

---

## 6. Local storage (separate)

```sql
CREATE TABLE secondary_scans (
    scan_id TEXT PRIMARY KEY,
    kind TEXT NOT NULL CHECK (kind IN ('SKIN','TEETH')),
    captured_at TEXT NOT NULL,
    top_label TEXT,
    top_score REAL,
    extra_json TEXT,          -- full label list or geometry summary
    third_party TEXT,         -- 'huggingface' | 'roboflow'
    model_id TEXT,
    sync_status TEXT DEFAULT 'LOCAL_ONLY'
);
```

- No image bytes.
- 30-day eligibility same as core.
- **Do not sync** to the study FastAPI in v1 (`LOCAL_ONLY`). Study backend is for ASHA screenings only.
- Not shown on S10.

---

## 7. Environment

| Dart define | Example |
|---|---|
| `SECONDARY_TOOLS` | `true` / `false` (default `false` on study) |
| `HF_TOKEN` | `hf_...` |
| `HF_MODEL` | _unset until a live Hub id is verified_ |
| `ROBOFLOW_API_KEY` | `...` |
| `ROBOFLOW_MODEL` | `your-workspace/teeth-det` |
| `ROBOFLOW_VERSION` | `1` |

Demo flavour: tools on, keys injected at build. If a key is missing, the tile on S13 is visible but disabled with “Not configured.”

---

## 8. Home / S13 layout

S02 adds a text button under the primary CTA: **More tools**.

S13:

```
┌────────────────────────────────────┐
│  ←  More tools                     │
│                                    │
│  These tools need internet.        │
│  Photos are sent to an outside     │
│  service. Not a diagnosis.         │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  Skin check                  │  │
│  │  Experimental · needs net    │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │  Teeth check                 │  │
│  │  Experimental · needs net    │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

---

## 9. Build order (after the core demo works)

| Day | Work |
|---|---|
| C+1 | S13 + consent copy + internet gate |
| C+2 | Skin capture + HF client + S16 |
| C+3 | ABCDE static page |
| C+4 | Teeth capture + Roboflow client + geometry + S19 |

If C+2 fails (model 404), leave the tile disabled. Do not swap in a random model without a pack note.

---

## 10. Pitch language

Allowed: “The app also has experimental, internet-only skin and teeth demos powered by public models.”  
Forbidden: “VYTRA detects melanoma” / “VYTRA grades your smile A to F as an orthodontist would.”

Keep these **off the 6-slide college deck** unless a faculty member asks for extra features. The nomination story is the offline ASHA screen.

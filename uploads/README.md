# VYTRA — Vibe-Coding Specification Pack

| | |
|---|---|
| **Product** | VYTRA |
| **Tagline** | See Health. Detect Early. |
| **Pack version** | 1.3.0 |
| **Status** | **AUTHORITATIVE — implement from this folder only** |
| **Date** | 2026-08-12 |
| **Platform** | Android 8.0+ (API 26), offline-first |
| **Hackathon** | Smart India Hackathon 2026 |
| **Owner** | Ravikiran Allampalli, MRCET |

---

## What this pack is

This folder is the **only** input an implementer — human or coding agent — is allowed to use.

Earlier drafts (lean PRD v1.4, implementation guide v2.2, AnamoAI PRD v1.0 draft, Technical Stack v1.2, defense guide, roadmap) are **superseded**. The working title **AnamoAI** is retired. Where they disagree with this pack, **this pack wins**. Do not merge them back in.

**VYTRA** (Vision + Vitality + Tracking + AI) is a non-diagnostic, offline-first Android screening aid for ASHA workers. The backronym is for the pitch deck only — do not put it in the worker UI. It estimates **anemia risk** from an everted lower-lid photograph and **jaundice risk** from a temporal-sclera photograph, using on-device CIELAB heuristics. It is not a medical device.

---

## Read in this order

| # | File | Why it exists |
|---|---|---|
| 0 | [`00_DOCUMENT_CONTROL.md`](00_DOCUMENT_CONTROL.md) | Authority, kill list, how to change anything |
| 1 | [`01_PRODUCT_LOCK.md`](01_PRODUCT_LOCK.md) | Frozen product decisions. Do not reopen these in code. |
| 2 | [`02_VIBE_SPEC.md`](02_VIBE_SPEC.md) | Master build spec: users, flow, FRs, NFRs, non-goals |
| 3 | [`03_SCREENS_AND_STATES.md`](03_SCREENS_AND_STATES.md) | Every screen, route, and state machine |
| 4 | [`04_DESIGN_SYSTEM.md`](04_DESIGN_SYSTEM.md) | Colour, type, spacing, ASCII wireframes |
| 5 | [`05_VISION_PIPELINE.md`](05_VISION_PIPELINE.md) | Capture choreography, ROI, quality gates, CIELAB |
| 6 | [`06_DATA_AND_API.md`](06_DATA_AND_API.md) | SQLite schema, sync contract, OpenAPI |
| 7 | [`07_LOCALIZATION.md`](07_LOCALIZATION.md) | Locked English + Telugu strings |
| 8 | [`08_ENGINEERING_BOOTSTRAP.md`](08_ENGINEERING_BOOTSTRAP.md) | `pubspec`, folders, manifest, Docker |
| 9 | [`09_CONSENT_AND_SAFETY.md`](09_CONSENT_AND_SAFETY.md) | Consent form and safety copy locks |
| 10 | [`10_ACCEPTANCE_TESTS.md`](10_ACCEPTANCE_TESTS.md) | Definition of done and fixtures |
| 11 | [`11_SECONDARY_MODULES.md`](11_SECONDARY_MODULES.md) | Optional skin (HF) + teeth (Roboflow). Cut first. |

Machine-readable companions (do not rewrite by hand in the app):

| Path | Contents |
|---|---|
| [`engineering/pubspec.yaml`](engineering/pubspec.yaml) | Resolvable Flutter dependencies |
| [`backend/openapi.yaml`](backend/openapi.yaml) | FastAPI contract |
| [`backend/docker-compose.yml`](backend/docker-compose.yml) | Local API + Postgres |
| [`backend/schema.sql`](backend/schema.sql) | Server schema |
| [`l10n/app_en.arb`](l10n/app_en.arb) | English strings |
| [`l10n/app_te.arb`](l10n/app_te.arb) | Telugu strings |
| [`vision/cielab_reference.py`](vision/cielab_reference.py) | Canonical converter |
| [`vision/golden_cielab.json`](vision/golden_cielab.json) | Unit-test oracles |
| [`legal/consent_form_en.md`](legal/consent_form_en.md) | Paper consent (study) |
| [`legal/consent_form_te.md`](legal/consent_form_te.md) | Paper consent (Telugu) |

---

## Rules for a coding agent

1. Read `01_PRODUCT_LOCK.md` and `02_VIBE_SPEC.md` before writing any file.
2. If a detail is not in this pack, **ask**. Do not invent medical copy, thresholds, schema columns, or package versions.
3. Never display raw `L*`, `a*`, or `b*` on any ASHA-facing screen or PDF.
4. Never persist a patient name, photograph, GPS point, or ASHA personal identifier.
5. Copy disclaimer and consent strings **verbatim** from `07_LOCALIZATION.md`. Do not paraphrase.
6. Use **true CIELAB** (D65, 2°), not OpenCV-scaled Lab (`L∈[0,255]`, `a/b + 128`). Thresholds assume true Lab.
7. Pin versions from `engineering/pubspec.yaml`. Do not “upgrade while scaffolding.”
8. Target **Android only**. Face Mesh is Android-only Beta. Do not add an iOS target in v1.

---

## What v1 ships

- Language: Telugu + English
- White-reference hard gate
- Two capture series (everted lid → anemia; open temporal sclera → jaundice)
- Up to 3 attempts per series, ≥ 2 valid, median aggregation
- `LOW` / `MODERATE` / `HIGH` / `UNABLE_TO_ASSESS`
- Local encrypted SQLite, PDF referral, optional HTTPS sync
- Mandatory disclaimer on every result surface

## What v1 does not ship

Neonatal jaundice, Hindi UI, skin/teeth modules, RITnet, ABDM/ABHA, device colour profiles, hemoglobin/bilirubin numbers, Play Store listing.

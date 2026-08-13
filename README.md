# VYTRA — vibe-coding specification

| | |
|---|---|
| **Product** | VYTRA |
| **Line** | See Health. Detect Early. |
| **Pack** | **1.4.0** — authoritative |
| **Date** | 2026-08-13 |
| **Platform** | Android 8.0+ (API 26), offline-first |
| **Hackathon** | Smart India Hackathon 2026 |

This folder is the only input a coder — human or agent — is allowed to use.

Older drafts (lean PRD, AnamoAI, Technical Stack v1.2, defense guide, roadmap) are retired. Where they disagree with this pack, **this pack wins**.

VYTRA is a non-diagnostic, offline-first Android screening aid for ASHA workers. It estimates **anemia risk** from an everted lower-lid photograph and **jaundice risk** from a temporal-sclera photograph, using on-device CIELAB heuristics. It is not a medical device.

---

## Read in this order

| # | File | Why |
|---|---|---|
| — | [`AGENT_PROMPT.md`](AGENT_PROMPT.md) | Paste this as the first message to a coding agent |
| 0 | [`00_DOCUMENT_CONTROL.md`](00_DOCUMENT_CONTROL.md) | Authority and kill list |
| 1 | [`01_PRODUCT_LOCK.md`](01_PRODUCT_LOCK.md) | Frozen product decisions |
| 2 | [`02_VIBE_SPEC.md`](02_VIBE_SPEC.md) | Flow, FRs, NFRs |
| 3 | [`03_SCREENS_AND_STATES.md`](03_SCREENS_AND_STATES.md) | Every screen |
| 4 | [`04_DESIGN_SYSTEM.md`](04_DESIGN_SYSTEM.md) | Colour, type, layout |
| 5 | [`05_VISION_PIPELINE.md`](05_VISION_PIPELINE.md) | Capture, ROI, Lab |
| 6 | [`06_DATA_AND_API.md`](06_DATA_AND_API.md) | Schema and HTTP |
| 7 | [`07_LOCALIZATION.md`](07_LOCALIZATION.md) | Locked EN + TE copy |
| 8 | [`08_ENGINEERING_BOOTSTRAP.md`](08_ENGINEERING_BOOTSTRAP.md) | How to create the repo |
| 9 | [`09_CONSENT_AND_SAFETY.md`](09_CONSENT_AND_SAFETY.md) | Consent and defects |
| 10 | [`10_ACCEPTANCE_TESTS.md`](10_ACCEPTANCE_TESTS.md) | Definition of done |
| 11 | [`11_SECONDARY_MODULES.md`](11_SECONDARY_MODULES.md) | Optional skin/teeth. Cut first. |

---

## Machine files (do not invent replacements)

| Path | Role |
|---|---|
| `engineering/pubspec.yaml` | Flutter pins that resolve |
| `engineering/l10n.yaml` | `gen_l10n` config |
| `engineering/local_schema.sql` | On-phone SQLCipher |
| `l10n/app_en.arb` `l10n/app_te.arb` `l10n/app_hi.arb` | Worker strings. camelCase keys |
| `vision/cielab_reference.py` | Canonical Lab |
| `vision/classify.py` | `th-1.0.0` bins + median |
| `vision/golden_cielab.json` | Oracle. Dart must match ±0.05 |
| `backend/openapi.yaml` | Study API |
| `backend/schema.sql` | Postgres for a later host |
| `backend/app/main.py` | Runnable four-route stub |
| `design/BRAND.md` + PNGs | Locked artwork |
| `assets/icons/*.svg` | Risk shapes and chrome |
| `legal/consent_form_*.md` | Paper study forms |
| `reference/lib/src/vision/*.dart` | Drop-in Dart port |
| `tools/verify_pack.py` | Pack go/no-go |

---

## Verify before you code

```bash
python3 tools/verify_pack.py
```

That command must exit 0. It checks file presence, ARB parity and camelCase, locked English copy, Lab goldens, classification boundaries, aggregation, FastAPI health/register/sync/revoke, OpenAPI parse, and banned phrases.

---

## First slice

1. `flutter create --org in.mrcet --project-name vytra --platforms android vytra_app`
2. Replace `pubspec.yaml`. Copy `l10n.yaml`, ARBs, brand PNGs, icons, fonts.
3. Port `vision/cielab_reference.py` (or copy `reference/lib/src/vision/`) and pass the goldens.
4. S01 Language → S02 Home → S03 Consent, Telugu included.
5. Then S04–S09. Sync last. Skin/teeth never, unless `SECONDARY_TOOLS=true` after the PDF path is green.

Android only. Airplane-mode screening must work.

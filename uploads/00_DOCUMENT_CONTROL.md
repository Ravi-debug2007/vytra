# 00 — Document Control

| Field | Value |
|---|---|
| Pack | VYTRA Vibe-Coding Specification |
| Version | **1.3.0** |
| Status | Authoritative |
| Effective | 2026-08-12 |
| Classification | Internal — implementation + SIH submission |
| Supersedes | AnamoAI PRD v1.0 (draft 2025-01-27); PRD v1.4; Technical Guide v2.2; Technical Stack v1.1 and v1.2; Strategic Roadmap (unversioned); Technical Defense Guide v2.1; this pack v1.0.0 (AnamoAI display name) |

---

## 1. Authority

This pack is the **single source of truth** for implementation.

| If this happens | Do this |
|---|---|
| Two files in this pack appear to disagree | `01_PRODUCT_LOCK.md` wins, then `02_VIBE_SPEC.md`, then the specialised file. File a pack defect. Do not pick silently. |
| This pack disagrees with an older PRD, stack note, pitch deck, or chat | This pack wins. |
| A coding agent wants a package, column, screen, or string not listed here | Stop and ask the project lead. |
| Safety copy (disclaimer, consent, forbidden claims) needs a wording change | Project lead written sign-off **and** a pack version bump. The in-app string files must be updated in the same change. |

---

## 2. Kill list — do not feed these to a coder

The following files are historical. They contain contradictions this pack resolved. **Do not add them to an agent context window.**

| Retired file | Why it is dangerous |
|---|---|
| Product Requirements Document (PRD) v1.4 | Lean one-shot product. No schema, no consent, wrong Tamir attribution. |
| Optimized Technical Implementation Guide v2.2 | Same lean product. 4-point ROI that is not conjunctiva. |
| AnamoAI PRD v1.0 draft | Excellent intent, but one-shot flow, API-key auth, neonatal scope, “exact 30-day” deletion. Retired name. |
| TECHNICAL_STACK v1.2 | Good fixes (`UNABLE_TO_ASSESS`, captures table) but invented `google_mlkit_face_mesh_detection ^0.12.0`, Flutter 3.22, and a Keystore PKI that Dart cannot implement as written. |
| Strategic Implementation Roadmap | Role names and day plan only. Not a spec. |
| Technical Defense Guide v2.1 | Judge talk-track. Author line previously attributed to an AI system. Not an implementation input. |

Pitch materials may still *summarise* this pack. They must not *override* it.

---

## 3. Versioning

- **MAJOR** — behaviour a clinician, ASHA, or ethics reviewer would notice (thresholds, consent, retention, what is stored, what is displayed).
- **MINOR** — new screen, new column, new endpoint, new language, compatible.
- **PATCH** — typo, clarification, pin bump that does not change behaviour.

Every change to a locked string, a threshold, or a schema column requires:

1. A dated note in this file’s changelog.
2. The same change in every specialised file that repeats the value.
3. A bump of `algorithm_version` or `threshold_version` if vision maths changed (see `05_VISION_PIPELINE.md`).

---

## 4. Changelog

### 1.3.0 — 2026-08-12

Audit auto-fix: anemia ROI no longer drops low-`a*` pixels (`algorithm_version` → `alg-1.1.0`); `captured_at` is UTC; ARB keys are camelCase for `gen_l10n`; FastAPI stub added; Postgres not published; `SECONDARY_TOOLS` defaults off; retired PRDs moved to `/home/user/retired-prds`.

### 1.2.0 — 2026-08-12

Secondary, optional, internet-only modules: skin (Hugging Face) and teeth (Roboflow). Spec `11_SECONDARY_MODULES.md`. They do not change the offline ASHA core. First item on the cut list. Photos for these tools leave the device after a separate consent. Not on the 6-slide college deck.

### 1.1.1 — 2026-08-12

Official logo locked: forest V + lime leaf-pulse + dot; wordmark **vytra**; category line AI HEALTH SCREENING. Colours `#0E2A1C` / `#6CA532`. The designer note “vitality + diagnostics” is not a product claim and must never ship. Artwork in `design/`.

### 1.1.0 — 2026-08-12

Display name and implementation identifiers renamed from AnamoAI to **VYTRA**.

### 1.0.0 — 2026-08-12

Initial authoritative pack. Resolves the audit of 2026-08-12.

| Decision | Frozen as |
|---|---|
| Scope | Maternal / adult-child household screening. **Neonates out of v1.** |
| Capture | Two series × up to 3 attempts. Median of ≥ 2 valid. Else `UNABLE_TO_ASSESS`. |
| Conjunctiva | Everted lower lid. Face Mesh is guidance, not the tissue definition. |
| Thresholds | Prototype heuristics. **Not** Tamir 2017 cutoffs. Tamir is prior RGB work only. |
| Auth | Device UUID + server-issued bearer token. No APK-baked API key. No client PKI. |
| Retention | Records become **eligible** at 30 calendar days and are deleted on the next retention run. |
| Lighting enum | `INDOOR_NATURAL`, `INDOOR_ARTIFICIAL`, `OUTDOOR_SHADE`, `OUTDOOR_DIRECT` |
| Languages | Telugu + English. Hindi deferred. |
| Flutter / ML Kit | Flutter 3.44 stable (or the machine’s current stable ≥ 3.35). `google_mlkit_face_mesh_detection: 0.5.0`. |
| Colour space | True CIELAB D65 2°. Never OpenCV uint8 Lab. |

---

## 5. Naming

| In speech | In code |
|---|---|
| The app | `vytra` |
| A completed visit | `screening` |
| One photograph attempt | `capture` |
| Everted-lid series | `series = ANEMIA` |
| Open-eye sclera series | `series = JAUNDICE` |
| Worker-facing app mode | `asha` |
| PIN-gated researcher view | `research` |

The display name is **VYTRA**. The category line **AI HEALTH SCREENING** appears only under the official lockup (S01 / splash / title slide), never as the app title and never on a result screen.

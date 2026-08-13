# VYTRA — Comprehensive Audit Report

**Date:** 2026-08-12  
**Scope:** Entire workspace (spec pack + college pack + leftover uploads).  
**Important:** There is **no Flutter/Dart application** and **no FastAPI `app/main.py`**. Phases written for running code are applied to the *normative spec and the two Python utilities that do exist*.

---

## 1. Summary dashboard

| Severity | Count |
|---|---|
| Critical | 5 |
| High | 10 |
| Medium | 12 |
| Low | 9 |
| **Total** | **36** |

| Phase | Issues |
|---|---|
| 1 Structure | 7 |
| 2 Syntax / compile | 3 |
| 3 Logic | 6 |
| 4 Cross-file | 8 |
| 5 Runtime / functional | 4 |
| 6 Security | 5 |
| 7 Performance / practice | 3 |

| Score | Meaning |
|---|---|
| **61 / 100** | As an *implementable single source of truth* |
| **n/a as a product** | Nothing can be launched; no APK, no API process |

The pack is internally much cleaner than the original six PRDs. It is **not** deployment-ready. The worst bugs are in *specified behaviour* (anemia filter vs thresholds; retention clock; ARB keys).

---

## 2. Phase 1 — File and structure

### 1.1 Inventory (authoritative trees)

| Tree | Purpose |
|---|---|
| `vytra-vibespec/` | Implementation SSOT (docs + YAML + SQL + ARB + Lab oracle) |
| `vytra-college-submission/` | 6-slide SIH PPT + 3-day plan + brand |
| `VYTRA_THE_IDEA.md` | Human briefing |
| `ANAMOAI_DOC_AUDIT_VIBECODING.md` | Historical audit of retired PRDs |
| `uploads/` | **Retired** original PRDs + logo sources |

No `lib/`, no `android/`, no `backend/app/`.

### 1.2 Orphans

| File | Severity | Notes |
|---|---|---|
| `uploads/*.md` (6 retired PRDs) | High | Kill-listed, but still in the workspace. A coding agent that scans `/home/user` will merge them. |
| `vytra-vibespec/vision/__pycache__/` | Low | Generated; should not be in the pack. |
| `ANAMOAI_DOC_AUDIT_VIBECODING.md` | Low | Useful history; not an input to a coder. |
| `build_deck.py` helpers `add_textbox`, `_p_set`, `bullets` | Low | Defined, never called. |

### 1.3 Missing referenced artefacts

| Missing | Referenced by | Severity |
|---|---|---|
| `backend/app/main.py` (and routers) | `Dockerfile` CMD `uvicorn app.main:app` | **Critical** |
| `assets/fonts/NotoSans*.ttf` | `pubspec.yaml` | High (first `flutter build` fails) |
| `assets/brand/` in pubspec assets | `08` copies PNGs there; pubspec only lists `fonts/` and `icons/` | High |
| `lib/l10n/` + project-root `l10n.yaml` | `engineering/l10n.yaml` is a *template*, not wired | High once app is created |
| Hugging Face repo `dima806/skin_diseases_classification` | `11_SECONDARY_MODULES.md` | **Critical** if `SECONDARY_TOOLS=true` |
| Roboflow model id | `11` | High if teeth tile enabled |
| Official SIH PS ID | Slide 1, roster | High for *college submit*, not for code |

### 1.4 Folder structure

Appropriate for a **spec pack**. Not yet a Flutter/FastAPI repo. `08_ENGINEERING_BOOTSTRAP.md` describes the target layout. Fine.

### 1.5 Duplicates

| Pair | Issue |
|---|---|
| `VYTRA_THE_IDEA.md` × root and college | Drift risk (currently identical) |
| Logo PNGs in `design/` and `brand/` | Intentional copies |
| Local SQL in `06` vs `backend/schema.sql` | Same columns except server extras — see Phase 4 |

### 1.6 Config consistency

| Item | Status |
|---|---|
| Lighting enum | Consistent 4 values |
| Risk enum | Consistent + `UNABLE_TO_ASSESS` |
| ML Kit **0.5.0** | Consistent |
| Flutter pin ≥ 3.35 | Consistent |
| Pack version **1.2.0** | README + `00` now agree |
| `pdf` 3.11.3 | `pubspec` and L12 now agree |
| `JWT_SECRET` / `ADMIN_KEY` | Placeholder `change-me-*` in compose |

---

## 3. Phase 2 — Syntax and compilation

| ID | File | Sev | Finding |
|---|---|---|---|
| 2.1 | `cielab_reference.py` | — | Compiles. Goldens pass. |
| 2.2 | `build_deck.py` | — | Compiles. PPTX 6 slides. |
| 2.3 | All `.md` / `.yaml` / `.arb` / `.sql` | — | Parse OK. |
| 2.4 | **No Dart / no FastAPI** | Critical | Nothing to typecheck as an app. |
| 2.5 | `l10n/app_en.arb` dotted keys (`consent.body`, `pdf.footer`, `action.anemia.high`, `secondary.modelScore`, …) | **Critical** | Flutter `gen_l10n` requires resource names to be **valid Dart identifiers**. Dots will fail or generate unusable getters. |
| 2.6 | `build_deck.py` L8–L11, L39–L66 | Low | Unused imports (`Emu`, `MSO_ANCHOR`, `nsmap`, `etree`, `deepcopy`) and dead `if False` in `add_textbox`. |
| 2.7 | `secondary.modelScore` `{pct}` | — | EN has `@` metadata. TE inherits from template. OK. |

---

## 4. Phase 3 — Logical errors

| ID | File:line | Sev | Description | Fix |
|---|---|---|---|---|
| 3.1 | `05_VISION_PIPELINE.md` §5.1 step 4 vs §6.1 | **Critical** | Keep pixels only if `a* ≥ 4`. Anemia **HIGH** is `a* < 5`. Pale conjunctiva (the signal) is filtered out; leftover pinker pixels bias toward **LOW**. | Drop the `a* ≥ 4` keep-rule. Filter lashes/specular with L* and maybe chroma, **not** a lower bound on a*. |
| 3.2 | `06_DATA_AND_API.md` §4 retention SQL | **Critical** | `captured_at` is ISO-8601 **with offset** (device local). `datetime('now')` is UTC. IST records can be deleted ~5.5 h early. `substr(...,1,19)` also drops the offset. | Store UTC (`captured_at_utc`) and compare UTC to UTC, or parse offset correctly. |
| 3.3 | `cielab_reference.py` `apply_white_patch` | High | `r / gain_r` if a caller passes 0 → ZeroDivisionError. Spec says gains < 0.05 are invalid; the function does not enforce it. | Guard `if min(gains) < 0.05: raise`. |
| 3.4 | `11` teeth `med_w = median(widths)` | High | Empty or zero-width boxes → divide by zero in `spacing` and `symmetry`. | If `med_w <= 0` or `n < 4` → `UNABLE_TO_ASSESS` (already have n<4; add width guard). |
| 3.5 | `06` UNIQUE `(screening_id, series, capture_index)` | High | Failed attempts also insert rows. If `capture_index` is “valid count” not “attempt number”, the second fail on index 1 violates UNIQUE. | Norm: `capture_index = attempt 1..3` including invalids. |
| 3.6 | `06` `deleted_at` | Medium | Specified as **always NULL**; deletion is hard `DELETE`. Dead column. Conditions on `deleted_at` are never true. | Remove column or use it as a real soft-delete (do not do both). |
| 3.7 | `05` §5.2 left-eye raw-x comment | Medium | Comment says `x < centre.x` then immediately says “do not use raw x.” A coder who stops at the first snippet laterals the wrong half of the eye. | Delete the raw-x snippet; keep only the `dot(p-centre, axis)` rule. |

No infinite loops in the two Python files. `median([])` raises — correct.

---

## 5. Phase 4 — Cross-file contradictions

| File A | File B | Contradiction |
|---|---|---|
| `06` “Two tables. No third…” | `11` `secondary_scans` | Third table exists when secondary tools are on. (`FR-LS-03` was patched; `06` heading was not.) |
| `06` / OpenAPI sync body | JWT `sub` | `device_id` is **not** a Screening field. Server must take it from the token. Not written in OpenAPI. |
| `02` E10 | `banner.referToday` | “Accompany the **patient**” vs “Accompany the **person**.” |
| `06` local `screenings` | `backend/schema.sql` | Local has `sync_status`, `deleted_at`. Server has `device_id`, `synced_at`. Expected, but a naïve “copy schema” will break one side. |
| `08` copy brand into `assets/brand/` | `pubspec.yaml` assets | Brand folder not declared → PNGs unused at runtime. |
| `01` L2 “not for self-screening” | `11` skin/teeth | Secondary tools are consumer-shaped. |
| `02` E7 “no internet wording on S01–S09” | `11` S13 | Correct split; implementers may still put a sync banner on Home. |
| `uploads/` retired PRDs | `00` kill list | Kill list says do not feed them to a coder; they still sit in the same workspace. |

OpenAPI paths (`/api/v1/health|devices/register|sync|devices/revoke`) match `06`. Methods match. Enums match.

Validation: OpenAPI `additionalProperties: false` on Screening/Capture is stricter than the prose “ignore extra fields” in `11` (different APIs). For the study sync API, extra fields are **rejected** — good.

---

## 6. Phase 5 — Runtime / functional

There is **no** end-to-end executable path.

| ID | Sev | Finding | Fix |
|---|---|---|---|
| 5.1 | Critical | `docker compose up` → image builds → container exits: module `app.main` missing. | Implement FastAPI from `openapi.yaml` or change Dockerfile until then. |
| 5.2 | Critical | Skin tile with default model id → HF **404**. | Do not ship `SECONDARY_TOOLS=true` until a live model is pinned. |
| 5.3 | High | First `flutter create` + copy pubspec → missing fonts, missing `l10n.yaml` at project root, missing `assets/brand`. | Bootstrap script should copy those three. |
| 5.4 | High | Edge cases specified well for the *core* flow (decline, offline, dual HIGH, mesh drop). **Not** specified: HF 422, Roboflow 429, 10 MB photo, JPEG EXIF orientation, phone in landscape, two faces, child on jaundice mesh. | Add to `11` / `02` edges. |
| 5.5 | Medium | Study n=20 + pulse-ox proxy: already named; do not treat as a runtime test of accuracy. | Keep off the PPT. |

---

## 7. Phase 6 — Security

| ID | File:line | Sev | Finding | Fix |
|---|---|---|---|---|
| 6.1 | `backend/docker-compose.yml` L6, L25–27 | High | `POSTGRES_PASSWORD: vytra`, `JWT_SECRET: change-me-in-any-non-local-deploy`, `ADMIN_KEY: change-me-admin`. Port **5432 published** to the host. | Local-only compose. For any shared host: secrets file, no host 5432. |
| 6.2 | `01` L11 / `06` §9 | High | Research PIN default `2580` is in the spec anyone can read. | Random PIN per study APK via dart-define; do not print the default in the pitch. |
| 6.3 | `06` §5.1 | Medium | `/devices/register` is unauthenticated except `org_code` allow-list. Org codes are guessable (`ASHA-HYD-04`). | Rate-limit (specified, not implemented) + unguessable org codes. |
| 6.4 | `11` | **Critical** (if enabled) | Skin/teeth JPEGs go to Hugging Face / Roboflow. Core promise is “photo never leaves the phone.” | Keep `SECONDARY_TOOLS=false` on study APK. Separate consent is necessary but not sufficient for a health study. |
| 6.5 | — | — | No hardcoded `hf_` / `sk-` tokens found in the pack. | Keep it that way. |
| 6.6 | `06` retention SQL | Medium | Spec shows SQL with string-cut timestamps, not bound parameters. | Bind `cutoff` as a parameter. |
| 6.7 | `05` §9 `debugPrint` of Lab | Low | Dev-only; study flavour must compile it out (already required). | — |
| 6.8 | CORS | Low | Not defined. Native app does not need it. Do not add `*` “to help.” | — |

Injection: no executable query layer. XSS: no web UI. Command injection: N/A.

---

## 8. Phase 7 — Performance and practice

| ID | Sev | Finding |
|---|---|---|
| 7.1 | — | Dataset n≈20; no N+1 concern. |
| 7.2 | Medium | Preview: Laplacian + (jaundice) mesh every frame on Snapdragon 665 is the real budget. Spec already degrades overlay. |
| 7.3 | Low | `workmanager: 0.5.2` is an old pin for 2026; verify package name (`workmanager` vs Android-only forks). |
| 7.4 | Low | `path: 1.9.1` is normally an SDK transitive; pinning can fight the Flutter SDK. |
| 7.5 | Suggestion | Sync batches max 100 — fine. |

---

## 9. Critical issues (must fix before any “release”)

### C1 — Anemia filter deletes the anemia signal
- **File:** `vytra-vibespec/05_VISION_PIPELINE.md` §5.1 (keep `a* ≥ 4`) vs §6.1 (`HIGH` if `a* < 5`)
- **Severity:** Critical  
- **Fix:** Remove `a* ≥ 4`. Keep L* band + optional upper a* to drop saturated blood/cloth. Pale tissue must survive.

### C2 — Backend will not start
- **File:** `backend/Dockerfile` line 7 (`uvicorn app.main:app`); no `backend/app/`
- **Severity:** Critical (for any compose/demo of sync)  
- **Fix:** Implement the four OpenAPI routes or stop claiming `docker compose up` works.

### C3 — Default skin model does not exist
- **File:** `11_SECONDARY_MODULES.md` §4.1  
- **Severity:** Critical if that tile is on  
- **Fix:** Pin a live HF model or keep `SECONDARY_TOOLS=false`.

### C4 — ARB keys are not Dart identifiers
- **File:** `l10n/app_en.arb` / `app_te.arb` (e.g. lines for `consent.body`, `disclaimer.full`, `action.anemia.high`)  
- **Severity:** Critical for first `flutter gen-l10n`  
- **Fix:** Rename to camelCase (`consentBody`, `disclaimerFull`, `actionAnemiaHigh`) in both ARBs and all docs.

### C5 — 30-day deletion uses mixed clocks
- **File:** `06_DATA_AND_API.md` §4  
- **Severity:** Critical for the privacy promise  
- **Fix:** Persist UTC; delete where `captured_at_utc < now_utc - 30 days`.

---

## 10. Warnings (should fix)

See High table in Phases 3–6: brand assets not in pubspec; `device_id` only via JWT; capture_index rule; compose secrets; PIN `2580`; kill-list files still in `uploads/`; banner “patient” vs “person”; white-patch / teeth divide-by-zero; 06 “two tables” heading.

---

## 11. Suggestions

- Delete `__pycache__`. Add `.gitignore`.  
- One `THE_IDEA.md` (symlink the other).  
- Clean `build_deck.py` dead helpers.  
- Move `l10n.yaml` copy into a one-line bootstrap.  
- Replace raw-x sclera snippet in `05`.  
- Drop unused `deleted_at`.  
- Un-pin `path`.  
- Fill PS ID and roster before college submit (process, not code).

---

## 12. What is working correctly

- Single product name **VYTRA**; AnamoAI only as retired history.  
- Offline-first ASHA path is specified end-to-end (S01–S09) with discard, dual HIGH, mesh fallback.  
- True CIELAB D65 pipeline + `golden_cielab.json` **pass** (±0.05) + boundary tests for 5 / 10 / 15.  
- Risk / lighting / series enums match across `01`, `06`, OpenAPI, Postgres SQL.  
- Privacy rules for the *core* path: no name in DB, no JPEG on disk, PDF name discarded.  
- Disclaimer text in `01` L8 matches `disclaimer.full` in EN ARB.  
- EN/TE ARB user keys **125 = 125**.  
- Kill list exists so old PRDs are not supposed to be coded.  
- College deck is exactly **6** slides, 16:9, logo lockup without “diagnostics.”  
- Secondary tools are behind a cut flag and a separate consent (correct posture).  
- No live API tokens in the repo.

---

## 13. Contradictions map

| File A | File B | Contradiction |
|---|---|---|
| `05` §5.1 `a* ≥ 4` | `05` §6.1 / `01` L6 `HIGH if a* < 5` | Filter removes the class you classify |
| `06` “two tables” | `11` `secondary_scans` | Third table |
| `06` sync JSON | OpenAPI Screening | No `device_id`; must come from JWT (unstated) |
| `06` local schema | `backend/schema.sql` | `sync_status`/`deleted_at` vs `device_id`/`synced_at` |
| `08` `assets/brand/` | `pubspec.yaml` | Brand not in `flutter.assets` |
| `02` E10 “patient” | `l10n` `banner.referToday` “person” | Copy drift |
| `01` L2 no self-screen | `11` skin/teeth | Audience drift |
| `00` kill list | `uploads/*.md` | Retired specs still on disk |
| Core “photo never leaves device” | `11` HF/Roboflow POST | True only if secondary off |
| `Dockerfile` | filesystem | `app.main` does not exist |

---

## 14. Auto-fix plan (dependency order)

Do **not** start a multi-agent coding run until 1–5 are done.

1. **C1** — Edit `05` §5.1: remove `a* ≥ 4`; bump `algorithm_version` if this ships after any capture.  
2. **C5** — Specify `captured_at_utc` + rewrite retention SQL; align consent language.  
3. **C4** — Rename all dotted ARB keys to camelCase in EN+TE and grep-replace docs.  
4. **H-pubspec** — Add `assets/brand/` ; copy `l10n.yaml` into the Flutter root in `08`.  
5. **C2** — Either stub `backend/app/main.py` to the OpenAPI or mark compose as “not runnable yet” in `backend/README.md`.  
6. **C3 / 6.4** — Default `SECONDARY_TOOLS=false`; remove the 404 model id or replace with a verified one.  
7. **H-unique** — Freeze `capture_index = attempt`.  
8. **H-JWT** — One sentence in OpenAPI: `device_id = JWT.sub`.  
9. **H-secrets** — Compose: no published 5432; `env_file`; rotate PIN.  
10. **H-uploads** — Move `uploads/*.md` out of the workspace or add `AGENT_PROMPT` “do not read `/uploads`.”  
11. Copy fixes: banner string; `06` “two or three tables”; delete `__pycache__`.

---

## 15. Needs manual review

- Whether college SIH 2026 still mandates the official 6-slide template (paste required).  
- Whether `workmanager 0.5.2` and `package_info_plus 8.3.0` resolve on Flutter 3.44 (2026).  
- Faculty ethics: any photo to Hugging Face / Roboflow.  
- NFHS-5 “57%” on slide 5 — cite the exact NFHS-5 table before printing.  
- Tamir 2017 citation on slide 6 is honest; keep it that way.

---

This workspace is a **specification**, not a deployed system. The right next move is to auto-fix C1, C4, C5, pubspec assets, and the backend stub — then stop until the college PPT is submitted.

Say if you want those auto-fixes applied now.

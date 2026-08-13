# Paste this as the first message to a coding agent

You are implementing **VYTRA**, an offline-first Android screening aid for ASHA workers. Not a medical device. Not a diagnosis.

## Authority

Read, in this order, only files from `vytra-vibespec/`:

1. `README.md`
2. `01_PRODUCT_LOCK.md`
3. `02_VIBE_SPEC.md`
4. `03_SCREENS_AND_STATES.md`
5. `04_DESIGN_SYSTEM.md`
6. `05_VISION_PIPELINE.md`
7. `06_DATA_AND_API.md`
8. `07_LOCALIZATION.md`
9. `08_ENGINEERING_BOOTSTRAP.md`
10. `10_ACCEPTANCE_TESTS.md`

Read `11_SECONDARY_MODULES.md` only after the airplane-mode PDF path is green. Do not start there.

Do not read older PRDs, stack notes, defense guides, or anything under `uploads/` / `retired-prds/`. The working title **AnamoAI** is dead.

Run `python3 vytra-vibespec/tools/verify_pack.py` before writing app code. If it fails, stop.

## Hard rules

- Android only. `minSdk` 26. `compileSdk` / `targetSdk` 35.
- Copy `engineering/pubspec.yaml` versions. Face Mesh is `google_mlkit_face_mesh_detection: 0.5.0`, not 0.12.0.
- Port `vision/cielab_reference.py` (or copy `reference/lib/src/vision/cielab.dart`). Pass `vision/golden_cielab.json` ± 0.05. True CIELAB D65 2°. Never OpenCV uint8 Lab.
- Use `l10n/app_en.arb`, `l10n/app_te.arb`, and `l10n/app_hi.arb` verbatim. Keys are camelCase (`consentBody`, not `consent.body`). Do not invent medical copy. Locales: `te`, `hi`, `en`.
- Never show `a*`, `b*`, `L*`, hemoglobin, or bilirubin on ASHA screens or the PDF.
- Never persist a name, a photograph, or a GPS point.
- Fewer than 2 valid captures in a series → `UNABLE_TO_ASSESS`, never `LOW`.
- White reference is a hard gate.
- Anemia = everted lower lid + static ellipse. Face Mesh is optional and often missing.
- Jaundice = temporal sclera + Face Mesh assist. Ellipse-only fallback after 15 s.
- Thresholds are prototype heuristics `th-1.0.0`, not Tamir 2017. `algorithm_version` is `alg-1.1.0`.
- `captured_at` is UTC ending in `Z`. `capture_index` is the attempt number 1–3, including failures.
- `SECONDARY_TOOLS=false`. Do not call Hugging Face or Roboflow on the study path.
- Display name is **VYTRA**. Tagline `See Health. Detect Early.` is S01 / splash / S02 only — never on results or the PDF. Do not render the Vision + Vitality + Tracking + AI expansion in the app. Do not print “diagnostics”.
- Official artwork: `design/vytra_logo_lockup.png` and `design/vytra_mark.png`. Do not redraw the V.

## First slice (stop and show a running app)

1. Flutter scaffold, theme from `04`, l10n `te` / `en`.
2. S01 Language → S02 Home → S03 Consent.
3. Dart Lab converter + `test/cielab_test.dart` green against the goldens.

Then S04–S09 in order. Sync and research mode last.

If something is unspecified, ask. Do not invent schema columns, thresholds, or disclaimer wording.

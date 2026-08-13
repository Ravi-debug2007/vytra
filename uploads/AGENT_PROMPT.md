# Paste this as the first message to a coding agent

You are implementing **VYTRA**, an offline-first Android screening aid for ASHA workers.

## Authority

Read, in order, only these files from `vytra-vibespec/`:

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
11. `11_SECONDARY_MODULES.md` — **only after** the core airplane-mode path works. Do not start here.

Do **not** read or merge older PRDs, stack notes, or defense guides. Do **not** read `/home/user/uploads` or `/home/user/retired-prds`.

## Hard rules

- Android only. minSdk 26.
- Copy `engineering/pubspec.yaml` versions. `google_mlkit_face_mesh_detection` is **0.5.0**, not 0.12.0.
- Port `vision/cielab_reference.py` to Dart. Pass `vision/golden_cielab.json` ± 0.05. True CIELAB, never OpenCV uint8 Lab.
- Use `l10n/app_en.arb` and `l10n/app_te.arb` verbatim. Do not invent medical copy.
- Never display a*, b*, L*, hemoglobin, or bilirubin on ASHA screens or the PDF.
- Never persist a name, photo, or GPS point.
- `< 2` valid captures in a series → `UNABLE_TO_ASSESS`, never `LOW`.
- White reference is a hard gate.
- Anemia capture = everted lower lid + static ellipse (Face Mesh optional).
- Jaundice capture = temporal sclera + Face Mesh assist, ellipse fallback after 15 s.
- Thresholds are prototype heuristics `th-1.0.0`, not Tamir 2017. `algorithm_version` is `alg-1.1.0`.
- `captured_at` is UTC (`Z`). `capture_index` is the attempt number 1–3 including failures.
- Leave `SECONDARY_TOOLS=false`. Do not call Hugging Face or Roboflow in the study path.
- ARB keys are camelCase (`consentBody`, not `consent.body`).
- Display name is **VYTRA**. Tagline `See Health. Detect Early.` is S01 / splash / S02 only — never on results or the PDF. Do not render the Vision+Vitality+Tracking+AI expansion in the app.

## First slice (stop and show a running app)

1. Flutter scaffold + theme + l10n (te/en).
2. S01 Language → S02 Home → S03 Consent.
3. Dart Lab converter + golden tests green.

Then implement S04–S09 in order. Sync and research mode last. Skin/teeth (S13–S20) only if `SECONDARY_TOOLS=true` and the core PDF path is green.

If something is unspecified, ask. Do not invent schema columns, thresholds, or disclaimer wording.

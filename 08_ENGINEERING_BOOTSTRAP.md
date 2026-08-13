# 08 — Engineering Bootstrap

This file tells a coding agent how to create the repo. Copy the machine-readable files; do not invent versions.

Before scaffolding, from the pack root:

```bash
python3 tools/verify_pack.py    # must print PACK GREEN
# or: bash tools/bootstrap.sh   # creates ../vytra_app and copies locked files
```

---

## 1. Create the Flutter app

```bash
flutter --version          # must report ≥ 3.35; prefer 3.44 stable
flutter create --org in.mrcet --project-name vytra --platforms android vytra_app
cd vytra_app
```

Replace the generated `pubspec.yaml` with [`engineering/pubspec.yaml`](engineering/pubspec.yaml). Then:

```bash
mkdir -p assets/fonts assets/icons assets/brand lib/l10n lib/src
cp ../vytra-vibespec/design/vytra_mark.png ../vytra-vibespec/design/vytra_logo_lockup.png assets/brand/
cp ../vytra-vibespec/engineering/l10n.yaml .
cp ../vytra-vibespec/l10n/*.arb lib/l10n/
# download Noto Sans + Noto Sans Telugu + Noto Sans Devanagari Regular/SemiBold into assets/fonts/
flutter pub get
```

`minSdk = 26` in `android/app/build.gradle.kts`.  
`compileSdk = 35`, `targetSdk = 35`.

---

## 2. Repository layout

```
vytra_app/
├── android/
├── assets/
│   ├── fonts/
│   ├── icons/
│   └── brand/
├── lib/
│   ├── main.dart
│   ├── l10n/                          # generated + source ARB
│   └── src/
│       ├── app.dart                   # MaterialApp, locale
│       ├── core/
│       │   ├── constants/
│       │   │   ├── versions.dart      # alg-1.1.0, th-1.0.0
│       │   │   └── disclaimer.dart    # re-exports l10n, no duplicate text
│       │   ├── theme/vytra_theme.dart
│       │   ├── database/db.dart
│       │   ├── auth/token_store.dart
│       │   ├── network/api_client.dart
│       │   └── background/{retention_worker.dart,sync_worker.dart}
│       ├── features/
│       │   ├── language/
│       │   ├── home/
│       │   ├── consent/
│       │   ├── metadata/
│       │   ├── white_ref/
│       │   ├── capture/               # Bloc + anemia/jaundice screens
│       │   ├── results/
│       │   ├── pdf/
│       │   ├── sync/
│       │   ├── settings/
│       │   └── research/
│       └── vision/
│           ├── cielab.dart            # must match golden_cielab.json
│           ├── quality.dart
│           ├── roi_anemia.dart
│           └── roi_jaundice.dart
├── test/
│   ├── cielab_test.dart
│   ├── classify_test.dart
│   ├── disclaimer_layout_test.dart
│   └── schema_test.dart
└── backend/                           # or sibling repo
    ├── app/
    ├── schema.sql
    ├── openapi.yaml
    └── docker-compose.yml
```

Do not put vision maths inside widgets.

---

## 3. AndroidManifest (study / demo)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <uses-feature android:name="android.hardware.camera" android:required="true" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />

    <application
        android:label="VYTRA"
        android:usesCleartextTraffic="false">
        <!-- FileProvider for share_plus / printing -->
    </application>
</manifest>
```

No `ACCESS_FINE_LOCATION`. No `READ_MEDIA_IMAGES`. No `FOREGROUND_SERVICE` unless WorkManager on the reference device actually requires it; if it does, declare `foregroundServiceType="dataSync"` and only for the sync worker.

ML Kit Face Mesh is Android-only. Do not add an iOS target.

---

## 4. Build commands

```bash
# dev
flutter run --dart-define=ORG_CODE=ASHA-HYD-04 \
            --dart-define=API_BASE_URL=http://192.168.1.10:8000 \
            --dart-define=RESEARCH_PIN=dev-only \
            --dart-define=DEBUG_LAB=true

# study APK (what volunteers install)
flutter build apk --release --flavor study \
            --dart-define=ORG_CODE=ASHA-HYD-04 \
            --dart-define=API_BASE_URL=https://YOUR_HOST \
            --dart-define=RESEARCH_PIN=CHANGE_ME \
            --dart-define=DEBUG_LAB=false

# demo APK (SIH stage, sync no-op)
flutter build apk --release --flavor demo \
            --dart-define=ORG_CODE=DEMO \
            --dart-define=API_BASE_URL= \
            --dart-define=DEBUG_LAB=false
```

If flavours feel heavy on Day 1, use a single target and `DEBUG_LAB=false` for anything that leaves the team. Add flavours by Day 9.

Cleartext is off. A local HTTP backend on a phone therefore needs either `adb reverse tcp:8000 tcp:8000` with an exception **only in the dev debug manifest**, or HTTPS via a tunnel.

---

## 5. Backend

```bash
cd backend
docker compose up --build
# GET http://localhost:8000/api/v1/health
```

`app/main.py` is implemented against [`backend/openapi.yaml`](backend/openapi.yaml). Copy env from `backend/.env.example`. Do not publish Postgres to the host. Do not add extra routes.

---

## 6. First tests that must exist before camera work

```bash
cp ../vytra-vibespec/vision/golden_cielab.json test/fixtures/
cp ../vytra-vibespec/vision/cielab_reference.py tool/   # optional oracle
flutter test test/cielab_test.dart test/classify_test.dart
```

If Lab goldens fail, stop. Every later screen will lie.

---

## 7. Agent prompt (paste this, not the old PRDs)

> Implement VYTRA from `/vytra-vibespec` only. Start with `01_PRODUCT_LOCK.md` and `02_VIBE_SPEC.md`. Use `engineering/pubspec.yaml` versions. Port `vision/cielab_reference.py` to Dart and pass `vision/golden_cielab.json`. Use ARB strings verbatim. Do not invent schema columns, thresholds, or medical copy. Android only. Offline screening must work in airplane mode.

---

## 8. Known integration traps

| Trap | What to do |
|---|---|
| `google_mlkit_face_mesh_detection` 0.12.0 | Does not exist. Use **0.5.0**. |
| Flutter 3.22 | Do not install. Use ≥ 3.35. |
| SQLCipher on API 26 | Prove open + encrypt on an API 26 emulator on Day 2. |
| Telugu PDF tofu | Embed the TTF; do not rely on device fonts. Day 1 PoC. |
| Camera image stream vs still | Preview uses stream; capture uses the **same** frame that passed the gates, converted to RGB. |
| `camera` 0.12 requires newer Flutter | If `pub get` complains, pin `camera: 0.11.2`. |
| WorkManager killed by OEM | Retention also runs on every cold start. |

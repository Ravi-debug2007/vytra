# VYTRA

VYTRA is an Android-only, offline-first screening aid for trained ASHA workers. This repository is initialized from the supplied authoritative VYTRA specification pack.

## Current milestone

The initial Flutter source slice includes:

- Android-only package configuration with the locked core dependencies.
- S01 language selection for English and Telugu.
- S02 home screen.
- S03 consent flow with the locked non-diagnostic safety disclaimer.
- S04 session metadata for Fitzpatrick scale, assessment method, and lighting.
- S05 white-reference route placeholder and hard-gate entry point.
- A true CIELAB D65/2° conversion module and initial golden sanity tests.

The camera, ML Kit Face Mesh, quality gates, SQLCipher persistence, PDF generation, background retention, and optional sync are intentionally the next implementation slice. Do not invent thresholds, schema fields, or safety copy; use the supplied pack verbatim.

## Validation

The sandbox used for this handoff does not include the Flutter SDK or Android SDK, so `flutter pub get`, `flutter analyze`, `flutter test`, and APK builds must be run on a Flutter-equipped development machine.

Expected first commands:

```bash
flutter --version
flutter pub get
flutter test test/cielab_test.dart
flutter analyze
flutter build apk --release --flavor demo \
  --dart-define=ORG_CODE=DEMO \
  --dart-define=API_BASE_URL= \
  --dart-define=DEBUG_LAB=false
```

Before distributing a build, add the Android manifest, minSdk 26, Telugu fonts, ARB localization generation, encrypted database, and the acceptance tests from the source pack.

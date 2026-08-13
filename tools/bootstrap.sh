#!/usr/bin/env bash
# Create the Flutter app next to this pack and copy locked files in.
set -euo pipefail
PACK="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$PACK/.." && pwd)"
APP="$ROOT/vytra_app"

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter is not on PATH. Install Flutter ≥ 3.35, then re-run."
  exit 1
fi

if [[ ! -d "$APP" ]]; then
  (cd "$ROOT" && flutter create --org in.mrcet --project-name vytra --platforms android vytra_app)
fi

cp "$PACK/engineering/pubspec.yaml" "$APP/pubspec.yaml"
cp "$PACK/engineering/l10n.yaml" "$APP/l10n.yaml"
mkdir -p "$APP/lib/l10n" "$APP/assets/brand" "$APP/assets/icons" "$APP/assets/fonts" \
         "$APP/test/fixtures" "$APP/lib/src/vision" "$APP/lib/src/core/constants" \
         "$APP/lib/src/core/theme"
cp "$PACK/l10n/"*.arb "$APP/lib/l10n/"
cp "$PACK/design/vytra_mark.png" "$PACK/design/vytra_logo_lockup.png" \
   "$PACK/design/vytra_app_icon_light.png" "$PACK/design/vytra_app_icon_dark.png" \
   "$APP/assets/brand/"
cp "$PACK/assets/icons/"*.svg "$APP/assets/icons/"
cp "$PACK/vision/golden_cielab.json" "$APP/test/fixtures/"
cp "$PACK/reference/lib/src/vision/"*.dart "$APP/lib/src/vision/"
cp "$PACK/reference/lib/src/core/constants/versions.dart" "$APP/lib/src/core/constants/"
cp "$PACK/reference/lib/src/core/theme/vytra_theme.dart" "$APP/lib/src/core/theme/"
cp "$PACK/reference/test/cielab_test.dart" "$APP/test/"

echo "Copied locked files into $APP"
echo "Next: download Noto Sans + Noto Sans Telugu into $APP/assets/fonts/"
echo "      then: cd $APP && flutter pub get && flutter test test/cielab_test.dart"

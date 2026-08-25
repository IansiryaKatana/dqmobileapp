#!/usr/bin/env bash
# Build a release IPA on macOS (requires Xcode + signing identities).
# Usage:
#   cp .env.example .env   # fill real keys
#   ./scripts/build-ios.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS IPA builds require macOS with Xcode. Use Codemagic workflow ios-release on Linux CI." >&2
  exit 1
fi

if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example and set SUPABASE / RevenueCat iOS / Stripe keys." >&2
  exit 1
fi

command -v flutter >/dev/null || { echo "flutter not found on PATH" >&2; exit 1; }

flutter pub get
(
  cd ios
  pod install
)

EXPORT_PLIST="${EXPORT_OPTIONS_PLIST:-ios/ExportOptions.plist}"
if [[ ! -f "$EXPORT_PLIST" ]]; then
  echo "Missing $EXPORT_PLIST (or set EXPORT_OPTIONS_PLIST)." >&2
  exit 1
fi

flutter build ipa --release \
  --dart-define-from-file=.env \
  --export-options-plist="$EXPORT_PLIST"

echo "IPA: $(ls -1 build/ios/ipa/*.ipa 2>/dev/null || echo 'see build/ios/ipa/')"

#!/usr/bin/env bash
# Build Donate Quran for iOS on this Mac (Codemagic not required).
#
# Usage:
#   cp .env.example .env          # fill real keys
#   ./scripts/build-ios.sh        # release IPA (default)
#   ./scripts/build-ios.sh sim    # iOS Simulator build
#   ./scripts/build-ios.sh ios    # device .app (no IPA export)
#   ./scripts/build-ios.sh open   # open Xcode workspace after pod install
#
# Optional env:
#   APPLE_TEAM_ID=XXXXXXXXXX     # Apple Developer Team ID (10 chars)
#   EXPORT_OPTIONS_PLIST=path    # override ExportOptions.plist
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
MODE="${1:-ipa}"

die() { echo "error: $*" >&2; exit 1; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script must run on the Mac with Xcode installed (this cloud agent is Linux)."
fi

command -v flutter >/dev/null || die "flutter not found on PATH (install Flutter, then re-open Terminal)"
command -v xcodebuild >/dev/null || die "xcodebuild not found — install Xcode from the App Store and run: sudo xcode-select -s /Applications/Xcode.app"
command -v pod >/dev/null || die "CocoaPods missing — run: sudo gem install cocoapods"

if [[ ! -f .env ]]; then
  die "Missing .env — run: cp .env.example .env   then fill SUPABASE / REVENUECAT_API_KEY_IOS / STRIPE_PUBLISHABLE_KEY"
fi

# Prefer Team ID from env, else from an already-configured Xcode project, else fail for IPA.
resolve_team_id() {
  if [[ -n "${APPLE_TEAM_ID:-}" ]]; then
    echo "$APPLE_TEAM_ID"
    return
  fi
  local from_proj
  from_proj="$(grep -o 'DEVELOPMENT_TEAM = [A-Z0-9]*;' ios/Runner.xcodeproj/project.pbxproj 2>/dev/null | head -1 | awk '{print $3}' | tr -d ';')" || true
  if [[ -n "${from_proj:-}" && "$from_proj" != "" ]]; then
    echo "$from_proj"
    return
  fi
  # First team from local signing identities (best-effort).
  local from_security
  from_security="$(security find-identity -v -p codesigning 2>/dev/null | grep -E 'Apple Development|Apple Distribution|iPhone' | head -1 | sed -n 's/.*(\([A-Z0-9]\{10\}\)).*/\1/p')" || true
  if [[ -n "${from_security:-}" ]]; then
    echo "$from_security"
    return
  fi
  echo ""
}

echo "==> flutter pub get"
flutter pub get

echo "==> pod install"
(
  cd ios
  pod install
)

case "$MODE" in
  open)
    open ios/Runner.xcworkspace
    echo "Opened Xcode. Select Runner → Signing & Capabilities → your Team, then Product → Archive."
    exit 0
    ;;
  sim|simulator)
    echo "==> flutter build ios --simulator"
    flutter build ios --simulator --debug --dart-define-from-file=.env
    echo "Simulator build: build/ios/iphonesimulator/Runner.app"
    echo "Run with: flutter run --dart-define-from-file=.env -d \"iPhone\""
    exit 0
    ;;
  ios|app)
    echo "==> flutter build ios --release"
    flutter build ios --release --dart-define-from-file=.env
    echo "Device build under build/ios/iphoneos/"
    exit 0
    ;;
  ipa|release|"")
    TEAM_ID="$(resolve_team_id)"
    EXPORT_SRC="${EXPORT_OPTIONS_PLIST:-ios/ExportOptions.plist}"
    [[ -f "$EXPORT_SRC" ]] || die "Missing $EXPORT_SRC"

    EXPORT_USE="$EXPORT_SRC"
    if grep -q 'TEAM_ID' "$EXPORT_SRC" 2>/dev/null; then
      [[ -n "$TEAM_ID" ]] || die "Set APPLE_TEAM_ID (10-char Apple Team ID) or open Xcode once: ./scripts/build-ios.sh open"
      EXPORT_USE="$(mktemp /tmp/ExportOptions.XXXXXX.plist)"
      sed "s/TEAM_ID/${TEAM_ID}/g" "$EXPORT_SRC" > "$EXPORT_USE"
      echo "==> Using Apple Team ID: $TEAM_ID"
    fi

    echo "==> flutter build ipa --release"
    flutter build ipa --release \
      --dart-define-from-file=.env \
      --export-options-plist="$EXPORT_USE"

    [[ "$EXPORT_USE" != "$EXPORT_SRC" ]] && rm -f "$EXPORT_USE"

    echo
    echo "IPA ready:"
    ls -la build/ios/ipa/*.ipa 2>/dev/null || echo "  (check build/ios/ipa/)"
    echo "Open Organizer: open build/ios/archive/*.xcarchive 2>/dev/null || true"
    ;;
  *)
    die "Unknown mode '$MODE'. Use: ipa | sim | ios | open"
    ;;
esac

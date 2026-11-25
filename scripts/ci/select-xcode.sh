#!/usr/bin/env bash
# Select the newest non-Beta Xcode installed on a GitHub Actions macOS runner,
# switch xcode-select to it, and export DEVELOPER_DIR to GITHUB_ENV if present.
set -euo pipefail

XCODE="$(
  for app in /Applications/Xcode*.app; do
    [[ -e "$app" ]] || continue
    [[ -L "$app" ]] && continue
    license=""
    if [[ -f "$app/Contents/Resources/LicenseInfo.plist" ]]; then
      license="$(plutil -extract licenseType raw "$app/Contents/Resources/LicenseInfo.plist" 2>/dev/null || true)"
    fi
    [[ "$license" == *Beta* ]] && continue
    ver="$(plutil -extract CFBundleShortVersionString raw "$app/Contents/version.plist" 2>/dev/null || echo "0.0")"
    printf '%s\t%s\n' "$ver" "$app"
  done | sort -V | tail -n 1 | cut -f 2
)"

if [[ -z "$XCODE" ]]; then
  echo "FAIL: no stable /Applications/Xcode*.app found on runner" >&2
  exit 1
fi

echo "Selected Xcode: $XCODE"
sudo xcode-select -s "$XCODE/Contents/Developer"
export DEVELOPER_DIR="$XCODE/Contents/Developer"
if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "DEVELOPER_DIR=$DEVELOPER_DIR" >> "$GITHUB_ENV"
fi
xcodebuild -version

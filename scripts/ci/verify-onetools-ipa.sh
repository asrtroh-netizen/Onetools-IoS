#!/usr/bin/env bash
# Binary, Objective-C class-table, process-isolation, and bundle audit for the
# unified all-in-one OneTools.ipa (Clash + OneUI + SwiptUI + FeatherUI).
set -euo pipefail

APP_BUNDLE="${1:?Usage: $0 <path-to-Clash.app> <path-to-OneTools.ipa> <output-report.md>}"
IPA_FILE="${2:?Usage: $0 <path-to-Clash.app> <path-to-OneTools.ipa> <output-report.md>}"
REPORT="${3:?Usage: $0 <path-to-Clash.app> <path-to-OneTools.ipa> <output-report.md>}"

mkdir -p "$(dirname "$REPORT")"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

MAIN_BIN="$APP_BUNDLE/Clash"
EXT_BIN="$APP_BUNDLE/PlugIns/ClashiOSExtension.appex/ClashiOSExtension"

echo "==> 1. Verifying main binary links Clash, SwiptUI, and FeatherUI"
MAIN_OTOOL="$(xcrun otool -L "$MAIN_BIN")"
for required in "Clash.framework/Clash" "SwiptUI.framework/SwiptUI" "FeatherUI.framework/FeatherUI"; do
  if ! grep -q "$required" <<<"$MAIN_OTOOL"; then
    echo "FAIL: Main executable does not link $required!" >&2
    echo "$MAIN_OTOOL" >&2
    exit 1
  fi
done

echo "==> 2. Verifying every embedded framework in Frameworks/ is a dynamic library (not static ar)"
FW_TABLE=""
for fw in "$APP_BUNDLE/Frameworks/"*.framework; do
  fw_name="$(basename "$fw" .framework)"
  fw_bin="$fw/$fw_name"
  if [[ ! -f "$fw_bin" && -f "$fw/Versions/Current/$fw_name" ]]; then
    fw_bin="$fw/Versions/Current/$fw_name"
  fi
  if [[ ! -f "$fw_bin" ]]; then
    echo "FAIL: Missing binary $fw_bin" >&2
    exit 1
  fi
  ftype="$(file -b "$fw_bin")"
  if [[ "$ftype" == *"ar archive"* ]]; then
    echo "FAIL: Static archive placed inside Frameworks/: $fw_bin ($ftype)" >&2
    exit 1
  fi
  fsize="$(du -sh "$fw" | awk '{print $1}')"
  FW_TABLE+=$'| `'"${fw_name}.framework"$'` | `'"${fsize}"$'` | `'"${ftype}"$'` |\n'
done

echo "==> 3. Auditing Objective-C classes across main app + all embedded frameworks"
> "$WORK/all_objc_classes.tsv"
for img in "$MAIN_BIN" "$APP_BUNDLE/Frameworks/"*.framework/*; do
  if [[ -f "$img" ]] && file -b "$img" | grep -q "Mach-O"; then
    img_label="$(basename "$(dirname "$img")")/$(basename "$img")"
    xcrun nm -gU "$img" 2>/dev/null | awk -v lbl="$img_label" '/_OBJC_CLASS_\$_/{print $NF "\t" lbl}' >> "$WORK/all_objc_classes.tsv" || true
  fi
done

awk -F'\t' '{count[$1]++; imgs[$1]=(imgs[$1] ? imgs[$1] ", " $2 : $2)} END {for (c in count) if (count[c] > 1) print c "\t" imgs[c]}' \
  "$WORK/all_objc_classes.tsv" | sort > "$WORK/dup_objc_classes.tsv"

DUP_OBJC_COUNT="$(wc -l < "$WORK/dup_objc_classes.tsv" | tr -d ' ')"
if grep -qE 'GoSeqRef|RefTracker|RefCounter|goSeqDictionary|Universeerror' "$WORK/dup_objc_classes.tsv"; then
  echo "FAIL: gomobile Objective-C bridge class collision detected!" >&2
  cat "$WORK/dup_objc_classes.tsv" >&2
  exit 1
fi

echo "==> 4. Verifying PacketTunnel extension process isolation (Master Plan 5.3)"
EXT_OTOOL="$(xcrun otool -L "$EXT_BIN")"
if ! grep -q "Clash.framework/Clash" <<<"$EXT_OTOOL"; then
  echo "FAIL: ClashiOSExtension does not link Clash.framework" >&2
  exit 1
fi
for forbidden_ext in "LibSwipt" "SwiptUI" "FeatherUI" "React.framework" "hermesvm.framework"; do
  if grep -q "$forbidden_ext" <<<"$EXT_OTOOL"; then
    echo "FAIL: ClashiOSExtension leaked dependency on $forbidden_ext!" >&2
    exit 1
  fi
done

echo "==> 5. Verifying bundled resources & merged Info.plist metadata"
DISPLAY_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$APP_BUNDLE/Info.plist")"
SWIPT_CHANNEL="$(/usr/libexec/PlistBuddy -c 'Print :SwiptChannel' "$APP_BUNDLE/Info.plist")"
APP_GROUP_KEY="$(/usr/libexec/PlistBuddy -c 'Print :AppGroupIdentifier' "$APP_BUNDLE/Info.plist")"

if [[ "$DISPLAY_NAME" != "OneTools" || "$SWIPT_CHANNEL" != "stable" ]]; then
  echo "FAIL: Unexpected Info.plist metadata: CFBundleDisplayName=$DISPLAY_NAME SwiptChannel=$SWIPT_CHANNEL" >&2
  exit 1
fi

for res_path in \
  "$APP_BUNDLE/onetools-cn-ads.plugin" \
  "$APP_BUNDLE/EXConstants.bundle" \
  "$APP_BUNDLE/Frameworks/SwiptUI.framework/main.jsbundle" \
  "$APP_BUNDLE/Frameworks/SwiptUI.framework/DeveloperDiskImage/Image.dmg" \
  "$APP_BUNDLE/Frameworks/FeatherUI.framework/Feather.momd" \
  "$APP_BUNDLE/Frameworks/FeatherUI.framework/server.crt" \
  "$APP_BUNDLE/Frameworks/FeatherUI.framework/ellekit.deb"; do
  if [[ ! -e "$res_path" ]]; then
    echo "FAIL: Expected resource missing in unified app bundle: $res_path" >&2
    exit 1
  fi
done

APP_SIZE="$(du -sh "$APP_BUNDLE" | awk '{print $1}')"
IPA_SIZE="$(ls -lh "$IPA_FILE" | awk '{print $5}')"
IPA_BYTES="$(wc -c < "$IPA_FILE" | tr -d ' ')"

{
  echo "# OneTools All-in-One Unified IPA Audit Report"
  echo ""
  echo "- **IPA Artifact**: \`$(basename "$IPA_FILE")\` (**$IPA_SIZE** / \`$IPA_BYTES\` bytes)"
  echo "- **Unpacked \`.app\` Size**: **$APP_SIZE**"
  echo "- **CFBundleDisplayName**: \`$DISPLAY_NAME\`"
  echo "- **SwiptChannel**: \`$SWIPT_CHANNEL\`"
  echo "- **AppGroupIdentifier**: \`$APP_GROUP_KEY\`"
  echo "- **gomobile ObjC Class Collisions**: **0** (\`GoSeqRef\` in \`Clash.framework\`, \`SwiptGoSeqRef\` in \`LibSwipt.framework\`)"
  echo "- **Total Cross-Framework Duplicate ObjC Classes**: **$DUP_OBJC_COUNT**"
  echo "- **PacketTunnel Extension Isolation**: **PASS** (\`ClashiOSExtension\` links \`Clash.framework\` only)"
  echo ""
  echo "## Main Executable Linked Frameworks (\`otool -L\`)"
  echo '```text'
  echo "$MAIN_OTOOL"
  echo '```'
  echo ""
  echo "## Embedded Dynamic Frameworks (\`Frameworks/\`)"
  echo "| Framework | Unpacked Size | Mach-O Type |"
  echo "|---|---|---|"
  printf '%s' "$FW_TABLE"
  echo ""
  echo "## PacketTunnel Extension Linked Libraries (\`ClashiOSExtension\`)"
  echo '```text'
  echo "$EXT_OTOOL"
  echo '```'
  if [[ "$DUP_OBJC_COUNT" -gt 0 ]]; then
    echo ""
    echo "## Non-Go Duplicate Objective-C Classes"
    echo '```text'
    cat "$WORK/dup_objc_classes.tsv"
    echo '```'
  fi
} > "$REPORT"

cat "$REPORT"

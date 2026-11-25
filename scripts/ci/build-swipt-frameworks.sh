#!/usr/bin/env bash
# Build dynamic LibSwipt.framework (with isolated SwiptGoSeqRef Objective-C classes)
# and SwiptUI.framework (+ React Native / Expo runtime frameworks) for embedding into
# the unified OneTools single-IPA host on Xcode 27.
set -euo pipefail

SWIPT_DIR="${1:?Usage: $0 <swipt-dir> <output-stage-dir> [spm-cache-dir]}"
OUT_DIR="${2:?Usage: $0 <swipt-dir> <output-stage-dir> [spm-cache-dir]}"
SPM_CACHE_DIR="${3:-${RUNNER_TEMP:-/tmp}/SwiptSPM}"

mkdir -p "$OUT_DIR/frameworks" "$OUT_DIR/resources"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"

cd "$SWIPT_DIR"

XCF_SLICE="Frameworks/LibSwipt.xcframework/ios-arm64/LibSwipt.framework"
STATIC_BIN="$XCF_SLICE/LibSwipt"
if [[ ! -f "$STATIC_BIN" && -f "$XCF_SLICE/Versions/A/LibSwipt" ]]; then
  STATIC_BIN="$XCF_SLICE/Versions/A/LibSwipt"
fi
HEADERS_SRC="$XCF_SLICE/Headers"
if [[ ! -d "$HEADERS_SRC" && -d "$XCF_SLICE/Versions/A/Headers" ]]; then
  HEADERS_SRC="$XCF_SLICE/Versions/A/Headers"
fi
MODULES_SRC="$XCF_SLICE/Modules"
if [[ ! -d "$MODULES_SRC" && -d "$XCF_SLICE/Versions/A/Modules" ]]; then
  MODULES_SRC="$XCF_SLICE/Versions/A/Modules"
fi

echo "==> Verifying isolated Objective-C bridge classes in LibSwipt static archive"
OBJC_CLASSES="$(xcrun nm -gU "$STATIC_BIN" | awk '/_OBJC_CLASS_\$_/{print $NF}')"
echo "$OBJC_CLASSES"
if ! grep -q '_OBJC_CLASS_\$_SwiptGoSeqRef$' <<<"$OBJC_CLASSES"; then
  echo "FAIL: Expected _OBJC_CLASS_\$_SwiptGoSeqRef in LibSwipt archive" >&2
  exit 1
fi
for forbidden in GoSeqRef RefTracker RefCounter goSeqDictionary Universeerror; do
  if grep -q "_OBJC_CLASS_\\\$_${forbidden}\$" <<<"$OBJC_CLASSES"; then
    echo "FAIL: Unprefixed Objective-C class $forbidden still present in LibSwipt archive!" >&2
    exit 1
  fi
done

echo "==> Wrapping LibSwipt c-archive into symbol-isolated @rpath/LibSwipt.framework"
DYN_WRAP_ROOT="$(mktemp -d "${RUNNER_TEMP:-/tmp}/libswipt-dyn.XXXXXX")"
cleanup() {
  rm -rf "$DYN_WRAP_ROOT" "$SWIPT_DIR/SwiptUIBuild.xcodeproj"
}
trap cleanup EXIT

DYN_FW="$DYN_WRAP_ROOT/LibSwipt.framework"
mkdir -p "$DYN_FW/Headers" "$DYN_FW/Modules"
cp -R "$HEADERS_SRC/"* "$DYN_FW/Headers/"
cp -R "$MODULES_SRC/"* "$DYN_FW/Modules/"

IOS_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
xcrun clang -arch arm64 -isysroot "$IOS_SDK" -miphoneos-version-min=16.4 \
  -dynamiclib -install_name "@rpath/LibSwipt.framework/LibSwipt" \
  -Wl,-force_load,"$STATIC_BIN" \
  -Wl,-exported_symbol,"_OBJC_CLASS_\$_*" \
  -Wl,-exported_symbol,"_OBJC_METACLASS_\$_*" \
  -Wl,-exported_symbol,"_LibSwipt*" \
  -Wl,-exported_symbol,"_Libswipt*" \
  -Wl,-exported_symbol,"_Swipt*" \
  -framework Foundation -framework Security -framework Network -framework UIKit \
  -lresolv -lc++ -lsqlite3 \
  -o "$DYN_FW/LibSwipt"

cat > "$DYN_FW/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>LibSwipt</string>
  <key>CFBundleIdentifier</key>
  <string>org.onetools.clash.libswipt</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>LibSwipt</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>MinimumOSVersion</key>
  <string>16.4</string>
</dict>
</plist>
PLIST

echo "==> Ensuring main.jsbundle exists"
make runtime_bundle

echo "==> Generating SwiptUIBuild.xcodeproj for SwiptUI.framework"
rm -rf SwiptUIBuild.xcodeproj
cp -R Swipt.xcodeproj SwiptUIBuild.xcodeproj

python3 - "$DYN_WRAP_ROOT" <<'PY'
from pathlib import Path
import re
import sys

dyn_wrap_root = sys.argv[1]
pbx_path = Path("SwiptUIBuild.xcodeproj/project.pbxproj")
text = pbx_path.read_text(encoding="utf-8")

# 1. Convert iOS app product reference & native target into SwiptUI.framework
text = text.replace(
    '5C0000000000000000000101 /* Swipt.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Swipt.app; sourceTree = BUILT_PRODUCTS_DIR; };',
    '5C0000000000000000000101 /* SwiptUI.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = SwiptUI.framework; sourceTree = BUILT_PRODUCTS_DIR; };',
)
text = text.replace(
    'productName = Swipt;\n\t\t\tproductReference = 5C0000000000000000000101 /* Swipt.app */;\n\t\t\tproductType = "com.apple.product-type.application";',
    'productName = SwiptUI;\n\t\t\tproductReference = 5C0000000000000000000101 /* SwiptUI.framework */;\n\t\t\tproductType = "com.apple.product-type.framework";',
)

# 2. Do not statically link LibSwipt.xcframework or embed nested RN frameworks inside SwiptUI.framework
text = text.replace('\t\t\t\t5C0000000000000000000201 /* LibSwipt.xcframework in Frameworks */,\n', '')
text = text.replace('\t\t\t\t11488A7061C8582F256B78D7 /* Embed React Native Flavored Frameworks */,\n', '')

# 3. Exclude AppIcon.icon & Swipt.entitlements from framework resources
text = text.replace(
    'membershipExceptions = (\n\t\t\t\tInfo.plist,\n\t\t\t);\n\t\t\ttarget = 5C0000000000000000000501 /* Swipt */;',
    'membershipExceptions = (\n\t\t\t\tInfo.plist,\n\t\t\t\tResources/AppIcon.icon,\n\t\t\t\tSwipt.entitlements,\n\t\t\t);\n\t\t\ttarget = 5C0000000000000000000501 /* Swipt */;',
)

# 4. Patch iOS target Debug (603) and Release (604) build configurations
def patch_ios_config(block: str, is_debug: bool) -> str:
    block = re.sub(r'\t+ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n', '', block)
    block = re.sub(r'\t+INFOPLIST_FILE = Swipt/Info\.plist;\n', '', block)
    block = block.replace('PRODUCT_BUNDLE_IDENTIFIER = io.nekohasekai.swipt;', 'PRODUCT_BUNDLE_IDENTIFIER = org.onetools.clash.swiptui;')
    block = block.replace('PRODUCT_MODULE_NAME = Swipt;', 'PRODUCT_MODULE_NAME = SwiptUI;')
    block = block.replace('PRODUCT_NAME = Swipt;', 'PRODUCT_NAME = SwiptUI;')
    cond = '"DEBUG ONETOOLS_EMBEDDED $(inherited)"' if is_debug else '"ONETOOLS_EMBEDDED $(inherited)"'
    extra = (
        f'\t\t\t\tDEFINES_MODULE = YES;\n'
        f'\t\t\t\tDYLIB_INSTALL_NAME_BASE = "@rpath";\n'
        f'\t\t\t\tINSTALL_PATH = "@rpath";\n'
        f'\t\t\t\tSKIP_INSTALL = NO;\n'
        f'\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = {cond};\n'
        f'\t\t\t\tFRAMEWORK_SEARCH_PATHS = (\n'
        f'\t\t\t\t\t"$(inherited)",\n'
        f'\t\t\t\t\t"{dyn_wrap_root}",\n'
        f'\t\t\t\t);\n'
    )
    block = block.replace(
        'OTHER_LDFLAGS = (\n\t\t\t\t\t"$(inherited)",\n',
        extra + '\t\t\t\tOTHER_LDFLAGS = (\n\t\t\t\t\t"$(inherited)",\n\t\t\t\t\t"-framework",\n\t\t\t\t\t"LibSwipt",\n',
    )
    return block

for cfg_id, is_dbg in (("5C0000000000000000000603", True), ("5C0000000000000000000604", False)):
    pattern = re.compile(rf'(\t\t{cfg_id} /\* (?:Debug|Release) \*/ = \{{.*?\n\t\t\}};)', re.DOTALL)
    m = pattern.search(text)
    if not m:
        raise SystemExit(f"Could not find config block {cfg_id}")
    text = text[:m.start(1)] + patch_ios_config(m.group(1), is_dbg) + text[m.end(1):]

pbx_path.write_text(text, encoding="utf-8")

scheme_path = Path("SwiptUIBuild.xcodeproj/xcshareddata/xcschemes/Swipt.xcscheme")
scheme_text = scheme_path.read_text(encoding="utf-8")
scheme_text = scheme_text.replace("container:Swipt.xcodeproj", "container:SwiptUIBuild.xcodeproj")
scheme_text = scheme_text.replace('BuildableName = "Swipt.app"', 'BuildableName = "SwiptUI.framework"')
scheme_path.write_text(scheme_text, encoding="utf-8")

print("Generated SwiptUIBuild.xcodeproj & updated Swipt.xcscheme successfully")
PY

# Keep sync-autolinking.sh stamp newer than SwiptUIBuild.xcodeproj/.spm-injected.json
if [[ -f build/generated/autolinking/.spm-sync-stamp ]]; then
  touch build/generated/autolinking/.spm-sync-stamp
fi

DERIVED_UI="${RUNNER_TEMP:-/tmp}/SwiptUIDerivedData"
COMP_CACHE="${RUNNER_TEMP:-/tmp}/SwiptCompCache"
rm -rf "$DERIVED_UI"

echo "==> Building SwiptUI.framework (Release, generic/platform=iOS)"
xcodebuild build \
  -project SwiptUIBuild.xcodeproj \
  -scheme Swipt \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_UI" \
  -clonedSourcePackagesDirPath "$SPM_CACHE_DIR" \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  COMPILATION_CACHE_ENABLE_CACHING=YES \
  COMPILATION_CACHE_CAS_PATH="$COMP_CACHE" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

SWIPT_UI_FW="$DERIVED_UI/Build/Products/Release-iphoneos/SwiptUI.framework"
if [[ ! -d "$SWIPT_UI_FW" ]]; then
  echo "FAIL: SwiptUI.framework not found at $SWIPT_UI_FW" >&2
  exit 1
fi

echo "==> Staging LibSwipt.framework, SwiptUI.framework, EXConstants.bundle & RN frameworks"
cp -RL "$DYN_FW" "$OUT_DIR/frameworks/LibSwipt.framework"
cp -RL "$SWIPT_UI_FW" "$OUT_DIR/frameworks/SwiptUI.framework"

if [[ -d "$SWIPT_UI_FW/EXConstants.bundle" ]]; then
  cp -RL "$SWIPT_UI_FW/EXConstants.bundle" "$OUT_DIR/resources/EXConstants.bundle"
fi

RN_FRAMEWORKS=(
  "build/xcframeworks/release/React.xcframework/ios-arm64/React.framework"
  "build/xcframeworks/release/ReactNativeDependencies.xcframework/ios-arm64/ReactNativeDependencies.framework"
  "build/xcframeworks/release/hermes-engine.xcframework/ios-arm64/hermesvm.framework"
  "build/xcframeworks/release/plugins/expo-font.xcframework/ios-arm64/ExpoFont.framework"
  "build/xcframeworks/release/plugins/expo-maps.xcframework/ios-arm64/ExpoMaps.framework"
  "build/xcframeworks/release/plugins/expo-modules-core.xcframework/ios-arm64/ExpoModulesCore.framework"
  "build/xcframeworks/release/plugins/expo-modules-worklets.xcframework/ios-arm64/ExpoModulesWorklets.framework"
)
for fw in "${RN_FRAMEWORKS[@]}"; do
  if [[ ! -d "$fw" ]]; then
    echo "FAIL: Expected RN framework missing: $fw" >&2
    exit 1
  fi
  cp -RL "$fw" "$OUT_DIR/frameworks/$(basename "$fw")"
done

ls -lh "$OUT_DIR/frameworks" "$OUT_DIR/resources"

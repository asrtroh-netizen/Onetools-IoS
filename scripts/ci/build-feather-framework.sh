#!/usr/bin/env bash
# Build standalone OneTools-Feather-unsigned.ipa AND dynamic FeatherUI.framework
# (+ IDevice.framework & OpenSSL.framework) on Xcode 27 for embedding into OneTools.
set -euo pipefail

FEATHER_DIR="${1:?Usage: $0 <feather-dir> <ipa-out-dir> <embedded-stage-dir> [spm-cache-dir]}"
IPA_OUT_DIR="${2:?Usage: $0 <feather-dir> <ipa-out-dir> <embedded-stage-dir> [spm-cache-dir]}"
EMBED_OUT_DIR="${3:?Usage: $0 <feather-dir> <ipa-out-dir> <embedded-stage-dir> [spm-cache-dir]}"
SPM_CACHE_DIR="${4:-${RUNNER_TEMP:-/tmp}/FeatherSPM}"

mkdir -p "$IPA_OUT_DIR" "$EMBED_OUT_DIR/host-frameworks" "$EMBED_OUT_DIR/runtime-frameworks"
IPA_OUT_DIR="$(cd "$IPA_OUT_DIR" && pwd)"
EMBED_OUT_DIR="$(cd "$EMBED_OUT_DIR" && pwd)"

cd "$FEATHER_DIR"

OBJC_MOD_DIR="$(mktemp -d "${RUNNER_TEMP:-/tmp}/feather-objc-mod.XXXXXX")"
cleanup() {
  rm -rf "$OBJC_MOD_DIR" "$FEATHER_DIR/FeatherUIBuild.xcodeproj"
}
trap cleanup EXIT

echo "==> Fetching Feather local HTTPS server TLS assets (deps)"
make deps

DERIVED_STANDALONE="${RUNNER_TEMP:-/tmp}/FeatherDerivedData"
COMP_CACHE="${RUNNER_TEMP:-/tmp}/FeatherCompCache"
rm -rf _build packages "$DERIVED_STANDALONE"

echo "==> Building standalone Feather.app (Release)"
xcodebuild \
  -project Feather.xcodeproj \
  -scheme Feather \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED_STANDALONE" \
  -clonedSourcePackagesDirPath "$SPM_CACHE_DIR" \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  COMPILATION_CACHE_ENABLE_CACHING=YES \
  COMPILATION_CACHE_CAS_PATH="$COMP_CACHE" \
  CODE_SIGNING_ALLOWED=NO \
  ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO

APP_DIR="$(find _build "$DERIVED_STANDALONE" -type d -name 'Feather.app' | head -n 1)"
if [[ -z "$APP_DIR" ]]; then
  echo "FAIL: Feather.app not found after standalone xcodebuild" >&2
  exit 1
fi
mkdir -p _build/Payload
cp -R "$APP_DIR" _build/Payload/Feather.app
chmod -R 0755 _build/Payload/Feather.app
cp deps/* _build/Payload/Feather.app/ || true
codesign --force --sign - --timestamp=none _build/Payload/Feather.app
ditto -c -k --sequesterRsrc --keepParent _build/Payload "$IPA_OUT_DIR/OneTools-Feather-unsigned.ipa"

echo "==> Creating Clang module map for Feather C/ObjC helpers"
cat > "$OBJC_MOD_DIR/FeatherObjC.h" <<'OBJC'
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIImage * _Nullable iconTest(NSURL * _Nonnull bundleURL);
NSString * _Nullable LCPatchMachOFixupARM64eSlice(const char * _Nonnull path);
NSString * _Nullable LCPatchMachOForSDK26(const char * _Nonnull path);
NSData * _Nullable LCGetMachOEntitlements(const char * _Nonnull path);
OBJC

cat > "$OBJC_MOD_DIR/module.modulemap" <<'MODMAP'
module FeatherObjC {
    header "FeatherObjC.h"
    export *
}
MODMAP

cat > "$OBJC_MOD_DIR/FeatherUI.exp" <<'EXP'
_OBJC_CLASS_$_OneToolsFeatherBridge
_OBJC_METACLASS_$_OneToolsFeatherBridge
_$s9FeatherUI*
_FeatherUI*
EXP

echo "==> Generating FeatherUIBuild.xcodeproj for FeatherUI.framework"
rm -rf FeatherUIBuild.xcodeproj
cp -R Feather.xcodeproj FeatherUIBuild.xcodeproj

python3 - "$OBJC_MOD_DIR" <<'PY'
from pathlib import Path
import re
import sys

objc_mod_dir = sys.argv[1]
pbx_path = Path("FeatherUIBuild.xcodeproj/project.pbxproj")
text = pbx_path.read_text(encoding="utf-8")

# 1. Convert Feather.app product & target to FeatherUI.framework
text = text.replace(
    '3379C1B92DA869A1004372DA /* Feather.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Feather.app; sourceTree = BUILT_PRODUCTS_DIR; };',
    '3379C1B92DA869A1004372DA /* FeatherUI.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = FeatherUI.framework; sourceTree = BUILT_PRODUCTS_DIR; };',
)
text = text.replace(
    'productName = Feather;\n\t\t\tproductReference = 3379C1B92DA869A1004372DA /* Feather.app */;\n\t\t\tproductType = "com.apple.product-type.application";',
    'productName = FeatherUI;\n\t\t\tproductReference = 3379C1B92DA869A1004372DA /* FeatherUI.framework */;\n\t\t\tproductType = "com.apple.product-type.framework";',
)

# 2. Exclude app-only Launch Screen, AppIcon.icon, Info.plist, entitlements, bridging header
text = text.replace(
    'membershipExceptions = (\n\t\t\t\tResources/ellekit.deb,\n\t\t\t\tResources/Info.plist,\n\t\t\t);',
    'membershipExceptions = (\n\t\t\t\tResources/ellekit.deb,\n\t\t\t\tResources/Info.plist,\n\t\t\t\tResources/AppIcon.icon,\n\t\t\t\t"Resources/Launch Screen.storyboard",\n\t\t\t\t"Supporting Files/Feather.entitlements",\n\t\t\t\t"Supporting Files/Feather-Bridging-Header.h",\n\t\t\t);',
)

# 3. Patch Debug (3379C1CE2DA869A3004372DA) & Release (3379C1CF2DA869A3004372DA) target configs
def patch_feather_cfg(block: str, is_debug: bool) -> str:
    for pat in (
        r'\t+ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n',
        r'\t+CODE_SIGN_ENTITLEMENTS = .*?;\n',
        r'\t+INFOPLIST_FILE = .*?;\n',
        r'\t+"?INFOPLIST_KEY_UIApplicationSceneManifest_Generation.*?\n',
        r'\t+INFOPLIST_KEY_UILaunchStoryboardName = .*?;\n',
        r'\t+SWIFT_OBJC_BRIDGING_HEADER = .*?;\n',
        r'\t+STRIPFLAGS = .*?;\n',
        r'\t+DEPLOYMENT_POSTPROCESSING = YES;\n',
        r'\t+SWIFT_ACTIVE_COMPILATION_CONDITIONS = .*?;\n',
        r'\t+PRODUCT_BUNDLE_IDENTIFIER = .*?;\n',
        r'\t+PRODUCT_NAME = .*?;\n',
        r'\t+IPHONEOS_DEPLOYMENT_TARGET = .*?;\n',
    ):
        block = re.sub(pat, '', block)

    cond = '"DEBUG ONETOOLS_EMBEDDED $(inherited)"' if is_debug else '"ONETOOLS_EMBEDDED $(inherited)"'
    injected = (
        f'\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = "";\n'
        f'\t\t\t\tDEFINES_MODULE = YES;\n'
        f'\t\t\t\tDEPLOYMENT_LOCATION = NO;\n'
        f'\t\t\t\tDEPLOYMENT_POSTPROCESSING = NO;\n'
        f'\t\t\t\tDYLIB_INSTALL_NAME_BASE = "@rpath";\n'
        f'\t\t\t\tINSTALL_PATH = "@rpath";\n'
        f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.4;\n'
        f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = org.onetools.clash.featherui;\n'
        f'\t\t\t\tPRODUCT_MODULE_NAME = FeatherUI;\n'
        f'\t\t\t\tPRODUCT_NAME = FeatherUI;\n'
        f'\t\t\t\tSKIP_INSTALL = NO;\n'
        f'\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = {cond};\n'
        f'\t\t\t\tEXPORTED_SYMBOLS_FILE = "{objc_mod_dir}/FeatherUI.exp";\n'
        f'\t\t\t\tSWIFT_INCLUDE_PATHS = (\n'
        f'\t\t\t\t\t"$(inherited)",\n'
        f'\t\t\t\t\t"{objc_mod_dir}",\n'
        f'\t\t\t\t);\n'
    )
    block = block.replace('\t\t\tbuildSettings = {\n', '\t\t\tbuildSettings = {\n' + injected)
    return block

for cfg_id, is_dbg in (("3379C1CE2DA869A3004372DA", True), ("3379C1CF2DA869A3004372DA", False)):
    pattern = re.compile(rf'(\t\t{cfg_id} /\* (?:Debug|Release) \*/ = \{{.*?\n\t\t\}};)', re.DOTALL)
    m = pattern.search(text)
    if not m:
        raise SystemExit(f"Could not find Feather config block {cfg_id}")
    text = text[:m.start(1)] + patch_feather_cfg(m.group(1), is_dbg) + text[m.end(1):]

pbx_path.write_text(text, encoding="utf-8")

scheme_path = Path("FeatherUIBuild.xcodeproj/xcshareddata/xcschemes/Feather.xcscheme")
scheme_text = scheme_path.read_text(encoding="utf-8")
scheme_text = scheme_text.replace("container:Feather.xcodeproj", "container:FeatherUIBuild.xcodeproj")
scheme_text = scheme_text.replace('BuildableName = "Feather.app"', 'BuildableName = "FeatherUI.framework"')
scheme_path.write_text(scheme_text, encoding="utf-8")

print("Generated FeatherUIBuild.xcodeproj & updated Feather.xcscheme successfully")
PY

DERIVED_UI="${RUNNER_TEMP:-/tmp}/FeatherUIDerivedData"
rm -rf "$DERIVED_UI"

echo "==> Building FeatherUI.framework (Release, generic/platform=iOS)"
xcodebuild build \
  -project FeatherUIBuild.xcodeproj \
  -scheme Feather \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED_UI" \
  -clonedSourcePackagesDirPath "$SPM_CACHE_DIR" \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  COMPILATION_CACHE_ENABLE_CACHING=YES \
  COMPILATION_CACHE_CAS_PATH="$COMP_CACHE" \
  DEPLOYMENT_LOCATION=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

FEATHER_UI_FW="$DERIVED_UI/Build/Products/Release-iphoneos/FeatherUI.framework"
if [[ ! -d "$FEATHER_UI_FW" ]]; then
  echo "FAIL: FeatherUI.framework not found at $FEATHER_UI_FW" >&2
  exit 1
fi

if ! xcrun nm -gU "$FEATHER_UI_FW/FeatherUI" | grep -q '_OBJC_CLASS_\$_OneToolsFeatherBridge$'; then
  echo "FAIL: _OBJC_CLASS_\$_OneToolsFeatherBridge not exported by FeatherUI.framework!" >&2
  xcrun nm -gU "$FEATHER_UI_FW/FeatherUI" | head -n 40 >&2
  exit 1
fi

echo "==> Bundling server TLS assets & ellekit.deb inside FeatherUI.framework"
cp -f deps/* "$FEATHER_UI_FW/" || true
if [[ -f Feather/Resources/ellekit.deb ]]; then
  cp -f Feather/Resources/ellekit.deb "$FEATHER_UI_FW/"
fi

cp -RL "$FEATHER_UI_FW" "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework"
rm -rf "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework/Headers" \
       "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework/PrivateHeaders" \
       "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework/Modules"
mkdir -p "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework/Headers" \
         "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework/Modules"

cat > "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework/Headers/OneToolsFeatherBridge.h" <<'OBJC'
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface OneToolsFeatherBridge : NSObject
+ (UIViewController *)makeRootViewController;
+ (void)handleIncomingURL:(NSURL *)url;
@end
NS_ASSUME_NONNULL_END
OBJC

cat > "$EMBED_OUT_DIR/host-frameworks/FeatherUI.framework/Modules/module.modulemap" <<'MODMAP'
framework module FeatherUI {
    header "OneToolsFeatherBridge.h"
    export *
}
MODMAP

echo "==> Checking dynamic XCFramework dependencies (IDevice.framework & OpenSSL.framework)"
OTOOL_DEPS="$(xcrun otool -L "$FEATHER_UI_FW/FeatherUI")"
echo "$OTOOL_DEPS"
for fw_name in IDevice OpenSSL; do
  if grep -q "@rpath/${fw_name}.framework" <<<"$OTOOL_DEPS"; then
    FW_PATH="$(find "$SPM_CACHE_DIR" "$DERIVED_UI" -path "*/ios-arm64/${fw_name}.framework" -type d | head -n 1 || true)"
    if [[ -z "$FW_PATH" ]]; then
      echo "FAIL: FeatherUI dynamically links @rpath/${fw_name}.framework, but slice was not found!" >&2
      exit 1
    fi
    echo "Staging dynamic $fw_name.framework from $FW_PATH"
    dst_fw="$EMBED_OUT_DIR/runtime-frameworks/${fw_name}.framework"
    cp -RL "$FW_PATH" "$dst_fw"
    rm -rf "$dst_fw/Headers" "$dst_fw/PrivateHeaders" "$dst_fw/Modules"
  else
    echo "Info: ${fw_name} is statically linked into FeatherUI.framework (not a dynamic @rpath framework)"
  fi
done

ls -lh "$IPA_OUT_DIR" "$EMBED_OUT_DIR/host-frameworks" "$EMBED_OUT_DIR/runtime-frameworks"

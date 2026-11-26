#!/usr/bin/env bash
# Build Clash-Client (standalone OneTools shell OR unified all-in-one OneTools IPA
# embedding Clash + OneUI + SwiptUI + LibSwipt + FeatherUI + SigningLogic)
# on GitHub Actions macOS runners without requiring Apple Developer credentials.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ART_DIR="${ART_DIR:-$ROOT/artifacts/onetools}"
BUNDLE_BASE="${BUNDLE_BASE:-org.onetools.app}"
MODE="${1:-all}"
EMBEDDED_STAGE_DIR="${ONETOOLS_EMBEDDED_DIR:-}"
mkdir -p "$ART_DIR"

cd "$ROOT/Clash-Client"

if [[ "$MODE" == "bootstrap" || "$MODE" == "all" ]]; then
  echo "==> Setting up Python venv for bootstrap.py & configure.py"
  python3 -m venv .build/python-env
  # shellcheck disable=SC1091
  source .build/python-env/bin/activate
  python3 -m pip install --quiet --upgrade pip PyYAML

  echo "==> Running Clash-Client/scripts/bootstrap.py"
  python3 scripts/bootstrap.py
  if [[ "$MODE" == "bootstrap" ]]; then
    exit 0
  fi
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "==> Installing xcodegen via Homebrew"
  brew install xcodegen
fi

if [[ ! -d .build/python-env ]]; then
  python3 -m venv .build/python-env
  # shellcheck disable=SC1091
  source .build/python-env/bin/activate
  python3 -m pip install --quiet --upgrade pip PyYAML
else
  # shellcheck disable=SC1091
  source .build/python-env/bin/activate
fi

# Ensure Clash.xcframework symlink & Vendor/ClashAdapter exist when restored from cache
if [[ ! -e Clash.xcframework || ! -d Vendor/ClashAdapter/Sources/ClashAdapter ]]; then
  echo "==> Materializing Clash.xcframework symlink & Vendor/ClashAdapter from cached dependencies"
  python3 scripts/bootstrap.py
fi

echo "==> Auditing G1 kernel facts (LoopbackAddress & ip_rewrite.go)"
{
  echo "# G1 Clash Kernel Loopback Audit (GitHub Actions macOS)"
  echo ""
  echo "- Kernel revision: \`$(git -C .build/dependencies/kernel rev-parse HEAD)\`"
  echo "- Adapter revision: \`$(git -C .build/dependencies/adapter rev-parse HEAD)\`"
  echo ""
  echo "## \`LoopbackAddress\` in \`listener/config/tun.go\`"
  echo '```go'
  grep -n "LoopbackAddress" .build/dependencies/kernel/listener/config/tun.go || echo "(not found)"
  echo '```'
  echo ""
  echo "## \`ip_rewrite.go\` under \`third_party/sing-tun*\`"
  echo '```text'
  find .build/dependencies/kernel/third_party -maxdepth 3 -name "*rewrite*" | sort || true
  echo '```'
} > "$ART_DIR/G1-clash-kernel.md"

if [[ "$MODE" == "build-unified" ]]; then
  if [[ -z "$EMBEDDED_STAGE_DIR" || ! -d "$EMBEDDED_STAGE_DIR" ]]; then
    echo "FAIL: build-unified requires ONETOOLS_EMBEDDED_DIR pointing to staged SwiptUI & FeatherUI frameworks" >&2
    exit 1
  fi
  echo "==> Staging unified OneTools metadata, frameworks, and resources into project.yml"
  python3 "$ROOT/scripts/ci/stage-onetools-unified.py" "$ROOT/Clash-Client" "$EMBEDDED_STAGE_DIR"
else
  echo "==> Staging standalone OneTools metadata & stripping paid iCloud entitlements in project.yml"
  python3 "$ROOT/scripts/ci/stage-onetools-unified.py" "$ROOT/Clash-Client"
fi

echo "==> Running configure.py (--bundle-base $BUNDLE_BASE --team '')"
python3 scripts/configure.py --bundle-base "$BUNDLE_BASE" --team ""

echo "==> Running swift test in Clash-Client/apple/ClashClientUI (SwiptLoopbackTests)"
swift test --package-path apple/ClashClientUI

echo "==> Running M7 Loon plugin compatibility audit against adblock/*.plugin & samples"
(
  cd "$ROOT"
  python3 - "$ART_DIR/M7-loon-ignored.md" <<'PY'
import pathlib, subprocess, sys

out_path = pathlib.Path(sys.argv[1])
targets = [pathlib.Path("adblock/onetools-cn-ads.plugin")] + sorted(
    pathlib.Path("adblock/samples").glob("*.plugin")
)
lines = [
    "# M7 Loon Plugin Compatibility Audit (Clash-Client Citation-Verified)",
    "",
]
for p in targets:
    proc = subprocess.run(
        [sys.executable, "tools/loon_lint.py", str(p)],
        capture_output=True,
        text=True,
    )
    output = ((proc.stdout or "") + (proc.stderr or "")).strip()
    lines.append(f"## `{p.as_posix()}`")
    if proc.returncode == 0:
        lines.append("- Result: **PASS (0 ignored / unsupported lines)**")
    else:
        entries = [ln for ln in output.splitlines() if ln.strip()]
        lines.append(f"- Result: **{len(entries)} conservative-subset warnings**")
        for item in entries[:30]:
            lines.append(f"  - `{item}`")
    lines.append("")

out_path.write_text("\n".join(lines), encoding="utf-8")
print(f"Wrote {out_path}")
PY
)

SPM_DIR="${RUNNER_TEMP:-/tmp}/ClashSourcePackages"
COMP_CACHE="${RUNNER_TEMP:-/tmp}/ClashCompilationCache"

echo "==> Building ClashiOS ($MODE, Release, unsigned)"
xcodebuild build \
  -project apple/ClashClient/ClashClient.xcodeproj \
  -scheme ClashiOS \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath .build/DerivedData-iOS \
  -clonedSourcePackagesDirPath "$SPM_DIR" \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  COMPILATION_CACHE_ENABLE_CACHING=YES \
  COMPILATION_CACHE_CAS_PATH="$COMP_CACHE" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

APP_PATH=".build/DerivedData-iOS/Build/Products/Release-iphoneos/Clash.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "FAIL: Expected $APP_PATH not found" >&2
  exit 1
fi

rm -rf .build/ipa-stage .build/ipa-lite-stage
mkdir -p .build/ipa-stage/Payload
cp -R "$APP_PATH" .build/ipa-stage/Payload/Clash.app
chmod -R u+w .build/ipa-stage/Payload/Clash.app

echo "==> Stripping non-global debug/local symbols across main executable, extensions, and embedded frameworks"
xcrun strip -x .build/ipa-stage/Payload/Clash.app/Clash || true
if [[ -d .build/ipa-stage/Payload/Clash.app/PlugIns ]]; then
  for appex in .build/ipa-stage/Payload/Clash.app/PlugIns/*.appex; do
    [[ -d "$appex" ]] || continue
    ext_bin="$appex/$(basename "$appex" .appex)"
    [[ -f "$ext_bin" ]] && xcrun strip -x "$ext_bin" || true
  done
fi
if [[ -d .build/ipa-stage/Payload/Clash.app/Frameworks ]]; then
  for fw in .build/ipa-stage/Payload/Clash.app/Frameworks/*.framework; do
    [[ -d "$fw" ]] || continue
    fw_bin="$fw/$(basename "$fw" .framework)"
    [[ -f "$fw_bin" ]] && xcrun strip -x "$fw_bin" || true
    rm -rf "$fw/BCSymbolMaps" "$fw/Headers" "$fw/PrivateHeaders" "$fw/Modules"
  done
fi

pack_ipa_max_deflate() {
  local stage_root="$1"
  local dst_ipa="$2"
  rm -f "$dst_ipa"
  python3 - "$stage_root" "$dst_ipa" <<'PY'
import os, stat, sys, zipfile

stage_root, dst_ipa = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(dst_ipa, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
    for dirpath, dirnames, filenames in os.walk(stage_root):
        dirnames.sort()
        filenames.sort()
        rel_dir = os.path.relpath(dirpath, stage_root).replace(os.sep, "/")
        if rel_dir != ".":
            st_dir = os.lstat(dirpath)
            zinfo = zipfile.ZipInfo(rel_dir + "/")
            zinfo.external_attr = ((st_dir.st_mode & 0xFFFF) << 16) | 0x10
            zinfo.compress_type = zipfile.ZIP_STORED
            zf.writestr(zinfo, b"")
        for fname in filenames:
            full = os.path.join(dirpath, fname)
            arcname = os.path.relpath(full, stage_root).replace(os.sep, "/")
            st = os.lstat(full)
            if stat.S_ISLNK(st.st_mode):
                target = os.readlink(full)
                zinfo = zipfile.ZipInfo(arcname)
                zinfo.create_system = 3
                zinfo.external_attr = (0o120777 << 16)
                zinfo.compress_type = zipfile.ZIP_STORED
                zf.writestr(zinfo, target.encode("utf-8"))
            else:
                zinfo = zipfile.ZipInfo.from_file(full, arcname)
                zinfo.create_system = 3
                zinfo.external_attr = (st.st_mode & 0xFFFF) << 16
                zinfo.compress_type = zipfile.ZIP_DEFLATED
                with open(full, "rb") as f_in, zf.open(zinfo, "w") as f_out:
                    while True:
                        chunk = f_in.read(1024 * 1024)
                        if not chunk:
                            break
                        f_out.write(chunk)
PY
}

if [[ -d .build/ipa-stage/Payload/Clash.app/Frameworks ]]; then
  find .build/ipa-stage/Payload/Clash.app/Frameworks -maxdepth 1 -name '*.framework' -exec \
    codesign --force --sign - --timestamp=none {} \;
fi
if [[ -d .build/ipa-stage/Payload/Clash.app/PlugIns ]]; then
  find .build/ipa-stage/Payload/Clash.app/PlugIns -maxdepth 1 -name '*.appex' -exec \
    codesign --force --sign - --timestamp=none {} \;
fi
codesign --force --sign - --timestamp=none \
  --entitlements apple/ClashClient/ClashClient.entitlements \
  .build/ipa-stage/Payload/Clash.app

if [[ "$MODE" == "build-unified" ]]; then
  IPA_OUT="$ART_DIR/OneTools-AllInOne-unsigned.ipa"
  pack_ipa_max_deflate .build/ipa-stage "$IPA_OUT"

  echo "==> Building Free 7-day Apple ID Lite Sideload IPA (1 App ID, zero paid entitlements)"
  mkdir -p .build/ipa-lite-stage/Payload
  cp -R .build/ipa-stage/Payload/Clash.app .build/ipa-lite-stage/Payload/Clash.app
  rm -rf .build/ipa-lite-stage/Payload/Clash.app/PlugIns
  codesign --force --sign - --timestamp=none .build/ipa-lite-stage/Payload/Clash.app
  IPA_LITE_OUT="$ART_DIR/OneTools-AllInOne-Lite-unsigned.ipa"
  pack_ipa_max_deflate .build/ipa-lite-stage "$IPA_LITE_OUT"

  echo "==> Running unified binary, ObjC class-table, lazy-dlopen, size-budget, and process-isolation audit"
  bash "$ROOT/scripts/ci/verify-onetools-ipa.sh" \
    .build/ipa-stage/Payload/Clash.app \
    "$IPA_OUT" \
    "$ART_DIR/OneTools-Unified-Audit.md" \
    "$IPA_LITE_OUT" \
    .build/ipa-lite-stage/Payload/Clash.app
else
  IPA_OUT="$ART_DIR/OneTools-ClashiOS-unsigned.ipa"
  pack_ipa_max_deflate .build/ipa-stage "$IPA_OUT"
fi

echo "==> Verifying ClashmacOS & ClashtvOS compile cleanly (regression gate)"
xcodebuild build \
  -project apple/ClashClient/ClashClient.xcodeproj \
  -scheme ClashmacOS \
  -configuration Debug \
  -destination 'generic/platform=macOS' \
  -derivedDataPath .build/DerivedData-macOS \
  -clonedSourcePackagesDirPath "$SPM_DIR" \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  COMPILATION_CACHE_ENABLE_CACHING=YES \
  COMPILATION_CACHE_CAS_PATH="$COMP_CACHE" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

xcodebuild build \
  -project apple/ClashClient/ClashClient.xcodeproj \
  -scheme ClashtvOS \
  -configuration Debug \
  -destination 'generic/platform=tvOS' \
  -derivedDataPath .build/DerivedData-tvOS \
  -clonedSourcePackagesDirPath "$SPM_DIR" \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  COMPILATION_CACHE_ENABLE_CACHING=YES \
  COMPILATION_CACHE_CAS_PATH="$COMP_CACHE" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

ls -lh "$ART_DIR"

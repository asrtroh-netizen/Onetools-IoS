#!/usr/bin/env bash
# Build Clash-Client (OneTools shell + OneUI + SigningLogic + Loon adblock plugin)
# on GitHub Actions macOS runners without requiring Apple Developer credentials.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ART_DIR="${ART_DIR:-$ROOT/artifacts/clash}"
BUNDLE_BASE="${BUNDLE_BASE:-org.onetools.clash}"
MODE="${1:-all}"
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

echo "==> Stripping paid-only iCloud entitlement keys from ClashiOS (Master Plan D8)"
python3 - <<'PY'
from pathlib import Path
import yaml

spec_path = Path("apple/ClashClient/project.yml")
doc = yaml.safe_load(spec_path.read_text(encoding="utf-8"))
icloud_keys = (
    "com.apple.developer.icloud-services",
    "com.apple.developer.icloud-container-identifiers",
    "com.apple.developer.ubiquity-container-identifiers",
)
props = (
    doc.get("targets", {})
    .get("ClashiOS", {})
    .get("entitlements", {})
    .get("properties", {})
)
removed = [k for k in icloud_keys if k in props]
for k in removed:
    props.pop(k, None)
info_props = doc.get("targets", {}).get("ClashiOS", {}).get("info", {}).get("properties", {})
info_props.pop("NSUbiquitousContainers", None)
spec_path.write_text(yaml.safe_dump(doc, sort_keys=False, allow_unicode=True), encoding="utf-8")
print(f"Stripped ClashiOS iCloud keys for self-signing compatibility: {removed}")
PY

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

echo "==> Building ClashiOS (Release, unsigned)"
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

echo "==> Packaging OneTools-ClashiOS-unsigned.ipa"
APP_PATH=".build/DerivedData-iOS/Build/Products/Release-iphoneos/Clash.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "FAIL: Expected $APP_PATH not found" >&2
  exit 1
fi
rm -rf .build/ipa-stage
mkdir -p .build/ipa-stage/Payload
cp -R "$APP_PATH" .build/ipa-stage/Payload/Clash.app
chmod -R u+w .build/ipa-stage/Payload/Clash.app

if [[ -d .build/ipa-stage/Payload/Clash.app/Frameworks ]]; then
  find .build/ipa-stage/Payload/Clash.app/Frameworks -maxdepth 1 -name '*.framework' -exec \
    codesign --force --sign - --timestamp=none {} \;
fi
if [[ -d .build/ipa-stage/Payload/Clash.app/PlugIns ]]; then
  find .build/ipa-stage/Payload/Clash.app/PlugIns -maxdepth 1 -name '*.appex' -exec \
    codesign --force --sign - --timestamp=none {} \;
fi
codesign --force --sign - --timestamp=none .build/ipa-stage/Payload/Clash.app
ditto -c -k --sequesterRsrc --keepParent .build/ipa-stage/Payload "$ART_DIR/OneTools-ClashiOS-unsigned.ipa"

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
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

ls -lh "$ART_DIR"

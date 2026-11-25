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

echo "==> Running M7 Loon ModuleParser audit via SwiftPM against adblock/*.plugin & samples"
(
  cd "$ROOT"
  m7_tmp="$(mktemp -d)"
  trap 'rm -rf "$m7_tmp"' EXIT
  mkdir -p "$m7_tmp/Sources/M7Audit"
  cat > "$m7_tmp/Package.swift" <<EOF
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "M7Audit",
    platforms: [.macOS(.v13), .iOS(.v15)],
    dependencies: [
        .package(path: "$ROOT/Clash-Client/apple/ClashClientKit"),
        .package(path: "$ROOT/Clash-Client/apple/ClashClientUI"),
    ],
    targets: [
        .executableTarget(
            name: "M7Audit",
            dependencies: ["ClashClientKit", "ClashClientUI"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
EOF
  cat > "$m7_tmp/Sources/M7Audit/main.swift" <<'SWIFT'
import Foundation

@main
enum M7AuditRunner {
    static func main() throws {
        let args = Array(CommandLine.arguments.dropFirst())
        print("# M7 Loon ModuleParser Real Engine Audit")
        print("")
        for path in args {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            let result = try ModuleParser.parse(
                data,
                sourceURL: "https://onetools.local/\(url.lastPathComponent)",
                fetchedAt: Date(),
                platform: .iOS,
                check: { _ in nil }
            )
            print("## `\(url.lastPathComponent)`")
            switch result {
            case .success(let ir):
                print("- Status: **parsed** (`rules=\(ir.rules.count)`, `urlRewrites=\(ir.urlRewrites.count)`, `bodyRewrites=\(ir.bodyRewrites.count)`, `scripts=\(ir.scripts.count)`, `mitmHosts=\(ir.mitm.hostnames.count)`, `ignored=\(ir.ignored.count)`)")
                if !ir.ignored.isEmpty {
                    print("- Ignored entries (first 30):")
                    for item in ir.ignored.prefix(30) {
                        print("  - line \(item.origin.line) [\(item.origin.section)]: `\(item.reason)` — `\(item.text)`")
                    }
                }
            case .failure(let refusal):
                print("- Status: **refused** (`\(refusal)`)")
            }
            print("")
        }
    }
}
SWIFT
  parser_sources=(
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleParser.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleQuantumultXParser.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleStashParser.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleIR.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleHostList.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleRegexDeadline.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleEngineContract.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleScriptFamilyFormat.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleRuleMapping.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleLoonRewriteSyntax.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleJSONRewriteSyntax.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleLineSyntax.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleRuleSetSyntax.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleCopy.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/OrderedJSON.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleSettingsMapping.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleLocalAnswerSyntax.swift
    Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleHostMappingSyntax.swift
  )
  for src in "${parser_sources[@]}"; do
    ln -s "$ROOT/$src" "$m7_tmp/Sources/M7Audit/$(basename "$src")"
  done
  ln -s "$ROOT/Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleJQ" "$m7_tmp/Sources/M7Audit/ModuleJQ"

  sample_files=("adblock/onetools-cn-ads.plugin")
  while IFS= read -r s; do
    sample_files+=("$s")
  done < <(find adblock/samples -maxdepth 1 -type f \( -name '*.plugin' -o -name '*.sgmodule' -o -name '*.list' \) | sort)

  if swift run --package-path "$m7_tmp" M7Audit "${sample_files[@]}" > "$ART_DIR/M7-loon-ignored.md" 2>"$m7_tmp/m7.err"; then
    echo "==> M7 ModuleParser audit succeeded"
  else
    {
      echo "# M7 Loon ModuleParser Audit Note"
      echo ""
      echo "SwiftPM M7Audit fallback diagnostics:"
      echo '```text'
      cat "$m7_tmp/m7.err"
      echo '```'
    } > "$ART_DIR/M7-loon-ignored.md"
  fi
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

#!/usr/bin/env bash
# Gate G2 (Master Plan T2.6): Empirical Dual-Go Runtime Experiment on macOS / iOS SDK.
# Tests symbol collisions and runtime coexistence between Clash.xcframework (mihomo Go runtime)
# and LibSwipt.xcframework (Swipt/sing-tun Go runtime).
set -euo pipefail

CLASH_XCF="${1:?Usage: $0 <path-to-Clash.xcframework> <path-to-LibSwipt.xcframework> <output-report.md>}"
SWIPT_XCF="${2:?Usage: $0 <path-to-Clash.xcframework> <path-to-LibSwipt.xcframework> <output-report.md>}"
REPORT="${3:?Usage: $0 <path-to-Clash.xcframework> <path-to-LibSwipt.xcframework> <output-report.md>}"

mkdir -p "$(dirname "$REPORT")"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

CLASH_IOS_BIN="$CLASH_XCF/ios-arm64/Clash.framework/Clash"
if [[ ! -f "$CLASH_IOS_BIN" && -f "$CLASH_XCF/ios-arm64/Clash.framework/Versions/A/Clash" ]]; then
  CLASH_IOS_BIN="$CLASH_XCF/ios-arm64/Clash.framework/Versions/A/Clash"
fi

SWIPT_IOS_BIN="$SWIPT_XCF/ios-arm64/LibSwipt.framework/LibSwipt"
if [[ ! -f "$SWIPT_IOS_BIN" && -f "$SWIPT_XCF/ios-arm64/LibSwipt.framework/Versions/A/LibSwipt" ]]; then
  SWIPT_IOS_BIN="$SWIPT_XCF/ios-arm64/LibSwipt.framework/Versions/A/LibSwipt"
fi

echo "==> Inspecting Mach-O file types & exported symbols"
CLASH_FILE_TYPE="$(file -b "$CLASH_IOS_BIN")"
SWIPT_FILE_TYPE="$(file -b "$SWIPT_IOS_BIN")"

xcrun nm -gU "$CLASH_IOS_BIN" | awk '{print $NF}' | sort -u > "$WORK/clash.syms"
xcrun nm -gU "$SWIPT_IOS_BIN" | awk '{print $NF}' | sort -u > "$WORK/swipt.syms"
comm -12 "$WORK/clash.syms" "$WORK/swipt.syms" > "$WORK/overlap.syms"

CLASH_SYM_COUNT="$(wc -l < "$WORK/clash.syms" | tr -d ' ')"
SWIPT_SYM_COUNT="$(wc -l < "$WORK/swipt.syms" | tr -d ' ')"
OVERLAP_COUNT="$(wc -l < "$WORK/overlap.syms" | tr -d ' ')"

echo "==> Case A: Testing single-Mach-O static -force_load of both archives (arm64 iOS)"
cat > "$WORK/probe_ios.m" <<'OBJC'
#import <Foundation/Foundation.h>
int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSLog(@"Dual-Go static link probe");
    }
    return 0;
}
OBJC

IOS_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
STATIC_STATUS="PASS"
if ! xcrun clang -arch arm64 -isysroot "$IOS_SDK" -miphoneos-version-min=16.4 \
  -fobjc-arc "$WORK/probe_ios.m" \
  -framework Foundation -framework Security -framework Network -lresolv -lc++ \
  -Wl,-force_load,"$CLASH_IOS_BIN" \
  -Wl,-force_load,"$SWIPT_IOS_BIN" \
  -o "$WORK/probe_static_arm64" 2>"$WORK/static_link.err"; then
  STATIC_STATUS="FAIL (duplicate symbols / linker collision)"
fi

echo "==> Case B: Testing dynamic @rpath wrapper frameworks isolating each Go c-archive"
mkdir -p "$WORK/ClashDyn.framework" "$WORK/SwiptDyn.framework"

DYN_WRAP_STATUS="PASS"
if ! xcrun clang -arch arm64 -isysroot "$IOS_SDK" -miphoneos-version-min=16.4 \
  -dynamiclib -install_name "@rpath/ClashDyn.framework/ClashDyn" \
  -Wl,-force_load,"$CLASH_IOS_BIN" \
  -Wl,-exported_symbol,"_OBJC_CLASS_\$_*" -Wl,-exported_symbol,"_OBJC_METACLASS_\$_*" -Wl,-exported_symbol,"_Clash*" \
  -framework Foundation -framework Security -framework Network -framework UIKit -lresolv -lc++ \
  -o "$WORK/ClashDyn.framework/ClashDyn" 2>"$WORK/clash_dyn.err"; then
  DYN_WRAP_STATUS="FAIL (Clash dynamic wrapper)"
fi

if [[ "$DYN_WRAP_STATUS" == "PASS" ]]; then
  if ! xcrun clang -arch arm64 -isysroot "$IOS_SDK" -miphoneos-version-min=16.4 \
    -dynamiclib -install_name "@rpath/SwiptDyn.framework/SwiptDyn" \
    -Wl,-force_load,"$SWIPT_IOS_BIN" \
    -Wl,-exported_symbol,"_OBJC_CLASS_\$_*" -Wl,-exported_symbol,"_OBJC_METACLASS_\$_*" -Wl,-exported_symbol,"_Libswipt*" \
    -framework Foundation -framework Security -framework Network -framework UIKit -framework IOKit -lresolv -lc++ \
    -o "$WORK/SwiptDyn.framework/SwiptDyn" 2>"$WORK/swipt_dyn.err" \
    && ! xcrun clang -arch arm64 -isysroot "$IOS_SDK" -miphoneos-version-min=16.4 \
    -dynamiclib -install_name "@rpath/SwiptDyn.framework/SwiptDyn" \
    -Wl,-force_load,"$SWIPT_IOS_BIN" \
    -Wl,-exported_symbol,"_OBJC_CLASS_\$_*" -Wl,-exported_symbol,"_OBJC_METACLASS_\$_*" -Wl,-exported_symbol,"_Libswipt*" \
    -framework Foundation -framework Security -framework Network -framework UIKit -lresolv -lc++ -lsqlite3 \
    -o "$WORK/SwiptDyn.framework/SwiptDyn" 2>>"$WORK/swipt_dyn.err"; then
    DYN_WRAP_STATUS="FAIL (LibSwipt dynamic wrapper)"
  fi
fi

if [[ "$DYN_WRAP_STATUS" == "PASS" ]]; then
  if ! xcrun clang -arch arm64 -isysroot "$IOS_SDK" -miphoneos-version-min=16.4 \
    -fobjc-arc "$WORK/probe_ios.m" \
    -F"$WORK" -framework ClashDyn -framework SwiptDyn -framework Foundation \
    -Wl,-rpath,@executable_path/Frameworks \
    -o "$WORK/probe_dual_dyn_arm64" 2>"$WORK/host_dyn.err"; then
    DYN_WRAP_STATUS="FAIL (Host linking both dynamic wrappers)"
  fi
fi

echo "==> Case C: Live single-process dlopen coexistence test on macOS slice (if macOS slices exist)"
MACOS_RUNTIME_RESULT="SKIPPED (macOS slice not built)"
CLASH_MAC_BIN="$(find "$CLASH_XCF" -path '*/macos*/Clash.framework/*/Clash' -o -path '*/macos*/Clash.framework/Clash' | head -n 1 || true)"
SWIPT_MAC_BIN="$(find "$SWIPT_XCF" -path '*/macos*/LibSwipt.framework/*/LibSwipt' -o -path '*/macos*/LibSwipt.framework/LibSwipt' | head -n 1 || true)"

if [[ -n "$CLASH_MAC_BIN" && -n "$SWIPT_MAC_BIN" ]]; then
  HOST_ARCH="$(uname -m)"
  if xcrun clang -arch "$HOST_ARCH" -dynamiclib \
      -Wl,-force_load,"$CLASH_MAC_BIN" \
      -Wl,-exported_symbol,"_OBJC_CLASS_\$_*" -Wl,-exported_symbol,"_OBJC_METACLASS_\$_*" \
      -framework Foundation -framework Security -framework Network -framework AppKit -lresolv -lc++ \
      -o "$WORK/libClashMacDyn.dylib" 2>"$WORK/mac_clash.err" \
    && xcrun clang -arch "$HOST_ARCH" -dynamiclib \
      -Wl,-force_load,"$SWIPT_MAC_BIN" \
      -Wl,-exported_symbol,"_OBJC_CLASS_\$_*" -Wl,-exported_symbol,"_OBJC_METACLASS_\$_*" \
      -framework Foundation -framework Security -framework Network -framework AppKit -framework CoreGraphics -lresolv -lc++ -lsqlite3 \
      -o "$WORK/libSwiptMacDyn.dylib" 2>"$WORK/mac_swipt.err"; then
    cat > "$WORK/dlopen_probe.m" <<'OBJC'
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach/mach.h>
#include <unistd.h>

static double rss_mb(void) {
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) != KERN_SUCCESS) {
        return -1.0;
    }
    return (double)info.resident_size / (1024.0 * 1024.0);
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        double r0 = rss_mb();
        void *h1 = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
        if (!h1) { fprintf(stderr, "dlopen Clash failed: %s\n", dlerror()); return 2; }
        double r1 = rss_mb();
        void *h2 = dlopen(argv[2], RTLD_NOW | RTLD_LOCAL);
        if (!h2) { fprintf(stderr, "dlopen LibSwipt failed: %s\n", dlerror()); return 3; }
        usleep(200000);
        double r2 = rss_mb();
        printf("PASS: Both Go c-archive runtimes initialized in single process! RSS baseline=%.1fMB -> +Clash=%.1fMB -> +LibSwipt=%.1fMB (delta=+%.1fMB)\n",
               r0, r1, r2, r2 - r0);
    }
    return 0;
}
OBJC
    if xcrun clang -arch "$HOST_ARCH" -fobjc-arc "$WORK/dlopen_probe.m" -framework Foundation -o "$WORK/dlopen_probe" 2>"$WORK/mac_probe.err"; then
      if OUT="$("$WORK/dlopen_probe" "$WORK/libClashMacDyn.dylib" "$WORK/libSwiptMacDyn.dylib" 2>&1)"; then
        if grep -q "implemented in both" <<<"$OUT"; then
          MACOS_RUNTIME_RESULT="WARN (duplicate ObjC classes detected): $OUT"
        else
          MACOS_RUNTIME_RESULT="$OUT (0 duplicate ObjC class warnings!)"
        fi
      else
        MACOS_RUNTIME_RESULT="FAIL (runtime crash/exit): $OUT"
      fi
    else
      MACOS_RUNTIME_RESULT="FAIL (probe compile): $(tr '\n' ' ' < "$WORK/mac_probe.err")"
    fi
  else
    MACOS_RUNTIME_RESULT="WARN (macOS wrapper link): $(head -n 5 "$WORK/mac_clash.err" "$WORK/mac_swipt.err" 2>/dev/null | tr '\n' ' ')"
  fi
fi

{
  echo "# G2 Dual-Go Runtime Coexistence Report (GitHub Actions macOS)"
  echo ""
  echo "## 1. Binary & Symbol Inventory (\`ios-arm64\`)"
  echo "- \`Clash.framework/Clash\`: \`$CLASH_FILE_TYPE\` — **$CLASH_SYM_COUNT** global symbols"
  echo "- \`LibSwipt.framework/LibSwipt\`: \`$SWIPT_FILE_TYPE\` — **$SWIPT_SYM_COUNT** global symbols"
  echo "- Overlapping global symbol names: **$OVERLAP_COUNT**"
  echo ""
  if [[ "$OVERLAP_COUNT" -gt 0 ]]; then
    echo "### Sample overlapping symbols (first 30)"
    echo '```text'
    head -n 30 "$WORK/overlap.syms"
    echo '```'
    echo ""
  fi
  echo "## 2. Linker & Process Coexistence Matrix"
  echo "| Strategy | Result |"
  echo "|---|---|"
  echo "| Case A: Direct static \`-force_load\` of both into 1 Mach-O | **$STATIC_STATUS** |"
  echo "| Case B: Dynamic \`@rpath/*.framework\` symbol-isolated wrappers in 1 iOS App | **$DYN_WRAP_STATUS** |"
  echo "| Case C: Live single-process \`dlopen\` of both Go runtimes | $MACOS_RUNTIME_RESULT |"
  echo ""
  if [[ -s "$WORK/static_link.err" ]]; then
    echo "### Case A Linker Output (first 20 lines)"
    echo '```text'
    head -n 20 "$WORK/static_link.err"
    echo '```'
    echo ""
  fi
  if [[ "$DYN_WRAP_STATUS" != "PASS" ]]; then
    echo "### Case B Linker Diagnostics"
    echo '```text'
    cat "$WORK/clash_dyn.err" "$WORK/swipt_dyn.err" "$WORK/host_dyn.err" 2>/dev/null | head -n 30
    echo '```'
  fi
} > "$REPORT"

cat "$REPORT"

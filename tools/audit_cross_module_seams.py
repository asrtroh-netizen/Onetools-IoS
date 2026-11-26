#!/usr/bin/env python3
"""Static regression & bug-hunt gate across Clash-Client, Swipt, Feather, Loon plugins, and CI.

Verifies:
1. Single-authority URL routing (no concurrent .onOpenURL hijacking of .ipa/.swiplet/feather://).
2. Sandbox directory & UserDefaults isolation (Feather clearWorkCache / resetUserDefaults, Swipt AppDirectory).
3. Sideloader-safe dynamic AppGroup / PacketTunnel / BGTaskScheduler lookup.
4. On-demand dlopen framework staging & Nuke RAM cache ceiling (<= 32 MiB) & LibSwipt FreeOSMemory.
5. Zero catastrophic-backtracking regexes in adblock/*.plugin.
6. Zero run-id cache key bloat in .github/workflows/macos-ci.yml.
"""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]

# Heuristic detector for nested-quantifier ReDoS patterns such as (a+)+, (.*)+, ([a-z]+)*
NESTED_QUANTIFIER_RE = re.compile(r"\([^()]*[+*][^()]*\)[+*?{]")
# Emoji pictograph range banned inside UI chrome / labels (DESIGN.md §1.3)
EMOJI_SLOP_RE = re.compile(r"[\U0001F300-\U0001FAFF]")


def check_emoji_slop_in_ui_text(text: str) -> list[str]:
    bad: list[str] = []
    for idx, raw in enumerate(text.splitlines(), 1):
        stripped = raw.strip()
        if stripped.startswith("//"):
            continue
        if EMOJI_SLOP_RE.search(stripped):
            bad.append(f"line {idx}: banned Emoji icon/glyph in UI source: {stripped[:90]}")
    return bad


def check_redos_in_plugin_text(text: str) -> list[str]:
    bad: list[str] = []
    for idx, raw in enumerate(text.splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("["):
            continue
        if NESTED_QUANTIFIER_RE.search(line):
            bad.append(f"line {idx}: nested quantifier risk: {line[:100]}")
    return bad


def run_all_checks(root: pathlib.Path = ROOT) -> list[str]:
    errors: list[str] = []

    def read(rel: str) -> str:
        p = root / rel
        if not p.is_file():
            errors.append(f"missing required file: {rel}")
            return ""
        return p.read_text(encoding="utf-8")

    def read_if_hydrated(rel: str) -> str | None:
        p = root / rel
        if not p.is_file():
            return None
        return p.read_text(encoding="utf-8")

    # 1. URL routing isolation (BUG-01)
    clash_app = read("Clash-Client/apple/ClashClient/Sources/ClashClientApp.swift")
    if clash_app and "OneToolsShellRouter.canConsume(url)" not in clash_app:
        errors.append("BUG-01 regression: ClashClientApp.swift missing OneToolsShellRouter.canConsume(url) guard")

    feather_app = read_if_hydrated("Feather/Feather/FeatherApp.swift")
    if feather_app is not None:
        if "#if !ONETOOLS_EMBEDDED\n\t\t\t\t.onOpenURL(perform: FeatherURLHandler.handle)" not in feather_app:
            errors.append("BUG-01 regression: FeatherRootView .onOpenURL is not gated by #if !ONETOOLS_EMBEDDED")
        m_cost = re.search(r"imageCache\.costLimit\s*=\s*(\d+)\s*\*\s*1024\s*\*\s*1024", feather_app)
        if not m_cost or int(m_cost.group(1)) > 32:
            errors.append("O3 regression: Feather Nuke imageCache.costLimit exceeds 32 MiB ceiling")
    else:
        feather_patch = read("patches/Feather.patch")
        if "OneToolsCertificateInbox" not in feather_patch or "24 * 1024 * 1024" not in feather_patch:
            errors.append("Patch sync regression: patches/Feather.patch missing embedded inbox or 24 MiB Nuke cap")

    open_swiplet = read_if_hydrated("Swipt/Swipt/Automation/OpenSwipletView.swift")
    if open_swiplet is not None:
        if 'pathExtension.lowercased() == "swiplet"' not in open_swiplet:
            errors.append("BUG-01 regression: OpenSwipletView.swift missing .swiplet extension check")
        if "#if !ONETOOLS_EMBEDDED" not in open_swiplet:
            errors.append("BUG-01 regression: OpenSwipletView.swift .onOpenURL not gated by #if !ONETOOLS_EMBEDDED")
    else:
        swipt_patch = read("patches/Swipt.patch")
        if "consumePendingSwipletURL" not in swipt_patch or "func FreeOSMemory()" not in swipt_patch:
            errors.append("Patch sync regression: patches/Swipt.patch missing pending Swiplet queue or FreeOSMemory()")

    # 2. Sandbox & UserDefaults isolation (BUG-02, BUG-03, H4)
    reset_view = read_if_hydrated("Feather/Feather/Views/Settings/Reset/ResetView.swift")
    if reset_view is not None:
        if 'where file.hasPrefix("Feather")' not in reset_view:
            errors.append("BUG-02 regression: Feather clearWorkCache() must only delete Feather* temp items")
        if 'key.hasPrefix("Feather.") || key.hasPrefix("feather.")' not in reset_view:
            errors.append("BUG-03 regression: Feather resetUserDefaults() must scope keys under ONETOOLS_EMBEDDED")

    swipt_dir = read_if_hydrated("Swipt/Swipt/Model/AppDirectory.swift")
    if swipt_dir is not None and 'appendingPathComponent("Swipt", isDirectory: true)' not in swipt_dir:
        errors.append("H4 regression: Swipt AppDirectory must scope Application Support/Swipt under ONETOOLS_EMBEDDED")

    # 3. Sideloader-safe dynamic identifiers & BGTask guards (BUG-05)
    clash_ids = read("Clash-Client/apple/ClashClient/Shared/ClashAppIdentifiers.swift")
    if clash_ids and "readEmbeddedApplicationGroups" not in clash_ids:
        errors.append("Sideload regression: ClashAppIdentifiers.swift missing dynamic Mach-O entitlement group lookup")

    bg_refresh = read("Clash-Client/apple/ClashClient/Sources/ConfigStore/BackgroundRefresh.swift")
    if bg_refresh and "BGTaskSchedulerPermittedIdentifiers" not in bg_refresh:
        errors.append("BUG-05 regression: Clash BackgroundRefresh.swift missing BGTaskSchedulerPermittedIdentifiers guard")

    feather_bg = read_if_hydrated("Feather/Feather/Utilities/BackgroundTaskManager.swift")
    if feather_bg is not None and "BGTaskSchedulerPermittedIdentifiers" not in feather_bg:
        errors.append("BUG-05 regression: Feather BackgroundTaskManager.swift missing BGTaskSchedulerPermittedIdentifiers guard")

    # 4. Lazy dlopen staging & Go memory release (O2, O3)
    stage_py = read("scripts/ci/stage-onetools-unified.py")
    if stage_py:
        if '"link": True' in stage_py:
            errors.append("O2 regression: stage-onetools-unified.py still sets link: True instead of on-demand dlopen")
        if '"swipt"' not in stage_py:
            errors.append("Metadata regression: stage-onetools-unified.py missing swipt URL scheme")

    swipt_go = read_if_hydrated("Swipt/libswipt/platform.go")
    if swipt_go is not None and "func FreeOSMemory()" not in swipt_go:
        errors.append("O3 regression: Swipt/libswipt/platform.go missing FreeOSMemory()")

    # 5. Adblock plugin ReDoS audit (O4)
    ad_dir = root / "adblock"
    if ad_dir.is_dir():
        for plugin in sorted(ad_dir.rglob("*.plugin")):
            for issue in check_redos_in_plugin_text(plugin.read_text(encoding="utf-8", errors="ignore")):
                errors.append(f"{plugin.relative_to(root).as_posix()}: {issue}")

    # 6. CI cache bloat guard (Wave 4)
    ci_yml = read(".github/workflows/macos-ci.yml")
    if ci_yml:
        for idx, line in enumerate(ci_yml.splitlines(), 1):
            if "key:" in line and "github.run_id" in line:
                errors.append(f"CI cache bloat regression at macos-ci.yml:{idx}: cache key must not include github.run_id")

    # 7. DESIGN.md & Anti-Slop Aesthetic Constitution guards (P8)
    design_md = read("DESIGN.md")
    if design_md:
        for required_token in ("OneBorderBeam", "OneSlidingPill", "OneBentoValueText", "SPRING_PRESS", "accessibilityReduceMotion"):
            if required_token not in design_md:
                errors.append(f"DESIGN.md missing required aesthetic spec token: {required_token}")

    micro_swift = read("OneUI/Sources/OneUI/Motion/OneMicroInteractions.swift")
    if micro_swift:
        for required_comp in ("OneBorderBeamModifier", "OneSlidingPill", "OneBentoValueText", "OneRhythmBars", "OneSwipeConfirm"):
            if required_comp not in micro_swift:
                errors.append(f"OneMicroInteractions.swift missing component: {required_comp}")

    overview_cards = read_if_hydrated("Clash-Client/apple/ClashClient/Sources/OverviewPrimaryCards.swift")
    if overview_cards is not None and ("tint: .orange" in overview_cards or "tint: .purple" in overview_cards):
        errors.append("Anti-Slop regression: OverviewPrimaryCards.swift reintroduced rainbow card header tints")

    if feather_app is not None and '"#848ef9"' in feather_app:
        errors.append("Anti-Slop regression: FeatherApp.swift reverted default tint to purple #848ef9")

    varied_tab = read_if_hydrated("Feather/Feather/Views/TabView/VariedTabbarView.swift")
    if varied_tab is not None and ".pickerStyle(.segmented)" in varied_tab:
        errors.append("Anti-Boxiness regression: VariedTabbarView.swift reverted to boxy .segmented picker")

    # Check UI Swift files for banned Emoji glyphs
    ui_scan_paths = list((root / "OneUI/Sources/OneUI").rglob("*.swift"))
    for optional_rel in (
        "Clash-Client/apple/ClashClient/Sources/OneTools/OneToolsRootShellView.swift",
        "Clash-Client/apple/ClashClient/Sources/OverviewComponents.swift",
        "Clash-Client/apple/ClashClient/Sources/OverviewPrimaryCards.swift",
        "Clash-Client/apple/ClashClient/Sources/OverviewDetailCards.swift",
        "Feather/Feather/Utilities/OneToolsFeatherPolish.swift",
        "Feather/Feather/Views/Settings/About/AboutView.swift",
    ):
        cand = root / optional_rel
        if cand.is_file():
            ui_scan_paths.append(cand)
    for ui_file in sorted(ui_scan_paths):
        for issue in check_emoji_slop_in_ui_text(ui_file.read_text(encoding="utf-8", errors="ignore")):
            errors.append(f"{ui_file.relative_to(root).as_posix()}: {issue}")

    return errors


def main() -> int:
    errs = run_all_checks()
    if errs:
        for e in errs:
            print(f"FAIL: {e}", file=sys.stderr)
        return 1
    print("cross-module seams, sandbox isolation, ReDoS, and CI cache audit: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())

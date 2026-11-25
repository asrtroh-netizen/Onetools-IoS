#!/usr/bin/env python3
"""Inject unified OneTools Info.plist metadata, embedded frameworks, and bundle resources
into Clash-Client/apple/ClashClient/project.yml prior to running scripts/configure.py."""

from __future__ import annotations

import pathlib
import sys
import yaml


def ensure_list_items(existing: list, additions: list) -> list:
    out = list(existing)
    for item in additions:
        if item not in out:
            out.append(item)
    return out


def main() -> int:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <path-to-Clash-Client> [embedded-dir]", file=sys.stderr)
        return 2

    clash_root = pathlib.Path(sys.argv[1]).resolve()
    embedded_dir = pathlib.Path(sys.argv[2]).resolve() if len(sys.argv) >= 3 else None

    spec_path = clash_root / "apple" / "ClashClient" / "project.yml"
    doc = yaml.safe_load(spec_path.read_text(encoding="utf-8"))

    clash_ios = doc["targets"]["ClashiOS"]

    # 1. Strip paid-only iCloud entitlement keys for self-signing compatibility (Master Plan D8)
    ent_props = clash_ios.setdefault("entitlements", {}).setdefault("properties", {})
    for icloud_key in (
        "com.apple.developer.icloud-services",
        "com.apple.developer.icloud-container-identifiers",
        "com.apple.developer.ubiquity-container-identifiers",
    ):
        ent_props.pop(icloud_key, None)

    # 2. Merge unified OneTools Info.plist keys (Master Plan 5.2 & integration-inventory.md)
    info_props = clash_ios.setdefault("info", {}).setdefault("properties", {})
    info_props.pop("NSUbiquitousContainers", None)
    info_props["CFBundleDisplayName"] = "OneTools"
    info_props["AppGroupIdentifier"] = "$(CLASH_APP_GROUP)"
    info_props["SwiptChannel"] = "stable"
    info_props["CADisableMinimumFrameDurationOnPhone"] = True
    info_props["UIFileSharingEnabled"] = True
    info_props["UISupportsDocumentBrowser"] = True
    info_props["NSLocationWhenInUseUsageDescription"] = (
        "Swipt uses approximate location only to keep background UI automation alive while locked or in other apps."
    )
    info_props["NSBonjourServices"] = ensure_list_items(
        info_props.get("NSBonjourServices", []),
        [
            "_remotepairing._tcp",
            "_remotepairing-pairable-host._tcp",
            "_swipt._tcp",
        ],
    )
    info_props["BGTaskSchedulerPermittedIdentifiers"] = ensure_list_items(
        info_props.get("BGTaskSchedulerPermittedIdentifiers", []),
        [
            "$(CLASH_BUNDLE_BASE).refresh",
            "$(CLASH_BUNDLE_BASE).pairing.*",
            "$(CLASH_BUNDLE_BASE).userTask.*",
        ],
    )
    info_props["UIBackgroundModes"] = ensure_list_items(
        info_props.get("UIBackgroundModes", []),
        ["fetch", "processing", "location", "audio"],
    )

    doc_types = list(info_props.get("CFBundleDocumentTypes", []))
    existing_doc_names = {d.get("CFBundleTypeName") for d in doc_types if isinstance(d, dict)}
    extra_doc_types = [
        {
            "CFBundleTypeName": "Swiplet",
            "CFBundleTypeRole": "Viewer",
            "LSHandlerRank": "Owner",
            "LSItemContentTypes": ["io.nekohasekai.swipt.swiplet"],
        },
        {
            "CFBundleTypeName": "iOS Package Archive",
            "CFBundleTypeRole": "Editor",
            "LSHandlerRank": "Alternate",
            "LSItemContentTypes": ["thewonderofyou.Feather.ipa", "com.apple.itunes.ipa"],
        },
        {
            "CFBundleTypeName": "AirDrop friendly iOS app",
            "CFBundleTypeRole": "Editor",
            "LSHandlerRank": "Alternate",
            "LSItemContentTypes": ["thewonderofyou.Feather.tipa"],
        },
        {
            "CFBundleTypeName": "PKCS#12 Certificate",
            "CFBundleTypeRole": "Viewer",
            "LSHandlerRank": "Alternate",
            "LSItemContentTypes": ["com.rsa.pkcs-12"],
        },
        {
            "CFBundleTypeName": "Provisioning Profile",
            "CFBundleTypeRole": "Viewer",
            "LSHandlerRank": "Alternate",
            "LSItemContentTypes": ["com.apple.mobileprovision"],
        },
    ]
    for dt in extra_doc_types:
        if dt["CFBundleTypeName"] not in existing_doc_names:
            doc_types.append(dt)
    info_props["CFBundleDocumentTypes"] = doc_types

    exported_utis = list(info_props.get("UTExportedTypeDeclarations", []))
    existing_uti_ids = {u.get("UTTypeIdentifier") for u in exported_utis if isinstance(u, dict)}
    for uti in (
        {
            "UTTypeConformsTo": ["com.pkware.zip-archive"],
            "UTTypeDescription": "Swiplet",
            "UTTypeIdentifier": "io.nekohasekai.swipt.swiplet",
            "UTTypeTagSpecification": {
                "public.filename-extension": ["swiplet"],
                "public.mime-type": ["application/vnd.swipt.swiplet+zip"],
            },
        },
        {
            "UTTypeConformsTo": ["com.apple.itunes.ipa", "public.data", "public.content"],
            "UTTypeDescription": "iOS Package Archive",
            "UTTypeIdentifier": "thewonderofyou.Feather.ipa",
            "UTTypeTagSpecification": {
                "public.filename-extension": ["ipa"],
                "public.mime-type": ["application/octet-stream"],
            },
        },
        {
            "UTTypeConformsTo": ["com.apple.itunes.ipa", "public.data", "public.content"],
            "UTTypeDescription": "AirDrop friendly iOS app",
            "UTTypeIdentifier": "thewonderofyou.Feather.tipa",
            "UTTypeTagSpecification": {
                "public.filename-extension": ["tipa"],
                "public.mime-type": ["application/trollstore-ipa"],
            },
        },
    ):
        if uti["UTTypeIdentifier"] not in existing_uti_ids:
            exported_utis.append(uti)
    info_props["UTExportedTypeDeclarations"] = exported_utis

    # 3. Wire staged SwiptUI + FeatherUI + runtime dynamic frameworks into ClashiOS ONLY
    if embedded_dir is not None and embedded_dir.is_dir():
        fw_dir = embedded_dir / "frameworks"
        res_dir = embedded_dir / "resources"
        spec_dir = spec_path.parent

        rel_fw_dir = pathlib.Path(
            pathlib.os.path.relpath(fw_dir, spec_dir)
        ).as_posix()

        base_settings = clash_ios.setdefault("settings", {}).setdefault("base", {})
        fw_search = base_settings.get("FRAMEWORK_SEARCH_PATHS", ["$(inherited)"])
        if isinstance(fw_search, str):
            fw_search = [fw_search]
        fw_search = ensure_list_items(
            fw_search,
            ["$(inherited)", f"$(PROJECT_DIR)/{rel_fw_dir}"],
        )
        base_settings["FRAMEWORK_SEARCH_PATHS"] = fw_search

        deps = clash_ios.setdefault("dependencies", [])
        existing_fws = {d.get("framework") for d in deps if isinstance(d, dict) and "framework" in d}
        staged_frameworks = sorted(fw_dir.glob("*.framework"))
        if not staged_frameworks:
            raise RuntimeError(f"No staged .framework bundles found in {fw_dir}")

        for fw in staged_frameworks:
            rel_fw = pathlib.Path(pathlib.os.path.relpath(fw, spec_dir)).as_posix()
            if rel_fw not in existing_fws:
                deps.append(
                    {
                        "framework": rel_fw,
                        "embed": True,
                        "codeSign": False,
                    }
                )
        print(f"Wired {len(staged_frameworks)} embedded frameworks into ClashiOS: {[f.name for f in staged_frameworks]}")

        ex_constants = res_dir / "EXConstants.bundle"
        if ex_constants.is_dir():
            rel_ex = pathlib.Path(pathlib.os.path.relpath(ex_constants, spec_dir)).as_posix()
            sources = clash_ios.setdefault("sources", [])
            if not any(isinstance(s, dict) and s.get("path") == rel_ex for s in sources):
                sources.append(
                    {
                        "path": rel_ex,
                        "buildPhase": "resources",
                    }
                )
            print(f"Wired bundle resource into ClashiOS: {rel_ex}")

    spec_path.write_text(yaml.safe_dump(doc, sort_keys=False, allow_unicode=True), encoding="utf-8")
    print(f"Updated {spec_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

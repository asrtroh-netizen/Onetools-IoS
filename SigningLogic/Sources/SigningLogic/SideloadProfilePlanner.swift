import Foundation

public enum SideloadChannel: String, CaseIterable, Sendable {
    case freePersonalAppleID
    case altStoreOrSideStore
    case paidDeveloperCert
    case trollStore
}

public struct SideloadBundlePlan: Equatable, Sendable {
    public let channel: SideloadChannel
    public let keptEntitlementKeys: [String]
    public let keptPlugInNames: [String]
    public let consumedAppIDCount: Int
    public let supportsPacketTunnel: Bool
    public let usesLocalAppGroupFallback: Bool

    public init(
        channel: SideloadChannel,
        keptEntitlementKeys: [String],
        keptPlugInNames: [String],
        consumedAppIDCount: Int,
        supportsPacketTunnel: Bool,
        usesLocalAppGroupFallback: Bool
    ) {
        self.channel = channel
        self.keptEntitlementKeys = keptEntitlementKeys
        self.keptPlugInNames = keptPlugInNames
        self.consumedAppIDCount = consumedAppIDCount
        self.supportsPacketTunnel = supportsPacketTunnel
        self.usesLocalAppGroupFallback = usesLocalAppGroupFallback
    }
}

public enum SideloadProfilePlanner {
    private static let paidOnlyEntitlements: Set<String> = [
        "com.apple.developer.networking.networkextension",
        "com.apple.developer.icloud-services",
        "com.apple.developer.icloud-container-identifiers",
        "com.apple.developer.ubiquity-container-identifiers",
        "aps-environment",
    ]

    public static func plan(
        for channel: SideloadChannel,
        originalEntitlementKeys: [String],
        plugInNames: [String],
        freeAccountSupportsAppGroup: Bool = false
    ) -> SideloadBundlePlan {
        switch channel {
        case .freePersonalAppleID:
            // Free 7-day personal team cannot sign PacketTunnel (`networkextension`) and has a strict
            // 10-App-ID/week rolling cap, so Lite sideload mode strips all .appex PlugIns (1 App ID total).
            let keptEnts = originalEntitlementKeys.filter { key in
                if paidOnlyEntitlements.contains(key) { return false }
                if key == "com.apple.security.application-groups" {
                    return freeAccountSupportsAppGroup
                }
                return true
            }.sorted()
            return SideloadBundlePlan(
                channel: channel,
                keptEntitlementKeys: keptEnts,
                keptPlugInNames: [],
                consumedAppIDCount: 1,
                supportsPacketTunnel: false,
                usesLocalAppGroupFallback: !freeAccountSupportsAppGroup
            )

        case .altStoreOrSideStore:
            // SideStore / AltStore with paid cert or App Group capability: keep PacketTunnel if allowed,
            // strip iCloud/APNs keys, and prune optional Widget/Share extensions to conserve App IDs.
            let essentialPlugIns = plugInNames.filter { $0.contains("ClashiOSExtension") }
            let keptEnts = originalEntitlementKeys.filter { key in
                !key.contains("icloud") && !key.contains("ubiquity") && key != "aps-environment"
            }.sorted()
            return SideloadBundlePlan(
                channel: channel,
                keptEntitlementKeys: keptEnts,
                keptPlugInNames: essentialPlugIns,
                consumedAppIDCount: 1 + essentialPlugIns.count,
                supportsPacketTunnel: keptEnts.contains("com.apple.developer.networking.networkextension"),
                usesLocalAppGroupFallback: !keptEnts.contains("com.apple.security.application-groups")
            )

        case .paidDeveloperCert, .trollStore:
            let keptEnts = originalEntitlementKeys.filter { key in
                !key.contains("icloud") && !key.contains("ubiquity")
            }.sorted()
            return SideloadBundlePlan(
                channel: channel,
                keptEntitlementKeys: keptEnts,
                keptPlugInNames: plugInNames,
                consumedAppIDCount: channel == .trollStore ? 0 : (1 + plugInNames.count),
                supportsPacketTunnel: keptEnts.contains("com.apple.developer.networking.networkextension"),
                usesLocalAppGroupFallback: false
            )
        }
    }

    /// Resolves a safe BGTaskScheduler identifier when a sideloader rewrites CFBundleIdentifier
    /// without rewriting BGTaskSchedulerPermittedIdentifiers in Info.plist.
    public static func resolvePermittedBGTaskPrefix(
        permittedIdentifiers: [String],
        wildcardSuffix: String
    ) -> String? {
        guard let matched = permittedIdentifiers.first(where: { $0.hasSuffix(wildcardSuffix) && !$0.contains("$(") }) else {
            return nil
        }
        if matched.hasSuffix(".*") {
            return String(matched.dropLast(2))
        }
        return matched
    }
}

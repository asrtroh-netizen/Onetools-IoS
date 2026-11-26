import XCTest
@testable import SigningLogic

final class SideloadProfilePlannerTests: XCTestCase {
    private let unifiedEntitlements = [
        "com.apple.security.application-groups",
        "com.apple.developer.networking.networkextension",
        "com.apple.developer.icloud-services",
        "com.apple.developer.ubiquity-container-identifiers",
    ]

    private let unifiedPlugIns = [
        "ClashiOSExtension.appex",
        "ClashControlsExtension.appex",
        "ClashShareExtension.appex",
    ]

    func testFreePersonalAppleIDProducesSingleAppIDZeroPaidEntitlementLitePlan() {
        let plan = SideloadProfilePlanner.plan(
            for: .freePersonalAppleID,
            originalEntitlementKeys: unifiedEntitlements,
            plugInNames: unifiedPlugIns
        )
        XCTAssertEqual(plan.keptEntitlementKeys, [])
        XCTAssertEqual(plan.keptPlugInNames, [])
        XCTAssertEqual(plan.consumedAppIDCount, 1)
        XCTAssertFalse(plan.supportsPacketTunnel)
        XCTAssertTrue(plan.usesLocalAppGroupFallback)
    }

    func testSideStorePrunesWidgetAndShareExtensionsToSaveWeeklyAppIDQuota() {
        let plan = SideloadProfilePlanner.plan(
            for: .altStoreOrSideStore,
            originalEntitlementKeys: unifiedEntitlements,
            plugInNames: unifiedPlugIns
        )
        XCTAssertEqual(plan.keptPlugInNames, ["ClashiOSExtension.appex"])
        XCTAssertEqual(plan.consumedAppIDCount, 2)
        XCTAssertTrue(plan.supportsPacketTunnel)
        XCTAssertFalse(plan.usesLocalAppGroupFallback)
    }

    func testPaidCertAndTrollStoreKeepAllExtensionsWithoutiCloudKeys() {
        let paid = SideloadProfilePlanner.plan(
            for: .paidDeveloperCert,
            originalEntitlementKeys: unifiedEntitlements,
            plugInNames: unifiedPlugIns
        )
        XCTAssertEqual(paid.keptPlugInNames.count, 3)
        XCTAssertEqual(paid.consumedAppIDCount, 4)
        XCTAssertTrue(paid.supportsPacketTunnel)

        let troll = SideloadProfilePlanner.plan(
            for: .trollStore,
            originalEntitlementKeys: unifiedEntitlements,
            plugInNames: unifiedPlugIns
        )
        XCTAssertEqual(troll.consumedAppIDCount, 0)
        XCTAssertTrue(troll.supportsPacketTunnel)
    }

    func testBGTaskPrefixResolverSurvivesAltStoreBundleIDRewrite() {
        let permitted = [
            "org.onetools.app.refresh",
            "org.onetools.app.pairing.*",
            "org.onetools.app.userTask.*",
        ]
        XCTAssertEqual(
            SideloadProfilePlanner.resolvePermittedBGTaskPrefix(
                permittedIdentifiers: permitted,
                wildcardSuffix: ".userTask.*"
            ),
            "org.onetools.app.userTask"
        )
        XCTAssertEqual(
            SideloadProfilePlanner.resolvePermittedBGTaskPrefix(
                permittedIdentifiers: permitted,
                wildcardSuffix: ".refresh"
            ),
            "org.onetools.app.refresh"
        )
        XCTAssertNil(
            SideloadProfilePlanner.resolvePermittedBGTaskPrefix(
                permittedIdentifiers: [],
                wildcardSuffix: ".userTask.*"
            )
        )
    }
}

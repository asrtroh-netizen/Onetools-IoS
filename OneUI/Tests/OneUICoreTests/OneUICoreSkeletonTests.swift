import Foundation
import XCTest
@testable import OneUICore

final class OneUICoreSkeletonTests: XCTestCase {
    func testModuleIsLoadable() {
        XCTAssertEqual(OneUICoreMarker.moduleName, "OneUICore")
    }

    func testPackageManifestDeclaresIcons() throws {
        let manifest = try String(contentsOf: packageManifestURL(), encoding: .utf8)
        let declaresIcons =
            manifest.contains(".copy(\"OneUI/Resources/Icons\")")
            || manifest.contains(".copy(\"Resources/Icons\")")
        XCTAssertTrue(declaresIcons)
    }

    #if os(Linux)
    func testIconsResourceIsReadable() throws {
        let icon = try XCTUnwrap(
            Bundle.module.url(
                forResource: "MaterialIcons-Regular",
                withExtension: "otf",
                subdirectory: "Icons"
            )
        )
        let bytes = try Data(contentsOf: icon)
        XCTAssertFalse(bytes.isEmpty)
    }
    #endif
}

private func packageManifestURL() -> URL {
    var url = URL(fileURLWithPath: #filePath)
    let root = URL(fileURLWithPath: "/")
    while url.lastPathComponent != "OneUI" && url.standardizedFileURL != root {
        url.deleteLastPathComponent()
    }
    return url.appendingPathComponent("Package.swift")
}

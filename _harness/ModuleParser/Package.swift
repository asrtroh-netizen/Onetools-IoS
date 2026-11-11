// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "ModuleParser",
    products: [
        .library(name: "ParserHarness", targets: ["ParserHarness"]),
    ],
    targets: [
        .target(name: "Darwin", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "os", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "CryptoKit", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "UniformTypeIdentifiers", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "ClashClientKit", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(
            name: "ClashClientUI",
            dependencies: ["ClashClientKit"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "ParserHarness",
            dependencies: ["Darwin", "os", "CryptoKit", "UniformTypeIdentifiers", "ClashClientKit", "ClashClientUI"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "ParserHarnessTests",
            dependencies: ["ParserHarness"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)

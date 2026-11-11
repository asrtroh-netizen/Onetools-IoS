// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SigningLogic",
    products: [
        .library(name: "SigningLogic", targets: ["SigningLogic"]),
    ],
    targets: [
        .target(name: "SigningLogic"),
        .testTarget(name: "SigningLogicTests", dependencies: ["SigningLogic"]),
    ]
)

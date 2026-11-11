// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "ClashLogic",
    products: [
        .library(name: "ClashClientUI", targets: ["ClashClientUI"]),
    ],
    targets: [
        .target(name: "ClashClientUI"),
        .testTarget(name: "ClashClientUITests", dependencies: ["ClashClientUI"]),
    ]
)

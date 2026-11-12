// swift-tools-version: 5.9
import PackageDescription

// 未在 Mac 上运行。数值草稿。不设 platforms：Linux 上要能 swift test。
// 文字、模糊、投影、水波纹触摸仍不选定实现。
let package = Package(
    name: "G3",
    products: [
        .library(name: "G3Numbers", targets: ["G3Numbers"]),
    ],
    targets: [
        .target(name: "G3Numbers"),
        .testTarget(
            name: "G3NumbersTests",
            dependencies: ["G3Numbers"]
        ),
    ]
)

// swift-tools-version: 5.9
import PackageDescription

// 数值草稿。不设 platforms：Linux 上要能解析。只有库 target G3Numbers。
let package = Package(
    name: "G3",
    products: [
        .library(name: "G3Numbers", targets: ["G3Numbers"]),
    ],
    targets: [
        .target(name: "G3Numbers"),
    ]
)

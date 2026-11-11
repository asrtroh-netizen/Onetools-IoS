// swift-tools-version: 5.9
import PackageDescription

// OneUI：从 OneWIFI（Flutter，ONEWIFIX/IOS/lib/design）提取的 One 家族玻璃设计系统，
// 重写为原生 SwiftUI。部署目标对齐 Clash-Client 的 iOS 15；iOS 26+ 自动走系统 Liquid Glass。
let package = Package(
    name: "OneUI",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "OneUI", targets: ["OneUI"]),
    ],
    targets: [
        .target(
            name: "OneUI",
            resources: [.copy("Resources/Fonts")]
        ),
    ]
)

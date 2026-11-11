// swift-tools-version: 5.9
import PackageDescription

// OneUI：从 OneWIFI（Flutter，ONEWIFIX/IOS/lib/design）提取的 One 家族玻璃设计系统，
// 重写为原生 SwiftUI。部署目标对齐 Clash-Client 的 iOS 15；iOS 26+ 自动走系统 Liquid Glass。
// 宿主不是 macOS 时不声明 SwiftUI 目标：界面源文件依赖 SwiftUI，Linux 上的 swift test 编不过。
// Linux 把 OneUICore 的 path 扩到 Sources，这样图标仍留在 Sources/OneUI/Resources/Icons，
// 也能声明进这个 target；exclude 掉界面目录，避免把 SwiftUI 源文件编进来。
// macOS 上不能共用这个 path，否则和 OneUI target 的 Sources/OneUI 重叠。

#if os(macOS)
let package = Package(
    name: "OneUI",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "OneUI", targets: ["OneUI"]),
        .library(name: "OneUICore", targets: ["OneUICore"]),
    ],
    targets: [
        .target(
            name: "OneUI",
            resources: [
                .copy("Resources/Fonts"),
                .copy("Resources/Icons"),
            ]
        ),
        .target(name: "OneUICore"),
        .testTarget(
            name: "OneUICoreTests",
            dependencies: ["OneUICore"]
        ),
    ]
)
#else
let package = Package(
    name: "OneUI",
    products: [
        .library(name: "OneUICore", targets: ["OneUICore"]),
    ],
    targets: [
        .target(
            name: "OneUICore",
            path: "Sources",
            exclude: [
                "OneUI/Components",
                "OneUI/Gallery",
                "OneUI/Glass",
                "OneUI/Theme",
                "OneUI/Tokens",
                "OneUI/Resources/Fonts",
            ],
            resources: [
                .copy("OneUI/Resources/Icons"),
            ]
        ),
        .testTarget(
            name: "OneUICoreTests",
            dependencies: ["OneUICore"]
        ),
    ]
)
#endif

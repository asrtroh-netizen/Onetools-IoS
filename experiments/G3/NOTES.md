未在 Mac 上运行

这里只放闸门 G3 前四项要用的数值。文字、模糊、投影、水波纹触摸的画法要等 Mac 上的实验，所以每项只记两个候选的名字，这里不选。本目录没有 UIKit 私有 API 的可编译代码。

## 文字

- UILabel 负 strokeWidth：用 UILabel 的负 `strokeWidth` 做 600 和 700 的合成加粗。这里不选。还没量过加粗之后字宽有没有变，也还没在真机上看中文：Montserrat 没有中文字形，Flutter 会回退到苹方，苹方有真正的 Medium 和 Semibold。
- CoreText 自绘：用 CoreText 自己画合成加粗。这里不选。同一次 Mac 实验还要量字宽，并用真机上的 OneWIFI 核对中文字重。行高要用 `minimumLineHeight` / `maximumLineHeight` 加 `baselineOffset` 模拟 Flutter 的上下均分，这一步也还没跑。

## 模糊

夹具里的 `blurPanel` 18、`blurBar` 24、`blurDock` 12、`blurLiquid` 10 是 `ImageFilter.blur` 的 sigma（`glass.dart:199-200`），不是半径。

- 半径等于 sigma：私有模糊接口的半径直接用这些 sigma。这里不选。还没和 `glass_panel`、`dock_static_0`、`status_hero_ready` 三张基准图对过，也还没和真机上的 OneWIFI 并排，每个系统大版本上接口还在不在也没确认。
- 半径等于二倍 sigma：同一接口把半径设成 sigma 的两倍。这里不选。要等上面那组对比图和真机并排之后再定。

## 投影

- blurRadius 的一半：SwiftUI 的 `shadow(radius:)` 取夹具 `blurRadius` 的一半。这里不选。还没和 `a5_shadows` 对过。
- blur × 0.57735 + 0.5：按总计划 T2.7 S3 的式子把 `blurRadius` 换成 sigma，再交给 `shadow(radius:)`。这里不选。系数不在夹具里，要等 Mac 上和 `a5_shadows` 的差异数字。Swift 文件里只存夹具原值，没有把这个式子写成已选实现。

## 水波纹触摸

- SwiftUI 手势：在滚动列表里的可点卡片上用 SwiftUI 手势拿按下坐标。这里不选。还没验证三件事：能拿到按下坐标；手指开始滚动时水波纹取消；滚动手感不受影响。
- UIKit 触摸视图：在 SwiftUI 下面垫一层 UIKit 触摸视图。这里不选。要等上面三件事在 Mac 上跑完；若 SwiftUI 手势做不到，再改用这一层。本目录没有这层视图的可编译代码。

## swiftc -parse

命令形式：`wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swiftc -parse` 加上文件的 `/mnt/e/GQ/Ultra/Onetools-IoS/experiments/G3/Sources/G3Numbers/` 路径。

- TextNumbers.swift 退出码 0
- BlurNumbers.swift 退出码 0
- ShadowNumbers.swift 退出码 0
- RippleNumbers.swift 退出码 0

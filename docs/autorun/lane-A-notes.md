# 线 A 备忘

开工 2026-11-11 23:49 +08，交回 2026-11-12 00:20 +08。A1、A2 已在本机验证。未动 git，未改代理、hosts、Flutter 的 git。

## A1

字体 SHA-256 与来源一致，前缀分别是 T1.1 写的 `F5A3F02C`、`D9865B67`：

- `F5A3F02C4A72F1DA11C6DADF4FD78C07B2F145A34ED46EB875ED0DA28CBD348C`
  - 来源：`E:\GQ\Ultra\ONEWIFIX\IOS\assets\fonts\Montserrat-Regular.ttf`
  - 副本：`_golden/fonts/Montserrat-Regular.ttf`
- `D9865B671A09D683D13A863089D8825E0F61A37696CE5D7D448BC8023AA62453`
  - 来源：`OneUI/Sources/OneUI/Resources/Icons/MaterialIcons-Regular.otf`
  - 副本：`_golden/fonts/MaterialIcons-Regular.otf`

`flutter pub get` 成功（Changed 106 dependencies）。之后 `git -C E:\GQ\Ultra\ONEWIFIX\IOS status --porcelain` 为空。

先红：字体还没复制时 `flutter test` 失败，`Cannot open file, path = 'fonts/Montserrat-Regular.ttf'`。复制后 `flutter test --update-goldens` 通过。接着不带参数连跑两次，都是 `All tests passed!`，两张图哈希不变：

- light `E01AC4A4F084965AB597EF552EF014F64555E654CB1199C395ED95912809048F`
- dark `02400F310CC76D53FBB53572EAD8398A0137050AD77EDEB9B7BFF15D1AA27A47`

尺寸 1170×2532。来源：总计划默认 `Size(390, 844)` × `devicePixelRatio = 3.0`（`_golden/test/support/scene.dart`）。浅色图的字形行有内孔（字腔），不是实心缺字方块。主代理仍需要目视确认。

自查：把样例改成 `HamburgefonstivX 0123456789` 后 `flutter test` 失败，两张图各 52485 px（1.77%）。改回后再跑一次，`All tests passed!`，哈希仍是上面两个。

命令都在 `_golden` 目录里跑：`C:\Flutter\flutter\bin\flutter.bat test`。字体路径相对于这个目录。

### 决定

1. 十个样式用 OneWIFI 设计组件实际引用的 M3 角色，从大到小：headlineSmall、titleLarge、titleMedium、titleSmall、bodyLarge、bodyMedium、bodySmall、labelLarge、labelMedium、labelSmall。字号出处：Flutter `typography.dart` 的 `_M3Typography.englishLike`（约 2102–2111 行）。引用出处：`page_head.dart`、`metric_card.dart`、`glass_dialog.dart`、`one_status_hero.dart`、`section.dart`、`nameplate.dart`、`feature_failure_notice.dart`、`soft_label.dart`、`glass_action.dart`、`ultra_glass_dock.dart`。displayLarge/Medium/Small 和 headlineLarge/Medium 在这些文件里没有 `textTheme` 引用。回退：把缺的五个加进 `A1Typography.styles`，再 `flutter test --update-goldens`。
2. 每行只画 `Hamburgefonstiv 0123456789`，不画角色名。依据：T1.1 规定的内容就是这句。加上角色名后，headlineSmall 一行贴到 x=1169，右缘被 1170 宽裁掉。回退：改文案并更新金图。
3. `pubspec.yaml`、`flutter_test_config.dart`、`scene.dart` 按总计划 P1 的文本。场景用 `OneTheme` 和 `Glass.backdrop`，没有仿写组件。

## A2

先写测试。模块不存在时：`python -m pytest tools/test_golden_diff.py -q` → `ModuleNotFoundError: No module named 'golden_diff'`，exit 2。实现后 4 passed。自查把 `diff_pixels` 加 1：同图变成 1，10×10 变成 101，3 failed；改回后再跑，`4 passed in 0.19s`，exit 0。

本机已有 Pillow 12.3.0、numpy 2.5.1、pytest 8.4.2。没有执行总计划里的 `pip install`。

### 决定

1. 差异像素 = 任一 RGBA 通道不等的像素数。最大通道差 = 各通道绝对差的最大值。占比 = 差异像素 / (宽×高)。
2. 单张尺寸不同抛 `SizeMismatch`。目录模式把该对记为 `size_mismatch`，仍写 `report.json`，进程退出码 1。没有成对、有缺文件、或任一差异像素 > 0 时 `ok` 为 false。
3. 只配对 `*.png` / `*.PNG`。热力图是每像素最大通道差，写进 R 通道，文件名 `<stem>.heatmap.png`。CLI：`python tools/golden_diff.py LEFT RIGHT --out DIR`。
4. 这些决定写在本文件。本任务不允许改 `docs/autorun/DECISIONS.md`。

## 不在本次任务里

- `flutter test` 提示有新版本。没有跑 upgrade。
- pub get 报告 24 个依赖有更新但受约束挡住。没有改 OneWIFI 的版本约束。
- 总计划写「10 个 M3 样式」但没点名。上面的十个是按组件引用选的；若要全部 15 个，按 A1 决定 1 回退。

## 收口

A2 本轮：`python -m pytest tools/test_golden_diff.py -q`
- 退出码：0
- 最后一行：`4 passed in 0.19s`

A1 上一轮已经连跑两次 `flutter test`（不带 `--update-goldens`），本轮按收口条件不再重跑。
- 第一次最后一行：`00:00 +2: All tests passed!`
- 第二次最后一行：`00:00 +2: All tests passed!`（退出码 0）
- 两次前后金图 SHA-256 相同，light `E01AC4A4F084965AB597EF552EF014F64555E654CB1199C395ED95912809048F`，dark `02400F310CC76D53FBB53572EAD8398A0137050AD77EDEB9B7BFF15D1AA27A47`。第二次没有改写文件内容。
- 本轮补跑（cwd `_golden`）：`git status --porcelain -- goldens` → `?? _golden/goldens/`，退出码 0。整包 `_golden/` 尚未入库，porcelain 显示未跟踪；这不是第二次测试改了金图。

## A3

开工 2026-11-12 00:55 +08。先红：`python -m pytest tools/test_check_fixtures.py -q` 收集失败，`ModuleNotFoundError: No module named 'check_fixtures'`。检查脚本写上之后、夹具还没生成时：`python tools/check_fixtures.py` 输出 `missing tokens.json` / `missing typography.json`，退出码 1。

生成后（cwd `_golden`）：`C:\Flutter\flutter\bin\flutter.bat test test/fixtures/export_test.dart` → `All tests passed!`。然后 `python tools/check_fixtures.py` → `ok tokens.json typography.json`。`python -m pytest tools/test_check_fixtures.py -q` 在补上底栏拒绝之后是 `5 passed`。自查把浅色描边 alpha 改成 `0.6000`、把 `radiusCard` 加 1，检查都失败，改回后再跑通过。没改 a1 金图。

### 决定

1. 五种填充按交接文档 3.3.1：`fill`、`fillStrong`、`barFill`、`modalFill`、`dialogFill`（`glass.dart` 115–126、128–134、216‑218、224‑225）。`blurredBarFill` / `liquidFill` / `liquidDockFill` 不算进这五种。回退：在 `resolved` 下加键，并让 `check_fixtures.py` 按 `glass.dart` 同名函数复算。
2. ColorScheme 字段从运行时的 `oneBlackWhiteLight` / `oneBlackWhiteDark` 读出，含 `primaryFixed*` 和已弃用的 `background` / `onBackground` / `surfaceVariant`。浅色描边 alpha 是 `Color.a.toStringAsFixed(4)`，结果 `0.5950`（`glass.dart` 229–234 的 `alphaBlend`，`tokens.json` 的 `resolved.light.stroke.alpha`）。
3. 字号是 MaterialApp 按语言合并之后的全部 15 个 TextTheme 样式，不只是 a1 画出来的 10 个。几何值对 `typography.dart` 2096–2111 行的 `_M3Typography.englishLike`。量高用 `TextPainter`，样例文字是 `A1Typography.sample`。行高会吸到最近的逻辑像素，headlineSmall 是 32（`24 * 1.33 = 31.92`）。
4. 深色主题用 `themeMode: ThemeMode.dark`，并把 `themeAnimationDuration` 设为 0。只改 `theme:` 时，AnimatedTheme 第一帧仍是上一个浅色 ColorScheme。

## A4

`dock_edges.json`、`ripple.json` 已写入，同一条 `python tools/check_fixtures.py` 输出 `ok tokens.json typography.json dock_edges.json ripple.json`。把第一条过渡的 `samples[5].left` 加 1，检查失败，改回后通过。

`icons.json` 没有写。`_ref/ow_icons.txt` 121 行里，`Icons.eye` 和 `Icons.eye_slash` 在 `_ref/flutter-3.44.9/material/icons.dart` 没有对应的 `static const IconData`。脚本能解析出 119 个码点，这两个名字也不能写成 `Icons.x.codePoint`（编译不过）。两种方式对这两个名字一致地得不到码点，所以停，没有把 121 改成 119，也没改 `ow_icons.txt`。来源是 `obscurable_field.dart` 51 行的 `CupertinoIcons.eye` / `CupertinoIcons.eye_slash`，抽取正则 `Icons.[a-z0-9_]+` 把后缀算进去了。

### 决定

1. 底栏：`count` 4，切换 0→1、0→3、3→0，`t` 为 `i/10`（i = 0…10）。数值来自运行时 `glassDockTabEdges`（`ultra_glass_dock.dart` 213–240）。
2. 水波纹：常量行号从 `_ref/flutter-3.44.9/material/ink_ripple.dart` 扫出（19–23、26、159、193）。半径和透明度用 Flutter 的 `Tween` / `IntTween` / `Curves.ease` / `Interval`。按住取 0、淡入结束、200、500、未松手时长；松手从 t=0 确认（同一帧按下并松开），取 0、淡入结束、半径时长、400、600。参考盒子是 `OneSizes.minimumTarget`（`one_tokens.dart` 65 行，44）的正方形，目标半径按 `ink_ripple.dart` 43–52 行的对角线公式。浅色水花 alpha 102、深色 64，来自主题 `splashColor`，对应 `theme_data.dart` 502 行。
3. 检查脚本每次从磁盘重读。A4 文件不在时不要求它们；文件在就检查。图标个数不写死，按 `ow_icons.txt` 的行数和 `icons.dart` 的解析结果比。

## 不在本次任务里

- `OneGlass.swift` 浅色描边仍是 0.6，夹具里是 0.5950。线 E 要改 Swift，这里没动 `OneUI/`。
- 没有开 A5。

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
- A5 见下节。未开任务 A6。

## A5

开工 2026-11-12 01:38 +08，交回 2026-11-12 02:08 +08。命令都在 `_golden`，`C:\Flutter\flutter\bin\flutter.bat test`。深浅各一张，1170×2532。未跑整包连跑两次。

- a2_weights | 通过 | `test/scenes/a2_weights_test.dart`，`goldens/a2_weights.light.png`，`goldens/a2_weights.dark.png` | 先红：缺图 `non-existent file`；`--update-goldens test/scenes/a2_weights_test.dart` → `All tests passed!`；不带参数 → `All tests passed!`
- a3_icons | 通过 | `test/scenes/a3_icons_test.dart`，`goldens/a3_icons.light.png`，`goldens/a3_icons.dark.png` | 先红缺图；`--update-goldens test/scenes/a3_icons_test.dart` → `All tests passed!`；不带参数 → `All tests passed!`。119 个 `Icons.*`（7×17），每格 20 和 24，没画 `Icons.eye` / `Icons.eye_slash`，没有空格。
- a4_fills | 通过 | `test/scenes/a4_fills_test.dart`，`goldens/a4_fills.light.png`，`goldens/a4_fills.dark.png` | 先红缺图；`--update-goldens test/scenes/a4_fills_test.dart` → `All tests passed!`；不带参数 → `All tests passed!`
- a5_shadows | 通过 | `test/scenes/a5_shadows_test.dart`，`goldens/a5_shadows.light.png`，`goldens/a5_shadows.dark.png` | 先红缺图；`--update-goldens test/scenes/a5_shadows_test.dart` → `All tests passed!`；不带参数 → `All tests passed!`
- a6_ripple_hold | 图已生成，确认未跑 | `test/scenes/a6_ripple_hold_test.dart`，`goldens/a6_ripple_hold.light.png`，`goldens/a6_ripple_hold.dark.png` | 先红缺图；`--update-goldens test/scenes/a6_ripple_hold_test.dart` → `All tests passed!`。不带参数的复跑没做（02:04 收窄后不再跑）。

主代理 2026-11-12 02:12 在 `_golden` 连跑两次不带 `--update-goldens` 的 `flutter test`，都是 `00:02 +15: All tests passed!`，退出码 0。14 张图的 SHA-256 两次相同。a1 仍是 light `E01AC4A4F084965AB597EF552EF014F64555E654CB1199C395ED95912809048F`、dark `02400F310CC76D53FBB53572EAD8398A0137050AD77EDEB9B7BFF15D1AA27A47`。
- a7_ripple_confirm | 通过 | `test/scenes/a7_ripple_confirm_test.dart`，`goldens/a7_ripple_confirm.light.png`，`goldens/a7_ripple_confirm.dark.png` | `--update-goldens test/scenes/a7_ripple_confirm_test.dart` → `All tests passed!`；不带参数 → `All tests passed!`

## A6

开工 2026-11-12 02:14 +08，交回 2026-11-12 02:28 +08。命令都在 `_golden`，`C:\Flutter\flutter\bin\flutter.bat test`。深浅各一张，1170×2532。未跑整包连跑两次。这 8 个场景没有 `SystemSwitch` / `SystemSpinner`（`GlassActionButton` 没开 `busy`），没装平台视图空实现。

- nameplate | 通过 | `test/scenes/b_nameplate_test.dart`，`goldens/nameplate.light.png`，`goldens/nameplate.dark.png` | 先红：缺图 `non-existent file`；`--update-goldens test/scenes/b_nameplate_test.dart` → `00:00 +2: All tests passed!`；不带参数 → `00:00 +2: All tests passed!`
- section | 通过 | `test/scenes/b_section_test.dart`，`goldens/section.light.png`，`goldens/section.dark.png` | 先红缺图；`--update-goldens test/scenes/b_section_test.dart` → `00:01 +2: All tests passed!`；不带参数 → `00:00 +2: All tests passed!`
- glass_tile | 通过 | `test/scenes/b_glass_tile_test.dart`，`goldens/glass_tile.light.png`，`goldens/glass_tile.dark.png` | 先红缺图；`--update-goldens test/scenes/b_glass_tile_test.dart` → `00:01 +2: All tests passed!`；不带参数 → `00:01 +2: All tests passed!`
- glass_panel | 通过 | `test/scenes/b_glass_panel_test.dart`，`goldens/glass_panel.light.png`，`goldens/glass_panel.dark.png` | 第一次编译失败：`glass.dart` 导出的 `GlassPanel` 与 `widgets/glass_panel.dart` 重名。`hide GlassPanel` 后先红缺图；`--update-goldens test/scenes/b_glass_panel_test.dart` → `00:01 +2: All tests passed!`；不带参数 → `00:00 +2: All tests passed!`
- metric_card | 通过 | `test/scenes/b_metric_card_test.dart`，`goldens/metric_card.light.png`，`goldens/metric_card.dark.png` | 先红缺图；`--update-goldens test/scenes/b_metric_card_test.dart` → `00:01 +2: All tests passed!`；不带参数 → `00:01 +2: All tests passed!`
- stage_row | 通过 | `test/scenes/b_stage_row_test.dart`，`goldens/stage_row.light.png`，`goldens/stage_row.dark.png` | 先红缺图；`--update-goldens test/scenes/b_stage_row_test.dart` → `00:00 +2: All tests passed!`；不带参数 → `00:00 +2: All tests passed!`
- soft_label | 通过 | `test/scenes/b_soft_label_test.dart`，`goldens/soft_label.light.png`，`goldens/soft_label.dark.png` | 先红缺图；`--update-goldens test/scenes/b_soft_label_test.dart` → `00:01 +2: All tests passed!`；不带参数 → `00:00 +2: All tests passed!`
- glass_action | 通过 | `test/scenes/b_glass_action_test.dart`，`goldens/glass_action.light.png`，`goldens/glass_action.dark.png` | 先红缺图；`--update-goldens test/scenes/b_glass_action_test.dart` → `00:00 +2: All tests passed!`；不带参数 → `00:00 +2: All tests passed!`

### 决定

1. 场景名用 T1.3 的 `nameplate` 等，测试文件用 `b_*_test.dart`。组件是 `package:onewifi_android/design/widgets/` 下的原类，不是仿写。
2. 需要有界宽度的卡片用 `test/support/b_frame.dart`：水平约束保留、高度不受约束，避免 `Column` 被拉成 844。宽度 250–320，给投影和选中光留边。
3. 文案只用拉丁字母和数字。`SoftLabel` 没开 `mono`：测试只装了 Montserrat，`monospace` 会成方块。

## A7

开工 2026-11-12 02:33 +08，交回 2026-11-12 02:46 +08。命令都在 `_golden`，`C:\Flutter\flutter\bin\flutter.bat test`。未跑整包。未改 OneWIFI，未做 git 写操作。

`page_head` 单文件先红：缺图 `non-existent file`，最后一行 `00:01 +0 -2: Some tests failed.`。接着十四个文件一起：

- `--update-goldens` 上面这 14 个 `test/scenes/b_*_test.dart` → 最后一行 `00:04 +28: All tests passed!`，退出码 0
- 同一条不带 `--update-goldens` → 最后一行 `00:04 +28: All tests passed!`，退出码 0

深浅各一张。`status_hero_*_280` 是 840×2532（`Size(280, 844)` × 像素比 3）。其余 11 个场景是 1170×2532。

- page_head | 通过 | `test/scenes/b_page_head_test.dart`，`goldens/page_head.light.png`，`goldens/page_head.dark.png` | `OwPageHead`
- ow_accent | 通过 | `test/scenes/b_ow_accent_test.dart`，`goldens/ow_accent.*.png` | `OwAccent`、`SelectedEdgeLight`。`glass.dart` 用了 `hide GlassPanel`
- one_mark | 通过 | `test/scenes/b_one_mark_test.dart`，`goldens/one_mark.*.png` | `OneMark`
- choice_toggle | 通过 | `test/scenes/b_choice_toggle_test.dart`，`goldens/choice_toggle.*.png` | `ChoiceToggle`。按钮文案写死为「开启 / 关闭」，金图里是缺字方块
- obscurable_field | 通过 | `test/scenes/b_obscurable_field_test.dart`，`goldens/obscurable_field.*.png` | `ObscurableField`。光标用 `EditableText.debugDeterministicCursor`。眼睛是 `CupertinoIcons`，测试只装了 Montserrat 和 MaterialIcons
- feature_failure_notice | 通过 | `test/scenes/b_feature_failure_notice_test.dart`，`goldens/feature_failure_notice.*.png` | `FeatureFailureNotice`。标题后缀「不可用」和超时文案「请求超时。」是类里写死的中文
- glass_dialog | 通过 | `test/scenes/b_glass_dialog_test.dart`，`goldens/glass_dialog.*.png` | `OneGlassDialog`。iOS 上帧是 `UiKitView` `onewifi/system_glass_surface`，测试里装了空平台视图
- dot_matrix_face | 通过 | `test/scenes/b_dot_matrix_face_test.dart`，`goldens/dot_matrix_face.*.png` | `DotMatrixFace`
- status_hero_ready | 通过 | `test/scenes/b_status_hero_ready_test.dart`，`goldens/status_hero_ready.*.png` | 宽 390，`OneChannelState.ready`
- status_hero_busy | 通过 | `test/scenes/b_status_hero_busy_test.dart`，`goldens/status_hero_busy.*.png` | `activating`，会建 `SystemSpinner` / `UiKitView`，只在测试里装空实现
- status_hero_alert | 通过 | `test/scenes/b_status_hero_alert_test.dart`，`goldens/status_hero_alert.*.png` | `inactive`
- status_hero_ready_280 | 通过 | `test/scenes/b_status_hero_ready_280_test.dart`，`goldens/status_hero_ready_280.*.png` | `size: Size(280, 844)`
- status_hero_busy_280 | 通过 | `test/scenes/b_status_hero_busy_280_test.dart`，`goldens/status_hero_busy_280.*.png` | 同上，忙态同样装空平台视图
- status_hero_alert_280 | 通过 | `test/scenes/b_status_hero_alert_280_test.dart`，`goldens/status_hero_alert_280.*.png` | `size: Size(280, 844)`

### 决定

1. 门面卡用 `design/one/one_status_hero.dart` 的 `OneStatusHero`，不用 `widgets/one_status_hero.dart`。后者把药丸和阶段写死成中文。场景名对应 `OneChannelState.ready` / `activating`（`isBusy`）/ `inactive`（`isAlert`）。`busyLabel` 传 `Wait`，避开默认的「处理中」。右上角挂了 `Icons.chevron_right`，宽 280 时它掉到标题行下面（内宽 < 300）。
2. 空平台视图在 `test/support/platform_views.dart`，只给 `glass_dialog` 和两个 busy 场景 `setUp`。渠道是 `SystemChannels.platform_views`，处理函数返回 null。ready / alert 不建 `SystemSpinner`，没装。

## A8

开工 2026-11-12 02:58 +08，交回 2026-11-12 03:07 +08。命令都在 `_golden`，`C:\Flutter\flutter\bin\flutter.bat test`。深浅各一张，默认 `Size(390, 844)` × 像素比 3，1170×2532。未跑整包。未改 OneWIFI，未做 git 写操作。未开 A9。

先红：17 个 `test/scenes/c_*_test.dart` 一起跑。`snack_bar`、`popup_menu` 编译失败（`find` 未导入 `flutter_test`）。其余到达缺图比较，最后一行 `00:07 +0 -33: Some tests failed.`。补上导入后只跑这两个文件，四张都是 `non-existent file`，最后一行 `00:03 +0 -4: Some tests failed.`。

接着 17 个文件：

- `--update-goldens` → 最后一行 `00:06 +34: All tests passed!`，退出码 0
- 同一条不带 `--update-goldens` → 最后一行 `00:06 +34: All tests passed!`，退出码 0

- text_field | 通过 | `test/scenes/c_text_field_test.dart`，`goldens/text_field.light.png`，`goldens/text_field.dark.png` | 空、聚焦、报错。光标 `EditableText.debugDeterministicCursor`
- text_button | 通过 | `test/scenes/c_text_button_test.dart`，`goldens/text_button.*.png` | `TextButton` 与 `TextButton.icon`
- icon_button | 通过 | `test/scenes/c_icon_button_test.dart`，`goldens/icon_button.*.png` | `IconButton`
- filled_button | 通过 | `test/scenes/c_filled_button_test.dart`，`goldens/filled_button.*.png` | 普通、`FilledButton.icon`、`FilledButton.tonal`、禁用
- outlined_button | 通过 | `test/scenes/c_outlined_button_test.dart`，`goldens/outlined_button.*.png` | `OutlinedButton` 与 `OutlinedButton.icon`
- card | 通过 | `test/scenes/c_card_test.dart`，`goldens/card.*.png` | `Card`
- alert_dialog | 通过 | `test/scenes/c_alert_dialog_test.dart`，`goldens/alert_dialog.*.png` | 直接放 `AlertDialog`，不走 `showDialog`
- snack_bar | 通过 | `test/scenes/c_snack_bar_test.dart`，`goldens/snack_bar.*.png` | `ScaffoldMessenger.showSnackBar`，再 `pump` 250ms
- list_tile | 通过 | `test/scenes/c_list_tile_test.dart`，`goldens/list_tile.*.png` | `ListTile`
- switch_list_tile | 通过 | `test/scenes/c_switch_list_tile_test.dart`，`goldens/switch_list_tile.*.png` | `SwitchListTile`（不是 `.adaptive`）
- checkbox_list_tile | 通过 | `test/scenes/c_checkbox_list_tile_test.dart`，`goldens/checkbox_list_tile.*.png` | `CheckboxListTile`
- divider | 通过 | `test/scenes/c_divider_test.dart`，`goldens/divider.*.png` | `Divider`
- progress | 通过 | `test/scenes/c_progress_test.dart`，`goldens/progress.*.png` | 线形 `value: 0.40`，圆形 `value: 0.65`
- app_bar | 通过 | `test/scenes/c_app_bar_test.dart`，`goldens/app_bar.*.png` | `AppBar`，`primary: false`，高 `kToolbarHeight`
- tab_bar | 通过 | `test/scenes/c_tab_bar_test.dart`，`goldens/tab_bar.*.png` | `DefaultTabController` + `TabBar`
- filter_chip | 通过 | `test/scenes/c_filter_chip_test.dart`，`goldens/filter_chip.*.png` | 选中、未选、禁用
- popup_menu | 通过 | `test/scenes/c_popup_menu_test.dart`，`goldens/popup_menu.*.png` | 点开 `PopupMenuButton`，再 `pump` 300ms

### 决定

1. 场景名用 T1.3 的 `text_field` 等，测试文件用 `c_*_test.dart`。控件是 Flutter Material 原件，由 `goldenScene` 套 `OneTheme`，没有仿写按钮样式。文案只用拉丁字母和数字。
2. 这 17 个没有调 `installEmptyPlatformViews`。`SwitchListTile` 用 Material `Switch`，不是 `Switch.adaptive`，不建 `SystemSwitch`。`CircularProgressIndicator` 不是 `.adaptive`，并且写死 `value`，走材质绘制，不建 `SystemSpinner`。测试能走到缺图比较，说明没有缺平台视图通道。
3. 进度不用空 `value`，避免不定态动画。`SnackBar` 必须带动画才能建，所以用 `ScaffoldMessenger` 弹出，只 `pump` 250ms（入场时长），不用 `pumpAndSettle`（会把 4 秒后的退场也跑掉）。菜单路由时长 300ms，点开后只 `pump` 300ms。
4. `AppBar` 内部 `Align` 会向最大高度撑满。放进 `SizedBox` 高 `kToolbarHeight`，并设 `primary: false`，避免 `SafeArea` 把工具栏顶出 56。

主代理 2026-11-12 03:32 在 `_golden` 连跑两次不带 `--update-goldens` 的整包 `flutter test`，都是 `00:11 +93: All tests passed!`，退出码 0。92 张图的 SHA-256 两次相同。C 组 34 张都是 1170×2532。浅色 `text_field` 能读到 Name / Required，`filled_button` 能读到 Filled / Icon / Tonal / Disabled。

## A9

开工 2026-11-12 03:14 +08，交回 2026-11-12 03:35 +08。命令都在 `_golden`，`C:\Flutter\flutter\bin\flutter.bat test`。深浅各一张，默认 `Size(390, 844)` × 像素比 3，1170×2532（已核 IHDR）。未跑整包。未改 OneWIFI，未做 git 写操作。未开 A10。

十个文件一起：

- `--update-goldens` → 最后一行 `00:03 +20: All tests passed!`，退出码 0
- 同一条不带 `--update-goldens` → 最后一行 `00:03 +20: All tests passed!`，退出码 0

- dock_static_0 | 通过 | `test/scenes/d_dock_static_0_test.dart`，`goldens/dock_static_0.*.png` | 选中第 0 格
- dock_static_1 | 通过 | `test/scenes/d_dock_static_1_test.dart`，`goldens/dock_static_1.*.png` | 选中第 1 格
- dock_static_2 | 通过 | `test/scenes/d_dock_static_2_test.dart`，`goldens/dock_static_2.*.png` | 选中第 2 格
- dock_static_3 | 通过 | `test/scenes/d_dock_static_3_test.dart`，`goldens/dock_static_3.*.png` | 选中第 3 格
- dock_slide_t000 | 通过 | `test/scenes/d_dock_slide_t000_test.dart`，`goldens/dock_slide_t000.*.png` | 0→2，`pump()` 后 t=0
- dock_slide_t025 | 通过 | `test/scenes/d_dock_slide_t025_test.dart`，`goldens/dock_slide_t025.*.png` | 再 `pump` 120ms
- dock_slide_t050 | 通过 | `test/scenes/d_dock_slide_t050_test.dart`，`goldens/dock_slide_t050.*.png` | 再 `pump` 240ms
- dock_slide_t075 | 通过 | `test/scenes/d_dock_slide_t075_test.dart`，`goldens/dock_slide_t075.*.png` | 再 `pump` 360ms
- dock_slide_t100 | 通过 | `test/scenes/d_dock_slide_t100_test.dart`，`goldens/dock_slide_t100.*.png` | 再 `pump` 480ms
- dock_pressed | 通过 | `test/scenes/d_dock_pressed_test.dart`，`goldens/dock_pressed.*.png` | 按住第 0 格：`kPressTimeout` 后再 `pump` 200ms

`python tools/check_fixtures.py` → `ok tokens.json typography.json dock_edges.json ripple.json layout.json`，退出码 0。`python -m pytest tools/test_check_fixtures.py -q` → `6 passed in 0.12s`。

### 决定

1. 底栏用 `package:onewifi_android/design/one/ultra_glass_dock.dart` 的 `GlassDock`（源码里没有 `UltraGlassDock` 这个类名）。没有仿写底栏。四格文案是 Home / Device / Mail / Proxy，图标是 Material `Icons`。
2. 底栏贴在默认场景底部。滑动：`selectedIndex` 从 0 改到 2，先 `pump()` 把动画停在 t=0，再按 480ms 的比例 `pump`。不用 `pumpAndSettle`。按下：指针不松，先 `pump(kPressTimeout)`（水波纹出生，这一帧 elapsed 为 0），再 `pump` 200ms。
3. `layout.json` 的常量和矩形都是测试里读的：`Glass.dockHeight` 等，以及 `tester.getRect` 的 `GlassDock` 和 `kGlassDockIndicatorKey`。检查脚本再从 `glass.dart` / `ultra_glass_dock.dart` 解析常量。文件不在时不要求；在就检查。原有 tokens / typography / dock_edges / ripple 没放宽。


# 夹具归宿（MA-1 / MA-2）

P2 的封存表在 `docs/findings/fixture-cross-audit.md`，本文不改那张表。对照范围是已有的 `tokens.json`、`typography.json`、`dock_edges.json`、`ripple.json`，以及 `layout.json` 的 `dock` 段。按条目的名字对键。同一个数出现在别的键上，不算这一条命中。没有改夹具。

源码根目录仍是 `ONEWIFIX/IOS/lib/design/`（`tools/check_fixtures.py` 第 18 行，仓库上一级的 `ONEWIFIX/IOS`）。下面的行号是对这些文件逐行看过的。

## MA-1：P2 那 17 条

原文不一致表是 `fixture-cross-audit.md` 第 102–118 行。当时只对过 `tokens.json`。这里改对到其余已有夹具，或写明合同不收。

结果：1 条在 `layout.json` 的 `dock.slideMs`；其余 16 条合同不收。没有同一键两边数值不同。

| # | 源码 | 值 | 归宿 |
|---:|---|---|---|
| 1 | `one/ultra_glass_dock.dart:392` `_lightHighlight[1]` | `0x14FFFFFF` | 故意不收。五份夹具都没有 `14FFFFFF`。总计划 T1.4（`docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md:497`）的 `tokens.json` 只收 ColorScheme、Glass 常量、五种填充、描边、两档投影、背景端点和 `accent`。`layout.json` 的 dock 段只收几何和 `slideMs`。 |
| 8 | `one/ultra_glass_dock.dart:329` `DockRimHighlightPainter._strokeWidth` | `1.25` | 故意不收。`tools/check_fixtures.py:1107-1114` 的 dock 键再加 `slideMs`，没有描边宽。同值的另一键是 `typography.json:31` 与 `:153` 的 `headlineLarge.height`（浅色、深色行高）。`tokens.json:134` 的 `glass.strokeWidth` 是 `0.8`，源码是 `one/glass.dart:103`。 |
| 9 | `one/glass.dart:141` `blurredBarFill` 暗色 alpha | `0.34` | 故意不收。A3 写明 `blurredBarFill` 不进五种填充（`docs/autorun/lane-A-notes.md:74`）。检查脚本的五种填充在 `tools/check_fixtures.py:26`。夹具里没有 `0.34`。 |
| 10 | `one/glass.dart:361` `Glass.apply` 的 `shadowColor` 暗色 alpha | `0.14` | 故意不收。T1.4 的两档投影是 `Glass.shadow`，已在 `tokens.json:249`（`0.2800`）和 `:259`（`0.3200`），源码是 `one/glass.dart:246`。第 361 行是主题卡阴影，没有同名键。 |
| 11 | `one/ultra_glass_dock.dart:384` `_darkHighlight[1]` | `0x0FFFFFFF` | 故意不收。同第 1 条，指示条画家颜色不在现有键集合里。检索 `0FFFFFFF` 无命中。 |
| 13 | `one/ultra_glass_dock.dart:352` 亮色描边 `[0]` | `0xB8FFFFFF` | 故意不收。同第 1 条。同一个前缀的另一键是 `tokens.json:146` `resolved.light.fillStrong.argb` `B8F3F3FA`。 |
| 14 | `tokens/one_tokens.dart:66` `OneSizes.control` | `52` | 故意不收。T1.4 的 tokens 收的是 Glass 常量，不收 `OneSizes`。同值的另一键是 `typography.json:17` 与 `:139` 的 `displayMedium.measuredHeight` `52.0`。`ripple.json` 的参考盒是 `minimumTarget` 44，不是 52。 |
| 16 | `one/ultra_glass_dock.dart:386` `_darkHighlight[3]` | `0x0AFFFFFF` | 故意不收。同第 1 条。检索 `0AFFFFFF` 无命中。 |
| 18 | `tokens/one_tokens.dart:20` `OneColors.transparent` | `0x00000000` | 故意不收。不是 ColorScheme 字段。五份夹具检索 `00000000` 无命中。 |
| 22 | `one/ultra_glass_dock.dart:391` `_lightHighlight[0]` | `0x66FFFFFF` | 故意不收。同第 1 条。检索 `66FFFFFF` 无命中。 |
| 24 | `one/glass.dart:149` `liquidDockFill` 亮色 alpha | `0.12` | 故意不收。A3 写明 `liquidDockFill` 不进五种填充（`lane-A-notes.md:74`）。底栏仍在 `one/ultra_glass_dock.dart:99` 调用它，所以这是范围决定，不是死代码。同值的另一键是 `tokens.json:243` `resolved.dark.stroke.alpha` `0.1200`，源码是 `one/glass.dart:230`。 |
| 29 | `one/glass.dart:182` `liquidHighlight` 亮色顶边 alpha | `0.38` | 故意不收。不在五种填充、描边、两档投影或背景端点里。调用在 `one/liquid_glass.dart:74`。`lane-A-notes.md:242` 写过 `LiquidGlass` 没有场景实例。夹具里没有 `0.38`。 |
| 30 | `one/ultra_glass_dock.dart:349` 暗色描边 `[2]` | `0x47FFFFFF` | 故意不收。同第 1 条。同一个前缀的另一键是 `tokens.json:248` `resolved.dark.shadow.normal[0].argb` `47000000`（黑）。 |
| 31 | `one/ultra_glass_dock.dart:348` 暗色描边 `[1]` | `0x1AFFFFFF` | 故意不收。同第 1 条。同一个前缀的另一键是 `tokens.json:186` `resolved.light.shadow.strong[0].argb` `1A000000`（黑）。 |
| 33 | `one/ultra_glass_dock.dart:34` `_slideDuration` 毫秒 | `480` | 在另一份夹具。`_golden/fixtures/layout.json:19` `dock.slideMs` 是 `480.0`。同文件第 9 行标注来源 `GlassDock._slideDuration`。`tokens.json` 没有 `slideMs`。 |
| 34 | `one/glass.dart:299` `backdrop` 亮色 tertiary alpha | `0.03` | 故意不收。导出的黑白方案走 `isNeutralAccent`（`one/glass.dart:284-291`）。`tokens.json:208` 与 `:212` 的 `resolved.light.backdrop` alpha 是 `1.0000`。第 299 行是非中性混色，没有同名键。 |
| 35 | `one/glass.dart:184` `liquidHighlight` 亮色底边 alpha | `0.05` | 故意不收。这条是高光字面量。同值的 `one/glass.dart:299` 暗色 tertiary `0.05` 是后出现，池子里只留第 184 行。中性背景仍是 `tokens.json:272` 与 `:276` 的 alpha `1.0000`。夹具里没有 `0.05`。 |

## 顺带扫过的四份夹具

合同内没有缺键，也没有改文件。

- `typography.json`：浅色、深色各 15 个样式。`fontSize`、`fontWeight`、`letterSpacing`、`height` 与 `_ref/flutter-3.44.9/material/typography.dart` 的 `_M3Typography.englishLike` 一致，没有缺样式，也没有几何字段不同。
- `dock_edges.json`：`count` 4（第 2 行）。过渡是 0→1（第 5–6 行）、0→3（第 66–67 行）、3→0（第 127–128 行），每条 11 个样本（t = 0、0.1…、1.0）。这就是 A4 要的三种切换。
- `ripple.json`：常量行号 19、20、21、22、23、26、159、193 都在（第 4–48 行）。按住取 0 / 75 / 200 / 500 / 1000 毫秒，松手取 0 / 75 / 225 / 400 / 600 毫秒，深浅都有。与 `lane-A-notes.md:88` 的取样点一致。
- `layout.json` 的 `dock`：`height` 56.0（第 13 行，`Glass.dockHeight`）、`radius` 28.0（第 14 行）、`bottomGap` 8.0（第 15 行）、`blur` 12.0（第 16 行）、`tabInset` 4.0（第 17 行）、`indicatorHeight` 48.0（第 18 行）、`slideMs` 480.0（第 19 行）。与 `one/glass.dart:44-60` 和 `one/ultra_glass_dock.dart:34` 一致。

总计划 T1.4 还写过 B、C、D 组场景矩形。A9 已经把 `layout.json` 收成底栏场景（`lane-A-notes.md` 里关于 layout 的决定；`check_fixtures.py` 的 `D_SCENES` 在第 1094–1105 行）。这次不把缺的 B/C 矩形算成要补的缺键，也不扩场景。

合同外、源码在用、夹具没有同名键的，只记录：

- `Glass.liquidDockIndicatorFill` 暗色 `0.10`、亮色 `0.08`（`one/glass.dart:154-155`）。底栏在 `one/ultra_glass_dock.dart:286` 调用。A3 排除名单是 `blurredBarFill` / `liquidFill` / `liquidDockFill`，没有这一个。`resolved` 下没有对应键。
- 指示条行程填充暗色 `0.14`、亮色 `0.10`（`one/ultra_glass_dock.dart:288-289`）。`0.14` 与 P2 第 10 条同值，键是 `shadowColor`；`0.10` 与上一条同值。没有单独的夹具键。
- 高光系数 `0.85`（`one/ultra_glass_dock.dart:310`）和外框描边 `1.25`（同文件第 329 行，即第 8 条）不在 dock 段的键里。

## MA-2：同一套洗牌的下一段

方法与 P2 相同：四个 Dart 文件、三类候选、按值去重、种子 `20261112`、glibc 风格 LCG（取 31 位状态本身，不右移 16 位）、从末尾向前的 Fisher-Yates。候选池 104。`opacity: 0.85 * travel`（`one/ultra_glass_dock.dart:310`）按「`opacity:` 后面的数值字面量」收进池子。

先用这套洗牌对封存表：前 40 条的值和次序与 `fixture-cross-audit.md` 第 23–62 行一致。然后取第 41–80 条。这 40 个值与 P2 那 40 个不重复。

结果：一致 32，在另一份夹具 1，未收录 7。没有同一键两边数值不同。

| # | 源码 | 值 | 归宿 |
|---:|---|---|---|
| 41 | `one/one_palette.dart:70` `oneBlackWhiteLight.onInverseSurface` | `0xFFF0F0F7` | 一致。`tokens.json:49` `schemes.oneBlackWhiteLight.onInverseSurface` `FFF0F0F7`。 |
| 42 | `one/glass.dart:73` `Glass.space20` | `20` | 一致。`tokens.json:125` `glass.space20` `20.0`。 |
| 43 | `one/one_palette.dart:64` `oneBlackWhiteLight.onSurfaceVariant` | `0xFF44474F` | 一致。`tokens.json:43`。后出现的同值是暗色 `outlineVariant`（源码 `one_palette.dart:105`，`tokens.json:97`）。 |
| 44 | `one/glass.dart:126` `fillStrong` 暗色 alpha | `0.62` | 一致。`tokens.json:227` `resolved.dark.fillStrong.alpha` `0.6200`。 |
| 45 | `one/glass.dart:44` `Glass.dockHeight` | `56` | 一致。`tokens.json:113` `glass.dockHeight` `56.0`，`layout.json:13` `dock.height` `56.0`。 |
| 46 | `one/one_palette.dart:46` `oneBlackWhiteLight.onSecondaryContainer` | `0xFF141B2C` | 一致。`tokens.json:16`。 |
| 47 | `one/ultra_glass_dock.dart:354` 亮色描边 `[2]` | `0x52FFFFFF` | 未收录。画家颜色，合同同第 1 条。五份夹具都没有这个色。 |
| 48 | `one/glass.dart:60` `Glass.dockIndicatorHeight` | `48` | 一致。`tokens.json:118` `glass.dockIndicatorHeight` `48.0`，`layout.json:18` `dock.indicatorHeight` `48.0`。 |
| 49 | `one/one_palette.dart:83` `oneBlackWhiteDark.onSecondary` | `0xFF2A3042` | 一致。`tokens.json:66`。`tokens.json:71-72` 的 `onSecondaryFixed` / `onSecondaryFixedVariant` 是回退成同一色。 |
| 50 | `one/glass.dart:69` `Glass.space6` | `6` | 一致。`tokens.json:121` `glass.space6` `6.0`。同值的另一键是 `tokens.json:170` 投影 `blurRadius` 6.0，源码 `one/glass.dart:256`，非 const blur。 |
| 51 | `one/glass.dart:103` `Glass.strokeWidth` | `0.8` | 一致。`tokens.json:134` `glass.strokeWidth` `0.8`。 |
| 52 | `one/ultra_glass_dock.dart:347` 暗色描边 `[0]` | `0x8CFFFFFF` | 未收录。同第 47 条。前缀相近的另一键是 `tokens.json:142` `resolved.light.fill.argb` `8CF9F9FF`。 |
| 53 | `one/one_palette.dart:69` `oneBlackWhiteLight.inverseSurface` | `0xFF2F3036` | 一致。`tokens.json:48`。后出现的同值是暗色 `onInverseSurface`（源码 `one_palette.dart:109`，`tokens.json:101`）。 |
| 54 | `one/ultra_glass_dock.dart:383` `_darkHighlight[0]` | `0x3DFFFFFF` | 未收录。同第 47 条。 |
| 55 | `one/glass.dart:118` `fill` 亮色 alpha | `0.55` | 一致。`tokens.json:143` `resolved.light.fill.alpha` `0.5500`。描边混色里的 `0.55` 在 `one/glass.dart:232`，与这条同值所以去重；解析结果是 `tokens.json:163` 的 `0.5950`。 |
| 56 | `one/glass.dart:149` `liquidDockFill` 暗色 alpha | `0.06` | 未收录。A3 不进五种填充（`lane-A-notes.md:74`）。底栏 `one/ultra_glass_dock.dart:99` 仍调用。夹具无 `0.0600`。 |
| 57 | `one/one_palette.dart:94` `oneBlackWhiteDark.surface` | `0xFF111318` | 一致。`tokens.json:85`。`tokens.json:275` `resolved.dark.backdrop.bottom` 同色，因为中性暗色底端用的就是 `surface`（`one/glass.dart:289`）。后出现的同值字面量是 `one_palette.dart:96` `surfaceDim`。 |
| 58 | `one/one_palette.dart:80` `oneBlackWhiteDark.primaryContainer` | `0xFF2B2930` | 一致。`tokens.json:59`。 |
| 59 | `one/glass.dart:67` `Glass.space2` | `2` | 一致。`tokens.json:119` `glass.space2` `2.0`。同值的另一键是 `tokens.json:172` 投影 `offsetY` 2.0，源码 `one/glass.dart:257`。 |
| 60 | `one/one_palette.dart:104` `oneBlackWhiteDark.outline` | `0xFF8E9099` | 一致。`tokens.json:96`。后出现的同值是 `surfaceTint`（源码 `one_palette.dart:111`，`tokens.json:103`）。 |
| 61 | `one/glass.dart:117` `fill` 暗色 alpha | `0.22` | 一致。`tokens.json:223` `resolved.dark.fill.alpha` `0.2200`。 |
| 62 | `one/one_palette.dart:53` `oneBlackWhiteLight.errorContainer` | `0xFFF9DEDC` | 一致。`tokens.json:31`。 |
| 63 | `one/one_palette.dart:90` `oneBlackWhiteDark.error` | `0xFFFFB4AB` | 一致。`tokens.json:81`。 |
| 64 | `one/one_palette.dart:89` `oneBlackWhiteDark.onTertiaryContainer` | `0xFFE5E1E6` | 一致。`tokens.json:76`。 |
| 65 | `one/glass.dart:38` `Glass.radiusHero`（`radiusCard + 4`） | `22` | 一致。`tokens.json:112` `glass.radiusHero` `22.0`。后出现的同值是 `tokens/one_tokens.dart:68` `OneSizes.icon`。 |
| 66 | `one/ultra_glass_dock.dart:310` 指示条高光 `opacity: 0.85 * travel` | `0.85` | 未收录。dock 段合同没有这个系数。夹具无 `0.85`。 |
| 67 | `one/glass.dart:246` `Glass.shadow` 暗色 strong alpha | `0.32` | 一致。`tokens.json:259` `resolved.dark.shadow.strong[0].alpha` `0.3200`。 |
| 68 | `one/glass.dart:222` `Glass.dialogAlpha` | `0.88` | 一致。`tokens.json:137` `glass.dialogAlpha` `0.88`；`tokens.json:159` 与 `:239` 的 `dialogFill.alpha` 都是 `0.8800`。 |
| 69 | `one/glass.dart:101` `Glass.liquidRefraction` | `0.04` | 一致。`tokens.json:133` `glass.liquidRefraction` `0.04`。 |
| 70 | `one/one_palette.dart:99` `oneBlackWhiteDark.surfaceContainerLow` | `0xFF191C20` | 一致。`tokens.json:91`。 |
| 71 | `one/glass.dart:438` `dividerTheme` 亮色 alpha | `0.65` | 未收录。T1.4 不含分割线。`tokens.json` 无 `0.6500`。 |
| 72 | `one/glass.dart:438` `dividerTheme` 暗色 alpha | `0.45` | 未收录。同上。停点 `0.45` 在 `one/ultra_glass_dock.dart:356`，同值后出现；规则不收 stop。 |
| 73 | `one/one_palette.dart:85` `oneBlackWhiteDark.onSecondaryContainer` | `0xFFE4E7F6` | 一致。`tokens.json:68`。 |
| 74 | `one/one_palette.dart:55` `oneBlackWhiteLight.surface` | `0xFFF9F9FF` | 一致。`tokens.json:33`。后出现的同值还有 `surfaceBright`（源码 `one_palette.dart:58`，`tokens.json:37`）、`surfaceVariant`（`tokens.json:35`）、`background`（`tokens.json:52`）。 |
| 75 | `one/glass.dart:126` `fillStrong` 亮色 alpha | `0.72` | 一致。`tokens.json:147` `resolved.light.fillStrong.alpha` `0.7200`。 |
| 76 | `one/glass.dart:48` `Glass.radiusDock`（`dockHeight / 2`） | `28` | 一致。`tokens.json:114` `glass.radiusDock` `28.0`，`layout.json:14` `dock.radius` `28.0`。 |
| 77 | `one/glass.dart:246` `Glass.shadow` 暗色 normal alpha | `0.28` | 一致。`tokens.json:249` `resolved.dark.shadow.normal[0].alpha` `0.2800`。 |
| 78 | `tokens/one_tokens.dart:65` `OneSizes.minimumTarget` | `44` | 在另一份夹具。`tokens.json` 没有这个键。`ripple.json:51-53` `referenceBox` 宽高 `44.0`，`source` 为 `OneSizes.minimumTarget`。同值的另一键是 `typography.json:25` 与 `:147` `displaySmall.measuredHeight` `44.0`。 |
| 79 | `one/glass.dart:57` `Glass.dockTabInset` | `4` | 一致。`tokens.json:117` `glass.dockTabInset` `4.0`，`layout.json:17` `dock.tabInset` `4.0`。后出现的同值是 `tokens.json:120` `glass.space4`，源码 `one/glass.dart:68`。 |
| 80 | `one/one_palette.dart:62` `oneBlackWhiteLight.surfaceContainerHigh` | `0xFFE7E8EE` | 一致。`tokens.json:41`。 |

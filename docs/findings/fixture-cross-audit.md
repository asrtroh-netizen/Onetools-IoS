# 夹具交叉审计（盲读阶段：尚未打开 `_golden/fixtures`）

本节写入时，审计人只读过下列四个 Dart 文件，**没有**打开 `Onetools-IoS/_golden/fixtures/` 下任何文件，也**没有**打开 `OneUI/Sources/OneUICore/Tokens/`。下表 40 条是从源码独立抽取的数值，此时尚未与夹具对照。

源码根目录：`ONEWIFIX/IOS/lib/design/`。

## 抽取规则

- 种子：`20261112`
- 候选池只收这三类，且不读注释：
  1. 具名 `const` / `static const` 的 `double` 或 `int`。初值若是同一作用域里已解析常量的一步四则（`+ - * /`），记求值后的数值。
  2. 任何 `Color(0x…)` 字面量（按 32 位 ARGB 整数去重）。
  3. `alpha:` 与 `opacity:` 后面的数值字面量（三元两侧都收）。
- 不收：注释里的数、`fontWeight`、`elevation`、非 const 的 blur/偏移/stop/icon size，以及只指向别的常量的别名（别名不引入新数值）。
- 去重：文件顺序 `one/glass.dart` → `one/one_palette.dart` → `tokens/one_tokens.dart` → `one/ultra_glass_dock.dart`，同行从左到右，规范数值只留第一次出现。颜色规范为 `0x` + 8 位大写十六进制；整数浮点收成整数；其余浮点去掉尾随 0。因 `0.60` 与 `0.6` 同值；`Glass.radiusHero` 求值 22 会占掉后来的 `OneSizes.icon = 22`。
- 洗牌：glibc 风格 LCG，`state = seed & 0x7FFFFFFF`（若为 0 则取 1），迭代 `state = (1103515245 * state + 12345) & 0x7FFFFFFF`。对去重后的候选做 Fisher-Yates（从末尾向前，`j = next() % (i + 1)`），取洗牌结果的前 40 个。
- 本次去重后候选池大小：104。

## 盲读 40 条（对照前封存）

| # | 文件 | 行号 | 名字 | 源码读到的值 |
|---:|---|---:|---|---|
| 1 | `one/ultra_glass_dock.dart` | 392 | `_GlassRRectHighlightPainter._lightHighlight[1]` | `0x14FFFFFF` |
| 2 | `one/glass.dart` | 31 | `Glass.radiusChip` | `10` |
| 3 | `one/one_palette.dart` | 51 | `oneBlackWhiteLight.error` | `0xFFBA1A1A` |
| 4 | `one/one_palette.dart` | 47 | `oneBlackWhiteLight.tertiary` | `0xFF5F5E62` |
| 5 | `one/one_palette.dart` | 100 | `oneBlackWhiteDark.surfaceContainer` | `0xFF1D2024` |
| 6 | `one/one_palette.dart` | 65 | `oneBlackWhiteLight.outline` | `0xFF74777F` |
| 7 | `one/glass.dart` | 72 | `Glass.space16` | `16` |
| 8 | `one/ultra_glass_dock.dart` | 329 | `DockRimHighlightPainter._strokeWidth` | `1.25` |
| 9 | `one/glass.dart` | 141 | `Glass.blurredBarFill` 暗色 alpha | `0.34` |
| 10 | `one/glass.dart` | 361 | `Glass.apply` shadowColor 暗色 alpha | `0.14` |
| 11 | `one/ultra_glass_dock.dart` | 384 | `_GlassRRectHighlightPainter._darkHighlight[1]` | `0x0FFFFFFF` |
| 12 | `one/one_palette.dart` | 45 | `oneBlackWhiteLight.secondaryContainer` | `0xFFE8E8EF` |
| 13 | `one/ultra_glass_dock.dart` | 352 | `DockRimHighlightPainter` 亮色描边 `[0]` | `0xB8FFFFFF` |
| 14 | `tokens/one_tokens.dart` | 66 | `OneSizes.control` | `52` |
| 15 | `one/one_palette.dart` | 63 | `oneBlackWhiteLight.surfaceContainerHighest` | `0xFFE2E2E9` |
| 16 | `one/ultra_glass_dock.dart` | 386 | `_GlassRRectHighlightPainter._darkHighlight[3]` | `0x0AFFFFFF` |
| 17 | `one/glass.dart` | 111 | `Glass.modalAlpha` | `0.92` |
| 18 | `tokens/one_tokens.dart` | 20 | `OneColors.transparent` | `0x00000000` |
| 19 | `one/one_palette.dart` | 92 | `oneBlackWhiteDark.errorContainer` | `0xFF93000A` |
| 20 | `one/one_palette.dart` | 82 | `oneBlackWhiteDark.secondary` | `0xFFC8C5D0` |
| 21 | `one/one_palette.dart` | 41 | `oneBlackWhiteLight.primaryContainer` | `0xFFF0F0F4` |
| 22 | `one/ultra_glass_dock.dart` | 391 | `_GlassRRectHighlightPainter._lightHighlight[0]` | `0x66FFFFFF` |
| 23 | `one/one_palette.dart` | 98 | `oneBlackWhiteDark.surfaceContainerLowest` | `0xFF0C0E13` |
| 24 | `one/glass.dart` | 149 | `Glass.liquidDockFill` 亮色 alpha | `0.12` |
| 25 | `one/glass.dart` | 25 | `Glass.radiusCard` | `18` |
| 26 | `one/one_palette.dart` | 66 | `oneBlackWhiteLight.outlineVariant` | `0xFFC4C6D0` |
| 27 | `one/one_palette.dart` | 101 | `oneBlackWhiteDark.surfaceContainerHigh` | `0xFF282A2F` |
| 28 | `one/one_palette.dart` | 61 | `oneBlackWhiteLight.surfaceContainer` | `0xFFEDEDF4` |
| 29 | `one/glass.dart` | 182 | `Glass.liquidHighlight` 亮色顶边 alpha | `0.38` |
| 30 | `one/ultra_glass_dock.dart` | 349 | `DockRimHighlightPainter` 暗色描边 `[2]` | `0x47FFFFFF` |
| 31 | `one/ultra_glass_dock.dart` | 348 | `DockRimHighlightPainter` 暗色描边 `[1]` | `0x1AFFFFFF` |
| 32 | `one/one_palette.dart` | 84 | `oneBlackWhiteDark.secondaryContainer` | `0xFF3F4759` |
| 33 | `one/ultra_glass_dock.dart` | 34 | `_GlassDockState._slideDuration` 毫秒 | `480` |
| 34 | `one/glass.dart` | 299 | `Glass.backdrop` tertiary 亮色 alpha | `0.03` |
| 35 | `one/glass.dart` | 184 | `Glass.liquidHighlight` 亮色底边 alpha | `0.05` |
| 36 | `one/one_palette.dart` | 88 | `oneBlackWhiteDark.tertiaryContainer` | `0xFF48464C` |
| 37 | `one/one_palette.dart` | 50 | `oneBlackWhiteLight.onTertiaryContainer` | `0xFF1B1B1F` |
| 38 | `one/one_palette.dart` | 54 | `oneBlackWhiteLight.onErrorContainer` | `0xFF410E0B` |
| 39 | `one/glass.dart` | 51 | `Glass.dockBottomGap` | `8` |
| 40 | `one/one_palette.dart` | 102 | `oneBlackWhiteDark.surfaceContainerHighest` | `0xFF33353A` |

## 对照（写完上表之后才打开 `_golden/fixtures/tokens.json`）

上表未改。颜色去掉 `0x` 后与夹具的 8 位 ARGB 比较。浮点按数值相等（`16` 与 `16.0`、`0.92` 与 `0.9200` 算同一值）。按这一条的名字对键；夹具没有该键就记未收录，不把别的键上的相同数字算成这一条命中。未改夹具。

结果：一致 23，不一致 17。不一致的 17 条都是夹具没有对应键。没有同一键两边数值不同。这 17 条是夹具未收录，不是源码把数写反。

### 一致

| # | 夹具键 | 夹具值 |
|---:|---|---|
| 2 | `glass.radiusChip` | `10.0` |
| 3 | `schemes.oneBlackWhiteLight.error` | `FFBA1A1A` |
| 4 | `schemes.oneBlackWhiteLight.tertiary` | `FF5F5E62` |
| 5 | `schemes.oneBlackWhiteDark.surfaceContainer` | `FF1D2024` |
| 6 | `schemes.oneBlackWhiteLight.outline` | `FF74777F` |
| 7 | `glass.space16` | `16.0` |
| 12 | `schemes.oneBlackWhiteLight.secondaryContainer` | `FFE8E8EF` |
| 15 | `schemes.oneBlackWhiteLight.surfaceContainerHighest` | `FFE2E2E9` |
| 17 | `glass.modalAlpha` | `0.92`（`resolved.light.modalFill.alpha` 与 `resolved.dark.modalFill.alpha` 同为 `0.9200`） |
| 19 | `schemes.oneBlackWhiteDark.errorContainer` | `FF93000A` |
| 20 | `schemes.oneBlackWhiteDark.secondary` | `FFC8C5D0` |
| 21 | `schemes.oneBlackWhiteLight.primaryContainer` | `FFF0F0F4` |
| 23 | `schemes.oneBlackWhiteDark.surfaceContainerLowest` | `FF0C0E13` |
| 25 | `glass.radiusCard` | `18.0` |
| 26 | `schemes.oneBlackWhiteLight.outlineVariant` | `FFC4C6D0` |
| 27 | `schemes.oneBlackWhiteDark.surfaceContainerHigh` | `FF282A2F` |
| 28 | `schemes.oneBlackWhiteLight.surfaceContainer` | `FFEDEDF4` |
| 32 | `schemes.oneBlackWhiteDark.secondaryContainer` | `FF3F4759` |
| 36 | `schemes.oneBlackWhiteDark.tertiaryContainer` | `FF48464C` |
| 37 | `schemes.oneBlackWhiteLight.onTertiaryContainer` | `FF1B1B1F` |
| 38 | `schemes.oneBlackWhiteLight.onErrorContainer` | `FF410E0B` |
| 39 | `glass.dockBottomGap` | `8.0` |
| 40 | `schemes.oneBlackWhiteDark.surfaceContainerHighest` | `FF33353A` |

### 不一致

| # | 源码行 | 源码值 | 夹具值 | 哪一边错 |
|---:|---|---|---|---|
| 1 | `one/ultra_glass_dock.dart:392` | `0x14FFFFFF` | 无 | 夹具未收录底栏亮色高光。源码字面量仍是这个值。 |
| 8 | `one/ultra_glass_dock.dart:329` | `1.25` | 无 | 夹具未收录底栏描边宽。不要对到 `glass.strokeWidth`（`0.8`），那是 `glass.dart:103` 的另一常量，两边一致。 |
| 9 | `one/glass.dart:141` | `0.34` | 无 | 夹具未收录 `blurredBarFill`。线 A 备忘 A3 已写明这个函数不进五种填充。源码暗色 alpha 仍是 `0.34`。 |
| 10 | `one/glass.dart:361` | `0.14` | 无 | 夹具未收录主题卡 `shadowColor`。`resolved.dark.shadow` 的 `0.2800` / `0.3200` 对的是 `Glass.shadow` 暗色（`glass.dart:246`），不是这一行。 |
| 11 | `one/ultra_glass_dock.dart:384` | `0x0FFFFFFF` | 无 | 夹具未收录指示条暗色高光。 |
| 13 | `one/ultra_glass_dock.dart:352` | `0xB8FFFFFF` | 无 | 夹具未收录底栏亮色描边。`resolved.light.fillStrong.argb` 是 `B8F3F3FA`，不是这个色。 |
| 14 | `tokens/one_tokens.dart:66` | `52` | 无 | 夹具没有 `OneSizes`。 |
| 16 | `one/ultra_glass_dock.dart:386` | `0x0AFFFFFF` | 无 | 夹具未收录指示条暗色高光。 |
| 18 | `tokens/one_tokens.dart:20` | `0x00000000` | 无 | 夹具没有 `OneColors.transparent`。 |
| 22 | `one/ultra_glass_dock.dart:391` | `0x66FFFFFF` | 无 | 夹具未收录指示条亮色高光。 |
| 24 | `one/glass.dart:149` | `0.12` | 无 | 夹具未收录 `liquidDockFill`（A3 不进五种填充）。`resolved.dark.stroke.alpha` 的 `0.1200` 对的是 `glass.dart:230` 暗色描边，不是这一行的亮色底栏填充。 |
| 29 | `one/glass.dart:182` | `0.38` | 无 | 夹具未收录 `liquidHighlight`。 |
| 30 | `one/ultra_glass_dock.dart:349` | `0x47FFFFFF` | 无 | 夹具未收录底栏暗色描边。`resolved.dark.shadow.normal[0].argb` 是 `47000000`（黑），不是白。 |
| 31 | `one/ultra_glass_dock.dart:348` | `0x1AFFFFFF` | 无 | 夹具未收录底栏暗色描边。`resolved.light.shadow.strong[0].argb` 是 `1A000000`（黑），不是白。 |
| 33 | `one/ultra_glass_dock.dart:34` | `480` | 无 | 夹具没有底栏滑动毫秒。 |
| 34 | `one/glass.dart:299` | `0.03` | 无 | 夹具未收录非中性混色 alpha。`resolved.light.backdrop` 走中性分支，底色 `FFEDEDF4`、alpha `1.0000`，与源码 `isNeutralAccent` 路径相符，不是把 `0.03` 算错。 |
| 35 | `one/glass.dart:184` | `0.05` | 无 | 夹具未收录该字面量。暗色 `resolved.dark.backdrop` 顶 `FF282A2F`、底 `FF111318`、alpha `1.0000`，同样是中性分支，不是 `0.05` 混色。 |

## 主代理复核（2026-11-12 04:19）

按表中行号重读源码，字面量与盲读表一致。抽查包括 `glass.dart` 第 182 行 `0.38`、第 184 行 `0.05`、第 299 行 `0.03`，`ultra_glass_dock.dart` 第 34 行 `480`，第 348–392 行的颜色字面量。`tokens.json` 里抽查的 12 个一致键数值相同。`OneSizes`、`liquidDockFill`、`blurredBarFill`、`liquidHighlight`、`slideMs` 都不在 `tokens.json`。

第 33 条的 480 毫秒在 `layout.json` 的 `dock.slideMs`，值是 `480.0`。本次对照范围是 `tokens.json`，所以对这一份夹具仍算未收录，不是滑动时长写错。

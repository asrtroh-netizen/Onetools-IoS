# 参考源

- Flutter 3.44.9
- 框架 `6b182d2c7585eba26d4edce0f97630effd256c33`
- 引擎 `5a2a6a42cce67f965cf540fcecf616faca624aa1`
- Skia `e9ed4fc9f1544c58d8a9347c1fc9471d8dd7c465`

Material 源码快照在 `_ref/flutter-3.44.9/material/`，从 `C:\Flutter\flutter\packages\flutter\lib\src\material\` 整目录复制。R0-8 验收时两边都是 200 个文件。

OneWIFI 图标清单在 `_ref/ow_icons.txt`，121 行，来自对 `E:\GQ\Ultra\ONEWIFIX\IOS\lib` 做 `Icons.[a-z0-9_]+` 抽取后去重。

## 合成加粗（C1，FakeBold / Embolden）

四个文件的 git blob 与提交 `e9ed4fc9f1544c58d8a9347c1fc9471d8dd7c465` 一致。2026-11-12 用 GitHub contents API 的 sha 对照本地 `git hash-object`（文件先把 CRLF 归一成 LF）。

- `src/core/SkScalerContext.cpp` `85edc26a3f7930ec9ffff752141ffacb881e7e23`
- `src/core/SkFontPriv.h` `c369533abe520093b235b5cc22819fad8e3ac701`
- `src/core/SkTextFormatParams.h` `9fd80330e00d39c94b30e08ae7f1ffe30191f2a7`
- `modules/skparagraph/src/OneLineShaper.cpp` `d36dfd86cb2ecd82883118d7717f0f9de1b776b3`

结论：一致。交接文档 §3.3.2 的 9 到 36、1/24 到 1/32 在 `src/core/SkTextFormatParams.h` 第 15–25 行：9 point 及以下描边增加 text size/24，36 point 及以上增加 text size/32，中间插值。键是 `SK_Scalar1*9` 与 `SK_Scalar1*36`（19–21 行），值是 `SK_Scalar1/24` 与 `SK_Scalar1/32`（23–25 行）。`SkScalerContext.cpp` 第 41 行包含这个头文件；1017–1027 行在 `kEmbolden_Flag` 置位时用这两张表算出 `extra = fTextSize * fakeBoldScale`，1029–1033 行把 extra 加进描边宽度；1125–1126 行在 `font.isEmbolden()` 时置该标志。`SkFontPriv.h` 第 58 行只说明 `GetFontBounds` 不算 fake bold。`OneLineShaper.cpp` 671–677 行在 `fakeMissingFontStyles()` 为真时，字重不低于 `kSemiBold_Weight` 且比当前字面重至少 200 就 `font.setEmbolden(true)`。三个最初点名的文件里没有 9、36、1/24、1/32 这些字面量，它们在被包含的头文件里。

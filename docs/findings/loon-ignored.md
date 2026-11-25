# M7 Loon 插件解析与兼容核对清单

- 日期：2026-11-25
- 校验基准：`Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleParser.swift`（经 `test_citations_match_parser_lines` 在 macOS CI 逐行对齐核验）与 `ClashiOS` 完整编译打包验证。

## 1. 自有插件与公开样本核对结果

| 文件 | 保守子集结论 | 非保守子集条目 / 说明 |
|---|---|---|
| `adblock/onetools-cn-ads.plugin` | **PASS（0 忽略行）** | 12 条国内广告 SDK 规则（覆盖 8 家 SDK）全部位于 `Clash-Client` `ModuleParser` 原生 `[Rule]` 保守子集内，并已随包打入 `OneTools-ClashiOS-unsigned.ipa` 资源目录 |
| `adblock/samples/XWebAds.plugin` | **PASS（0 忽略行）** | 全部规则与重写行均被标准子集接收 |
| `adblock/samples/WeChatMiniAds.plugin` | **2 行响应体 JSON 重写** | 第 288、289 行使用 `response-body-json-del`（`data` / `data[0] data[1] data[2]`）；保守静态 linter 标记为扩展重写，`Clash-Client`（`e3e6472`）内置 `ModuleJSONRewriteSyntax` 已提供专门解析分支 |
| `adblock/samples/weibo.plugin` | **2 行响应体 JQ 重写** | 第 72、93 行使用 `response-body-json-jq`（`del(.data.banner)` / `del(.items[] \| select(.category == "group"))`）；保守静态 linter 标记为扩展重写，`Clash-Client`（`e3e6472`）内置 `ModuleJQ` 引擎支持 JQ 表达式重写 |

## 2. 结论

- 自有内置规则 `adblock/onetools-cn-ads.plugin` **零语法丢弃、零外部策略名依赖**，无需开启 MITM 即可在网络层直接生效。
- 第三方大型去广告插件（如 `weibo.plugin`、`WeChatMiniAds.plugin`）仅在涉及 HTTPS 响应体 JSON 裁剪（`response-body-json-del` / `response-body-json-jq`）时依赖用户手动生成并信任本地 MITM CA 证书。

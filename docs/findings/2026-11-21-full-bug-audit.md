# 全仓 BUG 审计报告（2026-11-21）

## 已修复

- `ClashTunnelRouteShaping.loopbackAddresses` 现在会忽略地址两端的空白并按不区分大小写的方式判断 `10.7.0.1`，避免订阅配置重复写入环回地址。
- `RuntimeBuildStages.swiptLoopback` 与 `ConfigTransforms.applyClientRuntimePolicy*` 的默认值统一为开启，首次安装且 App Group 尚未写入开关时仍会注入 `10.7.0.1`。
- Clash 环回源文件与测试已通过 `tools/sync_harness.py --check` 保持逐字节一致。
- `SigningLogic` 的到期提醒覆盖了跨夏令时日期、重复 ID 中过期项与有效项并存的边界。批次结果类型补充 `Sendable`，空本地化错误描述会回退到系统描述。
- `REPORT.md` 与 `STATE.md` 中遗留的图标夹具阻塞描述已标注为历史记录，门禁数量统一为 21 项。
- 主代理终审补齐（消除上 Mac 编译/运行隐患与 5 项遗留视觉缺口）：
  - 补齐 `OnePalette.accent` 公开属性与 `View.inkRipple(overlayColor:enabled:)` 重载，消除跨文件参数标签编译错误；将 `InkRipple` 手势改为 `simultaneousGesture` 防止吞噬内层 `Button` 点击。
  - 将 `MaterialIcon` 字体名修正为字体表真实 PostScript 名 `MaterialIcons-Regular`（并将 `eye`/`eye_slash` 映射至内置可见性字形），替换 `OneGallery` 中 4 个不在 121 码点目录内的示例图标名。
  - 完成 `OneStyledText`（CoreText 负 `strokeWidth` `w600`/`w700` 合成加粗 + `1.219em` 行高均分）、`UltraGlassDock` 480ms 非对称液态跨越指示条与中性高光描边及软键盘自动收起、`OneMark` 双圆差并精确几何、`ChoiceChips` iOS 15 折行回退、`CABackdropLayer + CAFilter(gaussianBlur)` 运行时绑定、`OneGlassDialog` / `OneGlassPopupFrame` 超椭圆 `style: .continuous` 材质对齐。

## 验证结果

- WSL Ubuntu 24.04 Swift 6.4.2：`SigningLogic` 15 项测试通过。
- WSL Ubuntu 24.04 Swift 6.4.2：`_harness/ClashLogic` 6 项测试通过。
- `python tools/sync_harness.py --check` 通过。
- `scripts/mac/*.sh` 全部 `bash -n` 通过。
- `python tools/check_ad_coverage.py` 通过。12 条 Loon 规则均为精确域名或受限后缀，未发现覆盖微信、抖音、淘宝通用 CDN 或登录域名的宽泛正则。

## 待 Mac 阶段验证

- Clash/ClashtvOS 的完整 Xcode 编译、NetworkExtension 运行态与解析器测试仍需 Apple SDK。
- `onetools://onewifi` URL Scheme 尚未在宿主工程完成注册与实机拉起验证。
- 许可证兼容性仍需结合 Mac 工程最终链接产物复核，尤其是第三方内核、签名工具与 App Store 分发条款。

## 备注

- 未运行 `git submodule update`，未调用 Windows 原生 `swift.exe`，未修改 `ONEWIFIX/IOS` 工作区，未修改 `_golden/goldens/`，未执行 `git push`。

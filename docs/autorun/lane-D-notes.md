# 线 D 备忘

## D1

已验证。`rules.ts` 在 `Swiplets/skip-chinese-ads/src/rules.ts`（只读），`const sdk = {` 的键是 21 个。清单 `adblock/sdk-list.json` 的 `count` 由脚本每次重数，没有写死。

先红：测试写好时还没有 `tools/export_ad_sdks.py`，`python -m pytest tools/test_export_ad_sdks.py -q` 为 2 failed（2 passed），失败行是找不到该脚本。实现后 4 passed。自查把键循环改成 `keys[:-1]`，同一命令变成 2 failed（真实清单缺 `xhLaunchAd`，夹具缺 `gamma`），改回后再次 4 passed。关键行：`4 passed`，`sdk_count=21`。

## D2

已落盘 5 个样本，见 `adblock/samples/SOURCES.md`。哈希检查先红：没有 `check_samples.py` 时测试失败；实现被改成总是报 MISMATCH 时，错哈希没失败、对哈希反而失败；改回后临时假样本两个测试通过。

挑法：仓库近 30 天有推送且 star 高。`limbopro/Adblock4limbo`（star 4575，推送 2026-11-03）覆盖视频贴片；`fmz200/wool_scripts`（star 5952，推送 2026-11-11）的微博插件覆盖开屏和信息流，微信小程序插件再覆盖一家开屏，X 网页插件覆盖信息流。许可用限流前仓库接口的 SPDX：MIT 与 GPL-3.0。

拿不准（计划 5.5，最保守）：核心接口剩余 0，重置时刻 `2026-11-11T17:03:37Z`（还有约 47 分钟）。不等待，不走 raw.githubusercontent.com，不改 hosts，不用别的镜像。已经下到的 5 个文件作为本次样本。单文件提交早于 30 天的，在 SOURCES.md 的 why 里写明，不把仓库推送时间说成文件更新时间。

同一 URL 失败两次后换下一个，不再试：

- `https://api.github.com/repos/blackmatrix7/ios_rule_script/contents/rule/Loon/Advertising/Advertising.list` 两次 HTTP 403（此时尚未看到限流正文）。
- `https://api.github.com/repos/blackmatrix7/ios_rule_script/contents/rule/Loon/Advertising/Advertising_MITM.plugin` 两次 HTTP 403。
- `https://api.github.com/repos/Repcz/Tool/contents/Loon/Rules/Ads_AWAvenue.list` 两次 HTTP 403。
- 随后 `GET https://api.github.com/rate_limit` 显示 core remaining=0，used=60，reset=1794416617。下面四个同样两次 HTTP 403，响应体是 API rate limit exceeded：
  - `https://api.github.com/repos/fmz200/wool_scripts/contents/Loon/plugin/blockAds.plugin`
  - `https://api.github.com/repos/fmz200/wool_scripts/contents/Loon/rule/rejectAd.list`
  - `https://api.github.com/repos/limbopro/Adblock4limbo/contents/YouTubeAds.module`
  - `https://api.github.com/repos/217heidai/adblockfilters/contents/rules/adblockloonlite.list`

更早一次用 Python urllib 读大响应体，`IncompleteRead(598765 bytes read, 36368 more expected)`。同一做法不再用，改为 `curl.exe --noproxy *`。

## 未做

D3、D4 不在本次范围。没有写 `docs/findings/ad-sdk-domains.md`，没有改 Clash-Client，没有 git 写操作。

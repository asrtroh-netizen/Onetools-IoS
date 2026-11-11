# Loon 样本来源

抓取走 `https://api.github.com/repos/<owner>/<repo>/contents/<path>`，请求头 `Accept: application/vnd.github.raw`。未使用 raw.githubusercontent.com。下载文件只存储，没有执行。

挑法（计划 2.2）：公开仓库近 30 天有推送、被引用多（star / fork），并覆盖开屏广告、信息流广告、视频贴片。仓库元数据来自限流前的仓库接口（2026-11-11）。许可取该接口的 `license.spdx_id`：`limbopro/Adblock4limbo` 为 MIT（LICENSE 约 1069 字节），`fmz200/wool_scripts` 为 GPL-3.0（LICENSE 约 35149 字节）。核心接口随后返回 403，没有再下 LICENSE 正文。

仓库：

- `limbopro/Adblock4limbo`：star 4575，fork 242，推送 `2026-11-03T02:03:57Z`，MIT。说明里写明供 Quantumult X、Surge、Shadowrocket、Loon 使用。
- `fmz200/wool_scripts`：star 5952，fork 328，推送 `2026-11-11T14:06:43Z`，GPL-3.0。仓库含 Loon 插件目录。

`fmz200/wool_scripts` 里 2026-11-11 当天更新的 `Loon/plugin/blockAds.plugin` 没有下到，见 `docs/autorun/lane-D-notes.md`。下面三个插件的单文件提交早于 30 天，但所在仓库在 30 天内有推送，并且正文对得上三类广告。

<!-- sample -->
file: youtube-ads.sgmodule
url: https://api.github.com/repos/limbopro/Adblock4limbo/contents/YouTubeAds.sgmodule
fetched: 2026-11-11
sha256: d0902612cfcfd2fb3f80e17aeacb0b088a62808442809c355bc68af1e0dfaba3
license: MIT
covers: 视频贴片
why: Adblock4limbo 近 30 天有推送且 star 4575。该文件第 17 行用 Map Local 把 googlevideo 的 initplayback 且带 oad 的请求置空，这是 YouTube 视频广告播放地址。同仓库的 YouTubeAds.module 在限流后两次 403，未收入。此文件是 Surge sgmodule 写法，仓库同时面向 Loon。
<!-- /sample -->

<!-- sample -->
file: adblock4limbo.list
url: https://api.github.com/repos/limbopro/Adblock4limbo/contents/Adblock4limbo.list
fetched: 2026-11-11
sha256: 5fec42de94e30ae0a27ae0528e7c3f88bac57ffab4f0d31f99ee73a299f54909
license: MIT
covers: 网页广告域名
why: 同一仓库。文件头写明 Last updated 3/11月/2026，接口记录该路径提交于 2026-11-03T02:03:51Z。内容是 DOMAIN-SUFFIX 拒绝列表，用来补一份近期更新的域名规则，不当开屏或贴片样本。
<!-- /sample -->

<!-- sample -->
file: weibo.plugin
url: https://api.github.com/repos/fmz200/wool_scripts/contents/Loon/plugin/weibo.plugin
fetched: 2026-11-11
sha256: 6fb8f00e4d2b02b347388c824ea5ae9621c3ac9777ec88ee6823776b48f66a0e
license: GPL-3.0
covers: 开屏广告、信息流广告
why: wool_scripts 仓库 2026-11-11 仍在推送，star 5952。插件正文写明微博开屏（biz.weibo.com、bootpreload、bootrealtime），并改写 friends_timeline 与 container_timeline，对应信息流。单文件提交是 2025-12-16T13:36:03Z，早于 30 天；当天更新的 blockAds.plugin 下载失败，改用这份已经下到的正文。
<!-- /sample -->

<!-- sample -->
file: WeChatMiniAds.plugin
url: https://api.github.com/repos/fmz200/wool_scripts/contents/Loon/plugin/WeChatMiniAds.plugin
fetched: 2026-11-11
sha256: f8ef8e7cfa747bbb4ed57f9752fc0544a1f08187b8f1a4dca58aa3a0543c50c7
license: GPL-3.0
covers: 开屏广告
why: 同一仓库的 Loon 插件。正文写明交通银行小程序开屏广告与中石油开屏广告。单文件提交是 2025-06-30T13:59:46Z。用它补一类小程序开屏，与微博开屏不是同一家。
<!-- /sample -->

<!-- sample -->
file: XWebAds.plugin
url: https://api.github.com/repos/fmz200/wool_scripts/contents/Loon/plugin/XWebAds.plugin
fetched: 2026-11-11
sha256: b6d218d58a709cd72559fbe9c6d5eed5e6e5e2f003e7329fc34c2477cf785649
license: GPL-3.0
covers: 信息流广告
why: 同一仓库的 Loon 插件。脚本匹配 HomeTimeline 与 HomeLatestTimeline，对应信息流广告。单文件提交是 2026-06-17T11:40:00Z。与微博信息流不是同一家。
<!-- /sample -->

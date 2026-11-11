# 广告 SDK 域名

一个域名要在两份互相独立的公开规则里作为规则目标出现才收。目标指 `DOMAIN` / `DOMAIN-SUFFIX` 逗号后的主机，或 Adblock 的 `||主机^`。父域名的后缀不算子域名又被点了一次名。大平台主域名和共用 CDN 不收。

用了四份，其中公开列表三份，加 D2 样本一份：

- `adblock/samples/adblock4limbo.list`：limbopro 自己的短名单。文件头把 EasyList China 算成另一份 5716 条的外部名单，不是这份 2.4 万字节的短名单。
- `adblock/lists/easylistchina.txt`：easylist/easylistchina。
- `adblock/lists/AWAvenue-Ads-Rule.txt`：TG-Twilight 秋风。说明里写自己是上游名单。
- `adblock/lists/ADgk.txt`：banbendalao。说明里写作为 EasyList China 的补充，作者不是 EasyList。

`adblock/lists/anti-ad-domains.txt` 不当来源。anti-AD 说明写明合并了 EasyList、ACL4SSR、秋风和 ADgk。`adblock/lists/acl4ssr-banad.list` 也不引用：再引就是第四份公开列表，而且没有 SDK 域名只靠它补上第二来源。五个 Loon 样本里只有这份 limbo 名单写了下面这些主机。

两份名单都用后缀形式（`DOMAIN-SUFFIX` 或 `||主机^`）时，插件用 `DOMAIN-SUFFIX`。只有一份是后缀、另一份是精确 `DOMAIN` 时，插件用精确 `DOMAIN`。

看见但不收：`baidu.com`、`qq.com`、`kuaishou.com`、`jd.com`、`toutiao.com`、`snssdk.com`、`yximgs.com`、`baidustatic.com`、`bcebos.com`、`gtimg.com`。`cpro.baidustatic.com` 在 EasyList 第 6140 行和秋风第 356 行，但它在百度静态 CDN 上，不收。`e.qq.com` 在 limbo 第 695 行和 ADgk 第 993 行，后缀会盖住整个腾讯广告站，比 SDK 主机宽，不收；优量汇用 `gdt.qq.com`。`trace.qq.com`、`adslvfile.qq.com` 也各在两份名单里，前者是通用追踪，后者是 qq.com 上的文件主机，不收。`pangolin-sdk-toutiao.com` 整域只在 limbo 第 487 行。`pglstatp-toutiao.com` 只在秋风。`js-ad.a.yximgs.com` 只在 limbo 第 580 行。

## adgain

status: no-rule
reason: 只有秋风第 953 行写出 xadsmartget.adgain.cn，没有第二份。

## baidu

status: ruled
note: 百度联盟广告主机。不收 baidu.com。

- domain: cpro.baidu.com
  rule: DOMAIN-SUFFIX,cpro.baidu.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:469
  - adblock/lists/easylistchina.txt:6139

- domain: pos.baidu.com
  rule: DOMAIN-SUFFIX,pos.baidu.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:470
  - adblock/lists/easylistchina.txt:6213
  - adblock/lists/AWAvenue-Ads-Rule.txt:690

- domain: mobads.baidu.com
  rule: DOMAIN-SUFFIX,mobads.baidu.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:474
  - adblock/lists/easylistchina.txt:6190
  - adblock/lists/AWAvenue-Ads-Rule.txt:602
  - adblock/lists/ADgk.txt:4490

- domain: als.baidu.com
  rule: DOMAIN-SUFFIX,als.baidu.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:472
  - adblock/lists/AWAvenue-Ads-Rule.txt:216
  - adblock/lists/ADgk.txt:5895

- domain: afd.baidu.com
  rule: DOMAIN,afd.baidu.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:471
  - adblock/lists/ADgk.txt:6247

- domain: mobads-logs.baidu.com
  rule: DOMAIN-SUFFIX,mobads-logs.baidu.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:475
  - adblock/lists/AWAvenue-Ads-Rule.txt:600
  - adblock/lists/ADgk.txt:4489

## beizi

status: no-rule
reason: 只有秋风写出 beizi.biz（第 294 行）、sdk.beizi.biz（第 743 行）和 api-htp.beizi.biz（第 251 行）。

## bytedance

status: ruled
note: limbo 把这组放在 ByteDance 段下。穿山甲、字节开屏和 Pangle 用的是名单里的 pangolin 主机，所以三个 id 共用这三条。不另收没有第二份的国际站。

- domain: pangolin-sdk-toutiao-b.com
  rule: DOMAIN-SUFFIX,pangolin-sdk-toutiao-b.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:488
  - adblock/lists/AWAvenue-Ads-Rule.txt:671
  - adblock/lists/ADgk.txt:557

- domain: pangolin.snssdk.com
  rule: DOMAIN,pangolin.snssdk.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:491
  - adblock/lists/ADgk.txt:796

- domain: log-api.pangolin-sdk-toutiao.com
  rule: DOMAIN-SUFFIX,log-api.pangolin-sdk-toutiao.com,REJECT
  sources:
  - adblock/lists/AWAvenue-Ads-Rule.txt:536
  - adblock/lists/ADgk.txt:561

## cjzf

status: no-rule
reason: 这四份名单和五个样本里都没有 CJZF 的广告域名。

## csj

status: ruled
note: 穿山甲就是 pangolin 这组主机，来源与 bytedance 相同。

- domain: pangolin-sdk-toutiao-b.com
  rule: DOMAIN-SUFFIX,pangolin-sdk-toutiao-b.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:488
  - adblock/lists/AWAvenue-Ads-Rule.txt:671
  - adblock/lists/ADgk.txt:557

- domain: pangolin.snssdk.com
  rule: DOMAIN,pangolin.snssdk.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:491
  - adblock/lists/ADgk.txt:796

- domain: log-api.pangolin-sdk-toutiao.com
  rule: DOMAIN-SUFFIX,log-api.pangolin-sdk-toutiao.com,REJECT
  sources:
  - adblock/lists/AWAvenue-Ads-Rule.txt:536
  - adblock/lists/ADgk.txt:561

## cxh

status: no-rule
reason: 这四份名单和五个样本里都没有 CXH 的广告域名。

## cxjs

status: no-rule
reason: 这四份名单和五个样本里都没有 CXJS 的广告域名。

## dcloud

status: no-rule
reason: EasyList 只有 dcloud.net.cn 的元素隐藏，不是域名规则。dcloud.net.cn 是 uni-app 主站，不收。没有第二份广告专用子域。

## flink

status: no-rule
reason: 这四份名单和五个样本里都没有 FLink 的广告域名。

## gdt

status: ruled
note: 优量汇 / 广点通。与 tencent 共用 gdt.qq.com。不收 qq.com。

- domain: gdt.qq.com
  rule: DOMAIN-SUFFIX,gdt.qq.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:696
  - adblock/lists/easylistchina.txt:8092

## jd

status: no-rule
reason: ads-union.jd.com 只在 EasyList China 第 7015 行。jd.com 主域名不收。

## kuaishou

status: ruled
note: 磁力引擎域名，不是 kuaishou.com，也不是 yximgs.com。

- domain: e.kuaishou.com
  rule: DOMAIN-SUFFIX,e.kuaishou.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:579
  - adblock/lists/ADgk.txt:9097

## meishu

status: no-rule
reason: 没有美数专用域名同时出现在两份名单。秋风里的 1rtb.com 和 sdk.1rtb.net 只有这一份，不把它们当成美数。

## pangle

status: ruled
note: 与 bytedance、csj 共用名单里写明的 pangolin 主机。没有另一套国际域名拿到第二份。

- domain: pangolin-sdk-toutiao-b.com
  rule: DOMAIN-SUFFIX,pangolin-sdk-toutiao-b.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:488
  - adblock/lists/AWAvenue-Ads-Rule.txt:671
  - adblock/lists/ADgk.txt:557

- domain: pangolin.snssdk.com
  rule: DOMAIN,pangolin.snssdk.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:491
  - adblock/lists/ADgk.txt:796

- domain: log-api.pangolin-sdk-toutiao.com
  rule: DOMAIN-SUFFIX,log-api.pangolin-sdk-toutiao.com,REJECT
  sources:
  - adblock/lists/AWAvenue-Ads-Rule.txt:536
  - adblock/lists/ADgk.txt:561

## sdm

status: no-rule
reason: anythinktech.com 和 toponad.com 只在秋风，没有第二份。

## sigmob

status: ruled
note: adservice.sigmob.cn、track.sigmob.cn 和 sigmob.com 都只有一份，不收。下面这条两份都写了。

- domain: dc.sigmob.cn
  rule: DOMAIN-SUFFIX,dc.sigmob.cn,REJECT
  sources:
  - adblock/lists/AWAvenue-Ads-Rule.txt:370
  - adblock/lists/ADgk.txt:7249

## tencent

status: ruled
note: 规则类名是 TGGDT / 优量汇，与 gdt 共用 gdt.qq.com。不收 qq.com。

- domain: gdt.qq.com
  rule: DOMAIN-SUFFIX,gdt.qq.com,REJECT
  sources:
  - adblock/samples/adblock4limbo.list:696
  - adblock/lists/easylistchina.txt:8092

## tobid

status: no-rule
reason: 没有 WindMill 或 ToBid 专用域名。dc.sigmob.cn 只记在 sigmob 下，不记到这个聚合 id。

## ubix

status: no-rule
reason: ubixioe.com 只在秋风第 979 行，没有第二份。

## xhLaunchAd

status: no-rule
reason: 本地开屏控件，样本和名单里没有它的广告域名。

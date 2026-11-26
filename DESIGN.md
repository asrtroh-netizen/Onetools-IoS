# OneTools iOS Design System Specification (`DESIGN.md`)

> **Liquid Frosted Glass × Restrained BorderBeam × Precision Motion**
> Synthesized from `OneUI` tokens, Apple Liquid Glass, Linear/Raycast craft, `ismnoiet/border-beam-ios`, `beui.dev/motion`, and `guanmo-ai/ui-moments`.

---

## 1. Visual Identity & Anti-Slop Constitution

1. **Monochrome Foundation + Semantic Micro-Accents**:
   - Primary surfaces stay strictly in calm ash-white (Light) and obsidian-graphite (Dark).
   - Primary CTAs use pure high-contrast monochrome (`#FFFFFF` pill / `#000000` ink on Hero; `#1A1B20` / `#E2E2E9` on standard surfaces).
   - Semantic colors appear **only** on live status indicators, data deltas, expiry warnings, or active confirmations — never as decorative rainbow card headers.
2. **Anti-Boxiness (`Borderless Pill` & De-nested Surfaces)**:
   - Never nest hairline rectangular boxes inside hairline rectangular boxes for segmented tabs, filter strips, or inner metric grids.
   - Segmented switchers use a **borderless `999pt` frosted pill track** with a single GPU-gliding active capsule (`OneSlidingPill`).
   - Sub-tiles inside a `GlassCard` separate via subtle luminance fill (`6%–9%` alpha) + top `0.5pt` specular catchlight rather than a second outer stroke.
3. **Strict Prohibitions**:
   - **NO Emoji icons** in navigation, card headers, buttons, badges, or alerts — use `1.5pt`-stroke monochrome vector icons (`MaterialIcon` / SF Symbols).
   - **NO purple/indigo/neon gradient slops** (`#848ef9` or rainbow card titles) across embedded modules (`Clash`, `Swipt`, `Feather`).
   - **NO 3D tilt wobble** or gratuitous `> 400ms` slow-float entrance choreography on high-frequency utility views.

---

## 2. Color, Glass Material & Concentric Geometry Tokens

### Surface & Ink Palette (`OnePalette` / `OneGlass`)
| Role | Light Mode | Dark Mode | Notes |
| :--- | :--- | :--- | :--- |
| **Backdrop Canvas** | `#FFFFFF → #EDEDF4` | `#282A2F → #111318` | Neutral vertical gradient |
| **Card Glass (`fillStrong`)** | `rgba(243,243,250,0.72)` | `rgba(25,28,32,0.62)` | Paired with `CABackdropLayer` blur |
| **Sheer Tile (`fill`)** | `rgba(249,249,255,0.55)` | `rgba(51,53,58,0.22)` | Inner borderless plates & inputs |
| **Hairline Catchlight (`stroke`)** | `rgba(238,238,238,0.595)` | `rgba(255,255,255,0.12)` | `0.8pt` outer card rim only |
| **Primary Ink (`onSurface`)** | `#1A1B20` | `#E2E2E9` | High-contrast readable foreground |
| **Muted Ink (`onSurfaceVariant`)** | `#44474F` | `#C4C6D0` | Micro-indices, units, secondary copy |

### Semantic Accents
- **Emerald (Healthy / Connected / Active Sign)**: `#34D399` / `#3ECF8E`
- **Teal (Loopback / Secondary Ready)**: `#2DD4BF`
- **Amber (Handshake / 7d & 1d Cert Expiry)**: `#E59934`
- **Crimson (Error / Revoked / Destructive)**: `#F87171` / `#BA1A1A`

### Concentric Radii (`Exterior Radius − Padding ≈ Interior Radius`)
- **Floating Dock**: `28pt` (`height: 56pt`)
- **Hero Surface**: `22pt` (`padding: 24pt`)
- **Section Card**: `18pt` (`padding: 16pt`)
- **Inner Tile / Control**: `14pt`
- **Compact Chip**: `10pt`
- **Segmented Pill Track / Glider**: `999pt` (`Capsule`)

### `OneBorderBeam` Allocation Rules (`1.5pt` Dual-Pass Conic Sweep)
Never run `BorderBeam` on static idle cards. It is strictly reserved for **3 transient/high-priority states**:
1. **VPN Handshake (`Connecting / Reasserting`)**: Neutral silver-white `1.5pt` sweep around the `22pt` Connection Hero; extinguishes into a static catchlight once connected.
2. **Certificate Expiry Alert (`≤ 7 days`)**: Slow (`6s`) Amber (`#E59934`) sweep on the Signing certificate warning banner.
3. **Active Batch Signing Island**: Emerald (`#34D399`) sweep around the floating batch-signing progress dock while `Zsign` is running.

---

## 3. Precision Bento Typography (`DigitSwap` & Split-Weight Numbers)

- **Tabular Numerals Everywhere**: Every throughput rate, byte total, latency (`ms`), memory (`MB`), and count **must** apply `.monospacedDigit()`.
- **Split-Weight Metric Hierarchy (`OneBentoValueText`)**:
  - Top-left micro-anchor: `01 · 实时吞吐`, `02 · 出口延迟` in muted monospaced caption.
  - Primary integer: bold/semibold full-size foreground (`100%`).
  - Decimal fraction & unit suffix (`.48 MB/s`, ` ms`): scaled to **`76%`** font size with reduced weight and `72%` opacity.
- **Crisp Action Verbs**: Keep button labels concise (`2–4` CJK characters or `1–2` English words: `立即重连`, `一键重签`, `滑动重置`).

---

## 4. Motion Physics & Accessibility Fallbacks

| Interaction | Curve / Physics | Duration Budget | Constraints |
| :--- | :--- | :--- | :--- |
| **Button Press (`SPRING_PRESS`)** | `.spring(response: 0.16, dampingFraction: 0.82)` | `100ms – 150ms` | `scale(0.97)` (`0.95` on Hero CTA); instant release |
| **Workspace Tab Swap** | `timingCurve(0.16, 1, 0.3, 1)` | Exit `120ms` / Enter `180ms` | Vertical micro-shift locked `≤ 4pt` |
| **Sliding Pill Glider** | `timingCurve(0.22, 1, 0.36, 1)` | `240ms` | Single `matchedGeometryEffect` capsule |
| **Numeric Tick (`DigitSwap`)** | `.easeOut` + `.numericText()` | `180ms` | Only changed digits roll; units stay anchored |
| **Floating Island / Toast** | `timingCurve(0.16, 1, 0.3, 1)` | `200ms – 220ms` | Smooth bottom entrance without layout jump |
| **Reduced Motion Fallback** | `@Environment(\.accessibilityReduceMotion)` | Instant / Opacity | Strip scale, `translateY`, and `BorderBeam` rotation |

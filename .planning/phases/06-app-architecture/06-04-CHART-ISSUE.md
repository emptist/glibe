# 06-04 — bar_stream_chart 1.2.0 实测缺陷 + 修复计划

2026-11-20。owner 本轮指令："chart 代码不一定都对，错的部分自己报告 issue，
并制定计划改掉它。" 本文件只记**实测确认**的缺陷（file:line + 行文本 + 探针输出），
不记猜测。包源码位置：`~/gits/hub/tools_ib/bar_stream_chart`（v1.2.0，HEAD `ad21b14`），
经 `diff` 确认与 glibe `build/packages/bar_stream_chart` 的 hex 缓存**逐字节同源**。

## ISSUE-1 — KDJ 图层 live 轴被第一根 bar 收窄，导致 frame affine 非恒等、点移出 pane

### 现象（实测）

单根 bar push 后，`frame` 的 price / overlays / volume 三个 affine 都是恒等
`Affine(16.0, 1.0, 14.0, 0.0)`，**唯独 kdj 是 `Affine(16.0, 5.0, 14.0, -1890.08)`**。
scale_y=5、巨大负平移 ⇒ 第一根 bar 的 K/D/J 点被移出 pane。两根 bar 后变成
`Affine(16.0, 1.6667, 14.0, -335.84)`，随数据漂移，违反包自己 README 的承诺
（"shapes stay byte-identical across zoom/pan/auto-scale"）。

### 定位（file:line + 行文本，均在 `bar_stream_chart.gleam`）

- `:459` `let kdj_y = fn(raw: Float) { y_of(p.kdj, raw, 0.0, 100.0) }`
  —— KDJ 的 **reference 轴硬编码 `[0,100]`**（K/D/J 是 bounded 0-100 指标，这是对的）。
- `:421-422`（`carried_bounds` 的 `count == 0` 第一根分支）
  `live_kdj_min: kdj_lo,` / `live_kdj_max: kdj_hi,`
  —— 第一根 bar 把 **live 轴**设成该 bar 的实际 K/D/J 范围（如 `[60,80]`）。
- `:847` `axis_transform(0.0, 100.0, chart.live_kdj_min, chart.live_kdj_max, p.kdj)`
  —— frame 把 reference `[0,100]` 映射到这个被收窄的 live 轴，于是 scale =
  `100/(kdj_hi-kdj_lo) = 5`，dy 随之巨大。

对照：price 与 volume 的第一根分支（`:414-423`）用 bar 自己的 bounds **同时**设
reference 和 live，两者恒等 ⇒ affine 恒等。唯独 kdj 的 reference 固定 `[0,100]`、
live 却取 bar 范围，二者不一致。

### 对照探针（锁定根因，不是推断）

同一 bar，只改 K/D/J：

| K/D/J | live_kdj（bounds） | kdj frame affine | 判定 |
|---|---|---|---|
| `0/50/100`（铺满 [0,100]）| `[0,100]` | `Affine(16.0, 1.0, 14.0, 0.0)` | ✓ 恒等 |
| `70/60/80`（窄范围）| `[60,80]` | `Affine(16.0, 5.0, 14.0, -1890.08)` | ✗ 非恒等 |
| 第二根 `30/20/40` 后 | `[20,80]` | `Affine(16.0, 1.6667, 14.0, -335.84)` | ✗ 漂移 |

当 live_kdj 恰好等于 reference `[0,100]` 时 affine 恒等——证明缺陷就是第一根
bar 把 live_kdj 收窄，而非 axis_transform 本身。

### 修复计划（待 owner 批准后在 bar_stream_chart repo 执行）

1. **根因修复**：K/D/J 是 0-100 bounded 指标，live 轴不该被 bar 收窄。让
   `carried_bounds` 的 kdj live 边界**恒为 `[0,100]`**（或第一根分支也设
   `live_kdj_min: 0.0 / live_kdj_max: 100.0`，与 `:459` 的 reference 对齐）。
   这样 affine 对所有 K/D/J 值恒等，`:847` 的 `axis_transform` 退化为恒等映射。
2. **回归测试**（bar_stream_chart 包内，`gleam test`）：加一条断言——窄范围
   K/D/J（如 70/60/80）单 bar push 后 `frame(...).kdj.scale_y == 1.0` 且 `dy == 0.0`；
   再一条多 bar 后仍恒等。当前包测试全绿但无此断言，这正是漏网原因。
3. **发版**：修复 + 测试绿后，bar_stream_chart 从 1.2.0 → 1.2.1（patch，不破坏 API）。
4. **glibe 跟进**：`gleam.toml` 的 `bar_stream_chart` 约束已含 patch
   (`>= 1.2.0 and < 2.0.0`)，`gleam update bar_stream_chart` + 重跑门禁即可。
   本轮 glibe 不修改 chart 包源码（跨 repo、且需 owner 批准）；本文件即 issue 报告。

### 影响对 glibe 的判断

glibe 的 `push_one` 尚未填 body；按本文件修复前若直接用 1.2.0，K/D/J 非满量程时
KDJ 图层会画错。这是**外部包缺陷**，不是 glibe 设计问题；glibe 的架构文档不必因此改动。

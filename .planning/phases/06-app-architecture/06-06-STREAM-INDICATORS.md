# 06-06 — 指标计算必须是 O(1) stream，禁止 O(n²) 批量重算

2026-11-20。owner 三条连续指令的第三条：*"技术指标计算的代码，glibe的旧代码和
glib代码要相互比较，排除错误使用批量处理方式进行 Qn2 计算的黑代码，要用正确的
stream 流式设计代码"*；随后澄清 *"Qn2 是指 O(n²)，我不方便输入"*。

本文件记录**实测比对结果**（file:line + 原文），并把"将来填 `timeframe.indicator`
等 step 时必须用哪种算法"钉死。当前 `indicator` / `leaves` / `branches` /
`strategy` 四个 body 仍 todo（PENDING_DECISIONS R.5），本文件是它们填 body 时的
硬约束，不是现在就实现它们。

## 1. "O(n²) 黑代码"的精确定位（实测）

全库搜索 `Qn2`/`Qn²`/`n^2`/`O(n²)`/`平方和`/`Σx²` 后的结论：

- **当前生效源码**（`glib/src/glib/`、`glibe/src/`）里**没有** O(n²) 批量重算指标的代码。
- O(n²) 批量法只存在于**废弃记录**：
  - `glibe/deprecated/2026-11-12-pre-doc-tdd/notes/CHANGES_Bollinger_Welford.md:11-19`
    原文：*"Before: Batch standard deviation computation over a full window of bars:"*
    后接 `list.fold(window, 0.0, fn(acc,bar){...diff*.diff})` —— 这就是被废弃的批量黑代码。
  - 同文件 `:51`：*"The glibe project was still on the old batch approach. This port
    brings glibe in line with the streaming paradigm"* —— 旧批量法已被 stream 移植取代。
  - `glib/docs/archive/LEGACY_CODE_CLEANUP_ANALYSIS.md:186`：旧 `calc_bb` 的
    `sum_sq - mean²` 形式 *"risks catastrophic cancellation ... hidden by a silent
    float.max(0.0, ...) clamp"* —— 第二个黑代码特征：掩盖错误的静默 clamp。
  - `glib/README.md:881`：*"Phase 9: O(N) Refactoring (replaced O(N²) signal computation)"*。

## 2. 为什么 O(n²)/平方和公式是错的（owner 设计的裁定，非我的推断）

- `glib/docs/DESIGN.md:1427`：*"carry Σx and Σx², then σ² = Σx²/n − (Σx/n)².
  But that subtracts two numbers the size of price² to leave one the size of σ²:
  on BTC that is five digits gone, and a running sum never resets, so the error
  drifts without bound."*
- 同文件 `:1429-1432`：正确法是 **Welford online algorithm** —— 把方差存成 running
  sum of squared deviations `M2`，每样本 O(1) 更新。
- `glib/src/glib/indicator.gleam:46-48`：*"σ is carried as a Welford moving-window
  state ... so each bar is O(1) and no Σx²−(Σx)²/n subtraction forms (DESIGN §14.6)."*

根因两条：① 浮点灾难性抵消（price² 量级相减只剩 σ² 量级，BTC 损失约 5 位精度）；
② 运行和不重置 → 误差无界漂移。

## 3. glib 的正确 stream 设计（填 body 时照抄这三处）

| 指标 | O(1) 递推 | 权威出处 |
|---|---|---|
| SMA 五条 + KDJ 的 M | add arriving − subtract leaving：`size·prev + raw − leaving` | `glib/sma.gleam:50-89`（`sma` 通用递推，SMA 与 M 共用） |
| 布林带 σ | Welford moving-window：carry `SigmaState(n,mean,m2)`，`sigma_add` 进 + `sigma_remove` 出 | `glib/bollinger.gleam:69-186` |
| KDJ 的 HHV/LLV | 每 bar 缓存 `kdj_h/h_idx/l/l_idx`；仅当离窗 bar 恰是缓存极值时 `batch_window` 重扫一次（amortised O(1)） | `glib/kdj.gleam:74-139` |

注意 `batch_window`（`glib/kdj.gleam:119`、`glibe/deprecated/.../kdj.gleam:134`）名字含
"batch"，但它是 stream rare-path 的单次重扫，注释写明 *"Called only when the leaving
bar was the cached extreme, so it is the rare path (UC-64)"* —— **不是**要排除的 O(n²)
黑代码，别误删。

## 4. 两边 sma/bollinger/kdj 源码比对结论（实测）

`glib/src/glib/{sma,bollinger,kdj}.gleam` 与
`glibe/deprecated/2026-11-12-pre-doc-tdd/src/glibe/{sma,bollinger,kdj}.gleam`
**两者都是 stream 增量实现，不存在"一个批量一个 stream"的算法差异**：
- SMA：两边都是 `size*prev + raw − leaving`（glib `:76,85` / glibe-dep `:64-72`）。
- Bollinger：两边都定义 `SigmaState(n,mean,m2)` + `sigma_add`/`sigma_remove`。
- KDJ：两边都是缓存极值 + 仅极值离窗才重扫。
差异只在命名（`SmaTiny` vs `SmaSeriesTiny`）、导入路径、参数传递方式，都是表面。

⇒ owner 担心的"glibe 旧代码里的批量黑代码"指的是 deprecated **notes** 里那段被废弃的
`list.fold` 方差法，不是已经 stream 化的 sma/bollinger/kdj 源码本身。填 body 时以
`glib/src/glib/` 的当前实现为准（R42：glib 是实现参考，owner 设计权威）。

## 5. 对当前行动的影响

- `DataBar` 已补 8 个 chart 测量字段（sma_medium/yin_leaf_cma/yang_leaf_cma/k/d/j/bb_u3/bb_l3），
  `sourcebar.to_databar` 出生种 0.0，`dashboard.data_bar_to_chart_bar` 是真实消费方（RED→GREEN，
  56 passed）。这些字段的 writer 是 `timeframe.indicator`——将来填它时**必须**用 §3 的
  stream 递推，禁止 §1 的批量 fold。
- 窗口大小等参数在 R46 被删（settings 容器作废）；按 R32 参数须作为字段落到真正拥有它的
  type，随真实消费方出现再加，不预先造 settings。`timeframe.indicator` 的完整实现依赖这些
  参数归属 + PENDING_DECISIONS R.5 登记的 leaves/branches 开放点，本轮不擅自实现。

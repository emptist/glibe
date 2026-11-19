# 06-05 — plushie update 触发点裁定（owner 2026-11-20）

## 背景：我错过的层

owner 本轮指令："App View 和交易层面继续搭架子……尤其是确保单 bar 更新，View 和
App 任何部分不得另搞一套，完全使用 model 方面的 `working_databar_archived` 作为
plushie update 的触发点，chart 代码不一定都对，错的部分自己报告 issue，并制定计划改掉它。"

我最初拿 glibe 自己的 `.planning` 笔记加个人推断当设计，在 `dashboard.gleam` 骨架里写了
"bar 经 Msg 直接派发到 widget push"。owner 纠正："dashboard 怎么做在 glib 里面有完整的
计划文档等等，就是没有完善的代码，我的设计 AI 记录下来了，你不要在瞎搞一套，跟我设计
完全对不上。" **错误层**：没读 owner 让 AI 记录的 glib 权威设计就开始搭架子——这正是
"不读书就推断"的老毛病。本文件记录纠正后的、有原文出处的设计。

## 权威设计原文（glib `docs/`，逐条回读 2026-11-20）

| # | 原文 | 出处 |
|---|---|---|
| 1 | "the model changes at `working_databar_archived()` and the view follows" | `SYSTEM_MODEL.md:1356` |
| 2 | "one writer, one door, no dedup" | `SYSTEM_MODEL.md:1364`；`:1344` "one writer … one door, so none of the three can exist" |
| 3 | "the chart takes bars from `databar_list` — history only"；"a bar is drawn only once it is history. The working bar is never drawn" | `SYSTEM_MODEL.md:330/332/344` |
| 4 | `working_databar_archived` 运行时 "that bar becomes `databar_list`'s head — the chart marks the order on the bar that sent it" | `SYSTEM_MODEL.md:527` |
| 5 | "charting / publish reads `databar_list` and the record's own fields" — 不读 working bar | `SYSTEM_MODEL.md:618/622` |
| 6 | "no view step inside `databar_processing`" | `SYSTEM_MODEL.md:770/1307` |
| 7 | "a shadow is a second copy of state … I don't believe a shadow is ever needed" | `SYSTEM_MODEL.md:626-639` |

注：`DESIGN.md:2474` 曾写单 bar 接口"just before `working_databar_archived`, read
`working_databar` field"，与 `SYSTEM_MODEL.md:527` 的"after/archive → history head"
在"前/后"措辞上有张力（这是 glib 文档自身的演化痕迹，12.4/12.5 明确记录了 publish point
的变化）。**owner 本轮以当前话消解**：见下裁定。

## 裁定（owner 2026-11-20，本文件为落点）

**C1 — 唯一触发点是归档完成。** plushie 的 `update` 不得由"bar 经 Msg 直接到达"驱动。
一根 bar 要被画，必须先在 model 层走完 `sourcebar_gate → databar_processing →
working_databar_archived`：`working_databar` 从 `Some(bar)` 变回 `None`，那根 bar 成为
`Timeframe.databar_list` 的 head。**这一步完成 = 唯一发布点 = update 的触发点。**

**C1 的理由 = model 完整性（owner 2026-11-20 追问，逐字）：** *"working_databar 如果还在
工作，就不能更新 view，因为事情没有做完，model 不完整，怎么更新 view？这里的 model 是
Desk 展开的一些列的 types，他们各自的 field 什么时候完成，你不懂就去看文档。"*

不是"bar 换了位置"这么简单——是 **model（Desk 展开的整条链及每层 type 的 field）在 fold
跑完前处于半成品状态**。view 是 model 的投影，model 不完整就没有完整值可投影。字段完成
时序（glib `SYSTEM_MODEL.md:236-254`，逐行回读 2026-11-20；字段补全按 R26/R32 随真实
consumer 逐个落，不是一次塞满）：

| step | 完成的 field（谁写） | 此刻 model |
|---|---|---|
| `sourcebar_gate` | `working_databar` born whole（OHLCV / idx / timestamp）| `Some` — 半成品 |
| `indicator` / compute | 五条 SMA、布林带、KDJ（`sma_tiny`…、`bb_*`、`k/d/j`）| `Some` — 半成品 |
| `leaves` | 两个 leaf CMA（`yin_leaf_cma`/`yang_leaf_cma`）+ growing/settled leaf field | `Some` — 半成品 |
| `branches` | growing/settled branch field（读自己的四根 bar）| `Some` — 半成品 |
| `strategy` | `signal`（写在 working bar 上）| `Some` — 半成品 |
| **`working_databar_archived`** | bar 进 `databar_list` head；**`working_databar = None`** | **完整 — 可画** |

**唯一可画时刻 = 最后一行。** glib `SYSTEM_MODEL.md:487-489` 逐字："`working_databar`
being `None` at charting time is not incidental — it is the guarantee. It says: nothing is
half-built here; everything you are about to draw is finished." 三态（`:250-258`）：`None`
= idle between bars（画的就是这个状态）、`Some` = bar 在 fold 中 half-built、`Some→None` =
becoming history。**只要 `working_databar` 是 `Some`，任何 field 都可能还没写完，view 必须不动。**

**bar 与结构有别，别混**（`SYSTEM_MODEL.md:349-355`）：bar 的 half-built 是 bug（working 时
绝不画 bar）；growing leaf/branch 的 unfinished 是真实状态（作为信息进下半张表）。但两者
都只在 fold 完成后才读——那张表整体是 model 的投影。

**C2 — chart 从 history head 取 bar。** 触发后，update 从 `Timeframe.databar_list` head
取刚归档的那根 `DataBar`（owner 本轮选项："归档后读 history head"），经字段映射转成
`bar_stream_chart.Bar`，`push` 进对应稳定 ID 的 widget chart state。不从 `working_databar`
读（该字段此时已 `None`），不从 Msg payload 直接取。

**C3 — View/App 不得另搞一套。** Model 只有一份 `Desk`（R33/R50）；widget state 里的
`Chart` 是表现层派生的 opaque 形状累积，不回写 Desk、不是第二份 model；`Emit` 只发小
payload，没有"搬运 bar list"的路径（chart 库无 load-list/batch API，类型层禁止）。

**C4 — 结构不画、只列表。** bar 从 `databar_list`（history）画；leaf/branch 等结构进
下半张表（`SYSTEM_MODEL.md:388-399`）。drawn-from 分层按 level 钉死。

## 实现进度（2026-11-20，gdltdd）

- `app/runtime.gleam` 骨架已搭：Model = 唯一 `Desk`，`init` 填绿（空 Desk，`runtime_init_is_empty_desk_test`），
  `update` 仍 todo（trigger = archive 完成，见 §C1）。`////`/`///` 已写入 field-completion 时序。
- `app/dashboard.gleam` 的 `push_one` **已填绿**（`push_one_increments_chart_test`，54 passed）：
  一根 chart `Bar` → `bar_stream_chart.push` → 新 widget state，两次 push count 0→1→2。
  这是"单 bar 更新"的核心机制，已实测。

## 待补缺口（非待决项，按 R26/R32 随真实 consumer 落；owner 未拍板前不发明）

1. **DataBar → chart.Bar 字段映射**：`push_one` 收的是 chart 的 `Bar`（14 字段），而 glibe
   `DataBar` 目前只有 `idx/timestamp/OHLCV/signal/sma_tiny`（`databar.gleam:60-76`）。chart Bar
   需要但 glibe DataBar 还没有：`sma_medium / yin_leaf_cma / yang_leaf_cma / k / d / j / bb_u3 / bb_l3`。
   glib 原始 DataBar 有全部这些（`glib/src/glib/databar.gleam`），按 R26/R32 这些字段应随真实
   consumer（这里就是 chart）逐个加。**加哪些 / 何时加是 owner 的设计决定**——本轮不一次塞满，
   映射函数 `data_bar_to_chart_bar` 待字段就位后再建 body。这是"单bar更新"链路当前唯一断点。
2. **identity keys + chart carrier**：bar 的 (BrokerId/Symbol/Interval) 如何随 Msg 进入 update、
   归档 bar 如何到达 widget chart state —— glib 无对应（JS lightweight-charts），待 owner 裁定
   carrier（06-02 B3：plushie 0.6.0 无 `event.Custom`）。

## 对 06-02 §G3 的修订

`06-02-CHALLENGES.md` §G3 的 view-model 通信段已按本裁定改写，旧文本"bar 经 Msg 直接
派发到 widget push"标注作废。

## 相关：chart 包缺陷

`bar_stream_chart` 1.2.0 的 KDJ affine 缺陷（实测 + 修复计划）见 `06-04-CHART-ISSUE.md`。
那是外部包 bug，不改本裁定、不改 glibe 架构。

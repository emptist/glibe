# 06-07 — config.gleam：指标参数源（doc/type 层）

2026-11-20。这是 `src/glibe/config.gleam` 与 `api/interval.all()` 的**计划文档**——
按 gdltdd（R19）本应在 code file 之前写；本轮先写了代码、现补计划并让 `////` 指向
它。owner 两条逐字触发：

- *"R46 作废了 settings 容器，这是错的，config.gleam is a must, see glib for
  some of the use case"*
- *"glib project 已经冻结……你引用 glib 文档和代码都可以，因为他们已经冻结了"*

## 1. 已裁定前提（带出处，不重造）

- **config.gleam 是 must**。它 IS the settings file（`glib/config.gleam:1`），
  数字写成 Gleam 字面量，无外部文件、无 parser、无 `panic`。产出 `IntervalSettings`
  作为**参数**传给指标计算（`glib/indicator.gleam:35-39`:
  `compute_bar(databar, databar_list, settings)`）。
- **R46 只删空壳，不删 config**。R46 作废的是 AI 自造的 `TimeframeSettings` 空壳
  type + `Timeframe.settings` 字段 + `new()`（owner：*"我不知道是什么玩意"*）。
  glib 里 config 与 `Timeframe.settings` 共存；glibe 按 R46 **不回加**字段、不造
  `new()`，config 只产出参数值。更正见 `docs/RULINGS.md` R46 2026-11-20 条。
- **glib 冻结，可安全照抄**（本轮 owner 裁定，记于 R42 澄清）。窗口数字来自
  `glib/config.gleam:216-294`，引 owner 的 idib/seib，有出处、非臆造。R38 的
  "文档与实现对比"仍执行：抄前读对该行。
- **R21 构造器全名**：glib 用 `MIN1/D1/H1` 缩写键；glibe 的 `Interval` 是 9 个
  全名构造器（`IntervalOneMinute`…`IntervalOneMonth`），config 的 per-interval 表键
  用 glibe 自己的类型，不照搬缩写。

## 2. ownership（谁持有哪个值）

| 值 | 归属 type | 来源 | 读者（消费方） |
|---|---|---|---|
| 5 个 SMA 窗口、4 个 KDJ 数、bb_multiplier | `IndicatorSettings` | glib config.gleam:218-238（有出处） | `for_interval` 组装 → `IntervalSettings` → 指标 fn |
| sma_for_bbm（按 interval 选哪条 SMA 是布林中线） | `IndicatorSettings.sma_for_bbm: Dict(Interval, SmaSeries)` | glib config.gleam:239-255 | `bollinger`（经 `for_interval` 解成单值） |
| branch_exit_leaf_size（branch 写 exit_idx 的 leaf 大小） | `StructureSettings.branch_exit_leaf_size: Dict(Interval, Int)` | glib config.gleam:259-274 | `branch`（经 `for_interval` 解成单值） |
| 一个 interval 的参数快照 | `IntervalSettings`（**值/参数**，非字段） | `for_interval` 组装 | `indicator/sma/bollinger/kdj` 的参数（glib use case） |
| 全 9 interval 的枚举 | `api/interval.all()` | glib interval.gleam:84-86 | config 完整性检查 + round-trip 测试 |

`config.gleam` 不 import 任何 engine 模块（只 stdlib + api/interval），不持有
`Desk`/`Timeframe`；市场/券商目录（glib `Settings` 那几张表）依赖 glibe active
尚未迁移的 domain 类型，属另一个消费方，按 R26/R32 不臆造。

## 3. 类型与函数清单（已落地）

- 类型：`SmaSeries`（5 值闭集）、`IndicatorSettings`、`StructureSettings`、
  `IntervalSettings`、`SettingsError`、`Settings`。
- 函数：`default_settings`、`for_interval`、`for_interval_default`、`validate`、
  `describe_error`；私有 `at_interval`、`present`、`covers_all`。
- `api/interval.all()`：9 个全名构造器，对位 glib `interval.gleam:84-86`。

## 4. 边界与不跨步

- 不回加 `Timeframe.settings` 字段、不造 `new()`（R46/R49 仍有效）。
- 不实现 `timeframe.indicator` 四个 step（R.5 的 leaves/branches 开放点未到）；
  本 phase 只建参数源。config 是它们的输入，不是它们的实现。
- 不抄市场/券商目录表（无消费方，R26/R32）。

## 5. gdltdd 步骤与实测（R19）

1. `////` 命名本计划 → 类型 → `///` 全标注签名 → todo 骨架：`gleam check` exit 0。
2. 写 `test/config_test.gleam`（8 条断言）+ interval round-trip；RED = 56 passed /
   8 failures，失败全是 todo（实测 file:line `config.gleam:116/136/…`）。
3. 逐体填 GREEN：先 `interval.all()`（57 passed），再 `default_settings`（59），
   再 `for_interval` 组 + `validate`/`describe_error` → **64 passed, no failures**。
4. 门禁：`format/check/test/docs/export` 全 0；`WAE` exit 1 = 59 warnings
   （19 todo + 40 unused 骨架基线，无新增类别）。config/interval 无 todo 残留。

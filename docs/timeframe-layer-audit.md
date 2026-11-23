# Timeframe 层审计：glibe vs glib，改进还是退步（2026-11-24 02:38）

> owner 任务（逐字）：*"你的实现跟glib 在这个局部，就是timeframe层面，差距有多大，
> 你的是改进了，还是退步了，这个只能你自己比较"*；*"今天上午，已经查出你将大量不属于
> timeframe module的技术指标计算全部塞进来…类似的问题，有没有，需要你自己查"*；
> *"sourcebar_gate 这件事，看来要延后在推敲，因为现在基础可能都有问题。必须回到基础，进行复查。"*
>
> 性质：**审计，未改任何代码**。每条带 file:line。区分三类：① owner 已裁定的差异（不算错）；
> ② 真实退步/缺口（带证据）；③ 不确定、待 owner。查不出就写查不出，不臆造问题。

## 0. 结论摘要

- **不全是退步，也不全是改进**：结构层面（pipe 形状、指标外移、无 new、settled field、4 leaf 列表）
  是 owner 已裁定的**改进**，且比 glib 更符合要求；但**处理链少了一环**——`single_bar_test`
  （UC-60 坏 bar 拒绝）在 glibe 定义了却**生产代码零调用**，这是真实缺口（§2.1）。
- **"指标塞进 timeframe"这类问题上午已修**：`sma.gleam`/`bollinger.gleam`/`kdj.gleam`/`indicator.gleam`
  已拆出。本轮逐模块复查：**没有发现第二处同类"大块计算塞错模块"**（§3），但有一处边界模糊
  （`indicator` 薄适配层仍住 timeframe，glib 也是这样，不算错）。
- `sourcebar_gate` 相关全部**冻结**，本审计不碰（owner 明示延后）。

## 1. 逐字段对比（Timeframe record）

| 字段 | glib | glibe | 判断 |
|---|---|---|---|
| `settings: IntervalSettings` | ✅ `:77` | ❌ 无（改 pipe 参数） | **owner 裁定改进**（R46：settings 不作字段，随 consumer 走） |
| `growing_target_sourcebar` | ❌ 无 | ✅ `:120` | glibe 独有（合成层，owner 11-13）。非 glib 移植，属新增设计 |
| `working_databar` | ✅ | ✅ | 相同（R39 核心） |
| `databar_list` | ✅ | ✅ | 相同 |
| `sourcebar_buffer` | ✅ `:145` | ❌ 无 | owner R38 明确"不搬（离线导出）" |
| `growing_yin/yang_leaf` | ✅ | ✅ | 相同 |
| `signif_yin/yang_leaf_list` | ✅ | ✅ | 相同（R68 恢复） |
| `yin/yang_leaf_list`（完整） | ❌ 无 | ✅ `:131,134` | **owner 裁定改进**（R68：追溯研究素材） |
| `yin/yang_leaf_settled` | ❌ 无（用 var） | ✅ `:157,161` | **owner 裁定改进**（R63：settled 作 field） |
| `growing_yin/yang_branch` | ✅ | ✅ | 相同 |
| `yin/yang_branch_list` | ✅ | ✅ | 相同 |

## 2. 逐函数对比（处理链）

### 2.1 `databar_processing` —— 真实缺口：少了 UC-60 单 bar 检验

- **glib**（`glib/timeframe.gleam:338-488`）：`compute_bar` 之后调用 `indicator.single_bar_test(working)`
  （`:394`），`Ok` 才继续 leaves→branches→strategy→publish→archive；`Error` 则 `working_databar: None`、
  不动历史、打 `bar_error_text`（`:470-486`）。**坏 bar 不进入任何下游**。
- **glibe**（`glibe/timeframe.gleam:206-221`）：一条 pipe `indicator |> leaves |> branches |> strategy
  |> working_databar_archived`，**没有 single_bar_test 这一步**。
- **证据 single_bar_test 是死代码**：`grep single_bar_test(` 全 src 只有定义（`indicator.gleam:104`），
  生产调用 **0**；`bar_error_text(` 全仓 **0** 调用。测试里仅 `test/timeframe_steps_test.gleam:328,330`
  自测该函数本身。
- **结论**：**退步（真实缺口）**。glib 有"一条坏 bar 不毁掉整次 census"的防线，glibe 没有。
  注意：R38/RULINGS:1665 早已把这条记为"命名差异…且无 UC-60 单 bar 检验"，属**已知未补**，
  不是新发现；但确实是两代在这局部的实质差距。**是否补、怎么补（pipe 形状 vs 回调）待 owner**。

### 2.2 `indicator` 步骤 —— 改进（owner 已裁定）

- glib：`compute_bar` 内联在 `databar_processing:369-379`（虽调 `indicator.gleam`，但**没有独立的
  `timeframe.indicator` step**）。
- glibe：`timeframe.indicator`（`:244-260`）是 pipe 的一步，算法在 `indicator.gleam`（上午已拆 sma/bollinger/kdj）。
- 判断：**改进**，pipe 形状统一、每个 step 单一职责（R40/R41），算法不进 timeframe。

### 2.3 `leaves` / `branches` 传递 settled leaf —— 改进（owner 已裁定）

- glib：`leaves` 返回 3 元组 `#(Timeframe, Option(DataLeaf), Option(DataLeaf))`（`:511-513`），
  `branches(tf, yin_settled, yang_settled)` 接参（`:630-634`）——**破坏纯 Timeframe→Timeframe pipe 形状**。
- glibe：`leaves` 写 `yin/yang_leaf_settled` 字段，`branches(tf, settings)` 读字段（`:410-411`）——**纯 pipe 保持**。
- 判断：**改进**（R40/R41：每一步 subject-first 返回 Timeframe），已由 R63 裁定。

### 2.4 `publish` —— 差异，非缺陷（owner 已裁定）

- glib：`databar_processing(tf, databar, publish_model: fn(Timeframe)->Nil)`，publish 作**参数**，
  在 archive 前调（`:436`）。
- glibe：无 publish 参数；发布在 `app/runtime.gleam:105-110` 的 `publish_request` 由 archive 头驱动。
- 判断：**owner R33 裁定**（view 是纯投影、model 不调 view），glib 的回调被 R38 明确"不搬"。非缺陷。

### 2.5 `bars_listed` —— 可见性差异，非缺陷

- glib：`fn bars_listed`（私有，`:827`）；glibe：`pub fn bars_listed`（`:543`）。
- glibe 公开是因测试/其它模块要读 idx；R47 已记录读者。属无害放宽。

### 2.6 `new` —— 改进（owner 已裁定）

- glib 有 `timeframe.new(settings)`（`:156`）；glibe 无（R49/R64：见面即 bug）。改进。

## 3. 自查"同类问题"：还有没有函数放错模块

**方法**：逐模块核对每个 pub 函数的"算法归属"——计算型函数是否在 owner 模块，timeframe 是否只剩薄适配。

| 检查项 | 结果 |
|---|---|
| timeframe 里是否有大块指标算法 | ❌ 无。`indicator/leaves/branches/strategy` 都是薄适配，算法在各自模块（上午已修 sma/bollinger/kdj/indicator） |
| 算法模块是否越界命名 Timeframe | ❌ 无。`indicator.gleam:9-13` 明确"函数不命名 record" |
| `leaf.gleam` / `branch.gleam` 是否塞了不属于自己的计算 | ❌ 未发现；两者只做 leaf/branch 自己的识别与状态转移 |
| `app/*` 是否混进 domain 计算 | ❌ 未发现；runtime 只做 route + step + 发布请求组装 |
| `instrument.gleam` 是否定义了合成算法本体 | ❌ 无——只有 `case interval` 派发（`instrument.gleam:167-231`），本体在 `ib/sourcebar.gleam`（R50） |

**结论**：**没有发现第二处"大块计算塞错模块"**。上午那次修复后，模块边界在这局部是干净的。
唯一保留的边界模糊是 `timeframe.indicator` 这个薄适配层仍在 timeframe——但 glib 也是调用点在那里，
且它不含算法，不算错。

## 4. 冻结项

- `sourcebar_gate` 的一切（归属、签名、idx、配对）：**本审计不碰**，owner 明示延后到基础复查完。

## 5. 待 owner 裁定

1. §2.1 的 UC-60 缺口：是否补 `single_bar_test` 进处理链？补的话如何与纯 pipe 形状（R40/R41）共存？
2. §1 的 glibe 独有字段 `growing_target_sourcebar`、§2.3 settled field、§2.6 无 new：均 owner 已裁定，
   本审计只记录，不重开。

# DEVELOPER GUIDE — glibe / `doc-tdd`

> **本文是导航，不是规格。** 规格是代码内 `////` / `///`（`gleam docs build`
> 把它们渲染进 `package-interface.json`，编译器自己核对），以及
> `docs/RULINGS.md` 里的 owner 逐字。本文只做一件事：让你在填那些
> `todo as "..."` 之前，能读懂这些文档所描述的设计。
>
> 新会话顺序：`docs/HANDOFF.md` → `docs/RULINGS.md` R44–R50 →
> `docs/STATE.md` 最新节 → 载入 `gleam-language` 技能并**全文**读
> `references/gleam-core.md`（仓库镜像
> `docs/gleam-thinking-core-to-memory.md`）→ 本文。

**路径约定**：`glib/foo.gleam:N` 指参照实现 `../glib/src/glib/foo.gleam`
第 N 行；`glibe/foo.gleam:N` 指本项目 `src/glibe/foo.gleam` 第 N 行；
`test/…` 与 `docs/…` 相对本项目根。表格里只有 `:N` 的行号，承该表标题
所指的同一个文件。参照实现只读、不是规格、不是词库（R44 / R45）。

---

## 1. 先看这一句：不能按名字猜

owner 2026-11-15 逐字：*"整体设计是非常精巧的。不是粗心大意随便一看
文件名瞎猜一下就能用好的。"*

本系统里至少有三个名字，按字面猜一定写错：

| 名字 | 看起来像 | 实际 | 出处 |
|---|---|---|---|
| `bars_listed` | 数一数 `databar_list` 有多长 | 读**头部**那根 bar 的 `idx`，返回 `idx + 1` | `glib/timeframe.gleam:827`；`glibe/timeframe.gleam:191` |
| `last_bar` | 取 List 最后一根 | 读**头部**：倒叙归档下，头就是「上一根」 | `glib/timeframe.gleam:601` |
| `exited_branch` | 在分支表里 `list.find` 一个匹配 | 只读**头部**一根，比较它的 `exit_bar.idx` | `glib/branch.gleam:267`；`glibe/branch.gleam:160` |

三个都不是命名失误，而是同一个设计的三个后果：**倒叙归档**。

---

## 2. 语言事实：Gleam 的 `List` 不是数组

官方 `gleam_stdlib` v1.0.5 的 `gleam/list` 模块头逐字：

> *"New elements can be added and removed from the front of a list in
> constant time, while adding and removing from the end requires traversing
> and copying the whole list, so keep this in mind when designing your
> programs."*

同页对几个函数的逐字说明：

| 函数 | 官方原文 |
|---|---|
| `length` | *"This function has to traverse the list to determine the number of elements, so it runs in linear time. This function is natively implemented by the virtual machine and is highly optimised."* |
| `append` | *"This function runs in linear time, and it traverses and copies the first list."* |
| `last` | *"This function runs in linear time."* |
| `reverse` | *"This function has to traverse the list to create the new reversed list, so it runs in linear time."* |

即便 VM 为 `length` / `reverse` 做了高度优化，它们仍是 **O(n)**。把这类
调用放进「每根 bar 都跑一次」的路径，代价就是 **O(n²)**，而且历史越长越慢。
`gleam-core.md` §3 说得更直接：`List` 是 immutable singly-linked list，
`[x, ..rest]` prepend 是 O(1)；`case xs { [first, ..] -> ... }` 直接取头。

owner 2026-11-15 逐字：*"if you are to count the elements in a gleam list,
gleam docs tell you that will be very ineffecient action. list is not an
array, and is NOT a list you see in other languages."*

---

## 3. 系统的答案：倒叙归档 + `idx`

### 3.1 唯一不变量

**所有随数据流增长的历史 List，一律 newest-first：写入用 prepend
`[newest, ..list]`（O(1)），读取一律读头部（O(1)）。**

owner 逐字：*"list倒叙归档是我特别设计的，针对gleam list的设计特点。所以
凡遇到此类list相关的函数，以及成员的获取，一定要十分仔细，不要设计得好好
的却不用，去用非常蠢笨的方法，导致极低效率。"*

`glib/timeframe.gleam:96` 的 `databar_list` 定义处就写着这个设计的来历
（`:97-105`）：原来有一个 carried count 字段，`working_databar_archived` 每根
bar 递增它；现在字段整个删掉，因为 *"the head bar **is** the count —
`list.first(databar_list).idx + 1`, which is O(1) on a cons list and
cannot drift"*。实测记录是 **1001 根 bar 上 0 次 disagreement**。

- 归档：`glib/timeframe.gleam:848` `databar_list: [databar, ..timeframe.databar_list]`
- 已列根数：`:827` `bars_listed` = `list.first(...).idx + 1`，空表 `0`
- 「上一根」：`:280`（判重）、`:601`（`last_bar`）、`glib/kdj.gleam:38`、
  `glib/leaf.gleam:129`，全是 `list.first`
- 顺序反转只发生在**输出侧一次**，见 §6(b)。

### 3.2 为什么 `DataBar` 有 `idx`，`SourceBar` 没有

这是同一件事的另一半，不是两个随意不同的数据结构。

- `SourceBar` 是 provider 给的一根**已经 close 的蜡烛线**。它在系统外，
  不知道自己在流里排第几，也没有理由携带一个位置。
- `DataBar` 是这根 bar **进入系统**之后、被计算、被归档的值。位置是在
  边界上赋的：`glibe/api/sourcebar.gleam:225`
  `pub fn to_databar(sourcebar: SourceBar, idx: Int) -> DataBar`；
  glib 的调用点 `glib/timeframe.gleam:295` 是
  `to_databar(sourcebar, bars_listed(timeframe.databar_list))`。

也就是说，`bars_listed` 返回的那个 `Int` 同时是两件事：**已归档的根数**，
和**下一根 bar 的 `idx`**。两者本来就是同一个数——这正是不用 count 字段
也不会 drift 的原因。

`glib/databar.gleam:29-34` 对 `idx` 的定义逐字：*"The bar's own position in
the stream — 0 for the first bar of a run … a bar knows where it stands, so
a structure can name a **bar** instead of a number and still measure a size
or a span in O(1)"*。

有了 `idx`，下面这些「数数」全部退化成两个整数相减，都是 O(1)：

| 需求 | 写法 | 出处 |
|---|---|---|
| 已列根数 | `head.idx + 1` | `glib/timeframe.gleam:827` |
| 一片 leaf 的 size | `end_bar.idx - start_bar.idx + 1` | `glib/leaf.gleam:45-49` |
| 一条 branch 的 size | `exit_bar.idx - start_bar.idx + 1` | `glib/branch.gleam:96-99` |
| CMA 递推里的 `N_old` | `databar.idx - start_idx` | `glib/leaf.gleam:119` |
| KDJ 窗口的离场 bar | `working.idx - w`，与缓存的 `kdj_h_idx` / `kdj_l_idx` 比 | `glib/kdj.gleam:79-95` |
| 本 bar 是否结束了一条 branch | `exit_bar.idx == idx`，只读头 | `glib/branch.gleam:267-280` |

`idx` 不是「方便显示的行号」；它是把「遍历历史求长度/跨度」整体换成
「整数算术」的那个字段。owner 逐字：*"为什么databar和sourcebar不一样，
databar自带一个idx，原因也是如此。这是效率最高的做法。"*

---

## 4. 所有此类 List，同理类推

owner 逐字：*"注意不仅是 databar_list, 所有的需要反复提取计算长度的list，
同理类推，都应该倒叙归档"*。

glib 里随流增长的 List 都是这个形状，没有例外。下表所有裸 `:N`
行号均指 `glib/src/glib/timeframe.gleam`，写入列另写了模块名的除外：

| List | 定义 | 写入 | 读取 |
|---|---|---|---|
| `databar_list` | `glib/timeframe.gleam:96` | `:848` prepend | `:280` / `:601` / `:827` 头 |
| `sourcebar_buffer` | `:146-149`（注释明写 *"Newest-first like `databar_list`, so capture is O(1)"*） | `glib/sourcebar_export.gleam:45` `[sourcebar, ..buffer]` | `glib/trading/export.gleam:24` 一次性 `list.reverse` |
| `signif_yin_leaf_list` / `signif_yang_leaf_list` | `:127-128` | `:549` / `:555` prepend | 归档记录，不在每根 bar 的判定路径上 |
| `yin_branch_list` / `yang_branch_list` | `:144-145` | `:690` / `:694` prepend | `:746` → `branch.exited_branch` 读头 |

`glibe` 骨架里对应的字段是 `src/glibe/timeframe.gleam:110`
`databar_list`、`:115-116` `yin_branch_list` / `yang_branch_list`。
骨架的函数体多数还是 `todo`，但 **`todo` 的文字已经写明这个形状**（见 §7），
将来填 body 时不许再把它改成 `list.length` / `list.find` / `list.append`。

---

## 5. 高效用法：DO / DON'T

| 需求 | 用 | 不要用 | 依据 |
|---|---|---|---|
| 历史根数 / 下一根 `idx` | `bars_listed` 的两个 `case` arm：读头 `idx + 1`，空表 `0` | `list.length` | §2 官方逐字；`glibe/timeframe.gleam:191`（已编译、已 GREEN） |
| 上一根 bar、上一条 branch | `case list { [head, ..] -> ... }` | `list.last` / `list.reverse` | `glib/timeframe.gleam:601`、`glib/branch.gleam:267` |
| 归档一根 | `[newest, ..rest]` | `list.append(rest, [newest])` | 官方 `append` 逐字；`glib/timeframe.gleam:848` |
| 一段跨度 / 窗口大小 | `idx` 相减 | 扫表数元素 | §3.2 表 |
| 判定「本 bar 是否结束」 | 头一根的 `idx == idx` | `list.find` 全表 | `glib/branch.gleam:267` |
| 找出窗口内极值 | 缓存 `idx`，仅在离场 bar 恰是极值时重扫一次 | 每根 bar 重扫窗口 | `glib/kdj.gleam:79-95`，注释写 *"Amortised-constant"* |
| 把历史交给输出端 | 在**唯一一次**写/发布处 `list.reverse` | 每根 bar reverse 或 append | `glib/trading/export.gleam:24`、`glib/trading/ingest.gleam:164` |

`gleam-core.md` 里同向的两条禁令：**Do not index a list**（没有 `list.at`）、
**Do not build a list with `list.append` inside a fold**（quadratic）。

---

## 6. 三类例外，以及怎么判断「是不是搞错了」

owner 逐字：*"如果glib AI没有100%这么做，那说明要么搞错了，要么是一个
非数据类的很小的不会无限增长的list，或许都不应该用list的list。"*
以及前置的免责：*"其中AI是否100%按照我设计去实现我也不知道，至少凡是
我看到过的错误都纠正过来了"*。所以下面只是**按判据分类**，不是宣布
glib 全对；权威始终是 owner 逐字、代码内文档和编译器。

**(a) 有界窗口——不是历史，成本被常数窗口锁住。**
`glib/sma.gleam:69` 用 `list.split(databar_list, size - 1)` 找离场的那根，
`:75` 的 `list.length(settled)` 只作用于 `size` 以内的前缀；
`glib/kdj.gleam:124` 的 `list.take(databar_list, w - 1)` 只在
`batch_window` 这条罕有路径上跑（`rsv_extrema` 先用缓存 `idx` 挡掉）。
它们不会随历史变长而变慢，因为走的从来不是整条 `databar_list`。

**(b) 输出侧一次性 `reverse`——故意的、只做一次。**
`glib/trading/export.gleam:24`、`glib/trading/ingest.gleam:164` 在**写文件 /
发布**时各 reverse 一次；`glib/trading/live.gleam:129-131` 更把理由写进注释：
prepend + 一次 `reverse` 是 O(n)，逐行 `list.append` 是 **O(n²)**。
这是把 O(n) 从每根 bar 挪到唯一一次边界，不是违反设计。

**(c) 非数据类、小、不随流无限增长——可能压根不该是 `List`。**
`glib/execution/risk_manager.gleam` 里 `RiskResult.results` 是固定条数的
检查结果（每次调用重建、`list.append` 加一项、`:358` 末尾 `list.reverse` 一次），
`trades_today` / `last_trade_times` 按交易日重置（`:57-58`、`:146`），
`glib/web/branch_view.gleam:142-147` 是一次性的视图投影
（`list.append` + `list.sort` + `list.map`）。这些都不在 core 的
`databar_processing` 流里。其中
`last_trade_times: List(#(String, Int))` 配 `list.find`（`:377`）线性查找，
按本项目根法则（**该有 type 的地方就定义 type**）更像是该用 `Dict` 或
一个封闭类型，而不是用 List 去承担查找语义——这正是 owner 说的
「或许都不应该用 list」。本文不改 glib，也不把它写成新裁定。

**(d) 别把测试里的 `length` 当许可。**
`glib/timeframe.gleam:461` / `:469` 确实有 `list.length`，但它在
`is_product_version || { … }` 的短路块里（`glib/config.gleam:86` 当前为
`False`，产品版翻 `True` 后整块不再执行），是开发期的 at-home unit test，
用来断言「归档前后恰好长一根」，不是生产路径，也不是每根 bar 都跑。

---

## 7. 填 `glibe` 骨架时照这张表

`src/` 目前 15 个模块、多数 body 是 `todo`。下表路径全部相对
`src/glibe/`（测试路径相对项目根）。`////` / `///` 是规格，
`todo as "..."` 的文字是**填法**，下表把它与 glib 的实测实现对齐。

| 骨架位置 | todo / 现状 | 填 body 时 |
|---|---|---|
| `timeframe.gleam:191` `bars_listed` | **已实现** `[] -> 0` / `[newest, ..] -> newest.idx + 1` | 保持；`test/glibe_test.gleam:107` 的断言特意让 `list.length` 必红（头 `idx: 41`、两格，答案必须是 42 而不是 2） |
| `timeframe.gleam:180` `working_databar_archived` | `Some -> None, bar prepended to the HEAD of databar_list (O(1), newest stays first)` | `[databar, ..timeframe.databar_list]`，对应 `glib/timeframe.gleam:848` |
| `branch.gleam:160` `exited_branch` | `read the HEAD branch in O(1); Some only when its exit_bar.idx is idx` | `case branches { [head, ..] -> ... }`，禁 `list.find` |
| `branch.gleam:95` `branch_size` | `idx arithmetic, both ends included; never walk the branch lists` | `exit_bar.idx - start_bar.idx + 1` |
| `leaf.gleam:82` `leaf_size` | `idx arithmetic, both ends included; never walk databar_list` | `end.idx - start_bar.idx + 1` |
| `leaf.gleam:98` `cma_recurrence` / `:113` `leaf_cma` | 读 `databar_list` 头部 + `idx` 算术 | `list.first` 取上一根的 carried mean，`N_old = databar.idx - start_idx` |
| `api/sourcebar.gleam:225` `to_databar` | `one whole closed sourcebar born at the source boundary` | 写 `idx` 参数；这是 `idx` 唯一的出生点 |
| `databar.gleam:76` `idx` | `read the index of this bar` | 一个字段读取；不要顺手去数 List |

顺序仍是 R19：`////` 命名计划项 → `///` 写明谁读/写哪个具体值（R47）→
`todo` 空架子 → 单元断言（RED）→ 填一个 body（GREEN）→ 编译 → 循环。

---

## 8. 为什么文档先导的 TDD 是根本措施

owner 2026-11-15 逐字：*"在你刚才处理大量代码文件却不曾写多少代码的
过程中，你应该感悟到了，文档先导的tdd模式会强迫你把gleam document做
踏实，因为不然你将来将没法知道怎么实现那些空架子。这是一个根本性的
措施。否则都是没有好好写文档的代码文件，逐渐的代码就乱掉了，因为与
设计思路完全脱节，天马行空放飞自我了。"*

机制上的对应关系：

- `////` / `///` 是**规格**，`todo as "..."` 是**空架子**，测试是**承诺**，
  body 是**兑现**。架子留到将来填，那么「怎么填」必须已经写在 `///` 里；
  文档含糊，将来填的人只能猜，猜出来就与设计脱节。
- `gleam docs build` 把 `////` / `///` 渲染成 HTML 和
  `package-interface.json` 的 `documentation` 字段——**编译器自己的
  反漂移检查**。一行 `//`（而不是 `///`）就会让模块文档被截断，产物立刻
  看得出来；这比任何 shell guard 都可靠（`gleam-core.md` §14）。
- R47 要求每个 `////` / `///` 都能译成「谁读/写哪个具体值」，R50 要求一个
  文件只读写自己那一层持有的 Dict。这两条把散文挤出去，留下的正是
  实现 body 时需要的信息。
- 本轮就是实例：`bars_listed` 的旧 todo 写的是 *"count the settled
  bars"*，三处文档跟着写「counts」。文字错，方向就错——后来的人照着它
  写 `list.length` 完全「说得通」。把 todo 改成
  `read the head bar's idx and return idx + 1`，body 才可能写对。
  **改文档文字就是改设计**，不是润色。

---

## 9. 门禁（本文件只写文档，07:12 实测、07:31 复核一致）

```sh
export PATH="/opt/homebrew/bin:$PATH"
gleam format --check src test      # 0
gleam check                       # 0
gleam test                        # 16 passed, no failures
gleam docs build                  # 0
gleam export package-interface    # 0；modules: 15
gleam build                       # 0
gleam build --warnings-as-errors  # exit 1：196 = 76 Todo + 117 unused arg
                                  #       + 1 unreachable + 2 unused private ctor
```

`--warnings-as-errors` 是**从空架子起就固定的门禁**（R48），不是成绩单：
那 76 条 `Todo found` 就是逐条待实现的清单，不许按类别豁免，也不许用
`_` 批量静音。填掉一个 body 就少一条，且必须同时少一条对应的
`Unused function argument`（`bars_listed` 那次 198 → 196 正是这个差值）。

---

## 10. 本文的边界

- 本文**不新增 R 编号、不新增待裁决项、不改 `src/` 或 `test/`**。
  owner 逐字全文与查证记录的家是 `docs/RULINGS.md`（2026-11-15 执行注记）。
- `glib/` 是**参照实现**。owner 明说不知道其中 AI 是否 100% 照设计实现；
  文中每个 file:line 都是读过的代码事实，分类是说明，不是裁定。
- 文档里出现的 Gleam 片段来自已编译的 `src/glibe/timeframe.gleam:191`
  与它对应的 glib 实现（表格里的 `[] -> 0` / `[newest, ..] -> …`
  是这两个实现的 arm 摘录，不是独立可编译片段）；带 `...` 的示意
  写法只表示形状，不是源码逐字。没有凭空写出的代码。

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
>
> **术语守卫（owner 2026-11-17 10:25 / 10:27 / 10:31）**：`buffer` 与
> `replay` 是 AI 的蠢词，**从不是 owner 的话**。凡把这两词当设计术语用的
> 句子都是 AI 自己的说法；owner 只在「引用它们加以纠正」时用过。它们的
> 唯一合法出场是「被引用的 glib 旧代码字面 + 显式标注已否决」。owner 的词
> 是 `sourcebar_list`（与 `databar_list` 等 `xyz_list` 平行），系统是 pure
> stream、没有这些蠢物。读到这两词时先认清：要么是纠正引用，要么是 AI 污染。

**路径约定**：`glib/foo.gleam:N` 指参照实现 `../glib/src/glib/foo.gleam`
第 N 行；`glib/web/server_ffi.mjs:N` 指
`../glib/src/glib/web/server_ffi.mjs`；`glib/priv/index.html:N` 指
`../glib/priv/index.html`；`glibe/foo.gleam:N` 指本项目
`src/glibe/foo.gleam` 第 N 行；`test/…` 与 `docs/…` 相对本项目根。
表格里只有 `:N` 的行号，承该表标题所指的同一个文件。参照实现只读、
不是规格、不是词库（R44 / R45）。

---

## 1. 先看这一句：不能按名字猜

owner 2026-11-15 逐字：*"整体设计是非常精巧的。不是粗心大意随便一看
文件名瞎猜一下就能用好的。"*

本系统里至少有三个名字，按字面猜一定写错：

| 名字 | 看起来像 | 实际 | 出处 |
|---|---|---|---|
| `bars_listed` | 数一数 `databar_list` 有多长 | 读**头部**那根 bar 的 `idx`，返回 `idx + 1` | `glib/timeframe.gleam:827`；`glibe/timeframe.gleam:227` |
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
- 顺序反转只发生在**输出侧一次**，见 §6 与 §7(b)。

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
| `sourcebar_list`（glib 代码里被 AI 改名成 `sourcebar_buffer` —— 蠢名，已否决，owner 10:27） | `:146-149`（注释原写 *"Newest-first like `databar_list`, so capture is O(1)"*） | `glib/sourcebar_export.gleam:45` 的 cons（代码字面 `[sourcebar, ..buffer]`） | `glib/trading/export.gleam:24` 一次性 `list.reverse` |
| `signif_yin_leaf_list` / `signif_yang_leaf_list` | `:127-128` | `:549` / `:555` prepend | 归档记录，不在每根 bar 的判定路径上 |
| `yin_branch_list` / `yang_branch_list` | `:144-145` | `:690` / `:694` prepend | `:746` → `branch.exited_branch` 读头 |

`glibe` 骨架里对应的字段是 `src/glibe/timeframe.gleam:116`
`databar_list`、`:121-122` `yin_branch_list` / `yang_branch_list`。
骨架的函数体多数还是 `todo`，但 **`todo` 的文字已经写明这个形状**（见 §8），
将来填 body 时不许再把它改成 `list.length` / `list.find` / `list.append`。

---

## 5. 高效用法：DO / DON'T

| 需求 | 用 | 不要用 | 依据 |
|---|---|---|---|
| 历史根数 / 下一根 `idx` | `bars_listed` 的两个 `case` arm：读头 `idx + 1`，空表 `0` | `list.length` | §2 官方逐字；`glibe/timeframe.gleam:227`（已编译、已 GREEN） |
| 上一根 bar、上一条 branch | `case list { [head, ..] -> ... }` | `list.last` / `list.reverse` | `glib/timeframe.gleam:601`、`glib/branch.gleam:267` |
| 归档一根 | `[newest, ..rest]` | `list.append(rest, [newest])` | 官方 `append` 逐字；`glib/timeframe.gleam:848` |
| 一段跨度 / 窗口大小 | `idx` 相减 | 扫表数元素 | §3.2 表 |
| 判定「本 bar 是否结束」 | 头一根的 `idx == idx` | `list.find` 全表 | `glib/branch.gleam:267` |
| 找出窗口内极值 | 缓存 `idx`，仅在离场 bar 恰是极值时重扫一次 | 每根 bar 重扫窗口 | `glib/kdj.gleam:79-95`，注释写 *"Amortised-constant"* |
| 把历史交给输出端 | 边界投影优先走**单根增量流**（§6.2）；确需数组时只在唯一一次写/发布处 `list.reverse` | 每根 bar 整表 reverse、`list.append` | `glib/trading/export.gleam:24`、`glib/trading/ingest.gleam:164`；**反例见 §7(e) #8/#9** |

`gleam-core.md` 里同向的两条禁令：**Do not index a list**（没有 `list.at`）、
**Do not build a list with `list.append` inside a fold**（quadratic）。

---

## 6. 第二个关键措施：输出侧投影 + 单条增量流

owner 2026-11-15 逐字（问题）：*"如果list的data都是按照时间顺序倒过来放的，
那么在系统中，是不是有时候要用revert来把他顺过来才好用呢？那样不还是
低效率吗？比如画图，你怎不能倒过来制作chart吧？这里面涉及另一个系统
效率设计的关键措施。"*

**术语先对齐**：stdlib 里这个函数叫 `list.reverse`（§2 官方逐字），
glibe / glib 里都没有名为 `revert` 的函数。动词跟 function 走，本文只用
`reverse`。

### 6.1 是的，要顺过来——但只在边界各一次

`glib/src/glib` 全库 `list.reverse` 共 7 处（2026-11-15 检索），按触发
频率分类：

| 位置 | 什么时候跑 |
|---|---|
| `glib/trading/ingest.gleam:164` | 一次离线批次跑完，页面**初始绘制** |
| `glib/trading/export.gleam:24` | **退出时写导出文件**一次 |
| `glib/trading/live.gleam:130` | 一次 poll 窗口 decode 完（有界窗口，§7(a)） |
| `glib/census.gleam:172` / `:213` / `:363` | 生成离线报告 |
| `glib/execution/risk_manager.gleam:358` | 固定条数检查结果（§7(c)） |

**没有一处挂在「每根 bar 都跑」的 `databar_processing` 路径上。**
`glib/trading/ingest.gleam:151-154` 的注释逐字：*"The bars go
**newest-first inside the engine** (DESIGN §15) but are handed over
oldest-first, because the chart extends forward in time. Reversing is
not treatment — every value is exactly what `working_databar_archived`
stored."* —— reverse 不做计算，只把同一份值换个顺序交出去。

**但这个计数不证明 glib 做对了。** owner 07:59 逐字 *"glib has 7
positions where list.revers() is found, that smells. Was glib doing
properly? You have to ask."* 判据是对**每一处**问「能不能不用
reverse」，而不是按触发频率替它辩护。`*.mjs` 里还有 2 处 JS FFI 的
`.reverse()` 恰好挂在高频路径上：`glib/binance_trading_ffi.mjs:36-38`
的 `chart_bars()` 被 `apply_bar()` 调用，后者在 `:170`（seed）/ `:227`
（ws）/ `:282`（poll）三处触发 ⇒ **每根 bar 整表 reverse**；
`glib/paper_trading_ffi.mjs:273` 在 `:188` 的 poll 循环内 ⇒ **每次
poll 整表 reverse**。这两处是 O(N²)，逐处提问表见 §7(e)。

**磁盘顺序不约束消费方；「顺过来」靠读侧 prepend，不靠 reverse。**
owner 08:38 逐字 *"why should it be reversed before exporting? ... no
reason, since whether the data in disk is newest first or oldest first,
it will never prevent a comsumer to use it. The key is how the comsumer
will use it."*；08:58 逐字 *"旧数据放前面？那不是prepend是什么"*。
编译实测（`/tmp/glibe_format_probe/src/read_order.gleam`，exit 0）：
newest-first 文件逐根读 + `[record, ..acc]` → `10,20,30`，`list.first`
就是最旧那根，全程零 reverse / 零 append。所以「按时间顺序存储」
既不是数据性质、也不是格式必要条件，只是**一个消费方的读法**。
导出格式已定为 ETF term（§6.6）。逐字与查证链在
`docs/RULINGS.md`「2026-11-15 07:59 / 08:38 / 08:58」。

### 6.2 图表不是「reverse 完画一次」，是「一根一根长出来」

这才是问句里那个措施：**系统里只有一条流，实时每根只发一根，输出端
只做 O(1) 追加；顺序数据没有第二份。**

| 步 | 位置 | 做了什么 |
|---|---|---|
| 1 | `glib/timeframe.gleam:448` | 每根 bar 归档后 `publish_model(timeframe)` 一次 |
| 2 | `glib/web/server.gleam:57` / `:62` | `publish_model` 只从 `model.working_databar` 取**一根**；`None -> Nil`，被拒的 bar 一个字段都不占，不发 |
| 3 | `glib/web/server.gleam:110` → `glib/web/server_ffi.mjs:429` | SSE `chart_data` 发 `{symbol, interval, bar}` **一根**；`:417` 逐字 *"send ONE finished DataBar over SSE `chart_data` (not an array)"* |
| 4 | `glib/priv/index.html:768` → `:658` → `:691-705` | 收一根 → `appendBar` → 每条 series 各一次 `series.update` |
| 5 | `glib/priv/index.html:736-737` | **初始绘制也是 `bars.forEach(appendBar)`**，与实时走同一个函数 |
| 6 | `glib/web/server_ffi.mjs:418-419` | *"history and live are indistinguishable because both flow through sourcebar_gate"*；`glib/trading/ingest.gleam:1-8` 逐字 *"history is the same stream as live … no bulk seed, no `setData`, and no second pipeline"* |

前端明确禁用 bulk load：`glib/priv/index.html:644` *"No `setData`
anywhere"*（bulk load 会 REPLACE 整条 series，抹掉已画的调试证据）；
`glib/web/server_ffi.mjs:20` 也写死 *"not a second source of bars"*。

所以顺序**不需要在引擎里存第二份**：引擎永远只有倒序链表；chart
series / JS 数组是它的输出侧投影，靠**尾部追加**增长——JS 数组 `push`
与 `series.update` 都是 O(1)，恰好是 Gleam `List` 做不到的两件事。
`glib/web/server_ffi.mjs:32-38` 的 `gleam_list_to_array` 是那一次遍历。

### 6.3 效率算术：成本挂在哪个频率上

| | 引擎按 oldest-first 存 | 现在（倒叙 + 边界一次 reverse） |
|---|---|---|
| 每根新 bar 写入 | `list.append` O(n) | prepend O(1) |
| 每根取「上一根」 | `list.last` O(n) | 读头 O(1) |
| 每根发给图表 | 要保顺序就得 reverse 整个历史 O(n) | 广播一根 O(1) |
| N 根累计 | **O(N²)** | **O(N)** + 初始绘制 / 导出各一次 O(N) |

关键不在 reverse 是不是 O(n)——它是。关键是它挂在**「人打开一次
页面 / 退出一次导出」**的频率上，不是**「数据到达 N 次」**的频率上。
把 O(n) 从每根 bar 的路径挪到唯一一次边界，正是 §5 最后一行
「边界投影优先走单根增量流」的意思。

这张表算的是 **glibe 应有的形状**。`glib/binance_trading_ffi.mjs:81`
与 `glib/paper_trading_ffi.mjs:273` 把整表 reverse 挂在每根 bar /
每次 poll 上（§7(e) #8/#9），那才是 **O(N²)** 的一边。owner 07:59
的判据更根本：系统里只有一根 `working_databar` 在工作，谁在要整个
历史，谁就要被问一次（§6.5）。

### 6.4 它在 glibe 的裁定里已经有名字

- **R30**（`docs/RULINGS.md` 正文）定的是「标准层与显示层分开 … 同一个
绝对时刻在标准层只存一份，显示层是它的一个投影 … 不得为了显示把标准
类型改回日期字符串」。**顺序是同一条原则的同构应用**：标准层倒序存
一份，显示层顺序是它的投影；不得为了画图把存储改回顺序。
- **R20** `dashboard = VIEW`、**R33**（一条流、纯值重算、无 actor /
scheduler / clock / poll）、**R38**（流没有倒带）——新 bar 天然按时间
先后到达，输出端只管追加，不需要再排序。
- 代码侧：`src/glibe/desk.gleam:32-35` 的 `////`（VIEW / projection /
no clock / no poll）、`src/glibe/api/interval.gleam:30-31` 的 `////`
（R30 是 OUTPUT-side projection，不改变内部 grid）。

> **一句话**：倒叙是给机器算的，顺序是给人看的；两者只在边界相遇一次，
> 之后靠单条增量流各自 O(1) 增长。

### 6.5 owner 07:59 的回答：stream 模式，与绘图软件的第一条判据

owner 逐字（全文在 `docs/RULINGS.md`「2026-11-15 07:59」）：

> *"关键技术是stream模式，纵有万千条k线，系统里面其实只有一根在工作，
> 那就是 working_databar, you almost always only need that one databar."*
>
> *"其中第一条看是否支持单根bar更新chart，如果不能，那么我们的系统
> 不能用他。"*

**§6.2 描述的是应有的形状，不是 glib 全部实现的形状。** 判据比
「reverse 挂在哪个频率上」更根本：**系统里只有一根 bar 在工作**，
所以任何一处 `reverse` 整条历史，都说明某个消费方在要整个历史而不是
那一根 —— 这就是 owner 说的 *"that smells"*。`src/glibe/timeframe.gleam:112-126`
里 `working_databar: Option(DataBar)` 是那**一根**，`databar_list` 是
归档历史；R33 / R38 / R39 同向。每处 `reverse` 都要问一次「能不能
不用」，见 §7(e)。

**为什么那两个 AI 蠢词根本无处安放**（owner 10:37 反问的原话）：
*"in the stream, we only deal with the working_databar, what to buffer?
what to replay?"* —— 流里从头到尾只有一根 `working_databar` 在被处理：
合格的 sourcebar 一整根出生为它、在它上面算完决策、归档后它清回 `None`。
**没有第二个对象可攒、可倒带**，所以「存一份随流增长的副本」「重放一遍」
这类说法在 pure stream 里连个作用对象都没有。它们不是「做了太蠢」，是
**对象不存在**——这正是 10:25 / 10:27 / 10:31 三条裁定的根。

**绘图软件的第一条判据**（`try_plushie` 查证，源码为准）：

| 查什么 | 查到的事实 |
|---|---|
| 机制支持单根更新吗 | **支持**。`plushie_gleam` 有 `Snapshot`/`Patch`、`tree.diff` ID-keyed；`try_plushie/test/try_plushie_test.gleam:394-423` 断言稳定几何 + 稳定 id 时 `insert=1 / remove=1 / update_props=0` |
| 当前 app 做到了吗 | **没有**。`try_plushie/src/try_plushie.gleam:401-403` `subscribe()` 返回 `[]`（无归档事件源）；`try_plushie/src/fusion_view.gleam:231-237` `window()` 每次 `view` 都 `list.length` + `drop` + `take` + `list.reverse` 一个 160 根窗口 —— **绘图输入是整窗 list，不是 head 那一根** |
| 本项目这次跑过测试吗 | **没有跑通**：`gleam test` 在 `try_plushie` **exit 1**，`src/explore.gleam:158` 用了 `gleam_stdlib` v1.0.5 不存在的 `list.range`。上表断言数字是**测试源码里的断言**，不是本次实测 |

⇒ **owner 08:13 裁定（逐字）**：*"那个里面的绘图是手搓的，AI声称可以
单bar更新，确实最初版本是做到的，如果你发现目前不是，那是他后来搞
错了，不是不可以改正"*。所以判据问的**不是库的能力上限**，而是我们
自己的绘图实现有没有守住「只吃 head 那一根」；上表后两行是**后来
改错的实现回归，可以改正**，不是「不能用他」的证据。
**不判为当前不可用、不排除 plushie、不转向别的库。**
这与 `try_plushie/plushie-architecture.md:1463` 的 owner 逐字同向：
*"单bar更新做不到才会去整list，本来绘图根list无关，因为每次都仅需
第一个bar"*。对照 glib 用的是 Lightweight Charts v5 + SSE
`series.update` 单根增量（§6.2）；BEAM 侧 Plotto 因「无单 bar 增量」
在该项目已按同一判据被否（`plushie-architecture.md:513`）。
「最初版本做到」以 owner 逐字为准：`try_plushie` 仓库当前
`git log` 无提交（*"does not have any commits yet"*），无法从版本历史
复核，不写成实测。全文见 `docs/RULINGS.md`「2026-11-15 08:13」。

### 6.6 导出格式与读取方法（2026-11-17 09:40 定案：ETF term）

**格式已定：ETF（Erlang External Term Format），逐根一个 term。**
owner 09:40 逐字：*"要将glibe的输出格式按照最优解定下来"*。定案、
优先级与逐字全文在 `docs/RULINGS.md`「2026-11-17 09:40」。
owner 08:44 原问逐字：*"首先对export出去的文件的格式，需要探讨，
将来glibe用什么格式，用json？csv？更有效率的二进制方式？然后对读取
方法进行探讨，需要这个导出的文件必须按照时间顺序存储sourcebar信息
吗？"* 查证链在 `docs/RULINGS.md`「2026-11-15 08:44–08:58」。

**判据只有一条（根法则 / R13 / R21 / R27）：让类型自己说话，不为它补
一层 codec。** 标准 `SourceBar` 九个变体、grade 在变体里、`Timestamp`
是 opaque 纳秒值；`term_to_binary` / `binary_to_term` 直接存 term，
grade、纳秒、`Float` 精度全部原样保真。JSON / CSV 必须把 closed set 与
opaque 值降级成文本再 parser 回来、读方带外传 grade、还背格式兼容债
（glib 三代兜底就是账）。**零 codec 的一方胜。**

**优先级（owner 要的"优先级和选择建议"）：**

| 级 | 格式 | 判据 / 何时用 |
|---|---|---|
| **1（选定）** | **ETF term**：`term_to_binary` 逐根 append（OTP BIF，2 行 `@external`） | 类型原样保真、零 codec、零依赖、零手写 `.erl`、BEAM 原生；单根 73 bytes（JSON object 98）。最优解 |
| 2 | OTP `dets` / `mnesia`，或 hex `sqlight` / `khepri` | 只有出现「按 key 随机读写 / 查询」的真实消费方才上（R26/R32）：顺序在库里只是查询投影 |
| 3 | CSV / TSV（hex `gsv` / `tysv`） | 只有「表格工具 / 人直接读」成真实需求才用；仍付降级 codec 债 |
| 4 | JSON（positional array / JSON lines） | 不禁用但不选：`最懒的做法`（08:55）、整层 codec + 带外 grade + 兼容债；跨生态可读按 09:22 不计入优势 |

**顺序不是格式判据。** prepend / append 是**读侧**的事（外部文件读进
`List` 时逐根 `[record, ..acc]`）；输出侧不刻意造成顺序或逆序存储。
因此「某种格式能否 append 一根」不进上表的加减分。

**Q2「必须按时间顺序存储吗」已由 owner 裁定：不必须。**

> *"倒序资料肯定不影响消费呀 …… 如果你读取的使用也用list来存，
> 那么很简单的事情，你想怎么放？旧数据放前面？那不是prepend是什么"*

编译实测（`/tmp/glibe_format_probe/src/read_order.gleam`，exit 0）：
文件 newest-first `[30,20,10]` 逐根读、`[record, ..acc]` prepend
→ **10,20,30**，`list.first` 就是最旧那根；文件 oldest-first
同法 → 30,20,10。整个 reader **零 `reverse`、零 `append`、
零 `length`**。⇒ 要顺过来靠的是**读侧 O(1) 的 prepend 累积**，
不是 O(n) 的 `reverse` 重排。这是 08:38「磁盘顺序不约束消费方」
的具体读法，也与 §3 的唯一不变量一致：引擎内 `databar_list`
本来就是 newest-first。

| 读法 | 文件形状 | 得到什么 | 代价 |
|---|---|---|---|
| 逐根读 + prepend（owner 08:58） | newest-first | oldest-first List，头是最旧 | 每根 O(1)，零 reverse |
| 整份 `decode.list` + 从头 fold（glib） | oldest-first array | 直接就是喂流顺序 | 必须整份 parse、整份写 |
| 按 key 存取（`dets` / `mnesia` / `sqlight`） | 无「文件顺序」概念 | 顺序是查询时的一次投影 | 每根 O(1) 读写 |

**Q1 格式：JSON 不是默认答案。** owner 08:55 逐字
*"输出json是一种最懒的做法，因为不需要花精力去找最佳方案了。
但是或许hex有合适gleam的原生数据库都不一定的。"*
—— 批评的是「不花精力找方案」这个行为，**不是** JSON 禁用令。
08:49 逐字 *"gleam add 所有BEAM 也就是hex.pm package 并且直接
通过 `@external` 使用？不知道Gleam世界如此简单？"*

事实底座（都是查过 / 编译过的，不是口味）：

- **`src/` 现在零序列化、零文件 IO**；`Timeframe`（`:112-126`）
  没有那份随流增长的 sourcebar 列表字段、也没有 `export_flush`。
  这是定案，不是留白：owner 裁定该字段**非法**、glibe 不需要它；
  owner 的词是 `sourcebar_list`，只在将来导出时用（见 §7(e)）。
  （AI 曾把它叫 `sourcebar_buffer` —— 已否决的蠢名，仅此处引用纠正。）
- **`SourceBar` 是九个变体**，grade 在变体里不在字段里
  （`api/sourcebar.gleam:43`、`:105-178`）；`Timestamp` 是
  `pub opaque` 的 `Timestamp(seconds: Int, nanoseconds: Int)`
  （`gleam_time/timestamp.gleam:100`，纳秒精度）。
  JSON / CSV 要把 closed set 与 opaque 值降级成文本再 parser
  回来（正是 `gleam-core.md` §2 / R13 / R21 / R27 反对的）；
  glib 为此付的账是 `sourcebar.gleam:524-535` *"The variant is
  not spelled — the reader is told the interval"*、读方带外传
  `interval`、以及 `sourcebar_export.gleam:151-176` 的**三代格式
  兼容兜底**。
- **二进制不需要手写 codec**：一行
  `@external(erlang, "erlang", "term_to_binary")` + 一行
  `binary_to_term`，把「grade-in-variant 的六字段值」往返，
  实测 `ETF round-trip keeps grade + all six fields: True`
  （两个不同变体分别验过）。这**不是 FFI、不是手写 erl**，
  是 08:28 已裁定的正常 Gleam 设计。
- **`gleam add` 就够了**：探针 `gleam add simplifile` →
  `Added filepath v1.1.2` / `Added simplifile v2.7.0`，
  `append_bits` 本身就是 `@external(erlang, "simplifile_erl", ...)`；
  逐根 `write_bits` + `append_bits` 得 145 bytes（每根 73），
  **不攒整份、无 reverse**。
- **连 `gleam add` 都不用的一层**：OTP 29 内置
  `mnesia` / `dets` / `ets`（`code:ensure_loaded` 实测均为
  `{module, …}`）。DETS 故意乱序插 3 根、按 timestamp 查找
  全部命中、变体 tag 原样保真 ⇒ 按 key 的存储里根本没有
  「顺序」这个属性。（这条是 `erl -noshell` 层实验，不是
  Gleam 编译验证，如实区分。）
- **hex 上确实有**（`hex.pm` 08:56 实读）：Gleam 原生
  `sqlight` / `marmot` / `parrot` / `cake` / `gloo`、
  `gsv` / `tysv`（CSV）、BEAM 侧 `khepri` / `esqlite` /
  `concord`、时序 `oban_met` / `explorer`。owner 的猜测成立。
- **实测字节**（单根 / 10 根）：JSON object **98** /
  ETF **73**；JSON array **991**、JSON lines **989**、
  ETF 整表 **727**、ETF 逐记录 **73×10**。

**取舍（已定：ETF，见本节开头优先级表）**：ETF 直接存 term、零
codec、每根 O(1)、类型原样保真，是 **BEAM 原生格式**，故选它；
JSON / CSV 要付一整层 codec + 带外 grade，列为第 3、4 级。
OTP 内置库与 hex 包都是现成能力，不新增手写源码；DETS / 数据库
列为第 2 级，等「按 key 随机读写」的真实消费方出现才上（R26/R32）。
**owner 09:22 逐字** *"你担心依赖BEAM的问题，不用担心，
我就是打算靠BEAM吃饭的。你没看到我最近的项目都是gleam"*
⇒ 把「BEAM 专有、不可跨生态读、不可移植」写成**代价**是错的：
跨生态可读不是本项目的需求，BEAM 原生是性质而非减分项。
`term_to_binary/2` 选项与 `binary_to_term/2` 的 `safe` 警告，
官方页三次抓取超时只返回页首 —— **未取得逐字，本轮不引用**。

**这一节的语言事实已归入知识中心**：按 owner 09:22 的说明，
`~gits/gleam-language/knowledge/beam-doors-measured.md` 收录这一轮
全部编译实证（真实 exit code、未取证边界），用**单文件硬 `ln`**
接到 `~/.workbuddy/skills/gleam-language/references/`；
`externals.md` 也按同轮逐字 `ln` 到 `glibe/docs/externals.md`
方便查阅，三个名字同一 inode。本文只讲本项目的 list 效率与格式
探讨，不复制语言知识；逐字与 inode 实测在 `docs/RULINGS.md`
「2026-11-15 09:22」。

**owner 09:09 补的一层（说明，非裁定）**：*"BEAM里面有的东西好像都
不用另外做什么，直接可用 …… 归元无二路，方便有多门，gleam是最方便
的那扇门"*。本轮编译实证（`/tmp/glibe_beam_door_probe`，exit 0）：
零依赖、零手写 `.erl` 的四行 `@external` 直接调 `erlang:*` /
`lists:reverse`；本机 Elixir 1.20.4 的 `Elixir.String` 是同一 VM 上
的普通 `.beam`，Gleam 用一行 `@external(erlang, "Elixir.String",
"upcase")` 就能调（只多一个 `ERL_LIBS` code path）。这正是 §6.6 选
ETF、用 `@external` 直连 BIF 而不造 codec / 桥接层 / 手写目标源码的
根据。逐字与三条探针在 `docs/RULINGS.md`「2026-11-15 09:09」。

---

## 7. 例外与边界，以及怎么判断「是不是搞错了」

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

**(b) 输出侧一次性 `reverse`——不是例外，是 §6 那个措施在文件 / 发布
边界的形态。**
`glib/trading/export.gleam:24`、`glib/trading/ingest.gleam:164` 在**写文件 /
发布**时各 reverse 一次；`glib/trading/live.gleam:125-130` 更把理由写进注释：
prepend + 一次 `reverse` 是 O(n)，逐行 `list.append` 是 **O(n²)**。
这是把 O(n) 从每根 bar 挪到唯一一次边界，不是违反设计。为什么图表
不需要反复 reverse，见 §6.2。

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

**(e) owner 07:59：对每一处 `reverse` 都问同一个问题 —— 能不能不用？**

owner 逐字：*"can it not use reverse when doing sourcebar_list exporting
(for potential later offline tests only)? The same question should be asked
if there are other ocassions reverse() is used on a list"*。下表是
**逐处查证与提问，不是裁定**（权威仍是 owner 逐字与代码内文档）。
表中 glib 代码字面若出现 `sourcebar_buffer` / `replay`，那是 AI 旧名，
owner 10:25 / 10:27 已否决，仅作被引用的代码字面保留。

| # | 位置 | 触发 | 能不能不用 `reverse`（技术事实） |
|---|---|---|---|
| 1 | `glib/trading/export.gleam:24` | 退出写文件一次 | **「为什么 reverse」＝没有理由**（owner 08:38）；三处写方里只有它 reverse，见下方专段 |
| 2 | `glib/trading/ingest.gleam:164` | 一次离线批次跑完 | 这处服务 `web/server_ffi.mjs:42-44` 的 bulk `set_databars`。按 stream 判据要问：初始绘制能不能也一根一根发，省掉整表 reverse 与这份数组 |
| 3 | `glib/census.gleam:213` | 离线报告一次 | 后面 `:369` `in_span` 用 `filter`+`length`、`:382` `age_of_last` 用 `list.last` 且**依赖 oldest-first**；改读头 / `idx` 相减是否可省，未实测，要问 |
| 4 | `glib/census.gleam:172` | 每个 group 打印前 | 只为打印顺序，分组小表；是否必要取决于输出格式，要问 |
| 5 | `glib/census.gleam:363` | fold 末尾 | `extreme_indices` 是 prepend O(1) 累积 + 一次 O(n) reverse，改写法仍是同一次遍历；这处是**形状正确**的构造，但「顺序是否真被需要」仍要问 |
| 6 | `glib/trading/live.gleam:130` | 一次 poll 窗口 | 有界窗口、注释自证 prepend+reverse 优于逐行 `append`；但按 R33「无 poll」，这条路径本身要问 |
| 7 | `glib/execution/risk_manager.gleam:358` | 每次风控检查 | 前面 `:300`–`:355` 用 `list.append` 累积（本已保序）**之后**再 reverse 倒过来；两处都要问「为什么」，且与 `gleam-core.md` §5 的 append 禁令同形 |
| 8 | `glib/binance_trading_ffi.mjs:37/81` | **每根 bar** | `apply_bar` 在 `:170/:227/:282` 触发，每次整表 reverse ⇒ O(N²)。按 stream 判据，这处要的是整个历史而不是那一根 |
| 9 | `glib/paper_trading_ffi.mjs:273` | **每次 poll** | `:188` 的 `while` 循环内，无新 bar 也整表 reverse |

**第 1 处（owner 点名）：导出前的 reverse 没有理由。**

owner 08:38 逐字：*"why should it be reversed before exporting? to
answer this you have to answer no reason, since whether the data in
disk is newest first or oldest first, it will never prevent a comsumer
to use it. The key is how the comsumer will use it. Right? So how the
comsumer is using the exported data today in glib? that is where to
inspect."*

⇒ 磁盘顺序不约束消费方；同一份数组从哪头读、要不要一次 O(n) 遍历，
都是消费方的事。「去掉 reverse 会让消费方倒着喂流」是**一个消费方
的便利**，不是数据的性质，也不构成保留 reverse 的理由。逐字与查证
链在 `docs/RULINGS.md`「2026-11-15 08:38」。

**先看清三处写方，reverse 连「写方统一规则」都不是：**

| 写方 | 代码 | 是否 reverse |
|---|---|---|
| `glib/trading/export.gleam:21-25` `export_flush` | `to_json(list.reverse(sourcebar_buffer(timeframe)))`（代码字面；owner 的字段名是 `sourcebar_list`） | **是** |
| `glib/census_import.gleam:119-127` `store_fetch` | `to_json(sourcebar_list)`；`binance.fetch_bars` 原本 oldest-first | 否 |
| `glib/census_import.gleam:171-184` `import_daily` | `to_json(sourcebar_list)`；IB 下载原本 oldest-first | 否 |

`glib/sourcebar_export_ffi.mjs` 的 `write_session` 逐字 *"The payload
arrived already encoded and already ordered — this does no reshaping
of the data."* —— 三处都产出 oldest-first，A 只是用一次 reverse
**追上 B / C 已经是的形状**；它那份列表是 newest-first
（`glib/timeframe.gleam:146-149` 注释 = *"Newest-first like `databar_list`
… `export_flush` reverses it once, at the single write"*，累积是
`glib/sourcebar_export.gleam:41-46` 的 cons，代码字面 `[sourcebar, ..buffer]`）。
这份列表 owner 叫 `sourcebar_list`（与 `databar_list` 平行）；`buffer` 是
AI 旧名，已否决。

**消费方在哪、怎么用（这才是要查的地方）：**

1. `glib/trading/ingest.gleam:124-147` `run_offline` →
   `sourcebar_export.read`（`:130`）→ `feed_all`（`:142`）。
2. `glib/sourcebar_export.gleam:139-149` `read_payload` 用
   `decode_sourcebar_list` 解析；`glib/sourcebar.gleam:515-518`
   `decode.list` 与 `:534-535` `json.array` 都保序，`:145`
   把解码结果**原样**交回。
3. `glib/trading/ingest.gleam:75-81` `feed_all` 是
   `list.fold(sourcebar_list, timeframe, fn(t, b) { feed(t, b, publish) })`
   —— **从头部开始，一根一根喂**；`:57-70` `feed` →
   `sourcebar_gate` → `databar_processing` → `working_databar_archived`。
4. `glib/timeframe.gleam:280-283` `dealt_with_last` 读
   `list.first(timeframe.databar_list)` 与到达 bar 的 `Timestamp`
   比较；`:294-296` 给准入的 bar 一个 `idx = bars_listed(...)`（读头）。
   **这条流有状态、默认时间向前**；倒着喂时 `idx` 递增而 `date`
   递减，值是合法的、历史是错的。它**不校验**顺序，只是假定顺序。
5. 同批文件其余消费方：`glib/binance.gleam:168-205` 的
   `GLIB_SEED_FROM_FILE` 分支（`:198`）读同一个文件、原样返回 →
   `glib/trading/ingest.gleam:101-108` `run` → 同一个 `feed_all`；
   `glib/census.gleam:212-213` 调 `run_offline` 后再 reverse 出报告；
   CLI 入口 `glib/glib.gleam:300`。
6. 顺序被写成契约：`glib/test/sourcebar_export_test.gleam:122-150`
   `the_vault_reads_back_oldest_first_test` 断言 oldest-first；
   `glib/sourcebar_export.gleam:26-27` 的「整份顺序读一次」本身就是
   **为这个消费方选的格式**。

**结论**：这次 reverse 只服务一个消费方 —— `feed_all` 从链表头部
fold 进一条有状态的流。它是**边界投影**，可以等价地放在读侧，也可以
随消费方形状改变而整个消失（逐行 stream 写 / 从尾部读），不必挂在
写侧。按 07:59 的 stream 判据，真正要问的是**消费方本身**：
`run_offline` 把整份历史逐根重放过引擎，要的是「整个历史」而不是
「那一根 `working_databar`」—— 这才是 *"that smells"* 的落点。

`glibe` 的 `Timeframe`（`src/glibe/timeframe.gleam:112-126`）**没有**
那份随流增长的 sourcebar 列表字段、也没有 `export_flush`。owner 已裁定：
该字段（AI 旧名 `sourcebar_buffer`，已否决）**非法、不引入**；owner 的词
是 `sourcebar_list`，且它只用于**之后的导出**（saving for potential
offline use），不是 stream 的一部分、不参与任何 computation。`reverse`
从来不是决定性因素。

**「导出文件必须按时间顺序存储吗」＝不必须。** owner 08:58 逐字
*"倒序资料肯定不影响消费呀 …… 旧数据放前面？那不是prepend是什么"*。
读侧逐根 prepend 就能从 newest-first 文件得到 oldest-first List
（编译实测见 §6.6）；按 key 的存储（`dets` / `mnesia` / `sqlight`）
里连「顺序」这个属性都没有。导出格式为 ETF term，见 §6.6。

---

## 8. 填 `glibe` 骨架时照这张表

`src/` 目前 15 个模块；骨架已填过一批，下表位置是 2026-11-17 15:51
实测（行号随 body 填开会漂移，引用前按符号名重新定位）。下表路径全部相对
`src/glibe/`（测试路径相对项目根）。`////` / `///` 是规格，
`todo as "..."` 的文字是**填法**，下表把它与 glib 的实测实现对齐。

| 骨架位置 | todo / 现状 | 填 body 时 |
|---|---|---|
| `timeframe.gleam:227` `bars_listed` | **已实现** `[] -> 0` / `[newest, ..] -> newest.idx + 1` | 保持；`test/glibe_test.gleam:313-318` 的断言特意让 `list.length` 必红（头 `idx: 41`、两格，答案必须是 42 而不是 2） |
| `timeframe.gleam:206` `working_databar_archived` | `Some -> None, bar prepended to the HEAD of databar_list (O(1), newest stays first)` | `[databar, ..timeframe.databar_list]`，对应 `glib/timeframe.gleam:848` |
| `branch.gleam:197` `exited_branch` | `read the HEAD branch in O(1); Some only when its exit_bar.idx is idx` | `case branches { [head, ..] -> ... }`，禁 `list.find` |
| `branch.gleam:117` `branch_size` | `idx arithmetic, both ends included; never walk the branch lists` | `exit_bar.idx - start_bar.idx + 1` |
| `leaf.gleam:100` `leaf_size` | `idx arithmetic, both ends included; never walk databar_list` | `end.idx - start_bar.idx + 1` |
| `leaf.gleam:127` `cma_recurrence` / `:160` `leaf_cma` | 读 `databar_list` 头部 + `idx` 算术 | `list.first` 取上一根的 carried mean，`N_old = databar.idx - start_idx` |
| `api/sourcebar.gleam:253` `to_databar` | `one whole closed sourcebar born at the source boundary` | 写 `idx` 参数；这是 `idx` 唯一的出生点 |
| `databar.gleam:76` `idx` | `read the index of this bar` | 一个字段读取；不要顺手去数 List |

顺序仍是 R19：`////` 命名计划项 → `///` 写明谁读/写哪个具体值（R47）→
`todo` 空架子 → 单元断言（RED）→ 填一个 body（GREEN）→ 编译 → 循环。

---

## 9. 为什么文档先导的 TDD 是根本措施

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
- 本轮的实例：`bars_listed` 的 todo 必须写成
  `read the head bar's idx and return idx + 1`——准确到具体值，body 才
  可能写对。若文档只含糊说「count」，后来的人照着写 `list.length`
  也「说得通」，方向就错了。**改文档文字就是改设计**，不是润色。

---

## 10. 门禁（2026-11-17 16:xx 实测；每填一个 body 重测，旧数字作废）

```sh
export PATH="/opt/homebrew/bin:$PATH"
gleam format --check src test      # 0
gleam check                       # 0
gleam test                        # 46 passed, no failures
gleam docs build                  # 0
gleam export package-interface    # 0；modules: 15
gleam build                       # 0
gleam build --warnings-as-errors  # exit 1：40 = 12 Todo + 28 unused arg
```

`--warnings-as-errors` 是**从空架子起就固定的门禁**（R48），不是成绩单：
每条 `Todo found` 就是一条待实现的清单，不许按类别豁免，也不许用
`_` 批量静音。填掉一个 body 就少一条 `Todo`，且必须同时少一条对应的
`Unused function argument`；当前计数以本节实测为准（填 body 会持续下降，
旧数字留在带日期的历史节里，不当当前答案）。

---

## 11. 本文的边界

- 本文**不新增 R 编号、不改 `src/` 或 `test/`**。07:31 / 07:42 两轮
  「不新增待裁决项」只对各自那一轮成立；owner 07:59 明确要求
  *"You have to ask"*，本轮先记入两处；其中 plushie 选型已由 owner
  08:13 裁定并写进结论、导出格式已由 owner 09:40 定案（§6.6）。
  `sourcebar_buffer` 导出路径已由 owner 10:16 裁定为非法、不引入
  （`sourcebar_list` 只用于之后离线导出），撤出决策区。待裁决区现为
  1 项：owner 08:16「拒绝 JS target」是否一并收紧 `webclient/`。
  owner 逐字全文与查证记录的家是 `docs/RULINGS.md`（2026-11-15 /
  2026-11-17 各条执行注记）；08:16 的 target / 手写 `.erl` 实证、
  08:28 的 external 术语订正、09:09 的 BEAM 门裁定与三条编译探针
  都不在本文。08:38 的结论在 §6.1 与 §7(e) 第 1 处：导出前的
  `reverse` **没有理由**，要看的是消费方 `feed_all` 从头部 fold 进
  有状态的流；格式定案（ETF term）与读法在 §6.6。
  语言知识归 `~gits/gleam-language`（单文件硬 `ln`，零 symlink）；
  「靠 BEAM 吃饭」⇒ BEAM 原生不是代价。
  本文讲 list 效率、消费方查证、边界格式与骨架填写，
  **不复制语言知识**。零 `@external` 只是骨架现状，不是目标；
  `@external(erlang, …)` 不是 FFI，也不基于手写
  erl，`gleam add` + external 是正常做法。
- `glib/` 是**参照实现**。owner 明说不知道其中 AI 是否 100% 照设计实现；
  文中每个 file:line 都是读过的代码事实，分类是说明，不是裁定。
  §7(e) 逐处表是**提问清单**，不是「glib 做对了」的宣告，也不是
  「glib 错了」的宣告。
- 文档里出现的 Gleam 片段来自已编译的 `src/glibe/timeframe.gleam:227`
  与它对应的 glib 实现（表格里的 `[] -> 0` / `[newest, ..] -> …`
  是这两个实现的 arm 摘录，不是独立可编译片段）；带 `...` 的示意
  写法只表示形状，不是源码逐字。没有凭空写出的代码。

---

## 12. 用自然界实例记住这些原则（owner 2026-11-17 08:44 提问 / 08:51 拆解）

owner 08:44 逐字提问：*"再用人体生理学解释这些编程基本原则让你好理解和
记住，你必须写入开发者文档：遇到类似问题如何决定？任何人或动物，所吃
进去的食物和喝进去的饮料，里面所包含的蛋白质，脂肪，各种氨基酸，请问
动物和人体是直接拿去放进自己全身细胞里面，还是怎么样做的？"*

owner 08:51 逐字拆解：*"即便同样是脂肪，在自然界，都是分别定义的，大豆
不能帮花生定义自己的脂肪化学结构特点以及他与其他化学物质混合存在的混合
物结构特点，这些都是个自定义的。动物很聪明，他不会去混淆外来和自身这两
个存在的边界，因此永远没有一个动物会把外来的东西不经过自己的重定义就加
以使用，也没有一个无视外来的混合物的结构特征，就用完全相同的处理过程进
行处理的。这是对这个自然界真实案例的拆解。"*

本节把「类型边界 = 权限边界」（08:37 治理根）、「开放集」、R28「原生形状
→ 自身定义的标准形状」挂到这个你身上就有的实例上。

### 12.1 owner 对自然界真实案例的三条拆解

1. **同类也分别定义。** 即便同为脂肪，大豆的脂肪化学结构、以及它与别的
   化学物质共存时的**混合物结构**，都是**大豆自己定义的**；大豆不能替花生
   定义。→ 每个来源的东西（连同它与别的东西混合共存的结构）各自自定义。
2. **外来 vs 自身的边界不混淆。** 没有动物把外来东西**不经过自己的重定义**
   就拿来用。→ 边界是一道必经的「用自己的方式重新定义」。
3. **不无视结构特征、不用相同过程。** 没有动物无视外来物的结构特征、用
   完全相同的处理过程处理所有来源。→ 每个来源按其自身结构特征**分别处理**。

### 12.2 逐条映射到 glibe

| 自然界（owner 拆解） | glibe | 原则 |
|---|---|---|
| 大豆不能替花生定义脂肪结构 + 混合物结构 | 每个 broker 在自己的模块定义自己的原生 symbol / Kline，连同它与别的字段共存的结构 | 治理根：谁有权改谁定义；R50 一模块一所有权 |
| 外来物必经自身重定义才用 | 原生形状经**自己的** `to_symbol` / `to_sourcebar` 转成 glibe 自己定义的形状，才进标准层 | R28：原生 → 自身标准；边界是必经的重定义 |
| 不无视结构特征用相同过程 | 每个 `to_*` 针对该 provider 的结构特征分别写；不存在一个通用过程套所有来源 | 分别处理，不假装所有数据源长一样 |
| 外来不进自身、自身不外流 | 原生形状不进 `Broker.instruments`；其 key 只有标准 `Symbol` | 治理根：别人的东西不进我的类型 |
| 靠自身定义构建自身 | 标准 `Symbol`（单个 `String`）/ `SourceBar` 是 glibe **自己定义的**形状，用它构建自己的值 | 自身定义，不是外来身份的抹除 |
| 食物来源无法预料 | 开放集 ⇒ 标准类型不枚举 broker 变体 | R26：来源无法预料 |

必须同时抓住两点，不矛盾：**标准层是 glibe 自己的身体定义**（用自身的
语言重新表达外来物），**而每个外来物进来的重定义入口是分别的、针对其
结构特征的**（拆解 3）。标准形状不是外来身份的抹除，而是用自己的语言
重新表达。

### 12.3 遇到类似问题如何决定（可操作判据）

碰到「某个外部的东西，要不要放进我的类型/模块」，按这个顺序问，**不要
在文字里辩论，也不要造探针模拟不存在的场景**：

1. **问归属：** 谁有权改这个值？**谁有权改，谁定义它的类型**（08:37 治理根）。
2. **分别定义：** 这个来源的东西（连同它与别的东西共存的结构）由它自己
   所在模块定义；glibe 不替任何来源定义，也不把几家塞进一个类型。
3. **边界重定义：** 每个来源经**自己的** `to_*` 转成 glibe 自己定义的形状
   ——这是唯一入场通道（R28）。
4. **按特征分别处理：** 每个 `to_*` 针对该来源的结构特征写；不要用「通用
   过程」套所有来源，也不要说来源身份消失。
5. **开放集不枚举：** 来源无法预料 ⇒ 标准类型里**绝不写死来源变体**（R26）；
   注释里的 5 个变体是样例，不是决定（08:40）。
6. **用自身定义构建：** 内部用自己定义的形状（标准 `Symbol` = 单个
   `String`）和自己的算法构造自己的值——外来物经重定义后才用，不原样搬运。

判据终点是一个**所有权形状**：每个来源分别定义 → 各自在边界重定义 →
glibe 用自身定义构建自己。和 owner 的三条拆解逐条对应。

---

## 13. 小狗的那顿饭：完整案例（owner 提问 08:59 / 完整描述 / 总结 09:02）

> **本节读者多半是 AI。** 读的顺序被故意固定为：**① owner 的问题全文 →
> ② 消化吸收过程的完整描述 → ③ 从描述映射出的验收用例 → ④ 最后的总结。**
> 不许跳过 ② 直接抓 ④ ——那正是 AI「望文生义、落到邪见」的路径。
> 抽象原则对 AI 无效：它会把原则复述成漂亮句子，然后照旧写错。所以先
> 给足**看得见的实物细节**，总结只能放在最后。

### 13.1 owner 的问题全文（2026-11-17 08:59，逐字）

*"现在问多几个问题，看你是否真正理解：一条小狗吃进一块他从地上找到的
人吃剩下的骨头上的肉，然后过一段时间，有人喂食狗粮给他吃，后来又有小
朋友调皮硬给他塞进嘴里一根双汇火腿肠，一把蒲公英草，还给他灌了一点二
锅头，然后主人发现了，出于担心，喂食了一颗狗主人自己吃的三九胃泰胶囊，
请具体描述一下这小狗的消化吸收过程，详细到某一种消化酶在什么时候开始
以什么方式出现并起作用。"*

注意问题里钉死的两个约束：**(a) 具体描述整个过程**；**(b) 细到某一种酶
在什么时候、以什么方式出现并起作用**。少任何一条都没有回答这个问题。

### 13.2 消化吸收过程的完整描述

**总纲：这不是"一锅炖成通用营养汤"。每种东西走各自的路径，每种酶按
底物结构分别出现、分别激活。**

**0. 口腔（t=0，骨头肉）。** 狗的唾液**几乎没有淀粉酶**（与人类不同），
主要是水 + 黏液 + 溶菌酶。机械咀嚼磨碎、润滑成食团。此处不发生化学分解
——狗的淀粉消化要等胰腺。

**1. 胃（分批：肉 → 狗粮 → 火腿肠+草+酒 → 胶囊）。** 酶以**无活性酶原**
分泌，到胃里才被酸激活：

| 酶/物质 | 何时、以什么方式出现 | 对什么底物起作用 |
|---|---|---|
| 胃蛋白酶原 → 胃蛋白酶 | 主细胞分泌无活性酶原；壁细胞泌 HCl 使 pH 降到 1.5–3；低 pH 使酶原构象改变、**自催化激活**（胃蛋白酶再激活更多酶原，正反馈） | 肉/火腿肠的蛋白质：切芳香族氨基酸附近肽键；胶原蛋白（结缔组织、明胶胶囊壳）部分降解 |
| 胃脂肪酶 | 舌腺（von Ebner 腺）分泌，随唾液吞入，在胃的酸性环境中起作用 | 优先水解短/中链甘油三酯；只是前锋，主力在小肠 |
| 盐酸本身（不是酶） | 壁细胞泌酸，进食后 pH 波动 | 溶解骨片的碳酸钙→Ca²⁺；使蛋白变性展开暴露肽键；高浓度二锅头进一步改变环境 |

**二锅头是特殊的一课**：乙醇是小分子，既水溶又脂溶，**不需要消化酶**，
在胃里约 20–25% 直接扩散进血液，其余进小肠快速吸收。但 56% 的高度白酒
**使蛋白变性、刺激胃黏膜、抑制胃蛋白酶、延缓胃排空**——它改变了整个反应
环境。幼犬体重小、肝酶系统未成熟，这个剂量危险。

**胃还按物理性质分批排空**：液体（酒）快，固体（肉/狗粮）慢，脂肪最慢
——这几样东西**不是一起进小肠的**，又一处分别处理。

**2. 十二指肠（激素触发的酶级联——最精彩的"按需出现"）。** 酸性食糜一
进入，肠黏膜两种细胞发信号：

- **S 细胞**尝到酸 → 释放**促胰液素（secretin）** → 胰腺导管分泌**碳酸氢
  盐**，把 pH 从 2 拉到 6–8。
- **I 细胞**尝到脂肪酸和氨基酸 → 释放**胆囊收缩素（CCK）** → 胰腺腺泡
  分泌胰酶 + 胆囊收缩排出胆汁。

然后是**级联激活，不是一次性全开**：十二指肠黏膜分泌**肠激酶
（enteropeptidase）**，只做一件事——把**胰蛋白酶原**切一刀 → **胰蛋白酶**；
胰蛋白酶再逐个激活其余酶原：**糜蛋白酶原 → 糜蛋白酶**（切芳香族残基）、
**弹性蛋白酶原 → 弹性蛋白酶**（切弹性蛋白）、**羧肽酶原 → 羧肽酶**（从羧基
端切）、**辅脂酶原 → 辅脂酶**。四种蛋白酶**切不同氨基酸残基、各管一段**。

脂肪和淀粉各走各的：

- **胆汁盐不是酶**，是乳化剂：把脂肪打散成小液滴增大表面积。**胰脂肪酶 +
  辅脂酶**锚定在液滴表面，水解甘油三酯的 1、3 位 → 2-单酰甘油 + 2 个脂肪酸。
- **胰淀粉酶**管狗粮和火腿肠里的淀粉 → 麦芽糖、糊精。家犬在驯化中 **AMY2B
  基因拷贝数扩张**，胰腺淀粉酶高表达——这是狗能吃淀粉的分子根据。
- **核糖核酸酶/脱氧核糖核酸酶**分解食物细胞里的 RNA/DNA。

**3. 小肠刷状缘（膜结合酶，就地切割）。** 这些酶**不分泌到肠腔**，镶嵌在
微绒毛膜上，底物接触才水解：麦芽糖酶、蔗糖酶-异麦芽糖酶、氨基肽酶、
二肽酶。产物是最小单位——单糖、氨基酸、二三肽。吸收也分别走通道：
葡萄糖走 **SGLT1**（Na⁺ 依赖），果糖走 **GLUT5**，二三肽走 **PepT1**
（H⁺ 依赖）；脂肪酸和 2-单酰甘油形成微团进入肠上皮后**重新酯化成甘油
三酯**，打包成乳糜微粒走**淋巴**——不是原样搬运。

**4. 肝脏（"重定义"真正发生的地方）。**

- **乙醇**：门静脉送到肝 → **乙醇脱氢酶（ADH）** → 乙醛（有毒）→
  **乙醛脱氢酶（ALDH）** → 乙酸 → 乙酰辅酶 A → 进入自身代谢。乙醇虽直接
  穿过胃壁，但**在肝脏被身体用自己定义的酶重新定义**了才算能用。
- **三九胃泰**（人用药，给狗是错的）：明胶壳被蛋白/羧肽酶消化；里面的
  植物提取物（生物碱、黄酮、苷类）是**异物（xenobiotics）**——狗没有把它
  变成自身的酶，走 **CYP450 Phase I 氧化 → Phase II 结合（葡萄糖醛酸化/
  硫酸化）→ 胆汁或尿排出**。人的胃药不能替狗定义它的处理过程——这正是
  "大豆不能替花生定义"的活例子。
- 氨基酸、脂肪酸这些"通用件"进肝后，按**狗自己的 DNA** 合成的酶和蛋白
  才是狗自己的东西——**吃牛肉不长牛肌肉**。

**5. 大肠（蒲公英草：不能重定义的就不进入自身）。** 狗**没有纤维素酶**
（无法断 β-1,4 糖苷键）。蒲公英的纤维素走完整段小肠不被消化，进大肠后
由菌群发酵成短链脂肪酸（乙酸、丙酸、丁酸），部分被结肠吸收，其余随粪便
排出。骨头的尖锐碎片则是**物理结构问题**——不是任何消化酶能处理的，可能
划伤或梗阻。

### 13.3 从描述映射出的验收用例

上面每一条都是一次验收：若你的程序在对应处会出问题，那就是 bug。

| 小狗吃进的东西 | 身体的机制（正确设计） | 若写成程序，对应的 bug |
|---|---|---|
| 骨头上的肉（外来蛋白） | 胃蛋白酶原被酸激活成胃蛋白酶；完整外源蛋白过不了小肠上皮 | 把外来的东西**原样**塞进自己的类型/字典，靠注释说"应先用 `to_*`" |
| 狗粮（淀粉） | 胰淀粉酶切糖苷键；家犬 AMY2B 拷贝扩张才消化得了 | 一个通用 `String` + 解析器 + 一堆分支处理所有来源 |
| 火腿肠（另一家的肉 + 淀粉 + 添加剂） | 与肉、狗粮来源不同，结构特征不同 → 各自的酶 | 把火腿肠和肉写成同一个变体，理由"反正是肉"——抹平来源 |
| 蒲公英（纤维素） | 狗**没有**纤维素酶 → 不消化、排出，不进自身 | 假装能处理：写个 `todo` 或 catch-all「以后再说」 |
| 二锅头（乙醇） | 小分子直接扩散过胃壁，但肝脏 **ADH → ALDH** 重定义成乙酰 CoA 才用 | 以为"进得来就能用"——**进来 ≠ 被接纳**；缺肝脏这道重定义 |
| 三九胃泰（人用药） | 明胶壳被消化；植物提取物是异物 → **CYP450** 改造后排出 | 忘掉"来源有权定义自己"：人的药不能替狗定义处理过程 |
| 骨头碎片（尖锐物理结构） | 物理问题，任何酶都解决不了 → 排出/风险 | 以为类型系统能包办一切，忽略非类型的维度 |

**"酶何时、以什么方式出现" = 三种防 bug 机制：**

1. **酶原 + 酸激活（胃蛋白酶原 → 胃蛋白酶）：** 默认**不活动**，只有持权者
   在正确条件下激活，且自催化放大。→ 编程：值**默认造不出来**，只有持权者
   在构造器里造（opaque + 唯一入口）。不是"造出来再检查"，是"没授权就构造
   不出"。
2. **级联激活（肠激酶 → 胰蛋白酶 → 其余酶原）：** 一个开关打开一整串。
   → 编程：一次 `to_*` 转换打开下游整条链，转换是唯一入场口（R28）。
3. **刷状缘膜结合酶（就地切割）：** 不分泌到肠腔，底物接触才切。
   → 编程：转换就在**边界**发生，不在内部某个"以后处理"的地方。

### 13.4 最后才是总结（owner 09:02 观察 + 我的陈述）

owner 逐字观察（2026-11-17 09:02）：*"看到吗，小狗没有学过编程，但是比
不动点脑子的AI的程序写的更好，绝对没有那些显而易见的bug"*。

小狗靠**结构**，烂程序靠**纪律**。**让错误状态不可表示**——小狗的消化
系统里，"未重定义的外来物进入自身"这个状态**构造不出来**：不是运行时
检查后发现错了，而是压根表达不出来。

glibe 里那个已修掉的 bug（`symbol.gleam` 曾把 5 个外部变体写进标准
`Symbol`）正是这一类：错误状态当时**可表示**，所以编译器不拦；改成单一
`String` + 各 broker 自己的 `to_symbol` 后，边界才从注释变成机制。

**原则如果没被机制承接，就只是装饰。** 问自己一句就够：*这个错误，是
运行时检查出来的，还是构造时就表达不出来？* 后者才是 type 真正起作用。

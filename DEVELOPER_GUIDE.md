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
| `sourcebar_buffer` | `:146-149`（注释明写 *"Newest-first like `databar_list`, so capture is O(1)"*） | `glib/sourcebar_export.gleam:45` `[sourcebar, ..buffer]` | `glib/trading/export.gleam:24` 一次性 `list.reverse` |
| `signif_yin_leaf_list` / `signif_yang_leaf_list` | `:127-128` | `:549` / `:555` prepend | 归档记录，不在每根 bar 的判定路径上 |
| `yin_branch_list` / `yang_branch_list` | `:144-145` | `:690` / `:694` prepend | `:746` → `branch.exited_branch` 读头 |

`glibe` 骨架里对应的字段是 `src/glibe/timeframe.gleam:110`
`databar_list`、`:115-116` `yin_branch_list` / `yang_branch_list`。
骨架的函数体多数还是 `todo`，但 **`todo` 的文字已经写明这个形状**（见 §8），
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
| `glib/trading/ingest.gleam:164` | 一次 replay 跑完，页面**初始绘制** |
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

> **07:59 订正 —— 上面这句不能推广成「glib 做对了」。** 它只是对
> `*.gleam` 内 7 处 `list.reverse` 的计数陈述，句子本身仍成立；owner
> 07:59 逐字 *"glib has 7 positions where list.revers() is found, that
> smells. Was glib doing properly? You have to ask."* 要求的是对**每一处**
> 追问「能不能不用」，而不是按触发频率替它辩护。同一轮检索 `*.mjs`
> 另检出 **2 处 JS FFI 的 `.reverse()`**，恰好挂在高频路径上：
> `glib/binance_trading_ffi.mjs:36-38` 的 `chart_bars()` 在 `:81` 被
> `apply_bar()` 调用，而 `apply_bar` 在 `:170`（seed）/ `:227`（ws）/
> `:282`（poll）三处触发 ⇒ **每根 bar 整表 reverse**；
> `glib/paper_trading_ffi.mjs:273` 在 `:188` 的 poll 循环内 ⇒ **每次
> poll 整表 reverse**，无新 bar 也翻。逐处提问表见 §7(e)，owner 逐字
> 与查证链见 `docs/RULINGS.md`「2026-11-15 07:59」执行注记。

输出侧的形状也由用途决定：`glib/sourcebar_export.gleam:26-27` 逐字
*"one positional JSON array, oldest-first … the file is read whole,
sequentially, once, which is what an array is for."* 计算侧用**链表**
（头部 O(1)），输出侧用**数组**（顺序读一次）。

> **08:38 订正 —— 上面这两句把「一个消费方的便利」写成了「格式的
> 理由」。** owner 逐字：*"why should it be reversed before exporting?
> to answer this you have to answer no reason, since whether the data
> in disk is newest first or oldest first, it will never prevent a
> comsumer to use it. The key is how the comsumer will use it."*
> 磁盘是 newest-first 还是 oldest-first 都不妨碍消费方使用；「整份
> 顺序读一次」本身就是为 `feed_all` 那个消费方选的格式，不是数据
> 的性质。完整消费链、三处写方与订正见 §7(e) 第 1 处，owner 逐字
> 与查证链见 `docs/RULINGS.md`「2026-11-15 08:38」。

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

> **07:59 限定**：这张表算的是 **glibe 应有的形状**，不是 glib 各条
> 输出路径都做到了的实测结论。`glib/binance_trading_ffi.mjs:81` 与
> `glib/paper_trading_ffi.mjs:273` 恰恰把整表 reverse 挂在每根 bar /
> 每次 poll 上（§7(e) #8/#9），那才是 **O(N²)** 的一边。owner 07:59
> 的判据更根本：系统里只有一根 `working_databar` 在工作，谁在要整个
> 历史，谁就要被问一次（§6.5）。

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
那一根 —— 这就是 owner 说的 *"that smells"*。`src/glibe/timeframe.gleam:106-120`
里 `working_databar: Option(DataBar)` 是那**一根**，`databar_list` 是
归档历史；R33 / R38 / R39 同向。每处 `reverse` 都要问一次「能不能
不用」，见 §7(e)。

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
**逐处查证与提问，不是裁定**（权威仍是 owner 逐字与代码内文档）：

| # | 位置 | 触发 | 能不能不用 `reverse`（技术事实） |
|---|---|---|---|
| 1 | `glib/trading/export.gleam:24` | 退出写文件一次 | **「为什么 reverse」＝没有理由**（owner 08:38）；三处写方里只有它 reverse，见下方专段 |
| 2 | `glib/trading/ingest.gleam:164` | replay 跑完一次 | 这处服务 `web/server_ffi.mjs:42-44` 的 bulk `set_databars`。按 stream 判据要问：初始绘制能不能也一根一根发，省掉整表 reverse 与这份数组 |
| 3 | `glib/census.gleam:213` | 离线报告一次 | 后面 `:369` `in_span` 用 `filter`+`length`、`:382` `age_of_last` 用 `list.last` 且**依赖 oldest-first**；改读头 / `idx` 相减是否可省，未实测，要问 |
| 4 | `glib/census.gleam:172` | 每个 group 打印前 | 只为打印顺序，分组小表；是否必要取决于输出格式，要问 |
| 5 | `glib/census.gleam:363` | fold 末尾 | `extreme_indices` 是 prepend O(1) 累积 + 一次 O(n) reverse，改写法仍是同一次遍历；这处是**形状正确**的构造，但「顺序是否真被需要」仍要问 |
| 6 | `glib/trading/live.gleam:130` | 一次 poll 窗口 | 有界窗口、注释自证 prepend+reverse 优于逐行 `append`；但按 R33「无 poll」，这条路径本身要问 |
| 7 | `glib/execution/risk_manager.gleam:358` | 每次风控检查 | 前面 `:300`–`:355` 用 `list.append` 累积（本已保序）**之后**再 reverse 倒过来；两处都要问「为什么」，且与 `gleam-core.md` §5 的 append 禁令同形 |
| 8 | `glib/binance_trading_ffi.mjs:37/81` | **每根 bar** | `apply_bar` 在 `:170/:227/:282` 触发，每次整表 reverse ⇒ O(N²)。按 stream 判据，这处要的是整个历史而不是那一根 |
| 9 | `glib/paper_trading_ffi.mjs:273` | **每次 poll** | `:188` 的 `while` 循环内，无新 bar 也整表 reverse |

**第 1 处（owner 点名）—— 07:59 的「直接删不行」答错了问题**

owner 08:38 逐字：*"why should it be reversed before exporting? to
answer this you have to answer no reason, since whether the data in
disk is newest first or oldest first, it will never prevent a comsumer
to use it. The key is how the comsumer will use it. Right? So how the
comsumer is using the exported data today in glib? that is where to
inspect."*

⇒ **「导出前为什么要 reverse」＝ 没有理由。** 磁盘顺序不约束消费方；
同一份数组从哪头读、要不要一次 O(n) 遍历，都是消费方的事。07:59 /
08:13 我把「去掉 `list.reverse` 会让这一个消费方倒着喂流」当成了
答案，是把**一个消费方的便利**写成了**数据的性质**。历史注记原文
不改写，更正写在 `docs/RULINGS.md`「2026-11-15 08:38」。

**先看清三处写方，reverse 连「写方统一规则」都不是：**

| 写方 | 代码 | 是否 reverse |
|---|---|---|
| `glib/trading/export.gleam:21-25` `export_flush` | `to_json(list.reverse(sourcebar_buffer(timeframe)))` | **是** |
| `glib/census_import.gleam:119-127` `store_fetch` | `to_json(sourcebar_list)`；`binance.fetch_bars` 原本 oldest-first | 否 |
| `glib/census_import.gleam:171-184` `import_daily` | `to_json(sourcebar_list)`；IB 下载原本 oldest-first | 否 |

`glib/sourcebar_export_ffi.mjs` 的 `write_session` 逐字 *"The payload
arrived already encoded and already ordered — this does no reshaping
of the data."* —— 三处都产出 oldest-first，A 只是用一次 reverse
**追上 B / C 已经是的形状**；它的 buffer 是 newest-first
（`glib/timeframe.gleam:146-149` = *"Newest-first like `databar_list`
… `export_flush` reverses it once, at the single write"*，累积是
`glib/sourcebar_export.gleam:41-46` 的 `[sourcebar, ..buffer]`）。

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

`glibe` 的 `Timeframe`（`src/glibe/timeframe.gleam:106-120`）**没有**
`sourcebar_buffer` 字段、也没有 `export_flush`，这条消费方路径在
glibe 尚未存在；是否引入仍是待裁决第 1 项，但 `reverse` 已不是
决定性因素。

---

## 8. 填 `glibe` 骨架时照这张表

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
- 本轮就是实例：`bars_listed` 的旧 todo 写的是 *"count the settled
  bars"*，三处文档跟着写「counts」。文字错，方向就错——后来的人照着它
  写 `list.length` 完全「说得通」。把 todo 改成
  `read the head bar's idx and return idx + 1`，body 才可能写对。
  **改文档文字就是改设计**，不是润色。

---

## 10. 门禁（本文件只写文档，07:12 实测、07:31 / 07:42 / 07:59 / 08:13 / 08:16 / 08:30 / 08:38 复核一致）

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

## 11. 本文的边界

- 本文**不新增 R 编号、不改 `src/` 或 `test/`**。07:31 / 07:42 两轮
  「不新增待裁决项」只对各自那一轮成立；owner 07:59 明确要求
  *"You have to ask"*，本轮先记入两处；其中 plushie 选型已由 owner
  08:13 裁定并写进结论。待裁决区现为 2 项：`sourcebar_buffer` 导出、
  以及 owner 08:16「拒绝 JS target」是否一并收紧 `webclient/`。
  owner 逐字全文与查证记录的家是 `docs/RULINGS.md`（2026-11-15 各条
  执行注记，含 08:16 / 08:28 / 08:30 / 08:38）；08:16 的 target /
  手写 `.erl` 实证、08:28 的 external 术语订正都不在本文。
  08:38 的订正在 §6.1 与 §7(e) 第 1 处：导出前的 `reverse` **没有
  理由**，要看的是消费方 `feed_all` 从头部 fold 进有状态的流；本文
  只讲 list 效率、消费方查证与骨架填写。零 `@external` 只是骨架
  现状，不是目标；`@external(erlang, …)` 不是 FFI，也不基于手写 erl。
- `glib/` 是**参照实现**。owner 明说不知道其中 AI 是否 100% 照设计实现；
  文中每个 file:line 都是读过的代码事实，分类是说明，不是裁定。
  §7(e) 逐处表是**提问清单**，不是「glib 做对了」的宣告，也不是
  「glib 错了」的宣告。
- 文档里出现的 Gleam 片段来自已编译的 `src/glibe/timeframe.gleam:191`
  与它对应的 glib 实现（表格里的 `[] -> 0` / `[newest, ..] -> …`
  是这两个实现的 arm 摘录，不是独立可编译片段）；带 `...` 的示意
  写法只表示形状，不是源码逐字。没有凭空写出的代码。

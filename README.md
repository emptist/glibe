# glibe

Gleam on the BEAM (`target = "erlang"`). This branch is `doc-tdd`: a **framework
rebuild in types**, not a working system yet.

**Starting a new session? Read `docs/HANDOFF.md` first.**
**Before filling any `todo`, read `DEVELOPER_GUIDE.md`.**

## Name and lineage (owner, 2026-11-21)

**Name拆解** — owner 逐字：*"glibe，拆解：gl - gleam， ib- ib， b-binance， be- BEAM， e- erlang and elixir"*

**沿革** — owner 逐字（完整版见 `docs/RULINGS.md` 2026-11-21（五））。
**`ibOptions` 是侧支循环，不在直系主线上**；owner 给的画法（括号 = 侧支）：

```
Smalltalk → seib (-> ibOptions) → glib → idib → glibe
```

owner 2026-11-21 逐字：*"ibOptions 算是一个侧支循环，设计完全受制于pandas，所以如果画图，
应该是 (-> ibOptions) ->"*；*"分岔点是 ... seib (-> ibOptions) -> glib ..."*。
owner 追加（逐字）：*"因为手工策略以及一些设计，来自ibOptions，换句话说，他细节丰富，
结构迥异，语言垃圾（Python+Pandas）"*。所以 `ibOptions` 不在直系代码/语言路线上，但**手工策略与
部分设计来自它**。我上一轮写「侧支不回流」过强，按此更正。

1. **祖先 = Smalltalk 程序**，*"也是最完整最疯狂的版本，用3D做图，大Kline里面嵌套小Kline，
   View直接映射model关系，用kline高度宽度厚度分别映射价格、时间、成交金额，横看侧看反转看
   全凭鼠标操作，完全动态，直接在图形下方点开修改策略等等"*。原始文件已不存在——*"由于
   imagebased的原因，也因为产品来自Cincom，随着我旧电脑淘汰，目前已经没有原始文件"*。
2. **`seib`** = CoffeeScript 重新开发，*"仅保留了部分设计"*（结构判断另见 R34）。
3. **`glib`（本项目前身）、`idib`、可能还有其他的**，都是各种尝试；*"主要的参考对象是
   glib，idib来自他，glibe也来自他"*。glib 已冻结，只作设计来源（R42）。
4. **侧支 `ibOptions`** = CoffeeScript 2 出现后、Coffee 走下坡路时选大众语言的尝试，*"用了
   Python+Pandas重做，完全不是以前的设计路线，受制于pandas，交易要素齐全，能交易，但是
   非常不满意"*。它是分支，不是 `glib` / `idib` / `glibe` 的前一站。
5. **glibe = 未来的最终产品**：*"简化了Smalltalk中的设计，去掉了大量研究平台部分，保留
   最简化也是最实用的技术指标体系，新增多broker支持，新增人工智能策略模块。将会是今后的
   唯一开发项目。"*

第 5 条是**产品目标**：多 broker 的类型层已在，AI 策略模块尚无代码；当前实现程度只看
`docs/STATE.md` 最新节，不从这段沿革推断。

**归宿（owner 2026-11-21 逐字）**：*"换句话说，我用了几十年时间，从Smalltalk出发，归宿到BEAM，
以后不会再变化了。"* owner 把 BEAM 定为几十年路线的终点、不再变化；这与本文件的 BEAM-native
约束一致（R16–18、R42），不新增实现义务。

**技术选择的根本原因（owner 2026-11-21 逐字，属 owner 的技术判断，不是我的实测结论）**：
*"gleam没有Smalltalk简单，但是相比其他语言，都已经极其简单，尤其是在如此简单的小巧语言中，
实现完整的严格type系统，纯粹functional，以及无成本的分布式并发，堪称奇妙。BEAM也是唯一做对
分布式计算的。BEAM上面的各种语言互通，直接互动。也是一绝。这是技术选择落地的根本原因。
论优劣，各种候选语言于此有天壤之别。"* 这段解释「为什么归宿是 BEAM/Gleam」，不是新的实现义务。

owner 另举对照（逐字）：*"你看Swift作为一种苹果加持、业界高度评价的新近语言，为了解决数据竞争
篡位问题，用了多少年加了多少设计进去，搞到现在很多程序员都搞不定他的6.x版严格设计要求"*；owner
又补充（逐字）：*"其实你可以实地考察一下Swift设计，看看并发计算多任务等等版本演变历史，这已经是
一种很负责任的高质量语言了。"* 按 owner 的指示查了官方资料（**我核实的版本史，非推断**）：

- 2020 年发布并发路线图，data isolation enforcement 历经多年多个版本（swift.org, *Swift 5.10 Released*）。
- Swift 5.5（2021 秋）：async/await（SE-0296）、structured concurrency（SE-0304）、actors（SE-0306）等一次落地（*Swift 5.5 Released!*）；5.7 引入 `Sendable`（5.10 发布文）。
- Swift 5.10：`-strict-concurrency=complete` 在全语言范围做完整 data isolation，仍只是 warning；官方明确承认误报、6.0 重点是改善可用性（5.10 发布文）。
- Swift 6：opt-in 语言模式把竞态诊断变成 error，可按 target 逐步迁移、旧模式互通；官方迁移指南直说「数百甚至上千 warning 并不罕见」并给渐进方案（*Announcing Swift 6* / *Migration Strategy*）。官方原话：Swift 6 *"marks the start of the journey to make data-race safety dramatically easier"*。

**推断（我的，不是 owner 说的）**：Swift 的复杂度来自在已有成熟语言/生态上补静态竞态安全；owner 评它「很负责任的高质量」与「设计多年、6.x 难用」并不矛盾。此处只解释对照，不改 BEAM 归宿，也不新增实现义务。

owner 再把对照推到其它语言（逐字，属判断）：*"同样的问题，在其他语言中不是没有，不是已经解决了，而是作者根本没看到问题，或看到问题，但是已经没办法彻底纠正，或者有办法彻底纠正，但是成本太高，Swift早期版本是没有Actor的，多任务多线程是通过 objc写的旧的框架实现的。"*

其中 Swift 早期部分**我查证属实**：WWDC16 的 *Concurrent Programming With GCD in Swift 3* 讲的是 GCD dispatch queues / run loops / 自建线程；Apple 开发者论坛 2018 年官方答复明说 Swift *"provides no automatic mechanism"*，要用 dispatch queues、NSOperation、NSThread、pthreads 等平台框架，且 Swift 5 不会有大并发改动（[WWDC16/720](https://developer.apple.com/wwdc16/720)、[Apple Developer Forums, 2018](https://developer.apple.com/forums/thread/111009)）。actor 直到 5.5 才进语言（同上 swift.org 5.5 发布文）。其它语言「没看到/改不了/成本太高」三分法是 owner 的判断，我没有逐语言核验。

owner 收束（逐字，判断）：*"一个好的多任务语言设计是困难的，即便是对于llvm 作者来说，也一样是需要很多年经过团队努力才能逐步完成的。gleam就很惊艳了。"* 这是 owner 对难度与 Gleam 的评价，不是我的量化比较；只作技术选择背景，不新增实现义务。

**核查（回答 owner 追问）**：上面说的「llvm 作者」= **Chris Lattner**——Swift 的创建者，也是 LLVM、Clang、MLIR、CIRCT 的共同创建者；Mojo 出自他创立的 Modular AI。按他[个人主页](https://nondot.org/sabre/AboutMe.html)（2026-09 更新）的工作履历，现任 Qualcomm EVP, Advanced AI and Platforms。

owner 对 Mojo 的亲测结论（逐字，判断）：*"我也试过Mojo语言，但是经过比较，是一个试图借助Python资源获得优势的Swift简化版，有新的东西他会放进mojo，因为公司是他的，Apple的东西不太好驾驭，但是还是太早起，并且跟python世界绑定，不喜欢。不如gleam+BEAM，BEAM是实战考验出来的。"* 归入 owner 的技术评价；我未实测 Mojo，不替它背书，也不据此产生实现义务。

owner 再补充（逐字，判断）：*"前段时间，美国一些重要的IT科技公司系统出现问题，是长期未被发现的bug被利用造成的，有心人利用AI发现了那些隐藏的bug。语言和平台的选择，需要慎重的原因在此。"*

owner 2026-11-21 追加指认（逐字）：*"你提到PHP，对，我指的是这件事。PHP语言相关的一个事件。"* —— 这个举例的确指就是 **PHP2Shell** 漏洞，不是我上一轮泛化成的「IT 故障集群」。

**查证（新闻，不是本项目事实；PHP2Shell 在 2026-10，同周故障在 2026-11，都在三个月内）**：

- **PHP2Shell 确凿**：两个 critical 内存破坏漏洞 `CVE-2026-109618` / `CVE-2026-109619`，CVSS v4.0 **9.2/10**，未认证远程代码执行。OpenAI 的 "Patch the Planet" 计划下，Calif（用 GPT-5.6 Sol）与 Wiz（用 Gemini 4 Argon + GPT-5.6 Sol）于 **2026-10-21** 发现并协调披露，PHP 项目同日紧急发补丁（8.5.12 / 8.4.27 / 8.3.36 / 8.2.35）。漏洞自 PHP 5.x（约 2004）即存在、潜伏十余年：Wiz 说此前「太难利用」正是它无害的原因，而 LLM 能把 exploit 适配到不同版本/配置/内存布局——*"With AI this is no longer a barrier"*。PHP 驱动约 70% 网站（Axios、Wiz、Ars Technica、csoh.org）。
- **「被利用」确有两面**：Amazon 称该漏洞被 *"broadly exploited in the wild"*，蜜罐记录到 10-17（披露前 4 天）的探测尝试，CISA 于 10-26 把两个 CVE 纳入 KEV 目录（Ars Technica、csoh.org）。但 OpenAI 说「据我们所知，前沿 AI 在攻击者之前发现了漏洞」，披露时无在野利用确证；Wordfence / Wiz 到 10 月底也没看到大规模成功的端到端利用。
- **NSA 故障 = 打补丁引起，不是被攻击**：DNI Jay Clayton 在 Fox Business 说 *"The patching that has gone on following [a PHP vulnerability] has caused some of these systems to not come back up when you patch them as expected… That is what has happened at the NSA today."*；11-18 众议院国土安全委员会上他说高度确信不是协同/国家支持的攻击、各故障彼此无关（Breitbart / Apex Globe Media / pengnewtech 引 Fox Business 与听证）。NSANet 11-17 下线并蔓延到 Georgia 密码中心，NSA 对外仍称「例行维护期间的临时降级」。这不再是上一轮记的「单一来源转述」。
- **同周其它故障各有自身归因**：微软 7 月更新 bug（高流量 + 服务器下线时显现）、Chase 自家软件 bug、FAA 老化设备 + 换线数据洪流、Apple 内部更新；Rubio / Mullin / FAA 都否认协同攻击或 AI 关联。Warner 说 AI 正以空前速度找漏洞、导致多系统同时仓促打补丁。
- owner 追加推理（逐字）：*"PHP是广泛采用的语言，这件事情出来后，影响很大，重度使用PHP的公司当然需要跟进查漏洞补补丁。所以如果真是有组织大黑客或者地下组织，想要做点什么，就不是这么简单了。好在没有那么大的后台。"* —— 前提（PHP 广泛采用、全行业紧急补丁）上面已核实；「有组织势力介入会更复杂、幸而后台不大」是 owner 的判断，我没有证据支持或反证，只作背景记录，不新增实现义务。
- 结论仍按 owner 判断收录：语言/平台选择要慎重。这是 owner 的判断、上面是新闻事实核查；都不改 glibe 裁定、不新增实现义务。

The specification lives in the code's own `////` module docs and `///` item
docs — `gleam docs build` renders them into `package-interface.json`, so the
compiler checks them. `DEVELOPER_GUIDE.md` is a navigation aid for reading
those docs, not a second specification. Most function bodies are still
`todo as "..."`; the `Todo found` warnings are the remaining work.

## The engine is Erlang-target, and no hand-written target source

`gleam.toml` declares `target = "erlang"`; `src/` is 19 `.gleam` files and
currently has no `@external` — **that is a fact about the skeleton, not a
goal**. `@external` is a normal, necessary Gleam design; it is not FFI and
does not rest on hand-written Erlang/Elixir. Owner, 2026-11-15: *"exteranl
is not equal to FFI, and is not based on handwritten erlang or elixir,
while handwritten erlang and elixir by you are prohibited, external 是必须的
正常的合理的gleam设计"*（全文见 `docs/RULINGS.md`「2026-11-15
08:28」）；同一句里他还说 *"0 external 并不一定是好事，但是external
不等于手写erl，这一点AI总是弄混"*. Bind an OTP
module with `@external(erlang, ...)` or use a `gleam add` package whenever
a runtime API is actually needed. Owner, 2026-11-15 09:09: *"BEAM里面有的
东西好像都不用另外做什么，直接可用 …… 归元无二路，方便有多门，gleam
是最方便的那扇门"*. Measured with a zero-dependency, zero-hand-written-erl
probe: `@external(erlang, ...)` reaches OTP BIFs directly, and an Elixir
module (`Elixir.String`) through the same `erlang` compilation target.
Verbatim and the three probes: `docs/RULINGS.md`「2026-11-15 09:09」.

Owner, 2026-11-15 09:22: *"你担心依赖BEAM的问题，不用担心，我就是打算靠BEAM
吃饭的。你没看到我最近的项目都是gleam"* — BEAM-native storage is a property,
not a portability cost to hedge against; the export format stays an open
question. The compiled language facts behind this section live in
the `gl-center` skill's `references/`
(`~/.workbuddy/skills/gl-center/references/beam-doors-measured.md`);
`docs/gleam-thinking-core-to-memory.md` is the byte-equal git mirror of
`gleam-core.md` (`cmp` = 0), and `docs/externals.md` is a linked reference copy.
Verbatim and the inode measurements: `docs/RULINGS.md`「2026-11-15 09:22」.

What is banned is **us writing `.erl` / `.ex` / `.mjs` source into `src/`**.
Owner, 2026-11-15: *"我已经转向了glibe这个拒绝JS target的项目，mjs也是
祸根之一，AI不会自我约束，所以要换成erlang target，并且禁止手写erl"*. The
target declaration is a build-tool fact, not an AI promise: on the Erlang
target a JavaScript-only external is a compile error
(`error: Unsupported target`). A hand-written `.erl` in `src/`, by contrast,
compiles green into a `.beam` — which is exactly why it needs the explicit
ban. The `.erl` files under `build/packages/` belong to hex dependencies,
not to this source tree.

**No web front, no `webclient/`.** The old R16–R18 rulings allowed a separate
JavaScript-target package, but owner ordered *"webclient删除，继续做"* on
2026-11-19 and it was removed in commit `525a670` (history retained in
`docs/RULINGS.md`「2026-11-19 08:30」). The view is the plushie **Dashboard**;
no JS target, no hand-written `.mjs`.

## The lists are newest-first on purpose

Gleam's `List` is a singly-linked list: prepend and read the head are O(1),
while `length`, `last`, `append` and `reverse` walk it. Every data list that
grows with the stream is therefore archived **newest first** (prepend), and
every member access reads the **head**.

The count is never walked: `DataBar` carries `idx`, its position in the
stream, so `bars_listed` is `newest.idx + 1` — one head read. `SourceBar` has
no `idx`: a provider's closed candle does not know its position until
`sourcebar.to_databar(sourcebar, idx)` gives it one at the boundary. That
`idx` also turns every span and window size into subtraction instead of a
walk.

Do not guess from a name: `bars_listed` does not count, `last_bar` reads the
head, and `exited_branch` does not search.

The chart is **not** drawn backwards. In glibe the only publish point is
`timeframe.working_databar_archived`; the just-archived bar is read from
`databar_list` head and pushed **one bar at a time** through
`dashboard.push_one` → `bar_stream_chart.push`. Chronological order is a
projection, never a second stored copy — see `DEVELOPER_GUIDE.md` §6 and
`src/glibe/app/runtime.gleam` `////` (the `update` body that will do this is
still a `todo`).

An exported file does **not** have to be in time order. Owner, 2026-11-15:
*"倒序资料肯定不影响消费呀 …… 旧数据放前面？那不是prepend是什么"* —
read a newest-first file one record at a time and prepend, and the List
you hold is oldest-first with no `reverse` at all (measured in a compiled
probe). A keyed store has no file-order property to begin with. The export
format itself (JSON / CSV / binary term / a hex database) is still an open
discussion, not a settled choice — `DEVELOPER_GUIDE.md` §6.6.

That is the design, **not** a claim that the reference implementation got
everywhere right. Owner, 2026-11-15: *"关键技术是stream模式，纵有万千条k线，
系统里面其实只有一根在工作，那就是 working_databar, you almost always only
need that one databar."* So every place that reverses the whole history is a
place somebody asked for the entire history instead of that one bar.
`DEVELOPER_GUIDE.md` §6.5 / §7(e) asks exactly that question at each of the
9 `reverse` sites found in the reference code (7 Gleam + 2 JS FFI); two of
them do run per bar / per poll. The first test for any chart implementation
is therefore whether it can update **one** bar. Owner (08:13): *"AI声称可以
单bar更新，确实最初版本是做到的，如果你发现目前不是，那是他后来搞错了，
不是不可以改正"*. In glibe this is settled by our own `bar_stream_chart`
(1.2.1, local path dep until re-publish): `push(bar) -> chart` is the one-bar
update, and `dashboard.push_one` pins that shape in a passing test — see
`DEVELOPER_GUIDE.md` §6.5.

The guide also has the full list inventory, the exceptions and boundary
cases, the export-format discussion (§6.6), and a table saying how to fill
each remaining `todo`.

- Plan tree: `.planning/BRIEF.md` + `.planning/ROADMAP.md` (05-doc-tdd was archived)
- Developer guide (list efficiency, filling the skeleton): `DEVELOPER_GUIDE.md`
- Rulings and owner wording: `docs/RULINGS.md`
- Current state: `docs/STATE.md` (newest section at the top)
- Compiler interface check:
  `gleam export package-interface --out /tmp/glibe-interface.json`

The pre-`doc-tdd` implementation, tests, guard scripts and notes are kept
readable under `deprecated/2026-11-12-pre-doc-tdd/` as history only. No
project-level guard script exists here; the Gleam compiler's own commands
are the check.

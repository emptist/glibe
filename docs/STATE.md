# State — glibe

Measured facts. Each line carries the day it was taken, so a later reader can
tell a measurement from an intention. **The newest section is the state.** Older
sections are kept as history, not as the current answer.

## 2026-11-16 03:09 (当前状态)

- **owner 逐字**（上一会话末，授权提交）：*"你可以提交你所说的知识中心
  里面的变动，很好的。"* ⇒ **已提交** `~/gits/gleam-language` 的
  **`dc736df`**，5 files / 363 insertions(+) / 3 deletions(-)：
  `README.md`、`knowledge/SKILL.md`（M），`beam-doors-measured.md` /
  `beam-cross-platform-measured.md` / `externals.md`（A）。提交后工作树
  干净。该仓库**无 remote** ⇒ 只提交、无法 push。逐字与查证链见
  `docs/RULINGS.md`「2026-11-16 03:09」。
- **提交前的计数订正**：知识中心 `README.md` §2 原写
  `20 files / 2 new / fifteen references`；实测 `knowledge/` 21 文件、
  其中 3 份本轮新增，skill `references/` 16 个 ⇒ 改为
  `21 files / 3 new / sixteen references`，并把
  `beam-cross-platform-measured.md` 补进「same way」那句。
- **更正（我自己的错）**：上一轮答复称 `~/.workbuddy/skills/
  gleam-language` 是「另一个独立 git 仓库、没提交那边」——是推断、
  未经实测、且是错的。实测 `git rev-parse --show-toplevel` 报
  *"fatal: not a git repository (or any of the parent directories):
  .git"*，三层候选 `.git` 全不存在 ⇒ **没有第二个仓库，也没有
  「一起提交 skill」这个动作**；skill 目录只是硬 `ln` 的消费者。
  历史注记里「带他人未提交改动」也不准确：提交前逐行核对 diff，
  改动全部只关于本会话新增的三份文件与索引条目。
- **硬链接提交后仍活**：`externals.md` inode `339942506` / links 3
  （知识中心 + skill refs + `tools_ib/glibe/docs/`），
  `beam-doors-measured.md` `340468671` / links 2，
  `beam-cross-platform-measured.md` `340471733` / links 2，
  `SKILL.md` `324709842` / links 2；`find -type l` 全空。
- **门禁复核（只读，`src/` / `test/` 一行未改）**：`format --check` /
  `test`（**16 passed**）/ `docs build` / `export package-interface`
  （**modules 15**）/ `build` 全 0；WAE **exit 1 / 196 warnings** =
  117 unused argument + 76 Todo + 2 unused private constructor +
  1 unreachable pattern，与 09:22 节逐项一致、**零漂移**（R48 清单）；
  核心镜像 `cmp` 0。`glibe` 工作树干净，`HEAD` = `origin/doc-tdd`
  = `b17dae4`。
- **范围**：只写文档与 memory，不新增 R 编号、不增减决策区（仍 3 项、
  不催、不预设推荐）、不改 `src/` / `test/` / `webclient/` /
  `gleam.toml` / `manifest.toml`。按 R19 ④ 逐条填 body 仍是下一批
  工作，**不替 owner 挑哪一个**。

## 2026-11-15 09:22 (历史状态)

- **owner 逐字**（三条，全文在 `docs/RULINGS.md`「2026-11-15 09:22」）：
  ① 经实测验证的 Gleam 语言感悟写入 `~/gits/gleam-language`，或用
  **硬 `ln`**（*"注意我说的是硬，不是symbol link，this is unix family
  OS filesystem"*）连接过去；② *"你担心依赖BEAM的问题，不用担心，
  我就是打算靠BEAM吃饭的。你没看到我最近的项目都是gleam"*；
  ③ *"你可把exteranl.md ln 过来方便查阅"*。
- **语言知识落点（已落地）**：新建
  `~gits/gleam-language/knowledge/beam-doors-measured.md`（编译实证、
  真实 exit code、未取证边界），`ln` 到 skill `references/`，同
  inode `340468671`、links 2；`ln -f` 把原本字节相同但 inode 不同的
  两份 `externals.md`（`339942506` / `339942149`）并为一名，再 `ln`
  到 `glibe/docs/externals.md`，三名同 inode `339942506`、links 3；
  `find -type l` 全空（零 symlink）。`SKILL.md` 用 `open(..., "r+")`
  就地加索引条目，inode `324709842` / links 2 不变；知识中心
  `README.md` §2 的 shelf 计数与「`cmp` 分不出副本与链接」同步。
  该仓库**无 remote**且有他人未提交改动 ⇒ 只写、未提交、未 push。
- **更正（我自己的错）**：此前「不改知识中心任何文件」是 AI 自设
  边界，不是 owner 裁定；把「BEAM 专有、不可跨生态读、不可移植」
  写成格式选项的**代价**也不成立 —— 靠 BEAM 吃饭，BEAM 是方向。
  `docs/PENDING_DECISIONS.md` 第 3 项 A / C 与 `DEVELOPER_GUIDE.md`
  §6.6 已改成性质陈述；08:44–08:58 历史注记原文不改写；**格式
  仍待探讨**，不因此选 ETF、不因此禁 JSON，选项平列（08:27）、
  决策区不增不减（仍 3 项）。
- **改动（只写文档与链接）**：`docs/RULINGS.md` 追加 09:22；
  本文件新增本节；`DEVELOPER_GUIDE.md` §6.6 / §10 / §11、
  `README.md`、`docs/PENDING_DECISIONS.md`、`docs/HANDOFF.md`、
  两份 memory 同步；`glibe/docs/externals.md` 是硬 `ln` 的查阅
  入口，不是新写规格（08:16 禁手写目标源码仍管 glibe）。
  `src/` / `test/` / `webclient/` / `gleam.toml` / `manifest.toml`
  一行未改，不新增 R 编号、不新增 guard sh。
- 门禁：`format --check` / `check` / `test`（16 passed）/ `docs` /
  `package-interface`（modules 15）/ `build` 全 0；WAE exit 1、
  196 warnings（R48 固定清单，未变）；核心镜像 `cmp` 0。

## 2026-11-15 09:09 (历史状态)

- **owner 逐字**（全文在 `docs/RULINGS.md`「2026-11-15 09:09」）：
  *"BEAM里面有的东西好像都不用另外做什么，直接可用，gleam语言和erlang
  elixir都是BEAM的门，归元无二路，方便有多门，gleam是最方便的那扇门。"*
  ⇒ 能力已在 VM 里，取用不另造桥接层 / codec / 手写目标源码；
  **不是新增机制**，不推翻 R31 / R33，不改 08:16「禁手写 erl」。
- **编译实证**（`/tmp/glibe_beam_door_probe`，真实 exit 0）：
  ① 零依赖（`manifest` 包数 0）、零手写 `.erl`，四行 `@external`
  到 `erlang:*` / `lists:reverse` 全部可用，两个变体 ETF 往返
  各 `True`；产物只有 `.beam` 与生成的 `@@main.erl` runner stub。
  ② 本机 Elixir 1.20.4 / OTP 29；同一个 `erl` 会话里 `lists` 与
  `'Elixir.String'` 同为 `{module, …}`，`upcase(<<"beam">>)` →
  `<<"BEAM">>`（Erlang 字符串字面量是 list，须传 binary）。
  ③ `gleam run -m elixir_door` 用一行
  `@external(erlang, "Elixir.String", "upcase")` 打印 `"BEAM"`，
  编译目标仍是 `erlang`；Elixir 库只多一个 `ERL_LIBS` code path，
  OTP 内置 BIF 连这一步都不用。`monotonic_time()` 本次实测为
  `-576460751688905208`（我原先 `>0` 的假设不成立，只记测量值）。
- **语言知识落点**：`~gits/gleam-language/knowledge/externals.md`
  §2 / §4 / §5 与 core §9 已逐字同向；按 08:30 **不写进全局
  Memory**。本轮另把项目 `.workbuddy/memory/MEMORY.md` 压缩成
  索引（逐字仍只在 `docs/RULINGS.md` 与当日日志），历史日志未删。
- **改动（只写文档）**：RULINGS 追加 09:09；本文件新增本节；
  `DEVELOPER_GUIDE.md` §6.6 / §10 / §11、`README.md`、
  `docs/HANDOFF.md`、两份 memory 同步。`src/` / `test/` /
  `webclient/` / `gleam.toml` / `manifest.toml` 一行未改，探针全在
  `/tmp`，不新增 R 编号、不新增 guard sh、决策区不增不减。
- 门禁：`format --check` / `check` / `test`（16 passed）/ `docs` /
  `package-interface`（modules 15）/ `build` 全 0；WAE exit 1、
  196 warnings（R48 固定清单，未变）；核心镜像 `cmp` 0。

## 2026-11-15 08:58 (历史状态)

- **owner 四段逐字**（全文在 `docs/RULINGS.md`
  「2026-11-15 08:44–08:58」）：08:44 要求**探讨**导出格式
  （json / csv / 二进制）与读取方法（是否必须按时间顺序存储）；
  08:49 *"gleam add 所有BEAM 也就是hex.pm package 并且直接通过
  `@external` 使用？不知道Gleam世界如此简单？"*；08:55
  *"输出json是一种最懒的做法 …… 或许hex有合适gleam的原生数据库
  都不一定的"*；08:58 *"倒序资料肯定不影响消费呀 …… 旧数据放前面？
  那不是prepend是什么"*。
- **认错（本轮）**：本轮开头确按 R19 全文加载 `gleam-core.md`
  （379 行），镜像 `cmp` exit 0；但**加载了却没照着做** —— 第一版
  探针手写了 `int_to_string` / `digits` / `join_with` /
  `bool_to_string` 和定长位数组 codec，而 `gleam_stdlib` 早在
  `gleam.toml:6`。违反 core §8 / §12 与 owner 先前的
  「gleam add 去加上你却少的东西，不要绕圈子替换」。探针已重写为
  只用 stdlib + 一行 `@external`，下方数字全部来自重写后的产物。
  另把 JSON 当唯一格式、没去 hex 查方案，也是 08:55 批评的「懒」。
- **Q2 已由 owner 裁定：导出文件不必按时间顺序存储。**
  编译实测（`/tmp/glibe_format_probe/src/read_order.gleam` exit 0）：
  newest-first 文件逐根读 + `[record, ..acc]` → `10,20,30`，
  `list.first` 是最旧那根；全程零 `reverse` / `append` / `length`。
  按 key 存取的 `dets` / `mnesia` / `sqlight` 里连「顺序」属性都没有
  （DETS 乱序插 3 根、按 timestamp 查找全命中、变体 tag 保真）。
- **Q1 格式＝探讨中，不裁定**，选项平列、不预设推荐、不催，按
  08:27 约定只写进那一份单独文档（决策区 **2 → 3 项**，第 3 项
  依赖第 1 项；若第 1 项选「不引入」，格式问题自动消失）。
- **查证（实测，非推测）**：`glibe/src` 零序列化零文件 IO，
  `Timeframe:106-120` 无 `sourcebar_buffer` / `export_flush`；
  `SourceBar` 九变体、grade 在变体里（`api/sourcebar.gleam:43`），
  `Timestamp` 是 `pub opaque` 纳秒值（`gleam_time/timestamp.gleam:100`）。
  glib 的 positional JSON array 必须整份 parse，`sourcebar.gleam:524-535`
  逐字 *"The variant is not spelled — the reader is told the interval"*，
  `sourcebar_export.gleam:151-176` 有**三代格式兼容兜底**。
  hex 实读确有 Gleam 原生 `sqlight` / `marmot` / `parrot` / `gsv` /
  `tysv`、BEAM 侧 `khepri` / `esqlite` / `concord`、时序 `oban_met`；
  OTP 29 内置 `mnesia` / `dets` / `ets`（`code:ensure_loaded` 实测
  `{module,…}`，连 `gleam add` 都不用）。
- **编译探针**（Gleam 1.19.2 / OTP 29，`/tmp/glibe_format_probe`，
  真实 exit 0）：`@external(erlang, "erlang", "term_to_binary")` /
  `binary_to_term` 两行零 codec 往返，`ETF round-trip keeps grade +
  all six fields: True`（两个不同变体分别验过）；单根 JSON object
  **98** / ETF **73** bytes，10 根 JSON array **991** / JSON lines
  **989** / ETF 整表 **727**；`gleam add simplifile` →
  `Added filepath v1.1.2` / `Added simplifile v2.7.0`，
  `append_bits` 逐根写两根得 **145 bytes**（每根 73），无 buffer
  无 reverse。`term_to_binary/2` 选项与 `binary_to_term/2` 的
  `safe` 警告官方页三次抓取超时只返回页首 → **未取得逐字、不引用**。
- **改动（仍只写文档）**：`docs/RULINGS.md` 追加 08:44–08:58 注记；
  `DEVELOPER_GUIDE.md` 新增 §6.6、§6.1 与 §7(e) 加 08:58 订正、
  §10 / §11 同步；`README.md` 去掉「export on quit 也 reverse 一次」
  的过时例、加顺序裁定与 §6.6 指针；待裁决区新增第 3 项；
  本文件新增本节；`docs/HANDOFF.md` 指针、两份 memory 同步。
  `src/` / `test/` / `webclient/` / `gleam.toml` / `manifest.toml`
  一行未改，探针全在 `/tmp`，历史节原文不改写，不新增 R 编号、
  不新增 guard sh。
- 门禁：`format --check` / `check` / `test`（16 passed）/ `docs` /
  `package-interface`（modules 15）/ `build` 全 0；WAE exit 1、
  196 warnings（R48 固定清单，未变）；核心镜像 `cmp` 0。

## 2026-11-15 08:38 (历史状态)

- **owner 逐字**（全文 `docs/RULINGS.md`「2026-11-15 08:38」）：
  *"why should it be reversed before exporting? to answer this you have
  to answer no reason, since whether the data in disk is newest first or
  oldest first, it will never prevent a comsumer to use it. The key is
  how the comsumer will use it. … So how the comsumer is using the
  exported data today in glib? that is where to inspect."*
- **认错**：07:59 / 08:13 我答的是「能不能删掉 reverse 而不动别的」，
  并把 oldest-first 写成文件格式必要条件 —— 把**一个消费方的便利**
  写成了**数据的性质**。按 owner 的问法，答案是「没有理由」。历史
  注记原文不改写，更正写在 08:38 注记。
- **消费方实测**（全部 file:line 在 `docs/RULINGS.md` 08:38）：写侧
  三处（`trading/export.gleam:21-25` reverse；`census_import.gleam:119-127`
  与 `:171-184` 不 reverse）都产出 oldest-first，FFI `write_session`
  不重排 ⇒ reverse 只是让 newest-first buffer 追上另外两个写方。
  消费链是 `trading/ingest.gleam:124-147` `run_offline` →
  `sourcebar_export.read_payload:139-149` → `feed_all:75-81` 的
  `list.fold` **从头部一根一根喂** → `sourcebar_gate`；
  `timeframe.gleam:280-283` 读头判重、`:294-296` 按头算 `idx`，
  流**假定时间向前、不校验顺序**。`binance.gleam:198` 的
  `GLIB_SEED_FROM_FILE` 与 `census.gleam:212-213` 是同批文件的
  其余消费方；`test/sourcebar_export_test.gleam:122-150` 把
  oldest-first 钉成了契约。磁盘 `data/*.json` 抽样 10 个首尾递增。
- **结论**：这次 reverse 是为**一个消费方**做的边界投影，可等价地
  放读侧、也可随消费方形状改变而消失；按 stream 判据真正要问的是
  消费方本身 —— `run_offline` 重放整份历史，要的是整个历史而非
  那一根 `working_databar`。glibe 的 `Timeframe` 仍无
  `sourcebar_buffer` / `export_flush`，待裁决第 1 项收窄为「这条
  消费方路径要不要存在」。
- **改动（仍只写文档）**：`docs/RULINGS.md` 追加 08:38 注记；
  `DEVELOPER_GUIDE.md` §6.1 / §7(e) / §10 / §11；
  `docs/PENDING_DECISIONS.md` 第 1 项事实与选项重写；
  `docs/HANDOFF.md` 指针；当日日志与 `MEMORY.md` 同步。
  `src/` / `test/` / `webclient/` 一行未改，不新增 R 编号、
  不新增 guard sh，决策区仍 **2 项**。
- 门禁：`format --check` / `check` / `test`（16 passed）/ `docs` /
  `package-interface`（modules 15）/ `build` 全 0；WAE exit 1、
  196 warnings（R48 固定清单，未变）。

## 2026-11-15 08:27–08:30 (历史)

- **08:27 owner 逐字**（全文 `docs/RULINGS.md`「2026-11-15 08:27」）：
  *"你不可再使用这种提问方式，有决策问题写入 单独文档，我会去看。"*
  08:16 我用对话选项卡片问了 `webclient/` 收紧一事，**提问方式作废**；
  问题本身已在单独文档的「需要你决定」第 2 项，本轮**不重问、
  不重列、不催**。执行约定：决策问题只写进那一份单独文档；选项
  一律平列、不预设推荐（第 2 项 A 的「推荐理解」已删）；不催、
  不设时限、不把未答项当否决。决策区**仍为 2 项**：
  `sourcebar_buffer` 导出、`webclient/` 是否收紧，两项都未裁定。
- **08:28 owner 逐字纠正**（全文「2026-11-15 08:28」）：
  *"0 external 并不一定是好事 … exteranl is not equal to FFI, and is
  not based on handwritten erlang or elixir, while handwritten erlang
  and elixir by you are prohibited, external 是必须的正常的合理的
  gleam设计"*。**我 08:16 把「零 `@external`」列进「当前合规事实」
  是错的**：那只是骨架现状，不是目标、不是成绩；08:16 探针 2 里
  有问题的**是我手写的 `.erl` 文件**，不是 `@external` 属性。官方
  Externals guide 逐字 *"We recommend minimising use of externals,
  most projects won't use any at all"* 是用度建议与统计，不是
  「零才好」。需要运行时 API 时正常写 `@external(erlang, …)` 或
  `gleam add` 包；禁的只有 AI 手写 `.erl` / `.ex` / `.mjs` 进 `src/`。
- **08:30 owner 逐字**（全文「2026-11-15 08:30」）：*"如果没有找到
  关于FFI仅限于JS的原因，那么AI没记下来，他可能记录到workbuddy的
  全局Memory里面去了。很愚蠢的做法。"* 查证：FFI 限于 JS 的
  **理由找到了**，在 `~gits/gleam-language/knowledge/externals.md:14-20`
  §2（BEAM 同 VM ⇒ external；JS 跨运行时 ⇒ FFI），skill 副本 `cmp`
  exit 0；但该文件在知识中心仓库是 **`??` 未跟踪**、`SKILL.md` 是
  `M`、仓库无 remote ⇒ **没进版本历史**。WorkBuddy 全局 Memory 里
  只有 R14/R15 一句摘要，没有这个理由。⇒ 语言知识的家是
  `~gits/gleam-language`；本轮**不往全局 Memory 写语言知识**，也不
  擅自提交那个带别人未提交改动的仓库。
- **改动（仍只写文档）**：`docs/RULINGS.md` 追加 08:27 / 08:28 /
  08:30 三条注记；`README.md` 去掉「zero @external」成绩写法、写明
  external 是正常设计；`docs/HANDOFF.md` §1 指针 / §5；
  待裁决区头部记方法约定、去推荐标注、事实行标「现状非目标」；
  `DEVELOPER_GUIDE.md` §10 / §11；本文件；项目 memory 同步。
  `src/` / `test/` / `webclient/` 一行未改，08:16 及更早原文
  不改写，不新增 R 编号、不新增 guard sh。
- 门禁：`format --check` / `check` / `test`（16 passed）/ `docs` /
  `package-interface`（modules 15）/ `build` 全 0；WAE exit 1、
  196 warnings（R48 固定清单，未变）。

## 2026-11-15 08:16 (历史状态)

- **owner 逐字**（全文与实证在 `docs/RULINGS.md`「2026-11-15 08:16」）：
  *"注意经过对比和实证，我已经转向了glibe这个拒绝JS target的项目，
  mjs也是祸根之一，AI不会自我约束，所以要换成erlang target，并且
  禁止手写erl"*。这是对 07:59 审计给出的理由与铁律，不是新编号，
  不改写 R14–R18 及更早注记的历史原文。
- **三个探针实测**（`/tmp/glibe_target_probe`，Gleam 1.19.2，
  `target = "erlang"`，逐条报真实退出码）：
  ① JS-only `@external(javascript, "./foreign.mjs", "now")` →
  `gleam build` **exit 1**、`error: Unsupported target`（没有 Erlang
  实现就不能编译）；② `src/hand_written.erl` 配
  `@external(erlang, "hand_written", "go")` → **exit 0**，
  `hand_written.beam` 被产出（**编译器不拦手写 erl**）；
  ③ 孤立 `src/foreign.mjs` → **exit 0**，只复制进
  `_gleam_artefacts/`，无 JS 运行时产物。⇒「禁止手写 erl」是
  erlang target 之外必需的第二半，且这一半**编译绿不等于合规**。
- **glibe 当前合规事实**：`gleam.toml:3` 是 `target = "erlang"`，
  全文件无 `[javascript]` 节；`src/` = 15 个 `.gleam`、零个非
  `.gleam` 文件、零 `@external`；`build/dev/erlang/glibe/` 唯一的
  `.erl` 是 `glibe@@main.erl` runner stub，`find build -name '*.erl'`
  共 196 个（`80 dev` + `116 packages`），其余全属 `build/packages/`
  下的 hex 依赖源码。`webclient/` 仍是 R18 的独立 JS-target 包，
  1 个 `.gleam`、生成 `.mjs`、零手写 JS。
- **一处未擅动**：`webclient/gleam.toml:8` 与
  `webclient/src/webclient.gleam:20` 还留着 R16 / R18 的手写
  `.mjs` 兜底许可，形状正是「AI 自我约束」。owner 这句话没有点名
  `webclient/`，故不删、不改写、不宣布作废；是否收紧记入待裁决区。
- **决策区 1 项 → 2 项**：新增「拒绝 JS target 是否一并收紧
  `webclient/`」；原 `sourcebar_buffer` 导出一项原样保留、不催。
- **改动（仍只写文档）**：`docs/RULINGS.md` 追加 08:16 注记；
  `README.md` 新增 target 小节；`docs/HANDOFF.md` §1 指针 / §5
  「不要做」同步；待裁决区新增第 2 项；
  `DEVELOPER_GUIDE.md` §10 门禁复核时间、§11 边界；本文件新增本节；
  当日日志与 `MEMORY.md` 同步。`src/` / `test/` / `webclient/`
  一行未改，历史节原文不改写。
- 门禁：`src/` / `test/` 未改，复核结果与 07:42 / 07:59 / 08:13
  一致（`format --check` / `check` / `test` / `docs` /
  `package-interface` / `build` 全 0；`test` 16 passed；
  `modules: 15`；WAE exit 1、196 warnings 为 R48 固定清单）。

## 2026-11-15 08:13 (历史状态)

- **把 07:59 的两问交给 owner 后收到答复**（逐字与论证在
  `docs/RULINGS.md`「2026-11-15 08:13」）：
  - `sourcebar_buffer` 导出 → **「一会儿讨论这个问题」**：保持待裁决，
    07:59 的技术事实与四个选项原样不动、不预设、不催。
  - plushie 选型 → **「那个里面的绘图是手搓的，AI声称可以单bar更新，
    确实最初版本是做到的，如果你发现目前不是，那是他后来搞错了，
    不是不可以改正」**。
- **07:59 的 B.5 判断已修正**：我原来把「当前实现不满足第一条门槛」
  当成选库结论，落点错了。绘图是手搓的，判据问的不是库的能力上限，
  而是我们自己的实现有没有守住「只吃 head 那一根」；能力 owner 已
  确认最初版本做到过。`src/try_plushie.gleam:401-403` `subscribe()`
  返回 `[]`、`src/fusion_view.gleam:231-237` `window()` 每次 `view`
  整窗 `length`+`drop`+`take`+`reverse`，是**后来改错的实现回归、
  可以改正**，不是「不能用他」的证据。⇒ **不判当前不可用、不排除
  plushie、不转向别的库**。同向的 owner 逐字见
  `try_plushie/plushie-architecture.md:1463`。
- **两条查证边界如实保留**：① 本次 `gleam test` 在 `try_plushie`
  **exit 1**（`src/explore.gleam:158` 用了 stdlib 不存在的
  `list.range`），故 `insert=1 / 0 update_props` 是**测试源码断言、
  不是本次实测**；② `try_plushie` 仓库 `git log` 返回
  *"does not have any commits yet"*，**「最初版本做到」无法从版本
  历史复核**，以 owner 逐字为准，不写成我实测过。本轮未改该项目源码。
- **决策区 2 项 → 1 项**：plushie 那条整条删除、结论进 RULINGS；
  只剩 `sourcebar_buffer` 导出。
- **改动（仍只写文档，`src/` / `test/` 一行未改）**：
  `docs/RULINGS.md` 追加 08:13 注记；`DEVELOPER_GUIDE.md` §6.5
  结论段与 §11 边界改写；`README.md` 把「does not qualify」改成
  「fixable regression」并归位 owner 逐字；`docs/PENDING_DECISIONS.md`
  删第 2 项、标题改「当前 1 项」；本文件新增本节；
  当日日志与 `MEMORY.md` 同步。07:59 及更早的历史节原文不改写。
- 门禁：`src/` / `test/` 未改，复核结果与 07:42 / 07:59 一致
  （`format --check` / `check` / `test` / `docs` / `package-interface`
  / `build` 全 0；`test` 16 passed；`modules: 15`；
  WAE exit 1、196 warnings 为 R48 固定清单）。

## 2026-11-15 07:59 (历史状态)

- **本轮仍只写文档，`src/` / `test/` 一行未改**：owner 回答了自己
  07:42 的问题 —— 关键技术是 **stream 模式**，*"纵有万千条k线，系统
  里面其实只有一根在工作，那就是 working_databar, you almost always
  only need that one databar"*；绘图软件的**第一条判据**是能否单根 bar
  更新 chart，*"如果不能，那么我们的系统不能用他"*；并要求对 glib 的
  每处 `reverse` 追问 *"Was glib doing properly? You have to ask."*
  逐字全文与全部查证链在 `docs/RULINGS.md`「2026-11-15 07:59」。
  **本轮不宣布 glib 全对，也不宣布它错。**
- **07:42 那句结论被限定**：「7 处 `list.reverse` 无一处挂每根 bar」
  只是对 `*.gleam` 的计数陈述；另检出 **2 处 JS FFI 的 `.reverse()`**
  挂在高频路径上 —— `glib/binance_trading_ffi.mjs:36-38/81`
  （`apply_bar` 在 `:170/:227/:282` 触发 ⇒ 每根 bar 整表 reverse）、
  `glib/paper_trading_ffi.mjs:273`（`:188` 的 poll 循环 ⇒ 每次 poll
  整表 reverse，无新 bar 也翻）。`DEVELOPER_GUIDE.md` §6.1 已加
  07:59 订正块，§5 / §6.3 加了「这是应有形状，不是全部实测」的限定。
- **`sourcebar_list` 导出（owner 点名）**：`glib/sourcebar.gleam:534-535`
  `json.array` 与 `:515-518` `decode.list` 都保序，
  `glib/sourcebar_export.gleam:145` 读回按文件顺序逐根喂同一条流、
  `:26-27` 要求 oldest-first ⇒ **直接删 reverse 会倒着喂流**，挪到读侧
  只是把同一次 O(n) 换边。Gleam `List` 只能 O(1) 读头 / prepend，
  newest-first 链表生成 oldest-first 数组必然要一次 O(n) 反向遍历。
  要真正省掉只能不攒 buffer（每根顺手写一行）或不要这条导出。
  `src/glibe/timeframe.gleam:106-120` **没有** `sourcebar_buffer`
  字段、也没有 `export_flush`，这条路在 glibe 尚未存在。
- **`try_plushie` 判据**：框架机制**支持**单根更新
  （`test/try_plushie_test.gleam:394-423` 断言稳定几何 +
  稳定 id 时 `insert=1 / remove=1 / update_props=0`）；但当前 app
  `src/try_plushie.gleam:401-403` `subscribe()` 返回 `[]`（无归档
  事件源），`src/fusion_view.gleam:231-237` `window()` 每次 `view`
  都 `list.length` + `drop` + `take` + `list.reverse` 一个 160 根窗口
  —— **绘图输入仍是整窗 list，不是 head 那一根** ⇒ 按 owner 判据
  **当前不满足第一条门槛**。本次在 `try_plushie` 跑 `gleam test`
  **exit 1**（`src/explore.gleam:158` 用了 stdlib 不存在的
  `list.range`），故那组数字是**测试源码断言，不是本次实测**；
  本轮未改该项目任何源码。
- **逐处提问表**：`DEVELOPER_GUIDE.md` 新增 §6.5（stream 判据与绘图
  选型）、§7(e)（7 处 Gleam + 2 处 JS FFI，逐处「能不能不用
  reverse」的技术事实与待问点）；`README.md` 把「Each output
  boundary reverses its list once」改成「应有的形状」并加 07:59
  判据段；`docs/HANDOFF.md` §5 顺带修掉「不要 push（owner 没让）」
  这条与 2026-11-14 裁定冲突的假约定。
- **决策区由 0 项变 2 项**（owner 明说 *"You have to ask"*）：
  ① `sourcebar_buffer` 导出这条路 glibe 要不要存在（A 不引入 /
  B 改成 stream 写 / C 照 glib 抄 / D 先不定）；② plushie 是否
  记为「当前不可用」（A 判不可用 / B 机制算通过 / C 不再候选）。
  其余各处只记事实与提问，不预设结论。
- 本轮未新增 R 编号；`src/` / `test/` 一行未改，门禁数字沿用
  07:42 复核结果（16 passed / WAE 196 warnings / modules 15）。
  07:42 及更早的注记、append-only 日志原文均未改写。

## 2026-11-15 07:42 (历史状态)

- **本轮仍只写文档，`src/` / `test/` 一行未改**：回答 owner 07:42 的问题
  「倒叙 List 怎样画图、`reverse` 是不是低效」。结论是问句里那个
  **第二个关键措施 = 输出侧投影 + 单条增量流**：引擎只保存倒序那一份，
  顺序是它在输出边界的一次投影，之后每根 bar 只发一根、输出端只做
  O(1) 追加。owner 写的是 `revert`，官方函数名是 `list.reverse`；按
  「动词跟 function 走」，文档只用 `reverse`。
- **查证（glib 代码，非 glib `docs/`）**：`list.reverse` 全库 **7 处**
  （`trading/ingest.gleam:164` 页面初始绘制、`trading/export.gleam:24`
  退出导出、`trading/live.gleam:130` 有界窗口、`census.gleam:172/213/363`
  报告、`execution/risk_manager.gleam:358` 固定条数结果），**无一处挂在
  每根 bar 的 `databar_processing` 路径上**。实时链路：
  `timeframe.gleam:448` → `web/server.gleam:57/62`（只取
  `working_databar` 一根）→ `:110`/`server_ffi.mjs:429` SSE 发一根 →
  `priv/index.html:768` `appendBar` → `:691-705` 每条 series 一次
  `series.update`。初始绘制 `priv/index.html:736-737` 也是
  `bars.forEach(appendBar)`，前端 `:644` 明写 *"No `setData` anywhere"*；
  `server_ffi.mjs:20` *"not a second source of bars"*——顺序数据没有第二份。
- **效率算术**：若按 oldest-first 存，每根写入 `list.append`、取上一根
  `list.last`、保图表顺序 reverse，各 O(n)，N 根累计 **O(N²)**；现在是
  prepend / 读头 / 广播一根各 O(1)，N 根 **O(N)** + 初始绘制 / 导出各
  一次 O(N)。reverse 确是 O(n)（官方逐字），但它挂在**「人打开一次页面 /
  退出一次导出」**的频率上，不在**「数据到达 N 次」**的频率上。
- **与既有裁定的关系（不是新裁定）**：R30「标准层与显示层分开 … 显示层
  是它的一个投影 … 不得为了显示把标准类型改回日期字符串」的同构应用
  ——不得为了画图把存储改回顺序；R20 `dashboard = VIEW`、R33 一条流 /
  纯值重算、R38 流没有倒带共同保证新 bar 天然按时间到达、输出端只管
  追加。`DEVELOPER_GUIDE.md` 新增 **§6**，原 §6–§10 顺延为 §7–§11，
  §7(b) 从「例外」改述为「§6 措施在文件边界的形态」；`README.md` 加
  *The chart is not drawn backwards* 一段。
- owner 逐字、7 处 reverse 的逐条查证、6 步实时链路见
  `docs/RULINGS.md`「2026-11-15 07:42」执行注记；**不新增 R 编号、
  不新增待裁决项**。§6 新增的 20 条 `file:line` 按路径约定全部解析成功
  并抽查内容吻合。历史节、append-only 日志原文不改写。
- 决策区仍 **0 项**；未定只剩 `Symbol` 变体归属。WAE 那 76 条 `Todo`
  仍是下一批按 R19 逐条填的清单。

## 2026-11-15 07:31 (历史状态)

- **本轮只写面向开发者的文档，`src/` / `test/` 一行未改**：新建
  **`DEVELOPER_GUIDE.md`**（根，10 节），改写 `README.md`，
  `docs/HANDOFF.md` 顶部加一行导航。owner 逐字全文、官方 stdlib
  引文、glib 代码查证与分类表见 `docs/RULINGS.md`「2026-11-15
  07:31」执行注记。非新裁定，不新增编号 / 待裁决项。
- **要叙述的是既有设计，不是新设计**：Gleam `List` 是单向链表，
  prepend / 读头 O(1)，`length` / `last` / `append` / `reverse` 官方
  逐字均为 linear time（hexdocs `gleam_stdlib` v1.0.5 `gleam/list`，
  本轮 WebFetch）。随流增长的历史 List 一律**倒叙归档**、成员获取
  一律读头；`DataBar` 自带 `idx` 而 `SourceBar` 没有，因为位置只在
  `sourcebar.to_databar(sourcebar, idx)` 这个系统边界上赋，那个
  `Int` 既是 `bars_listed` 的结果也是下一根的 `idx`。有了 `idx`，
  长度、跨度、窗口边界全变成整数相减，不再遍历。
- **「同理类推」已核实**：`databar_list`、`sourcebar_buffer`、
  `signif_*_leaf_list`、`yin/yang_branch_list` 在 glib 里**全部**
  prepend + 头部读取（file:line 见 RULINGS / GUIDE §4）。三类例外
  按 owner 判据分类：有界窗口（`list.split` / `list.take`）、输出侧
  **一次性** `list.reverse`、非数据类小 list（execution / view 层，
  其中 `last_trade_times` 配 `list.find` 更像该用 type / Dict）。
  `timeframe.gleam:461` / `:469` 的 `list.length` 在开发期
  at-home test 里，不是生产路径。owner 明说不知道 glib AI 是否
  100% 照设计实现，故只分类、不宣布 glib 全对。
- **GUIDE 的核心是「不能按名字猜」**：`bars_listed` 不 count、
  `last_bar` 读头、`exited_branch` 不 find；并附骨架 `todo` 对照表，
  把每个待填 body 与 glib 的实测实现对齐。另有一节写文档先导 TDD
  为何是根本措施（`///` 是规格、`package-interface.json` 是编译器
  自己的反漂移检查；旧 todo 写 "count the settled bars" 就会把后来
  的人带去 `list.length`）。
- **README 两处假话已修**：`Every function body is todo` →
  `Most … todo`；「设计不在 prose documents 里」改成「规格是代码内
  `////` / `///`，GUIDE 是导航、不是第二份规格」。
- 文中 37 条 `file:line` 引用全部解析成功、抽查内容吻合；Gleam
  片段只取自已编译的 `src/glibe/timeframe.gleam:191` 与 glib 实现。
- 决策区仍 **0 项**；未定只剩 `Symbol` 变体归属。门禁数字与
  07:12 相同（`16 passed` / WAE `196 = 76 Todo + 117 unused arg +
  1 unreachable + 2 unused private ctor`），本轮复核后确认。

## 2026-11-15 07:12 (历史状态)

- **本轮落了两件 owner 裁定，不是再一轮命名类推**：
  ① `bars_listed` **真填了 body**（doc-tdd 第二个实现）；
  ② `symbol.symbol_to_string` → **`symbol.to_string`**。
  逐字全文、glib 代码查证、落实表见 `docs/RULINGS.md`
  「2026-11-15 07:04–07:12」执行注记。
- **`bars_listed` 是函数，不是计数**：`pub fn bars_listed(databar_list:
  List(DataBar)) -> Int`。owner 的 in-code comment 逐字保留在
  `databar.gleam` 的 `idx` 文档末尾；实现为
  `case databar_list { [] -> 0  [newest, ..] -> newest.idx + 1 }`——
  取链表头 O(1)，不 import `gleam/list`，不调 `list.length`。
  owner：*"if you are to count the elements in a gleam list, gleam docs
  tell you that will be very ineffecient action. list is not an array"*，
  且 *"list倒叙归档是我特别设计的，针对gleam list的设计特点"*。
  glib 代码佐证：`timeframe.gleam:827` 读头 + `idx+1`、`:848`
  prepend、`:99` 明写 "O(1) on a cons list"、`:280` / `:602`
  `list.first`；`branch.gleam:271` 也只读头；`leaf.gleam:113`
  CMA 递推 O(1)。
- **「凡遇到此类 list 相关的函数，以及成员的获取」已全面类推**：
  `working_databar_archived` todo 的 `appended` → `prepended to the HEAD`；
  `branch.exited_branch` 文档补「Never `list.find`」、todo 改「读 HEAD」；
  `branch_size` / `leaf_size` todo 改 `idx arithmetic … never walk`；
  `leaf.cma_recurrence` / `leaf_cma` 明写 O(1) 头读取；
  `databar.idx` 与 test 文档不再写「counts」。
- **`symbol.to_string`**：官方 `x_to_y` 惯例规定 module 名与 type 名
  相同时省略前缀；owner 明说先前那条 in-code review 是
  *"I haven't noticed the module file name"*。`<**human: …**>` 原文
  逐字保留在代码里（与 `interval.gleam` 未采纳的 review 同一处置），
  但不再当规格；`//// R19 status` 与 test 绑定同步。
  `package-interface.json` 实测 `glibe/api/symbol` functions =
  `string_to_symbol` / `to_string`。
- **RED → GREEN**：`bars_listed_reads_head_idx_test` 用 `idx: 41` 的头
  bar + 更旧的一根，断言 **42 而非 List 长度 2**、空表 **0**；
  RED `15 passed, 1 failures`（`todo timeframe.gleam:192`）→
  GREEN `16 passed, no failures`。断言特意让 `list.length` 必红。
- **R19 status 同步**：`timeframe.gleam` 与 `test/glibe_test.gleam`
  两处自称「全是 todo」「一个断言」已改为实况。
- 门禁：`format --check` 0 · `check` 0 · `test` 0（16 passed）·
  `docs build` 0 · `export package-interface` 0 · `build` 0；
  **`build --warnings-as-errors` exit 1**：196 warnings = 76 `Todo` +
  117 `Unused function argument` + 1 `Unreachable pattern` +
  2 `Unused private constructor`。上一轮 198 = 77 / 118 / 1 / 2，
  差值恰好是填掉的 1 个 body 与其参数 → 零静音、零新增 TODO（R48）。
  `package-interface.json`：`modules: 15`，`to_string` 与
  `bars_listed` 的 documentation 完整、无 `//` 截断。
- 决策区 **0 项**。**未定**：只剩 `Symbol` 变体归属（Shape A / B
  编译比较见 `.workbuddy/memory/2026-11-15.md`）。
  `trading/signal.from_string` / `api/interval.from_string` owner 未点名、
  不属本轮问题，不动、不列待裁决项。
- 普通 fast-forward push 照 owner 2026-11-14 逐字直接做；任何 force
  类操作先问。

## 2026-11-15 06:56 (历史状态)

- **本轮是命名类推，不是填 body**：`src/` 仍 15 个模块
  （`package-interface.json` 实测 `modules: 15`），函数体仍多为
  `todo`。唯一新增测试是 `sourcebar_closed_shape_test`（shape test，
  不触发 todo）：`gleam test` **15 passed, no failures**（14 → 15），
  `gleam build` 0。
- **`interval.bucket_ends` → `interval.sourcebar_closed`**：owner
  2026-11-15 逐字原则「不要用没有Type定义的名字去替换有Type的名字」、
  「对于一个kline或者sourcebar来说，完成了就是close了」、
  「nouns and verbs … go after types and functions」。owner 在
  `interval.gleam` 留的 `bar_close(s/closed)` 建议连同官方
  conventions 查证一起处理：官方页无 Bool / 时态规定，且 `bar` 同样
  无 Type 支撑，故取 `sourcebar_closed`。逐字全文、判据、落实表见
  `docs/RULINGS.md` 2026-11-15 执行注记。
- **全面类推覆盖**：`api/interval`、`api/sourcebar`、`databar`、
  `timeframe`、`instrument`、`ib/sourcebar`、`binance/kline`、
  `test/glibe_test`。`bucket` / `bar` / `instant` / `finished` /
  `unclosed` → `SourceBar` / `sourcebar` / `Timestamp` / `open_time`
  （provider 字段名）/ `closed` / `has not closed`。
  **保护不动**：`working_databar_archived`（owner 逐字，与 `SourceBar`
  的 close 是两件事）、`open` / `close` 字段、`start_bar` / `end_bar`
  等 owner 逐字字段名、provider 原生 `open_time` / `wap` / `count`、
  `latest close`。`latest_price` 在 Binance / IB bars 中不存在，不引入。
- **编译器实测**：`let assert Ok(sourcebar)` 与同作用域
  `sourcebar.SourceBarOneMinute(..)` 共存无遮蔽错误；`open_time:`
  shorthand 合法；`timestamp: open_time` 的 provider 出口映射合法。
- **历史文档里的 `bucket_ends` 不改原文**（本文档历史节、R29 原裁定、
  旧 `.planning` 阶段计划、append-only 日志）：只加 dated 注记
  （`05-01-PLAN.md` §8 / `docs/RULINGS.md`），当前状态另写本节。
- 门禁：`format --check src test` 0 · `check` 0 · `test` 0（15 passed）·
  `docs build` 0 · `export package-interface` 0 · `build` 0；
  **`build --warnings-as-errors` exit 1**：198 warnings =
  77 `Todo` + 118 `Unused function argument` + 1 `Unreachable pattern`
  + 2 `Unused private constructor`，与 11-15 日志的 198 / 77 **逐条相同**
  → 零静音、零新增 TODO（R48）。`package-interface.json` 的
  `glibe/api/interval` functions = `from_string` / `sourcebar_closed` /
  `to_string`，模块文档 41 行完整、无 `//` 截断。
- 决策区 **0 项**。**未定**：`Symbol` 变体归属、`symbol_to_string` 与
  官方 `x_to_y` 惯例的冲突（两者需 owner 一句话，不擅自选）。
  `trading/signal.from_string` / `api/interval.from_string` owner 未点名，
  且不是本次「无 Type 支撑的名词」问题，本轮不动、不列为待裁决项。
- 普通 fast-forward push 照 owner 2026-11-14 逐字直接做；任何 force
  类操作先问。

> **⚠ 2026-11-15 07:12 更正**：本节是 06:56 当时的记录，不是当前答案。
> 上面「未定」里的 `symbol_to_string` 冲突已由 owner 裁定为
> `symbol.to_string`；`bars_listed` 也已填入真实 body（不再是 `todo`）。
> 本节其余原文不动；当前状态见本文档 2026-11-15 07:12 节。

## 2026-11-14 07:41 (历史状态)

- **`src/` = 15 个模块**（`gleam export package-interface` 实测
  `modules: 15`）；11-12 记录的「14 个」少了 `ib/sourcebar.gleam`。
- **「仍留白」清单已失效**：11-12 的 5 项里 4 项早已落进骨架 ——
  `DataBar`（`databar.gleam:60-`）、`YinLeaf` / `YangLeaf` 3 字段、
  `YinBranch` / `YangBranch` 4+ 字段、`BinanceKline` 12 字段、
  `SourceBarRejectionUnqualified`。只有 `Account` 仍是
  `account.gleam:27-29` 的零字段占位，那是 R26 / R32 等真实消费方的
  **刻意决定**，不是待 owner 给的词。下一段「仍留白」是历史记录。
- **Kline 线格式不是设计留白**：Binance 官方 `GET /api/v3/klines`
  响应 12 字段（Open time / Open / High / Low / Close / Volume / Close
  time / Quote asset volume / Number of trades / Taker buy base asset
  volume / Taker buy quote asset volume / Ignore）与
  `binance/kline.gleam:103-116` **逐项对应、顺序一致**。线格式
  integer-ms → `Timestamp`（R27）、string 数字 → `Float`、
  `Number of trades` → `Int`、`Ignore` → `String`。照抄，不设计。
  R28「provider 原生形状各自保留」。
- **R19 第一个 body 已填**：`kline.to_sourcebar`。RED `11 passed /
  1 failure`（崩在 `kline.gleam:242` 的 todo）→ GREEN
  `12 passed, no failures`。编译器实测：构造子作为一等函数时**不接受
  labelled argument**，故 9 个 arm 各自带 label 构造。`volume: Float →
  Int` 在 provider 出口以 `float.truncate` 落地（R28：转换只发生在
  出口）；`open_time` 已是 `Timestamp`，不再折 epoch。
- 门禁：`check` 0 · `test` 0（12 passed）· `format --check src test` 0 ·
  `docs build` 0 · `export package-interface` 0；
  **`build --warnings-as-errors` 仍 exit 1**（192 warnings，
  `Todo found` 70 → **69**，零静音）。这是逐条待实现清单，不是成绩单（R48）。
- 决策区 **0 项**。**2026-11-14 已普通 push**（fast-forward，无任何
  force 参数）：`fb0082a..757cf63`，本地 HEAD、远端
  `refs/heads/doc-tdd`、`origin/doc-tdd` 三者一致。下面 11-12 历史节
  那句「分支 `doc-tdd`，不 push」是**当时的状态，不是规则**；owner
  2026-11-14 逐字与查证见 `docs/RULINGS.md` 相应执行注记。

## 2026-11-12 (doc-tdd — 系统性重建；历史状态)

- **R50（owner 在 `desk.gleam` 留 12 条 review 评论后追加两轮追问）= 当前结构**：
  一个模块只读写它自己那一层**持有的** Dict；`desk.gleam` 233 → 56 行，
  只留 `Desk` + `get/put_broker`。新增 `id`（零 import 叶子）、
  `account`、`instrument`、`broker`；删 `timeframe_under` /
  `put_timeframe_under` / `LookupError` / **`config.gleam`**。
  **R42「Desk 上面不再有东西」也管模块，不只管 type**：唯一的一个
  `Desk` 不需要配置层去生产它。依赖单向：
  `id`/`account` → `instrument` → `broker` → `desk`，无环。
  逐字原话与实测见 `docs/RULINGS.md` R50、05-01-PLAN §5.5。
- **当前 `src/` = 14 个模块、零行实代码**；`test/` 9 个空 shape test。
  门禁：`check` 0 · `test` 0 · `format --check` 0 · `docs build` 0 ·
  `export package-interface` 0 · `build --warnings-as-errors` **故意红**
  （骨架阶段逐条待实现清单，详见下条 R48）。
- **分支 `doc-tdd`，不 push。** 旧 `src/` / `test/` / `scripts/` / `probes/`
  与补课笔记整体移入 `deprecated/2026-11-12-pre-doc-tdd/`（79 files）；
  它们只读，不是依据（R44 / R45）。旧红 / 绿数字不再衡量任何东西。
- **项目层没有 guard sh**，CI 也删掉了 `scripts/guards.sh --all`（R44）。
  项目层只保留 Gleam 编译器自己的命令；`package-interface.json` 是编译器
  的防漂移产物，不是脚本。行为纪律（及时提交）不靠脚本探测。
- **`gleam build --warnings-as-errors` 是固定门禁（R48），已写入 CI**；
  逐个查过 help，这个 flag **只在 `gleam build`**，`check` / `test` /
  `docs` / `format` 都没有，不能用 `gleam check` 顶替。核心卡片 §10/§13/§14
  早就写着它，此前 CI 未挂、本地未跑。当前骨架实跑 **exit 1**，末尾
  `error: 85 warnings generated.`（30 `Todo` + 52 unused argument +
  3 private constructor）：是**逐条待实现清单**，必须读到具体行，既不是
  成绩单也不许整包归类为「expected skeleton shape」。R19 / core §14 /
  skill 里「warnings 合法 / 只是 GREEN gate」全部作废。`_` 是 discard
  name（body 不能引用），禁止用它批量静音；`src/` / `test/` 本轮未改一行。
- **R49：`new` 是 Python 式垃圾，见到即当 bug，无 container 豁免**。
  现行 `src/` / `test/` 的 `new` 零出现（R46 已删净）；core §3 那个
  `pub fn new(...)` 示例已改成 `clamp_positive`，§5 新增「No `new`」，
  `gleam-language/SKILL.md` 的豁免作废，镜像 `cmp` 一致。主动核验另抓到
  `config.gleam` 把 AI 裁定正文写成「R33 owner 逐字命名 `default_config()`」
  —— R33 四段逐字原话只命名 `Desk`、无任何函数名，已如实改标词源；
  同时改掉把这个函数称作 "constructor" 的 Python 式措辞。
  **⚠ R50 已把整个 `config.gleam` 删除**，本条只记录当时的词源核验；
  「`default_config()` 保留」那句作废。
- **（R50 前，历史）`src/` 曾 = 11 个模块、零行实代码**：`////` / `///`、
  type 关系、全标注签名，函数体一律 `todo as "..."`。空 unit test 只
  固定 in / out types（R42 07:39）。当时链的 read / write 服务错误地
  集中在 `desk.gleam`，已由 R50 分层；`timeframe.gleam` 仍持有直线与
  管道全部 fn。R46 删掉了 `indicator_settings.gleam`。
- **设计探针（报缺口，不报分数）**：`gleam check` exit 0、无设计缺口，
  输出仅 `Todo` / unused-arg / unused-private-constructor warning；
  `gleam build` / `gleam format --check src test` exit 0；
  `gleam docs build` exit 0；`gleam export package-interface --out` exit 0，
  当时 12 个模块的 `////` 全部完整渲染、无 `//` 截断（R50 后为 14 个）。
- **R43 首次空架子阶段核验已实测**，逐条记录在
  `.planning/phases/05-doc-tdd/05-01-PLAN.md` §5；裁定见 R44 / R45。
  **11:46 第二轮（§5.1）**：owner 追问 *「他做什么，谁用他，为什么存在」*，
  查出第一轮漏掉的 `TimeframeSettings` 是自造概念 —— 我曾在 R23 §3
  把自己写的「保留为参数包」当词源，又在 R45 把它列为合法来源。
  已按 **R46** 删除 module / field / `new` / 空 test；**词源收紧为 owner
  逐字原话**，裁定正文里 AI 写的名字不算。全绿编译不检查名字出处。
- **仍留白（R26 / R32，故意）**：`DataBar` 计算字段、leaf / branch
  内部字段、`Kline` 线格式字段、`SourceBarRejection` 的具体拒绝原因、
  `Account` 字段。settings **不是留白，是被否决的东西**（R46）。
- **未收敛**：`gleam.toml` 依赖表仍是旧列表；`webclient/`（R16–R18
  唯一 JS target 包）仍是旧实现。两者等各自消费方 / 框架定型后单独处理，
  本轮不动。根目录 `README.md` 已换成 15 行索引（旧 464 行移入
  `deprecated/2026-11-12-pre-doc-tdd/notes/`）。
- 决策区仍 **0 项**；**未 push**。

## 2026-11-10 10:42 (04-10 — 裁定已落入代码；历史状态)

- **owner 逐字（10:42）**：*"这些逻辑，需要在设计module以及type的时候，用gleam
  document的规矩，写进代码文档，之后是unit test 以及填充实际代码完成 test，
  形成 概念 -> type definition -> unit test -> implementation 完整链条"*。
  执行注记在 `docs/RULINGS.md` 文末（非新裁定）；计划与结果在
  `.planning/phases/04-domain-cleanup/04-10-PLAN.md` /
  `04-10-SUMMARY.md`。
- **制作流程（R19；owner 10:42 / 10:58 / 11:01 / 11:03 同一条指示，
  逐字全文在 `docs/RULINGS.md` 文末「一个 module 文件的制作流程」段）**：
  「实际完成方式」就是制作流程，对象是**一个 module 文件** ——
  ① 先写描述 → ② 再写空架子（没有实际东西）→ ③ 再写 test，
  **设计目标在此** → ④ 逐步测试、逐步完成全部合乎 test 要求的代码。
- **11:05 批评与如实定位（逐字在 `docs/RULINGS.md` 11:05 段）**：04-10
  **不是**这条流程的示例 —— `Desk` 等 type 与逐层 `get_*` 早已实现，
  本轮才补 `////` / `///` 与 6 个断言，是**倒过来整**的反向补课；
  只有 `timeframe_under` 一小段走了「`///` + `todo` → test → 实现」。
  以后新建 module 必须从描述开始，禁止先实现后补文档 / 补 test。
- **11:11 文档体系裁定（逐字在 `docs/RULINGS.md` 11:11 段）**：`docs/` 下
  大量文档之所以存在，正因没做到「gleam document 领先于测试、测试领先
  于实际代码」；它们是 owner 发现错误后上课留下的**「差生补课笔记」**，
  不是设计资产或权威，**流程做对，很多文档不需要**。11:10 把 seib 读成
  Python 那一误解就是「反着做习惯」的证据，与 11:05 同一根因。纪律：
  不新建散文文档、已有文档只在改错 / 记逐字裁定 / 记实测时更新、
  文档量应下降；概念进 `////` / `///`，设计目标进 test，实现最后。
- **本轮实际做了什么（retrofit）**：① `////` 模块文档命名 04-10 计划、每个
  type / function 的 `///` 写清「为什么在这一层」（`desk.gleam`、
  `config.gleam`、`timeframe.gleam`、`api/symbol.gleam`、
  `api/interval.gleam`、`web/server.gleam`）；② **不新增 type** —— 现有
  `Desk ▸ Broker ▸ Instrument ▸ Timeframe` 就是裁定所描述的定义（R35
  「简单是验证码」），只补带 `todo as "…"` 的签名；③
  `test/level_judgement_test.gleam` 6 个测试固定 R34 / R36 / R37，
  **RED = 68 passed / 2 failures**；④ 填 `desk.timeframe_under` 的
  三行 `result.try` 纯读取，**GREEN = 70 passed, no failures**。
- **`desk.gleam` 里「Market 尚未确定、以后可能加一层」的旧句已更正**为
  R36 的否决；`Market` 双向都不隶属，不是开放选项。
- **反漂移检查**：`gleam docs build` 后，根包 6 个模块的 `////` 与
  `timeframe_under` 的 `///` 在 `package-interface.json` 中完整渲染
  （desk 4469 字符 / web server 5193 字符），均含 04-10 计划链接，无
  `//` 截断；webclient 包接口文档完好。
- **边界**：没有新增 type / field / relation、没有依赖、没碰三张目录表、
  没改 `monitor.gleam`、没预设 `Asset` / `Exchange` / `Market` 关系；
  `timeframe_under` 是纯读取，不是 R33 作废的 `monitor.advance` 那一层。
  决策区仍 **0 项**。
- **绿灯**：`BUILD_WAE=0`（0/0）、`TEST=0`（70 passed）、`FORMAT=0`、
  `guards: all green`（7 fixture 用例）、`DOCS=0`、思考核心镜像 `cmp=0`。
- **上一节 R34–R37 里「本轮不改 `src/`」只描述 10:18–10:37 的裁定记录
  轮次**，不是对写代码的永久禁令；裁定内容一条未改。

## 2026-11-10 (R34–R37 — 先驱定位、SwiftUI 类比、层次核对与主干判据；裁定记录轮次)

> **owner 10:26 更正（逐字）**：*"注意我说的seib的结构是对的，ibOptions结构
> 不好，用settings解决结构问题，按照你的复述，可就变成了seib也不对，他的
> settings也应该是types。这就乱了。"* 本段初稿把两者并列成同一缺陷，已按
> 此更正。
>
> **owner 11:10 定稿（逐字在 `docs/RULINGS.md` R34）**：**seib 是
> CoffeeScript、是 owner 的系统设计**，没有 Python/pandas 局限、不存在
> 「连类型都搞不清楚」；**ibOptions 是为了迁就语言凑合的**，五脏俱全
> 但**都不对劲**。**两者完全两码事**，唯一共同点只是数量上都只有一个
> broker。此前复述像「seib 也是 python 写的、只不过没受限制」，是错的。

- **owner 逐字裁定**在 `docs/RULINGS.md` R34。数量上唯一的共同点只是
  **都仅支持一个 broker / 数据源**，性质完全不同：
  - **seib 的结构是对的**（owner 10:26 逐字）：「大格局都有了，细节
    也有了」。**CoffeeScript 写的、owner 自己的系统设计**，没有
    Python/pandas 局限，也不存在「连类型都搞不清楚」（11:10）。
    它**只缺一层**「多个经纪商数据提供者」——当时没有
    binance（owner 带「我印象中」：仅 IB 一个数据源）。缺这一层不是
    结构错误；**seib 不存在「settings 应该是 types」这件事**。
  - **ibOptions 是为了迁就语言凑合的**（Python + pandas）：结构性
    问题被压进配置；正常手工和自动交易的细节需求它都有（**五脏俱全**），
    但 11:10 定稿是**都不对劲**，整体不足取，**只能看有哪些设置**。
    它同样只有一个 broker。**与 seib 完全两码事**（11:10）。
- **settings 是被压扁的 type（仅 ibOptions，与 seib 无关）**：那些设置本应由 type 定义，被迫做成了
  settings 文件。在 glibe 里，现实事物是 type，某事物的一方面是已有
  Type 定义里的一个 field（R32 / R26）；不搬 ibOptions 的配置形状、
  不预先批量造 type、不预设 `Asset` / `Exchange` / `Market` 关系。
- **seib 缺的那一层已存在**（补层，不是修 seib 的结构，也不搬 ibOptions
  的 settings）：`Desk(brokers: Dict(BrokerId, Broker))`
  （`src/glibe/desk.gleam:92-93`），`config.default_config()` 建了
  `binance` / `ib` / `futu` 三个 broker（`src/glibe/config.gleam:87-101`）；
  与 R33「`Desk` 是顶层唯一 Value」及管道头 `api provider / data sources`
  相合。R34 **未新增 provider / data-source 类型**，`Broker ▸ Instrument`
  （R26）不变。
- **R33 的规格不变**：系统本来就活、数据动每个 type 就动、无数据则睡觉
  等待、`monitor.advance` 那层不是本系统 type、glib 与先驱不作依据。
  待做是把各数据源的实时到达接到标准 `SourceBar` 入口；历史批次是同一条
  流的前段，不是重放（R38）。
- **引用限定**：R29 里 `~/gits/hub/ibOptions` 的两处时区实例只是事实
  线索，不是架构依据，IANA / 拒绝固定 offset 的结论不变。
- **10:29 因果补正（R34）**：owner 逐字 *"ibOptions受制于Python+Pandas
  的局限性，才会变成那样"*。**是语言 / 库的局限使结构性关系无法写成
  type，才被迫压进 settings 文件**；不是随意乱做，更**不是 seib 的缺陷**。
  受局限的是 ibOptions，结构对的是 seib，只缺现实层次的是 seib ——
  复述时主语不能串（*"要看仔细"*）。
- **R35（SwiftUI 类比 / 简单验证码）**：相似**只指 View 的定义与实现**
  （纯 functional + value types），不是 Swift 整体；Swift 从 view model
  的 class、model 不限 struct/class/actor 起把简单的事做复杂，数据竞争
  要大量补救 —— 这在 Gleam 里不可能出现。**SwiftUI 的 view 为什么会
  更新 = R33**：type 定义好、函数定义对，系统本身就是活的。并发课题
  遇到再查官网 + 做几个方案 demo 对比解决，即 TDD 落实。
  *「简单是正确的验证码。如果复杂，基本上可以判断type 函数和模块定义
  有错误」* —— 复杂是设计出错信号，回去修定义，不加机制。
- **R36（type 系统与断层核对）**：owner 记忆里的主要 type 系统，glib
  的记录在 `~/gits/hub/tools_ib/glib/docs/SYSTEM_MODEL.md` §2 `:102-119`
  与 `domain-hierarchy-2026-10-22.md`（README 只有 `:907` 一行 Phase 32）；
  **glib 不作依据**（R33）。glibe 现有链逐项对上、**没有缺少**。
  断层判断：**`Market` 与 `Broker` 两个方向都不隶属 → 否决**，
  `Desk` 直接持有 Brokers 合乎事实、**无断层**；`Asset` / `Exchange` /
  `Market` 关系按 R26 开放、`APIProvider` 与 broker 同物（R26）、
  `Account` 已由 Broker 持有（当前 keyless，等消费方）、`Symbol` /
  `Interval` 是 key 不是层。**当前链无断层，不新增 type / field / 关系**。
- **R37（主干判据；owner 10:34 逐字）**：举 Desk/Market/Broker 是
  **教怎么思考 type 架构**，不是只要一个否决结论。构成层次某一层的
  type **必须跟上下级有两个隶属关系**（既隶属上层、又拥有下层）；
  其他 type 不属主干：**依附于某 type 但不是隶属**（不插进上下级、
  不产生层级），**谁也不依附就放 `Desk`**（至少属于我们系统）。
  **身份在持有者的 Dict key**：`interval` 不是 `Timeframe` 的 field、
  `brokerId` 不是 `Broker` 的 field，分别是 `Instrument.timeframes` 与
  `Desk.brokers` 的 key。owner 10:37 逐字比喻：*"你的左手不知道他是左
  还是右，同样，Timeframe不应该知道他是什么interval"* —— 左 / 右是
  持有者给的方位标签，不是手自己的属性；谁持有，谁命名。
  owner 指路的 glib 思路记录在
  `~/gits/hub/tools_ib/glib/docs/NAMING.md:575-589`
  （*"the owner holds what it owns, and the owned never names its owner"*、
  "A collection is not an owner-pointer"）与
  `~/gits/hub/tools_ib/glib/docs/DESIGN.md` §18.2 `:3269-3299`
  （owner 2026-11-04 关于 interval 作 key 的逐字）；glib 文档写
  `Desk → List(Broker)`，glibe 的 `Dict(BrokerId, Broker)` 是 R32 按
  访问方式选的，**不是搬来的**。这是判定法则，不重构 `src/`。
- **本轮范围**：只记裁定、只读核对、同步稳定文档；**不删、不改 `src/`、
  不加依赖、不写 probe、不新增待裁决项**。决策区仍 **0 项**。

## 2026-11-10 (R33 — 系统本来就是活的；现行规格)

- **owner 09:57 / 09:59 / 10:04 / 10:09 四条逐字裁定**在 `docs/RULINGS.md` R33。
  一句话：*`api provider / data sources → history + live data → sourcebar_gate
  → databar_processing → model ↔ view`* 这条管道本来就是活的；**数据动，
  每一个 type 就动，因为定义好了**。`Desk` 是顶层唯一的 Value，逐层嵌套即
  完整系统；在 Gleam 里唯一要做的就是定义 types，基本结构对了什么都有了。
- **数据为什么会动**：订阅了数据源的实时数据；各家推送 / 订阅 / 主动获取
  用各自的方式，属输入边界事实。**没有数据系统就不动了，睡觉，等待**——
  静止是正常状态，不需内部时钟、轮询或心跳补救。
- **撤回三层外来概念**：`monitor.advance` / `TimeframeAddress` /
  `IncomingBar` / `MonitorError` 不是这个系统的 type（*"哪有这些type"*）；
  actor 是结构没设计对才去找的补救；「每一个叶子活起来」既用错了「叶子」
  （特指 `YinLeaf` / `YangLeaf`）也用错了「活」。R31 并发框架、R32
  「每个 Timeframe 活着 / 让叶子活起来的运行时」措辞一并作废。
  **R32 花园方法论仍成立**：加 field、倒推隶属、集合对比、R26 不预设层级。
- **glib 不是权威**：可能只记录了设计与计划、未必落实，已落实的也未必对。
  唯一权威是 owner 当前陈述；此前「glib 核实：四类型链已落地」类断言降级
  为「读过 glib，不作依据」，不得作为设计正确或已落实的证据。
- **本轮范围**：只记裁定、撤回错误结论、清理词汇；**不删生产代码、
  不新增 type、不写 probe、不加依赖**。`monitor.gleam` 那层的处置由
  owner 定，在此之前不作为结构依据。决策区仍 0 项。

## 2026-11-10 (R32 — 结构是花园；历史记录，并发框架经 R33 作废)

> **R33 更正**：下面「每一个 Timeframe 都活着」「当前缺口：运行时还没让
> Timeframe 活起来」「glib 核实：已落地」三处均作废 —— 系统本来就活，
> 「叶子」特指 `YinLeaf` / `YangLeaf`，glib 不是权威。原文保留为历史。
> 花园方法论（加 field / 倒推隶属 / 集合对比 / R26）仍然成立。

- owner 09:45 逐字裁定：*"结构复述正确，不过这是一个花园，不断根据需要往里面加新的花盆。实际上就是在Type定义中加新field而已 … 那就倒推他和其他type现实中什么关系呢？隶属于谁呢？如果谁也不隶属，是其他关系，那么可能放在Desk里面就好了，那么用dict还是list还是其他东西放呢？根据需要来对比研究决定。"* 全文在 `docs/RULINGS.md` R32。
- **结构确认**：`Desk` 只有一个；Desk 里若干 Broker（binance、ib）；每个 Broker 有一组 `Instruments` 和一组 `accounts`；每个 `Instrument` 有 `Dict(Interval, Timeframe)`；**每一个 Timeframe 都活着**，各自处理数据、进行交易。glibe `src/glibe/desk.gleam:74-94` 已有这条静态链，`config.gleam:75-101` 建了 3 broker × 3 品种 × 2 周期。
- **glib 核实**：`glib/src/glib/desk.gleam:11-13`、`broker.gleam:29-34`、`domain/instrument.gleam:76-82` 已落地同一四类型链（含 `accounts` 与 `Dict(Interval, Timeframe)`），`55-02-SUMMARY.md` 标 done；`glib/docs/DESIGN.md:3264-3286` 逐字记了 owner 2026-11-04 的 "instrument with a dictionary of timeframes using interval as key"。但 glib 是 `target = "javascript"`，其 `.planning/HANDOFF-2026-11-03.md:297-305` 自承 runtime 是 single-stream walls，「每个 Timeframe 活着」**未做到**。
- **撤回 04-09 的错误结论**：`probes/parallel-bars/` 把一份 `Desk` 复制进 6 个进程、返回 6 份 partial `Desk`；由此写出的「0/6 合并 / 所有权决定」是伪问题。R31 该段、`docs/DESIGN.md` 04-09 节、`04-09-SUMMARY.md` §4、README / ROADMAP / PENDING 的相应结论作废；官方 BEAM 证据与 `gleam_otp` 事实更正保留。probe 留作带 `////` 作废注记的历史实验。
- **当前缺口**：静态链已有，运行时还没有让任何一个 `Timeframe` 活起来（无进程、无行情流、无交易输出）。按 R32 这是往类型里加 field 的正常生长，不是新框架；按 R26 等真实消费方，本轮**不新增生产类型、不改 `src/` 逻辑、不写新 probe**。
- 本轮没有新增待裁决事项。

## 2026-11-10 (phase 04-09 — BEAM 并行实测 / R31，历史记录；结论见 R32 作废)

- 按 `.planning/phases/04-domain-cleanup/04-09-PLAN.md` §4 复工；范围严格
  **Erlang / BEAM**（owner 06:09）。
- 新建 `probes/parallel-bars/`（独立 Erlang-target 包，`glibe` 为 path 依赖）。
  按 R19：骨架 + `////` 点名 04-09 计划 + 类型 + `///` 签名 + `todo` → 4 个
  测试 RED（0 passed / 4 failures / 0 编译错误 / 5 todo warnings）→ 填体
  GREEN（**4 passed**，`build --warnings-as-errors` 0/0）。
- `gleam run -m parallel_bars` 实测输出：6 个带 `TimeframeAddress` 的 bar →
  **6 个不同 BEAM Pid**（`<0.117.0>`…`<0.122.0>`），回复顺序与发出顺序相反；
  **0 actor / 0 supervisor / 0 lock / 0 FFI**；
  `partial Desks equal to the single-owner fold: 0 / 6`。
- **诚实结论（不是同步问题，是所有权问题）**：每份并行 `Desk` 只改了自己一个
  地址，另外五个仍是原值；N 份不可变值不会自己合并。要么单一 owner 按到达
  顺序 fold，要么每个地址自己持有 `Timeframe`（不需要全局 `Desk`）。按 R26
  等真实消费方决定，**不新增生产类型**；生产代码逻辑未改（`monitor.gleam`
  仅同步 `////` 模块文档到 R31 / 04-09），依赖未加。
- **R31 已写入 `docs/RULINGS.md`**：逐字记录 owner 06:01 / 06:09 原话、官方
  证据、actor 的准确位置、值住在各进程自己的堆（不存在的是共享可变内存）、
  04-09 实测与两处事实更正。
- **两处事实错误已纠正**：① `gleam_otp` 早就是根 `gleam.toml` 的直接依赖；
  ② `docs/DESIGN.md` 04-08 段末 "no … `gleam_otp` dependency" 同错。
  `:101` 表格与 04-08 段末「Stage F 的受监督 actor」框架已重写；
  `README.md`、`.planning/ROADMAP.md` 与临时待裁决文档同步。
- **待裁决事项仍为 0 项**；R31 不是待裁决项。
  历史 review / session 文档（含 04-08 PLAN/SUMMARY、10-04 改进计划）按惯例
  保留旧措辞作为记录。
- 全套绿灯、核心镜像 `cmp`、`package-interface.json` 计划链接、反向引用检查
  均已在收尾提交前跑完（全 0）；按逻辑即时提交，**不 push**。

## 2026-11-09 (Gleam 天然并行研究 — DEFERRED，本日只记录状态)

- owner 06:01 指出：Gleam 天然多线程、并行任务非常简单自然，不必把「受监督
  actor / 订阅 / 行情流」当成复杂补救措施；要求查官网与 Wisp / Lustre 等著名代码。
  owner 06:07 追加：**今天浅尝即止，明天免费 token 到手再继续，今天只把任务和
  现有发现记下来**。owner 06:09 再纠正：*"你去看什么javascript target完全不对路，
  我们是erlang 和 BEAM专属项目"* —— 本项研究范围收窄为 **Erlang / BEAM**，
  JavaScript target / promise 的旁证已从记录中删除。
- 本日**只做了查证与记录**：`https://gleam.run/` 首页 "multi-core actor based
  concurrency system … millions of concurrent green threads" 与三行
  `new_subject` / `spawn` / `receive` 示例；官方 v0.12 发布文「no need for an
  `async/await` syntax or callbacks」「no special types such as futures or
  promises」「don't have mutable state so locks and shared mutable state is not
  an option」以及 actor / supervisor 的定位；本机
  `build/packages/gleam_erlang/src/gleam/erlang/process.gleam:36,78,138,194,227`
  与 `gleam_otp/actor.gleam:1-14`；Wisp `wisp.gleam` 0 处 `process.`；
  glisten `:274,397,435,446`；Lustre `runtime/server/runtime.gleam:81-122`。
  完整引文与 URL 在 `.planning/phases/04-domain-cleanup/04-09-PLAN.md` §2。
- **发现我自己的两处错误**：① 上一轮答复说「`gleam_otp` 也没引入」是错的，
  根 `gleam.toml` 早有 `gleam_otp = ">= 1.3.0 and < 2.0.0"` 直接依赖；
  ② `docs/DESIGN.md` 04-08 段末 "no … `gleam_otp` dependency" 同错。
  `:101` 表格与 04-08 段末把并发写成「Stage F 的受监督 actor」的框架也待复核。
- **本日未改动**：`src/`、`gleam.toml`、`docs/DESIGN.md`、`docs/RULINGS.md`、
  无 probe、无编译、无测试、无 R31。工作树只有记录类文件。
- 明天按 `04-09-PLAN.md` §4 继续：编译实测 spawn + Subject → 诚实回答 N 份新
  `Desk` 的合并/所有权 → 重写 Stage F 框架 → 纠正两处事实 → 验证与即时提交。
  不是 owner 待裁决项，临时待裁决文档的决策区仍 0 项。

## 2026-11-09 (phase 04-08 — one addressed bar advances one timeframe)

- Measured answer to "can the type structure monitor many instruments, each
  with many intervals, at the same time?": the STATIC chain was already
  complete (`desk.gleam:74-94`, `config.gleam:75-101`: 3 brokers × 3
  instruments × 2 intervals = six independent `Timeframe` states), but a bar's
  ARRIVAL had no address and gate-path errors were `String`.
- New `src/glibe/monitor.gleam`: `TimeframeAddress(BrokerId, Symbol,
  Interval)`, `IncomingBar(address, bar)`, `MonitorError` (address + typed
  lower-level reason), and the pure
  `advance(desk, incoming) -> Result(Desk, MonitorError)`. One bar advances
  exactly one `Timeframe`; no fan-out to all intervals.
- `SourceBarRejection` closed set replaces five `Error("…")` arms in
  `sourcebar.validate`; `timeframe.sourcebar_gate` propagates it.
  `binance.fetch_klines` now takes `Symbol`, not `String` (R22); its return
  type is unchanged and no provider↔broker relation was invented (R26).
- Six new tests in `test/monitor_test.gleam`: addressed timeframe advances,
  other interval / other brokers untouched, two instruments keep their own
  closes, non-boundary bar only opens a bucket, same bar closes 1h but not 4h,
  and both error paths carry the address.
- RED 58 passed / 6 `todo` failures (0 compile errors, 3 skeleton warnings).
  GREEN `gleam build --warnings-as-errors` 0/0, `gleam test` **64 passed**,
  `gleam format --check src test` 0, `guards.sh --all` 0, `gleam docs build` 0;
  `package-interface.json` carries `04-08-PLAN.md` on all four touched modules.
- Deliberately NOT done: actors / subscriptions / streams / replay CLI /
  `gleam_otp` (Stage F), `Market` / `Asset` / `Exchange` relations (R26), any
  field on `SourceBar` or `Timeframe` (R23 / R27 / R28).
- Owner items waiting for a ruling: **0**. This is R26 work, not a ruling.

## 2026-11-09 (R30 / phase 04-07 — local time in the web view, documentation only)

- Owner ruling R30: the web interface shows date-times in **local** time so
  analysis is readable, which requires time-zone conversion and daylight
  saving; the requested deliverable is documentation in the corresponding
  modules so the implementation can be done later.
- R30 = output side (instant → viewer's local wall clock); R29 = input side
  (market local → instant). Both use IANA rules, never a fixed offset; they
  are separate conversions and are not merged.
- Standard `SourceBar.timestamp` / `DataBar.timestamp` (unix time, R27),
  `interval.bucket_ends` (UTC-aligned unix grid) and CSV UTC RFC3339 are
  unchanged. No `tzif` dependency, no new type, no conversion code, no test.
- `////` module docs in `src/glibe/web/server.gleam` (main specification),
  `webclient/src/webclient.gleam`, `src/glibe/export/csv.gleam` and
  `src/glibe/api/sourcebar.gleam` all link plan 04-07; verified in **both**
  packages' `package-interface.json`.
- Also measured this round: the 04-06 module docs of `databar.gleam` and
  `export/csv.gleam` had been truncated mid-sentence where a `////` block
  broke into `//` lines. `gleam docs build` exposed it; both are whole now.
- Measured: `gleam build --warnings-as-errors` 0/0, `gleam test` **58 passed**,
  `format --check src test` 0 (root and `webclient/`), `guards.sh --all` 0,
  `gleam docs build` 0 in both packages; core mirror `cmp` 0; no document
  references the temporary decisions file.
- Owner items waiting for a ruling: **0**.

## 2026-11-09 (R27–R29 / phase 04-06 — unix time at the ingest boundary)

- Standard `SourceBar.timestamp: gleam_time.Timestamp`; `DataBar.timestamp`
  likewise. `date: String`, `normalize_date`, `date_to_iso`, `epoch_ms_to_iso`,
  `civil_from_days`, `clock_of`, `minute_of`: all deleted.
- `binance/kline.gleam` keeps a native twelve-field `Kline`; `decode_klines`
  returns `List(Kline)`; `to_sourcebar` converts `openTime` to unix time.
  `binance/binance.gleam` is the standardisation exit.
- `bucket_ends` is a unix-second remainder grid. Bare dates and unreadable
  labels are `SourceBarTimeError` rejections; the old `False` fallback is gone.
- Compiler-found bug fixed at the wire edge: `float.parse("100")` is
  `Error(Nil)`, so `get_float` / `get_int` had never read Binance's integer
  strings. `parse_number` widens an `Int` to `Float` at the boundary.
- Measured: `gleam build --warnings-as-errors` 0/0, `gleam test` **58 passed**,
  `format --check` 0, `guards.sh --all` 0, `gleam docs build` 0; core mirror
  `cmp` 0; no document references the temporary decisions file.
- Owner items waiting for a ruling: **0**.

## 2026-11-09 (phase 04-05 — the product web layer, adopted)

| axis | value | how it was taken |
|---|---|---|
| framework | **Mist 6.0.3 + Wisp 2.2.2** in the root `gleam.toml`; no Lustre server components, no npm deps | R24 demo conclusion adopted by `04-05-PLAN.md` |
| new module | `src/glibe/web/server.gleam` — closed `Route` set, `desk_to_json`, `page`, `handle_request`, `main` | `gleam docs build` → `package-interface.json` carries `04-05-PLAN` |
| data served | the REAL `config.default_config().desk`, not a demo fixture | `GET /desk` returned binance/BTCUSDT, futu/SPY_FUTU, ib/SPY, each `["1h","1d"]` |
| HTTP | `GET /` 200 (371 B, `<table` + `BTCUSDT` + `futu`), `GET /desk` 200 (236 B valid JSON), `GET /nope` 404 | `gleam run -m glibe/web/server` on port 8610, real requests; port released afterwards |
| GREEN | `gleam test` **54 passed / 0 failures**, `--warnings-as-errors` 0, `format --check` 0, `guards.sh --all` 0, `docs build` 0 | RED was 50 passed / 4 `todo` failures |
| docs coverage | `glibe/web/server` documented; empty module docs 15 / 25 | `package-interface.json` |
| owner rulings | **0** | adoption is AI work under R24, not a ruling |

## 2026-11-09 (R24 / phase 04-04 web demos)

| axis | value | how it was taken |
|---|---|---|
| demos | **3 runnable Erlang-target projects** in `probes/web-layer/` | `gleam run` + real HTTP GET on ports 8601/8602/8603 |
| Gleam / Hex / JS | A 72 lines / 22 pkgs; B 124 / 23; C 82 / 14; **all 0 hand-written JS, 0 npm** | non-blank source count + `manifest.toml` |
| one settled bar | `GET /` and `GET /bar` 200 with `123.5` in all three; B `GET /poll` returns Lustre `Mount` (`kind:0`) | HTTP response bodies |
| runtime import | `webclient.mjs` → `IMPORT_OK exports=["main"]`, exit 0 | `node --input-type=module -e "import(...)"` |
| GREEN | 3 × `gleam test` 1 passed, `--warnings-as-errors` 0, `docs build` 0, plan link in `package-interface.json` | forced recompile after `touch src/*.gleam` |
| conclusion | **recommend A**, not adopted; recommendation in `docs/DESIGN.md` | R24 boundary kept |
| open owner rulings | **0** | R24 was AI work, not a ruling |

## 2026-11-09 (R26 / catalogue types)

| axis | value | how it was taken |
|---|---|---|
| settled relation | **only `Broker ▸ Instrument`**, from the data-source argument | `glib/docs/reference/domain-hierarchy-2026-10-22.md` §1 + §1.18; `src/glibe/desk.gleam` |
| `assets` | 9 `Asset(id, name, class)` catalogue entries; `get_asset` has **0 callers** | `src/glibe/config.gleam:139-212,583` + repo-wide Grep |
| `exchanges` | 3 connection-parameter records; `get_exchange` has **0 callers** | `src/glibe/config.gleam:101-138,568` + repo-wide Grep |
| `markets` | rule sets; `get_market` has **1 caller**, a test | `src/glibe/config.gleam:213-559,595`; `test/interval_test.gleam:99` |
| open owner rulings | **0** | R26 is a ruling, not a new question |

**Owner's direction:** *"其他type之间的关系，比较难确定，可以按需要逐步增加
type，届时关系可能就比较明晰了"* — no advance identity-typing plan, no
speculative relations. Full text: `docs/RULINGS.md` R26.

## 2026-11-09 (R22–R25 / phase 04-03)

| axis | value | how it was taken |
|---|---|---|
| build | **exit 0, 0 errors, 0 warnings** | `gleam build --warnings-as-errors` |
| tests | **50 pass, 0 fail** | `gleam test` (was 44) |
| format / guards | clean / **exit 0** | `gleam format --check src test`, `sh scripts/guards.sh --all` |
| docs | **exit 0**; 6 touched modules carry the `04-03-PLAN` link; empty module docs **15 of 24** | `gleam docs build` + `package-interface.json` |
| `Symbol` | an opaque **name** with a 2-function codec; no instrument fields | `src/glibe/api/symbol.gleam` (R22) |
| ownership | `Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe`, **one** dictionary on `Instrument` | `src/glibe/desk.gleam` (R23) |
| `Timeframe` | ~~carries `settings`~~ **R46 整条作废**；**no** `symbol` / `interval` / `market_type`，也没有 settings | `src/glibe/timeframe.gleam` (R23 / R46) |
| config | `AppConfig` holds a typed `Desk`; the two `List(#(String, …))` tables, `"BTCUSDT_H1"` and both `list.find` accessors are **gone** | `src/glibe/config.gleam` (R23) |
| `Timeframe` pipeline | `sourcebar_gate(tf, interval_key, bar) -> Result(Timeframe, SourceBarRejection)`; `databar_processing(tf)` = `tf |> indicator |> leaves |> branches |> strategy |> working_databar_archived` | `src/glibe/timeframe.gleam` (R39/R40/R41/R42) |
| open owner rulings | **0** | `docs/RULINGS.md` R22–R25 closed all four |

**Owner's direction this day:** a name is not the thing; wrong things are
corrected cleanly, never worked around; type problems are solved with types.
`Desk ▸ Broker ▸ Instrument ▸ Timeframe` is the shape, and the web-layer
framework choice is the AI's demo work, not an owner ruling. Full text and
verbatim quotes: `docs/RULINGS.md` R22–R25.

## 2026-11-07 (Round 5)

| axis | value | how it was taken |
|---|---|---|
| toolchain | **gleam 1.19.2, OTP 29** | `gleam --version`, `erlang:system_info(otp_release)` |
| target | **`erlang`, pure** | `gleam.toml:3`; no JS target, no `@external(javascript, …)` |
| build | **exit 0, 0 errors, 0 warnings** | `gleam build` |
| tests | **26 pass, 0 fail** | `gleam test` — 23 prior + 3 Round-5 invariant tests |
| format | clean | `gleam format --check src test` |
| guards | **3 scripts, all green** | `sh scripts/guards.sh --all` (compiles, mixture, no_foreign_source) |
| CI | pins **1.19.2 / OTP 29**, runs guards | `.github/workflows/test.yml` |
| handwritten foreign source under `src/` | **0 compiled** | `ibkr.ex` retired; 2 `.disabled` design records remain |
| `src/glibe` modules | **23 `.gleam`** | `git ls-files src` |
| closed sets as types | `Signal` (3 constructors), `Interval` (7), `SmaForBbm` (5), `SmaSeries` (5, one home) | code read |
| duplicate `SmaSeries` | **0** | dead 4-constructor copy deleted |
| lower-band floor | **one `1e-6·bb_m` floor, before interpolation** | `bollinger.gleam`, owner §1.13/§1.14 |

**Owner's direction this day:** glibe is the future; **it stops waiting on
glib**. See `REVIEW_ROUND5.md` §1 and `DEVELOPER_GUIDE.md`. The two Gleam
references the owner named are recorded in `DEVELOPER_GUIDE.md` and `README.md`.

## 2026-10-04 (historical)

| axis | value | how it was taken |
|---|---|---|
| build | clean, **0 warnings** | `gleam build` (gleam 1.18.1, OTP 29, erl/erlc/escript at `/opt/homebrew/bin`) |
| tests that run | **23 pass, 0 fail** | `gleam test` — 19 original bodies + 4 ingest-boundary tests |
| format | clean | `gleam format --check` |
| guards | **3 scripts, all green** | `sh scripts/guards.sh --all` |
| unwritten `DataBar` fields | **0** | deleted in `databar.gleam`; every remaining field is written by a module |
| module purity | enforced by a script | `scripts/no_timeframe_mixture.sh` |
| interval codec | present | `api/interval.gleam` `to_string` / `from_string` / `all()` |
| ingest boundary | present | `api/sourcebar.gleam` `validate` + `normalize_date` |

**Not taken here (environment):** CI (`.github/workflows/test.yml`) pins
gleam 1.16.0 / OTP 28. The download could not be fetched (no network in the
sandbox), so the pinned-version build is unverified. The guards scripts default
`GLEAM` to `/opt/homebrew/bin/gleam` for the same reason.

**Lagging glib on this day (since withdrawn — see the withdrawn records in `docs/QUESTIONS.md`):**
KDJ window is `w+1` (glib `w`); D uses alpha ½ (glib's is dead); σ excludes the
bar in hand; lower bands still clamped; `kdj_d_period` still a field;
`window_kdj_size` not yet renamed to `kdj_window_size`. These are Stage D, next.

## What "green" means —— 2026-11-12 R44 作废，保留作历史

~~A stage is done only when all three are true: `gleam build` clean, `gleam test`
green, and `sh scripts/guards.sh --all` green. A stage that cannot be verified
is not done — that rule is why the guard scripts exist before the work they
guard.~~

R44：项目层不再有 `guard sh`，这段连同它描述的三件门槛一起作废。空架子阶段
只把 `gleam check` / `build` / `docs build` / `package-interface` 当设计探针
用来暴露缺口。~~`--warnings-as-errors` 是将来填完 body 之后的 GREEN 闸门。~~
**R48 更正**：这句正是「把 warnings 当奖励」的免检牌，已作废；WAE 从
空架子起就是固定门禁。行为层（例如提交是否及时）由纪律约束，脚本探测不到。

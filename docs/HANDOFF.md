# HANDOFF — glibe / `doc-tdd`

> **新会话先读这一节。** 再读 `docs/RULINGS.md` R44–R50。
> **不要读 `deprecated/`**：里面是旧实现，只读、不是依据、不是词库（R44/R45）。
> **动手前**：载入 `gleam-language` 技能并**全文**读
> `~/.workbuddy/skills/gleam-language/references/gleam-core.md`
> （仓库镜像 `docs/gleam-thinking-core-to-memory.md`，`cmp` 一致，R19）。
> **list 效率设计与骨架填写**：`DEVELOPER_GUIDE.md`（2026-11-15 起，
> 导航文件，不是第二份规格）。
>
> 首次交接 2026-11-13 00:28，owner 当时最后一句：
> *「完了，你。一片混乱。写交接文档，开新会话吧。这样做下去毫无意义。」*
> ⇒ 那一会话**停止重构**，只做实测、校准、交接、提交。
> 本文件由 2026-11-13 的新会话（载入核心卡片后）更新，见 §1.1。

---

## 1. 状态（实测，非估计）

- 分支 **`doc-tdd`**，2026-11-14 **已普通 push** 到 `origin/doc-tdd`
  （fast-forward，无 force）；工作树干净。本 §1 其余数字是 2026-11-13
  快照，当前实测见 `docs/STATE.md` **顶部（2026-11-16 03:09）**；
  待裁决项现为 3 项，见该节。知识中心 `~gits/gleam-language` 已于
  2026-11-16 提交 `dc736df`（owner 授权），**无 remote、无法 push**；
  skill 目录不是 git 仓库，只是硬 `ln` 的消费者。
- `src/` = **14 个 Gleam 模块、零行实代码**（函数体全 `todo as "…"`）。
- `test/` = **9 个空 shape test**，只钉 in/out types，无断言、不调用 `todo`。
- 待裁决 **0 项**（2026-11-13 快照；当前 **3 项**，见
  `docs/STATE.md` 顶部 2026-11-16 03:09 节）。第 1 项已按 owner
  08:38「reverse 没有理由、要看消费方」收窄，08:58 又裁定
  「不必按时间顺序存储」（读侧 prepend）；第 3 项是 owner 08:44
  要求的导出格式探讨，依赖第 1 项、不预设推荐、不催。09:09 的
  BEAM 门裁定、09:22 的「靠 BEAM 吃饭 / 语言知识归知识中心」
  **都不新增决策项**；09:22 只是把第 3 项里「BEAM 专有」从
  「代价」改成性质，**格式仍待探讨、不替 owner 选**。
  逐字与 inode 实测在 `docs/RULINGS.md`「2026-11-15 09:22」，
  三条编译探针在同文件「2026-11-15 09:09」，其余查证链在
  「2026-11-15 08:38」与「2026-11-15 08:44–08:58」。

| 命令 | exit | 结果 |
|---|---|---|
| `gleam check` | 0 | |
| `gleam test` | 0 | **9 passed, no failures** |
| `gleam format --check src test` | 0 | |
| `gleam docs build` | 0 | |
| `gleam export package-interface --out …` | 0 | **14 模块** `////` 全渲染 |
| `gleam build --warnings-as-errors` | **1** | **故意红**：73 warnings = 27 `Todo` + 43 `Unused function argument` + 3 `Unused private constructor` |

`export PATH="/opt/homebrew/bin:$PATH"` 后才有 `gleam`。

### 1.1 新会话（载入核心卡片后）实测

- `gleam-language` 技能已载入；核心卡片全文读过，
  `gleam-core.md` 与 `docs/gleam-thinking-core-to-memory.md` `cmp` exit 0。
- 上表六条命令在**源码改动前后各跑一次**，数字逐项相同：WAE 仍 73；
  `package-interface` 复验 **14 模块** `////` 全渲染、无 `//` 截断。
- 改动只在 `src/glibe/leaf.gleam` / `branch.gleam` 的 `////`：删掉
  R47 §2 禁止的自我豁免措辞「a documented type is a valid skeleton
  item」，换成 `timeframe.leaves` / `timeframe.branches` 与 `Timeframe`
  具体字段的读写关系。**零行实代码、零个新名字、零个 `_` 静音。**
- R19 ④（空 shape test → 真断言、逐个填 body）**尚未开始**；
  §5「本阶段不写实现」边界未解除，等 owner 明示。

### WAE 是什么
`gleam build --warnings-as-errors` 把编译器的 warning 当 error，使 build
返回非 0。**逐个查过 `gleam --help`：这个 flag 只在 `build` 子命令有**，
`check` / `test` / `docs` / `format` 都没有，`gleam check` 顶替不了。
R48 由 owner 点名启用，原话 *「把warnings当作奖励，也是AI特有的
美德，所以你要用 gleam warnings-as-error 这个开关」*。

### 门禁是什么
`.github/workflows/test.yml` 里排在 `gleam test` 之前、必须 exit 0 才继续
的那条命令。骨架阶段它**从第一具空架子起就故意红**：每一条 warning
对应一行还没写的代码（27 个 `todo` + 43 个未用参数 + 3 个未用私有
构造子），填一个 body 少一条。R48 已作废「warnings 是预期骨架形状」
这类免检牌，并禁止用 `_` 前缀批量静音（实测 `_a` 是 discard name，
body 引用会报 `Found a discard name`）。
**它不是成绩单，是逐条待实现清单。** 本分支已 push（2026-11-14）、CI 的 push 触发
只有 master/main，所以现在没拦住东西；**开 PR 到 master 会红**。

---

## 2. 当前结构（R50）

一条规则：**一个模块只读写它自己那一层「持有的」 Dict；函数跟着它
读写的 Dict 的持有者走。** `Broker` 按 R33/R36 持有两个 Dict，仍属同一层。
`Desk` 是唯一顶层 Value，**上面不再有任何 module**（R42 / R50 §7）。

```
id, account     零 import 叶子
instrument      Instrument + get/put_timeframe          → timeframes
broker          Broker + get/put_instrument/account     → instruments, accounts
desk            Desk   + get/put_broker                → brokers
timeframe       Timeframe + 直线 / 管道全部 fn
其余            api/{interval,symbol,sourcebar}, databar, leaf, branch,
                trading/signal, binance/kline
```

依赖单向无环：`id` / `account` → `instrument` → `broker` → `desk`。
实测约束：`pub opaque` 构造子跨模块 → `error: Use of private value`；
互相 import → `error: Import cycle`。所以 id 必须是零 import 叶子，
`broker_id` / `account_id` 必须与 id type 同模块。

**已删除**：`config.gleam`（import desk、返回 Desk，是包在根上面的
配置层）、`timeframe_under`、`put_timeframe_under`、`LookupError`、
`indicator_settings.gleam`、`Timeframe.settings`、`timeframe.new`。
四个 `get_*` 返回 `Result(v, Nil)`（core §6 / R37：caller 本来就持有 key）。

---

## 3. 权威与词源

- **owner 当前陈述 > spec > 旧代码 > 我的推断。**
- 名字只从 **owner 逐字用词 + 裁定**取；没命名的按 R26/R32 **留空**。
- `glib/docs/` 是另一个模型 hy4 的 AI 散文，不是证据、不是词源。
- **AI 自己记在 `RULINGS.md` 里的裁定也不是 owner 逐字**（R46/R49）。
- 裁定全文与逐字原话在 `docs/RULINGS.md`（R44–R50）；**别凭转述**。
- 引用必须真逐字，不得把转述或截断句标成 `owner, verbatim`（R43/R47）。

---

## 4. 失败模式（新会话要防的那几条）

上一会话：我在 `desk.gleam` 的 `////` 里自己写着
`WRITES: Desk, Broker, Instrument, Account...` —— **一个模块读写四层，
证据就在这个文件里**，却没拿它去量这个文件；还把 core §5
「Do not fragment modules」（那条官方反模式针对的是**按设计模式切**
controllers/services/types，不是按业务域归属切）当免检牌。
R47 的判据只用在「单条 `///` 能否自译」，**没有用在「一个文件能否
译成一条归属关系」**。

owner 连续点出的 `TimeframeSettings` → `new` → `LookupError` →
`config.gleam` 是**同一层错误**：造了一个没有真实消费方、没有归属、
讲不出「谁读写哪个具体值」的东西，每轮都靠 owner 点名才发现。
**诚实标注：「无提示自行发现」至今未实测，不预写成功。**

**2026-11-13 新会话又犯了一次同类错误**：把 `leaf.gleam` / `branch.gleam` 的
`No function here yet.`（这两个模块确实零个函数）按「统一措辞」换成
描述 `todo` 骨架的 `No working line here.` —— 一次字符串替换，不是
重新描述（R47 §1.1）。owner 逐字 *「no function here yet -> no working
line here yet; nonsense」*，已恢复原句。
⇒ 把措辞对齐到别的模块不是理由；每句 `////` / `///` 都要重新对着
**这个模块**的事实写。该会话加载核心卡片后主动跑 §13 / R47 判据，
查出上述两处 R47 残留（owner 未点名文件）；但同一处改动里的替换错误
仍由 owner 点出，是否算「无提示自行发现」不自行下结论。

> **动手前先问：这个 type / fn / module 谁读写它？答不出就不要写。**

---

## 5. 不要做

- 不要翻 `deprecated/` 取名字或抄实现。
- 不做字符串级「措辞统一」；每句文档重新对着本模块事实写（§4）。
- 本阶段**不写实现**；不要为让 WAE 变绿而用 `_` 静音或整包豁免。
- 不新增 guard sh；不新建 `engine` / `monitor` / `replay` / `AppConfig` /
  `config` / 任何 provider 统一框架 / 任何跨层便捷函数。
- **不手写 `.erl` / `.ex` / `.mjs` 进 `src/`**（owner 2026-11-15 08:16 /
  08:28 逐字，见 `docs/RULINGS.md` 同名注记）。但**`@external(erlang, …)`
  是必须、正常、合理的 Gleam 设计**：它不等于 FFI、不基于手写 erl；
  「FFI 只限于 JS」的理由是 BEAM 同 VM / JS 跨运行时
  （`~gits/gleam-language/knowledge/externals.md` §2）。需要运行时 API
  就调 OTP 模块或 `gleam add` 的包，**零 external 不是目标、不是成绩**。
  根包的 target 声明会让 JS 外实现编译失败，但**手写 `.erl` 会被静默
  编译成 `.beam`**，所以禁手写这一半不靠编译绿来证明，靠 `src/` 的
  文件清单。Gleam 语言知识的家是 `~gits/gleam-language`，不是 WorkBuddy
  全局 Memory（owner 08:30）；owner 09:22 追加：实测验证的语言感悟
  **写进知识中心**，消费方用**单文件硬 `ln`**接过去，
  **不得用 symbol link、不得链接目录结构**，检查用
  `stat -f '%i %l'`（`cmp` 分不出副本与链接）。本项目的
  `docs/externals.md` 就是这么链进来的查阅入口，不是新写的规格。
- **不要把「依赖 BEAM」当顾虑**（owner 09:22：*"我就是打算靠BEAM
  吃饭的。你没看到我最近的项目都是gleam"*）。BEAM 原生是性质，
  不是格式选项的减分项；这不等于替 owner 选了导出格式。
- **不要改写远端历史**：普通 fast-forward `git push` 直接做；
  `--force` / `--force-with-lease` / rebase 后强推 / 删远端分支
  **必须先问 owner**（2026-11-14 裁定，逐字见 `docs/RULINGS.md`
  同日执行注记）。原先这行写的「不要 push（owner 没让）」是 AI
  注记冒充 owner 约定，已作废。
- 不写长篇 prose 文档记录概念；设计写进 `////` / `///`。

## 6. 留白（R26/R32，等真实消费方，不是待办清单）

`DataBar` 计算字段、leaf/branch 内部字段、`Kline` 线格式字段、
`SourceBarRejection` 具体原因、`Account` 字段。
`gleam.toml` 旧依赖表与 `webclient/` 旧实现未收敛。

## 7. 读文件顺序

0. `gleam-language` 技能 + `gleam-core.md` 全文（见文件首）
1. 本文件
2. `docs/RULINGS.md` **R44–R50**（R50 §7 = 删 `config.gleam`）
3. `.planning/phases/05-doc-tdd/05-01-PLAN.md`（§4 模块清单、§5 六轮核验）
4. `src/glibe/desk.gleam` → `broker` → `instrument` → `id` → `account` → `timeframe`
5. `test/glibe_test.gleam`（空 shape test 钉住各层签名）
6. `docs/STATE.md` 顶部

**提交**：本轮核验与交接随最后一个 commit 落地；
`git log --oneline -8` 可看按逻辑分的原子提交。push 边界见
`docs/RULINGS.md` 2026-11-14 执行注记：普通 fast-forward push 直接做，
任何 force / 改写远端历史的操作先问 owner。

# glibe — 跨 WorkBuddy / CodeBuddy 的会话入口

本文件不含设计内容，只指出材料在磁盘上的位置。判断依据是 owner 当前的
逐字陈述；其余文档只作出处。不要在别处复制这些材料。

官方依据（逐字）：

- WorkBuddy 项目文档：「进行代码开发时，WorkBuddy 支持读取项目工作目录下的
  `.codebuddy/` 项目级配置，行为与 CodeBuddy Code 保持一致」；
  「兼容现有配置：与 `CODEBUDDY.md`、`.codebuddy/CODEBUDDY.md`、`AGENTS.md`
  及用户级 `~/.codebuddy/` 配置兼容，可并存使用」。
- CodeBuddy Code 文档：`.codebuddy/CODEBUDDY.md` 为「项目级记忆文件」，
  记忆加载顺序第 3 项为「项目级记忆：CODEBUDDY.md（从 cwd 向上递归查找）」。

## 打开这个项目后按顺序读

1. `docs/HANDOFF.md`
2. `docs/RULINGS.md`（尤其 R44–R50）
3. `/Users/jk/gits/gleam-language/gleam-thinking-core.md` — 核心卡片单一
   数据源，与 skill 的 `references/gleam-core.md` 是同一 inode，完整读
4. `/Users/jk/.workbuddy/skills/gleam-language/SKILL.md`
5. `.workbuddy/memory/MEMORY.md` 与当日日志
6. `.planning/phases/05-doc-tdd/05-01-PLAN.md`

跨项目偏好在 `~/.codebuddy/CODEBUDDY.md`（与 `~/.workbuddy/MEMORY.md`
同一 inode）；gleam-language skill 文档在 `~/.codebuddy/skills/`，
与 WorkBuddy 侧逐文件硬链接，两边是同一批文件。

## 工作方式（owner 逐字）

- 「我现在对AI的要求降低到听写这一层了。能智能化听写就不错」
  （2026-11-13）：照逐字落，不自行推断；owner 没说过的只能作为待裁定，
  不能写成正文。
- 「不写实现，但是框架你搭建完整了吗？ / unit test这一步在框架初步建完，
  复查没问题之后。 / 下一步是填充具体实现。」
- 「按照用户的指引，以及 business logic 去重新设计，框架搭建和测试不就是
  设计阶段吗」
- 「继续做，直到做完。…你可以从任何一个点切入，跟着逻辑走，必然发现缺环，
  然后就去设计补上，等所有的通路都没有缺环，设计不就是完工了？」
- 「关键是，你这次是把type搞对，也就是那一个type的对应模块做什么工作，
  这个分工搞清楚，不要搞得乱七八糟越俎代庖」

每次改动后回显「owner 原话 → 落到哪个文件哪一段 → 可核对出处」的校对稿；
不要求人回忆细节。

## 当前阶段

虚体结构：module / type / fn 签名 + `////` / `///`，不写业务实现。
框架复查通过之后才写 unit test。

门禁（完整命令）：

```
gleam check
gleam test
gleam format --check src test
gleam docs build
gleam export package-interface --out /tmp/g_pi.json
gleam build --warnings-as-errors
```

# Questions — glibe（历史记录 / 已撤回条目）

本文件只保留**已撤回条目**与撤回理由，供追溯；**不再存放待裁决项**。
待裁决项由 owner 在一个**临时工作文档**里单独查看：那个文档可以从别处搬运
内容，但**其他文档一律不引用它**——它裁决后整条删除、换上新的，反向引用
只会留下悬空链接。

引用规则：**文件全路径 + 条目名**，例如 *`docs/RULINGS.md` R16* 或
*`docs/REVIEW_ROUND5.md` §13.8*。
**不使用裸编号**（"Q" 加数字）：它既像 Question N 又不是，且曾与聊天消息里的
问题编号混淆——`docs/REVIEW_ROUND5.md` §11.2 曾借某个编号指 live view 是否
强制 JS target，而本文件同编号的条目一直是「下轨地板」。该处已改正。
2026-10-04 版给条目编过 1–7，那些编号随条目一起废止。

## 已撤回 2026-11-07（Round 5）

五个 2026-10-04 条目已经过时，另两个本来就把裁定引错了。继续挂着它们就是
owner 说的「endless waiting」。旧编号已废止，此处按主题列出。

| 已撤回条目 | 撤回理由 |
|---|---|
| KDJ 窗口 `w` 还是 `w+1` | 代码已经用 **`w`，含手中这根 bar**（`kdj.gleam:19-22, 89-99`，`batch_window` 取 `w-1` 根 settled bar）。`w+1` 已在 `b0f5f33` 修掉。取值来源是 idib 的 `kdjPeriod = 7`。 |
| σ 用哪个窗口 | 代码**含手中这根 bar**（`bollinger.gleam:72`），注释说明了原因，与 glib 一致。 |
| 下轨要不要地板 | **条目把裁定引错了。** owner 没说「no floor」：§1.13/§1.14（2026-10-14，2026-11-02 定稿）是**一个极小的正数 `1e-6·bb_m` 地板，加在外缘、插值之前**。已落在 `bollinger.gleam` 并有不变量测试；Round 4 的 `0.0` clamp 是错的，已删。 |
| K 与 D 用同一个 alpha | 已落地：单一 alpha `1/kdj_k_period`，`kdj_d_period` 删除（Round 4）。 |
| `window_kdj_size → kdj_window_size` | 本轮已在 settings、config、kdj 和测试里改名。 |
| AI 策略层「等 glib 做完再移植」 | **假前提。** owner 已下令删掉 glib 的 AI 层（`a99e615`）；`ai_s1`、`learn`、`boost`、`knn` 在 glib `src/` 里 grep 全为 0。没有东西可移植，也没有什么可等。 |

## 相关稳定文档

| 想找什么 | 去哪里 |
|---|---|
| 裁定原文（含 R16：手写 JS 的可接受范围） | `docs/RULINGS.md`；glib `docs/RULINGS.md` §1.28 |
| 评审与测量（框架来源、能力对比、行数成本、生成 mjs 探针） | `docs/REVIEW_ROUND5.md` §10 / §12 / §13 / §13.8 |
| 设计 | `docs/DESIGN.md` |
| 当前状态 | `docs/STATE.md` |

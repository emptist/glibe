# Externals — `@external` 的术语、边界与铁律

> 来源：gleam.run **Externals** guide（不是 "FFI doc"——gleam.run 上没有 FFI 文档，只有
> Externals 文档，讲的是 `@external` 机制）。本文件是 owner ruling 2026-11-13 的落点。

## 1. 名字：是 Externals，不是 "FFI"

gleam.run 上没有 "FFI" 文档。相关文档是 **Externals guide**
（`https://gleam.run/documentation/externals`），讲的是 `@external` 机制。不要把
`@external(erlang, …)` 叫做 "FFI"。

## 2. external 与 foreign 的边界（owner ruling 2026-11-13）

- **BEAM 目标下，Gleam 调用 Erlang / Elixir / LFE = `external`（外部），但绝不是
  `foreign`（外来）。** 它们同跑在一个 BEAM VM 上，运行时表示一致，是同一个世界的兄弟
  语言。调用它们用 `@external(erlang, …)`。
- **JS = `foreign`（外来）。** 它是完全不同的运行时；跨运行时才叫 Foreign Function
  Interface（FFI）。JS 目标的外部源文件（`.mjs` / `.js`）才是 FFI。

一句话：**在 BEAM 上，Erlang/Elixir/LFE 是"外部"；只有 JS 是"外来"。** 不要混为一谈，也
不要把 `@external(erlang, …)` 叫做 "FFI"。官方文档原文：

> Gleam on Erlang can use Erlang, Elixir, LFE, and other BEAM languages.
> Gleam on JavaScript can use JavaScript, and other compile-to-JavaScript languages.

## 3. 语法：无函数体的声明

`@external` 装饰一个**带类型注解、但没有函数体**的 Gleam 函数。三个参数：

1. 目标：`erlang` 或 `javascript`。
2. 外部函数所在的模块名（JS 是相对文件路径）。
3. 函数名。

```gleam
@external(erlang, "lists", "reverse")
pub fn reverse_list(list: List(element)) -> List(element)
```

类型注解 **mandatory**。编译器保证调用处的类型正确，但**无法验证**外部实现是否真的存在、
是否返回注解的类型——所以外部函数要比平时多写测试（`gleeunit`）。

## 4. Elixir：目标仍是 `erlang`，模块名带 `Elixir.` 前缀

```gleam
@external(erlang, "Elixir.Pokemon", "badge_count")
pub fn pokemon_badge_count() -> Int
```

注意：即使函数是用 Elixir 写的，`@external` 的**目标还是 `erlang`**——因为是 BEAM 目标在
编译。

## 5. 铁律：绝不手寫 `.erl` / `.ex`（owner ruling 2026-11-13）

**你本人不写任何目标语言源文件。** 要 Erlang/Elixir 能力，只有两条路：

1. **调用 VM 自带的 OTP 模块**——例如 `@external(erlang, "os", "cmd")`
   （`os:cmd`）、`@external(erlang, "httpc", "request")`、`@external(erlang, "lists", "reverse")`。
   这些是运行时提供的 API，不是你写的源码；属于合法的 `external`（不是 foreign，也不是手寫）。
2. **用 `gleam add` 加一个包，再调它的纯 Gleam API**——例如 `gleam_httpc` 内部用
   `@external(erlang, "httpc", "request")` 包住了 OTP 的 `httpc`，对外暴露纯 Gleam 的
   `httpc.send`。你只写纯 Gleam，不碰 `.erl`。

手寫 `.erl`/`.ex` 是违规：它绕过"包提供代码"的边界，无法被编译器类型检查，而且一旦需要 JS
目标就直接编译失败。

## 6. 优先纯 Gleam 包（官方指南）

Externals 应当 **sparingly** 使用：首选纯 Gleam 方案；没有现成纯 Gleam 库时，先查有没有现成
包（`gleam add`），而不是手寫目标代码。只有两种情况官方认可：

- 需要调用**运行时 API**（例如取虚拟机内存统计）；
- 运行时上**已经有一个别人写好的实现**，自己实现不划算（预算/期限）。

## 7. 多目标

一个函数可同时挂两个 `@external`（各一个目标），从而两个目标都可用：

```gleam
@external(erlang, "lists", "reverse")
@external(javascript, "./my_ffi.mjs", "reverse_list")
pub fn reverse_list(list: List(element)) -> List(element)
```

JS 那边才需要手寫 `.mjs`（那是 FFI，JS 目标的外部源文件），不是 BEAM 这边。

## 8. 反例已删，正例已落地（本项目 try_plushie，2026-11-13 完成）

- **反例（已删，落点 confirmed）**：原 BEAM 项目里手寫的 `glib_client_ffi.erl` /
  `voice_ffi.erl` 已删除。它们本想做 HTTP/SSE 与 TTS，但手寫 `.erl` 既绕过"包提供代码"
  的边界、无法被编译器类型检查，又会让 JS 目标直接编译失败——纯属违规。
- **正例（已落地，已验证）**：消费 glib 已发布的 model —— `glib_client.gleam` 用纯 Gleam 包
  `gleam_httpc`（`httpc.send`，内部 `@external(erlang,"httpc","request")`，零手寫 `.erl`）
  取 `GET /api/databars`，并用 `@external(erlang,"inets"/"ssl","start")` 调 OTP 启动
  inets/ssl（VM 自带 API，合法 external）；TTS 走 plushie 内置 `command.announce`。wire JSON
  经 `decode_bar` / `decode_snapshot` / `decode_live` 解码后直接渲染，**不重算**任何
  bar/指标。glib 基础代码一行未改。
  - 契约已对拍真实 glib 源码：`encode_data_bar`（字段 `idx/open/high/low/close/volume/
    sma_medium/yin_leaf_cma/yang_leaf_cma/signal`）与 `server_ffi.mjs` 的
    `GET /api/databars → {ok,symbol,interval,data}` 及 SSE `chart_data → {symbol,interval,bar}`
    完全吻合。
  - `gleam check` 干净、`gleam test` 7/7 通过（含 `decode_snapshot_test` 按 glib 同款 wire 解码、
    `consume_render_test` 把模拟快照送进 update 验证"消费→解码→渲染"闭环，渲染管线不因重复
    node ID 崩溃）。
  - **这就是"完美客户端"考察点的结论：能顺接 glib、不重算、不改基础代码，且是纯 Gleam、零
    手寫 `.erl`。** 唯一未跑的是"真·HTTP 实拉"——需另起 glib 的 Node 服务做端到端；解码/契约
    与渲染闭环已被单测与集成测覆盖。

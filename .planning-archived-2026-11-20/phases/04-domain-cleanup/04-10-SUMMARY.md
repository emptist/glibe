# Phase 04 Summary 10 — the design rulings became CODE (2026-11-10)

**Result: GREEN.** Plan `.planning/phases/04-domain-cleanup/04-10-PLAN.md`
was executed in four logical commits, not as one batch.

> **R19 的制作流程（owner 逐字全文在 `docs/RULINGS.md` 文末「一个 module
> 文件的制作流程」段）**：「实际完成方式」就是制作流程，对象是
> **一个 module 文件** —— ① 先写描述 → ② 再写**空架子**（没有实际东西）→
> ③ 再写 test，**设计目标在此** → ④ 逐步测试、逐步完成全部合乎 test
> 要求的代码。
>
> **如实定位（owner 11:05，逐字在 `docs/RULINGS.md` 11:05 段）：04-10
> 没有照这条流程走。** `Desk` 等 type 与逐层 `get_*` 早已实现，本轮才补
> 文档与断言，是「倒过来整」的反向补课；**不是**流程示例。只有
> `timeframe_under` 一小段是「`///` + `todo` → test → 实现」的顺序。
> 本文件记录一次 retrofit，不冒充按流程制作 module。

## What actually happened — a retrofit, NOT the making process

| work done (retrofit) | commit | measured state |
|---|---|---|
| plan item | `3e7ac3b` | `04-10-PLAN.md` names the plan, the four steps, the scope and the GREEN gate |
| 后补 `////` / `///` 文档 + 一个带 `todo` 的签名 | `7594beb` | six existing modules; **no new type**; one documented signature with `todo as "…"` and no real body. `gleam build` = 0 errors / 5 warnings (4 unused args + 1 `Todo found`), `gleam format --check` = 0 |
| 后补 6 个断言 | `2d3aff9` | `test/level_judgement_test.gleam`, each with `///`. `gleam test` = **68 passed, 2 failures**, both crashing at `src/glibe/desk.gleam:289` with the `todo` message |
| 填 `timeframe_under` 的 body | `44a8142` | `todo` replaced by three `result.try` steps. **70 passed, no failures**, `--warnings-as-errors` 0/0 |

## What was written into the code

- `src/glibe/desk.gleam` — R33 (one top-level Value, pure recomputation),
  R36 (`Market` rejected in both directions, no gap), R37 (two ownership
  relations, attachment ≠ ownership, identity in the holder's key, the
  left-hand words verbatim), R34 (the multiple-brokers layer is here); `///`
  on `Desk` / `Broker` / `Instrument` / `Account` / `LookupError` /
  `BrokerId` / `AccountId` states WHY each sits where it does. The stale
  *"Market is not a level in this chain yet"* paragraph is **corrected**.
- `src/glibe/config.gleam` — R34: both predecessors had one broker; seib's
  structure was right and lacked only the layer; ibOptions' settings were
  flattened types because Python + pandas could not express structural
  relations; `default_config()`'s `binance` / `ib` / `futu` IS that layer.
- `src/glibe/timeframe.gleam`, `src/glibe/api/symbol.gleam`,
  `src/glibe/api/interval.gleam` — R37: the key is the holder's name; a
  `Timeframe` does not know its interval.
- `src/glibe/web/server.gleam` — R35: the View is a projection of a value,
  which is why it updates (R33); concurrency = official docs + competing
  demos = TDD; *"简单是正确的验证码"*.
- `src/glibe/desk.gleam` — `timeframe_under(desk, broker_id, symbol,
  interval) -> Result(Timeframe, LookupError)`, a pure read following the
  three holders' keys. **No address type, no advance, no state** — it is not
  R33's void `monitor.advance` / `TimeframeAddress` / `IncomingBar` /
  `MonitorError` layer.
- `test/level_judgement_test.gleam` — 6 assertions: three brokers (R34);
  `Market` is a catalogue entry while `Desk` still holds `Broker` directly
  (R36); a keyless `Broker` under two keys; equal `Timeframe`s under two
  interval keys (R37); the whole-chain read equals the three per-level reads;
  each failure carries its own key from the closed `LookupError` set.

## GREEN gate — measured

```
gleam build --warnings-as-errors  BUILD_WAE=0   (0 errors / 0 warnings)
gleam test                       TEST=0        (70 passed, no failures)
gleam format --check src test    FORMAT=0
sh scripts/guards.sh --all       GUARDS=0      (7 fixture cases, all green)
gleam docs build                 DOCS=0
core mirror cmp                  CMP=0
```

`gleam docs build` → `package-interface.json` (documentation is a LIST OF
LINES, not a string): `glibe/desk` 4469 chars, `glibe/web/server` 5193,
`glibe/config` 2675, `glibe/timeframe` 2592, `glibe/api/interval` 2521,
`glibe/api/symbol` 1818 — all carry the **04-10 plan link** and their
judgements, none truncated by a stray `//`. `timeframe_under`'s `///` is 854
chars with R33 / R36 / R37. `webclient`'s interface is intact (unmodified).

## Scope held

No new type, field or relation; no dependency; no change to the three
catalogue tables or their accessors; no `monitor.gleam` edit; no probe; no
replay CLI; no concurrency framework; decisions section still **0 items**;
one-way reference rule preserved (no other document points at that temporary
file). Work tree clean; **not pushed**.

The real work is unchanged: connect each data source's live arrival to the
standard `SourceBar` entry, and the replay CLI. `monitor.gleam`'s disposition
is the owner's call.

# Phase 04 Plan 09 — Summary

**Status: DONE (2026-11-10).** Owner 2026-11-09 asked whether Gleam's natural
parallelism really needs "all those actor things", and told me to check the
official site plus well-known code (Wisp / Lustre). 2026-11-09 was record-only
(`04-09-PLAN.md`); this is the 2026-11-10 implementation. **Scope: Erlang /
BEAM only** (owner 06:09: *"你去看什么javascript target完全不对路，我们是erlang 和
BEAM专属项目"*).

## 1. Delivered

`probes/parallel-bars/` — a standalone Erlang-target Gleam package whose only
production dependency is the root `glibe` via a path dependency:

- `gleam.toml`, `manifest.toml`
- `src/parallel_bars.gleam` — `////` module doc naming
  `.planning/phases/04-domain-cleanup/04-09-PLAN.md`, `StepReply(address,
  worker: Pid, outcome: Result(Desk, MonitorError))`, documented signatures for
  `sample_arrivals` / `advance_in_parallel` / `advance_in_order` / `describe` /
  `main`, and private `quote` / `addressed` / `collect`.
- `test/parallel_bars_test.gleam` — four tests written BEFORE the bodies (R19).

No `src/` logic changed in the root package, no dependency added, no FFI, no
`gleam_otp` import in the probe. `monitor.gleam`'s `////` module doc was synced
to R31 (specification text only).

## 2. R19 cycle

| Phase | Measured |
|---|---|
| RED | `gleam build` 0 errors / 5 `Todo found` warnings; `gleam test` **0 passed, 4 failures**, each printing the `todo` file:line and message |
| GREEN | `gleam build --warnings-as-errors` **0/0**; `gleam test` **4 passed, no failures**; `gleam format --check src test` 0; `gleam docs build` 0 |

## 3. Measured run — `gleam run -m parallel_bars`

```
04-09 | 6 addressed bars, 6 distinct BEAM processes, 0 actor / 0 supervisor / 0 lock
  futu/SPY_FUTU/1d     //erl(<0.122.0>)
  futu/SPY_FUTU/1h     //erl(<0.121.0>)
  ib/SPY/1d            //erl(<0.120.0>)
  ib/SPY/1h            //erl(<0.119.0>)
  binance/BTCUSDT/1d   //erl(<0.118.0>)
  binance/BTCUSDT/1h   //erl(<0.117.0>)
  partial Desks equal to the single-owner fold: 0 / 6
```

Six `IncomingBar` values at six configured `TimeframeAddress` values, one
`process.spawn` each, one typed `Subject(StepReply)` owned by the caller,
`process.receive(from:, within: 5000)` to collect. Replies arrived in **reverse
spawn order** — the BEAM scheduler, not a sequential loop.

## 4. The honest conclusion: ownership, not synchronisation

Each parallel worker returns a whole new `Desk` that advanced **ONE** address
and still holds the original state at the other five. **0 of 6 partial `Desk`
values equal the single-owner fold.** Immutable values do not merge themselves;
"take the last one" silently drops N−1 updates. The two correct shapes are:

1. **One owner** applies the steps in arrival order (`advance_in_order`).
2. **Each address owns its own `Timeframe`** — then there is no global `Desk`
   to merge at all.

Both need **no lock, no retry, no supervisor**. This is a data-flow / ownership
decision, to be taken when a real consumer needs it (R26). No new production
type was invented. Values DO live in memory — in each process's own heap,
immutable and copied on send; what does not exist is **shared mutable memory**.

## 5. Evidence (full quotes and `file:line` in `04-09-PLAN.md` §2)

- `https://gleam.run/`: "multi-core actor based concurrency system … millions
  of concurrent green threads"; a three-line `new_subject` / `spawn` /
  `receive` example.
- `https://gleam.run/news/gleam-v0.12-and-gleam-otp-v0.1-released/`: "there's
  no need for an `async/await` syntax or callbacks", "doesn't require any
  special types such as futures or promises", "Erlang and Gleam don't have
  mutable state so locks and shared mutable state is not an option", "The Gleam
  compiler can full type check channels". Actor = long-lived state + OTP system
  messages; supervisor = fault tolerance, not parallelism.
- Local: `gleam_erlang/process.gleam:36 spawn`, `:78 opaque Subject(message)`,
  `:138 new_subject`, `:194 send`, `:227 receive`, `:676 call`;
  `gleam_otp/actor.gleam:1-14` "An Actor is a process like any other BEAM
  process"; Wisp `wisp.gleam` **0** `process.` calls; glisten `:274,397,435,446`
  one process per connection + supervision pool; Lustre server runtime
  `runtime/server/runtime.gleam:81-122` exactly one actor + factory supervisor.

## 6. Two facts I got wrong on 2026-11-09, now corrected

1. "**`gleam_otp` 也没引入**" — false. Root `gleam.toml` already has
   `gleam_otp = ">= 1.3.0 and < 2.0.0"` as a direct dependency. What was
   missing was its USE, not the dependency.
2. `docs/DESIGN.md` 04-08 section's "no … `gleam_otp` dependency" — same error,
   now rewritten. The 04-08 PLAN and SUMMARY keep their original text with a
   dated correction note at the top (historical records).

## 7. Documents changed

- `docs/RULINGS.md` — **R31** added: owner's verbatim words, scope correction,
  official evidence, actor's exact position, the memory clarification, the
  measured result, and the two fact corrections.
- `docs/DESIGN.md` — new section "Parallel addressed steps are already natural
  (04-09 / R31)"; `:101` runtime row, 04-08 section ending, and "What glibe
  does not do yet" rewritten. The **Stage F = supervised actors** framing is
  gone; replay CLI / live feed remain listed as work.
- `docs/STATE.md` — new 2026-11-10 state section (the newest state).
- `.planning/ROADMAP.md` — Phase 04 Plan 09 completion entry.
- `README.md` — monitoring row, tests row (64 root + 4 probe), project tree.
- `docs/PENDING_DECISIONS.md` — `# REFERENCE` and the "不需要你决定" list
  corrected; **decision area still 0 items**. No other document references it.
- `src/glibe/monitor.gleam` — `////` module doc only (R31 / 04-09 / the probe).
- `04-08-PLAN.md`, `04-08-SUMMARY.md` — dated correction notes, original text
  preserved. `04-09-PLAN.md` — status now records the 11-10 completion.
- `.workbuddy/memory/MEMORY.md`, `.workbuddy/memory/2026-11-10.md`.

## 8. Verification (all green, 2026-11-10)

| Check | Result |
|---|---|
| root `gleam build --warnings-as-errors` | 0 errors / 0 warnings |
| root `gleam test` | **64 passed** |
| root `gleam format --check src test` | 0 |
| `sh scripts/guards.sh --all` | 0 (7 fixture cases) |
| root `gleam docs build` | 0 |
| `webclient/` format + docs | 0 / 0 |
| probe build WAE / test / format / docs | 0/0 / **4 passed** / 0 / 0 |
| `package-interface.json` | probe module carries `04-09-PLAN.md`; `glibe/monitor` doc complete with R31 + `04-08-PLAN.md` |
| core mirror `cmp` | 0 |
| reverse refs to the temporary pending-decisions doc | 0 |

## 9. Not done

No live market feed, no replay CLI, no `DataGenerator` retirement, no new
production type, no new dependency, no `tzif`. **Concurrency itself is no
longer on the "not done" list.** Working tree committed in logical steps;
**not pushed**. R31 is not a pending owner decision.

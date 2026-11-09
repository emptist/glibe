# Design — glibe

glibe is the BEAM port of glib's two-chain self-nesting yin-yang fractal. This
document is glibe's own design — what it keeps from glib, what it changes, and
why. For the rulings that bind it see `RULINGS.md`; for the measurements
behind the remaining decisions see `REVIEW_ROUND5.md` (withdrawn items remain
in `QUESTIONS.md`).

## The one idea

glib's own docs say a module should hold one class, and say `timeframe.gleam` is
the exception because Gleam refuses the import cycle between the record and the
leaves/branches. glibe does not have that argument. The cycle was never real:
`leaf.gleam` and `branch.gleam` never imported the `Timeframe` record; only the
record imported them. So **split the state from the pipeline that threads it** —
`timeframe.gleam` keeps the record and `new`, `engine.gleam` keeps every step.
What cannot be argued about cannot drift.

And the part glib does not have: a **mechanism**. glib moved three predicates out
of `timeframe.gleam` because the user asked; nothing stops them coming back.
glibe has `scripts/no_timeframe_mixture.sh`, which fails the build if the mixture
returns. (R7: a principle without a mechanism is decoration.)

## The ownership chain (R22 / R23)

A name is not the thing named. `Symbol` is the spelling a broker uses to name
one instrument; it is the key in `Broker.instruments` and carries none of the
instrument's facts. `Interval` is the key in `Instrument.timeframes`; a
`Timeframe` never stores its own interval, its own symbol or a market tag.
The caller that selected a `Timeframe` from that dictionary already holds the
interval, which is why `engine.sourcebar_gate` receives it as an argument.

```
Desk(brokers: Dict(BrokerId, Broker))
  └─ Broker(instruments: Dict(Symbol, Instrument), accounts: …)
       └─ Instrument(timeframes: Dict(Interval, Timeframe))    ← ONE dictionary
            └─ Timeframe(settings: TimeframeSettings, …state…)
```

`TimeframeSettings` is **not an entity**: a 12-number parameter block whose
only home is `Timeframe.settings`. There used to be a second dictionary
`Dict(Interval, TimeframeSettings)` on `Instrument`, a config table keyed by
`"BTCUSDT_H1"`, two `list.find` accessors, and an extra `settings` argument on
`databar_processing`. That was a circle standing in for the missing type
relation; R23 deletes all of it. `AppConfig.desk` is now a typed `Desk` value.
Full reasoning and the owner's verbatim words: `docs/RULINGS.md` R22 / R23;
plan and measurements: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.

## The pipeline

The order is fixed and not a matter of taste:

```
sourcebar_gate  →  databar_processing
                    indicator     the five smas, the band, KDJ
                    leaves        both twins grow; the bar gets its cmas
                    branches      recognised off the leaf that just settled
                    strategy      the manual signal, written on the bar
                    accept        the bar joins the history
```

- **Branches after leaves** — a branch is recognised off the leaf that settles
  (辞旧迎新). `strategy` after `branches` — the branch's two bars *are* the manual
  enter and exit (UC-62).
- **`accept` is the only writer of history** — it prepends; the list is
  newest-first, so the head bar's `idx` is the count and no counter is kept
  (`engine.bars_accepted` asks the list, not the record).
- **The signal is written on the bar, not the record** — only a bar is broadcast,
  drawn and accepted; a signal left on the `Timeframe` is a signal nothing can
  reach.

## The ingest boundary

`api/sourcebar` is the one place a bar is made well-formed and made readable:

- `validate` rejects a bar whose own numbers disagree — rejects, never repairs (R8).
- `normalize_date` turns the provider's epoch-milliseconds into ISO-8601 (R9).
  This is the whole of the hourly-bar bug that lived through three review rounds: an
  hourly timeframe never closed a bar on Binance data because `"1705309200000"`
  matched no minute field.

## The bar carries measurements, and one derived word

`DataBar` has **33 fields** (measured 2026-11-07), every one written by a
module. Fifteen that nothing wrote were deleted — a `bias`, four crossovers and
counters, four `inner_*_cma` levels this engine does not compute, and six
boolean verdicts. A verdict belongs to whoever decides (R10): the manual one is
**derived** in `trading/strategy.gleam` and its **one word** is written on the
bar, because only a bar is broadcast, drawn and accepted. That word is a
`Signal`, not a `String` (R13) — three constructors, exhaustively checked.

## Deviations from glib, and why

| axis | glib | glibe | reason |
|---|---|---|---|
| module purity | argued, partly done | enforced by script | R7 |
| end bars | `Option` (ruling landed) | `Option` (same ruling) | R1 — both agree |
| unwritten bar fields | 0 | 0 (deleted 15) | R10 |
| **target** | `javascript` (dual-target only planned) | **`erlang`, pure** | *"BEAM is great"* — glibe is the future |
| **foreign source in `src/`** | 14 handwritten `.mjs` | **0 compiled** | *"No handwritten erlangs or even worse JS source files"* |
| **runtime** | one JS process | **BEAM** | `process.spawn` + a typed `Subject`; no shared memory, no lock (R31). A long-lived state owner may use an actor, but parallelism does not require one |
| **dashboard** | handwritten JS + FFI | Phoenix/Elixir + JS in `apps/` | **unowned AI choice** (`5e91f44`), debt — owner decision pending; `REVIEW_ROUND5.md` §10, `RULINGS.md` R14/R16. The *chart* is the owner's (UC-56/57/60); the framework is not |
| KDJ window | `w` | **`w`** | same; idib `kdjPeriod = 7` |
| σ window | includes bar in hand | **includes it** | same |
| lower-band floor | `1e-6·bb_m`, one floor, before interpolation | **same** | owner §1.13/§1.14 (R12) |
| signal | `SignalType` custom type | **`Signal` custom type** | R13 — *"Gleam is a typed language"* |

**The three former "lags" (KDJ window, σ, floor) are closed.** They were
stale claims in this document, not states of the code. The one real imported
mistake — seib's three graded lower-band clamps — is fixed to the owner's
ruled order (R12). See `REVIEW_ROUND5.md` §5–§6.

## The catalogue tables are NOT in the ownership chain (R26)

`AppConfig` still carries three `List(#(String, …))` catalogues —
`exchanges`, `assets`, `markets`. They are **not** levels of the `Desk` chain
and they are **not** related to `Instrument` by any type today:

| table | what one entry actually is | consumers in `src/` and `test/` |
|---|---|---|
| `assets` | `Asset(id, name, class)` — 9 standardised things (BTC, SPY, USD…). `class` is the category. | `get_asset`: **none** |
| `exchanges` | `Exchange(id, name, mic, base_url, ws_url, gateway_host, gateway_port)` — connection parameters. | `get_exchange`: **none** |
| `markets` | `Market(exchange: String, asset_class, rules)` — a rule set (hours, fees, limits, settlement). | `get_market`: one test, `test/interval_test.gleam:99` |

The owner's words: *"Assets are standardized by laws"*, *"Market is often
related to different exchanges"*, *"different market have different settings
so they should not be mixed together"* (UC-47), and, on IB, *"exchange放在
contract里面"* (`glib/docs/RULINGS.md` §1.17). So exchange is a routing/venue
fact on a contract, market is a rule set, and an asset is a legally
standardised thing — three different kinds of fact, not three layers of one
tree. Any sentence equating them, or writing `Instrument = Asset on Market`,
is AI prose and was deleted under R22.

**Only `Broker ▸ Instrument` is settled**, from the data-source argument:
*"又必须隶属于某个提供商，因为提供商提供的数据格式不同，推送方式不同，推送
申请不同，推送频率不同"* (`glib/docs/reference/domain-hierarchy-2026-10-22.md`
§1). R26 (2026-11-09): the remaining relations are hard to settle now, so
types are added **one at a time, when a consumer needs one**, and the
relations will become clear then. No advance identity-typing plan, no
speculative `Market` level on `Instrument`. This is not permission to keep
`String` in the domain model — R13 still applies the moment a type is called
for. Full text and verbatim quotes: `docs/RULINGS.md` R26.

## The BEAM web layer, measured (R24)

R24 put the framework choice on the AI, by running demos. Three minimal
Erlang-target Gleam projects in `probes/web-layer/` all serve the same settled
bar (`index: 42, close: 123.5`) and were started with real HTTP requests
against them. Full RED/GREEN record and runtime output:
`.planning/phases/04-domain-cleanup/04-04-SUMMARY.md`.

| demo | server half | src Gleam | Hex pkgs | hand-written JS | client asset |
|---|---|---|---|---|---|
| A | Mist + Wisp | **72** | 22 | **0 lines** | generated `webclient.mjs` (3 lines) |
| B | Mist + Wisp + Lustre server component | 124 | 23 | **0 lines** | `lustre-server-component.min.mjs`, 14,191 B (Hex-shipped) |
| C | Mist only, no framework | 82 | 14 | **0 lines** | same generated `webclient.mjs` |

All three: `gleam test` 1 passed, `--warnings-as-errors` 0, `gleam docs build`
0, npm deps 0, identical build steps (`deps download` → `build` → `run`, plus
one shared `webclient` build). `GET /` and `GET /bar` returned 200 with the bar
in all three. B's `GET /poll` returned a real Lustre `Mount` patch (`kind: 0`,
`vdom` containing `123.5`) — the server-component data path works, it is not a
mock. Node imports the generated `.mjs` (`exports: ["main"]`, exit 0), which is
the runtime check a green `gleam build` cannot supply.

**Recommendation: A — Mist + Wisp for thin data endpoints, the view in the
generated `webclient/` `.mjs`. Do not adopt Lustre server components as the
default.** The view this product needs is a JS chart (R17) and tabulated
fractal data; Lustre server components patch DOM, so driving a canvas chart
would need a further custom-element bridge, plus an OTP runtime to supervise
and a 14 KB client runtime, for a data path the chart does not use. A has the
least Gleam code because Wisp supplies the request edge; C has 8 fewer Hex
packages but more hand-written Gleam and no static/logging/crash-rescue
middleware. Every option has the same browser asset and zero hand-written JS —
**the framework choice changes only the server half**, not R17/R18.

At the time of the measurement this was a recommendation, **not an adoption**
(R24): nothing was added to the root `gleam.toml` and the root `src/` was
untouched. Demos are measurement apparatus: all three `gleam.toml` files are
erlang-target, `webclient/` remains the product's only JavaScript-target
package (R18).

**2026-11-09 adoption — phase 04-05.** The recommendation is now built. Root
`gleam.toml` has `mist` + `wisp` (Hex only), and `src/glibe/web/server.gleam`
serves the real `config.default_config().desk`: `GET /` is a server-rendered
table, `GET /desk` is the same `Desk ▸ Broker ▸ Instrument ▸ Interval` chain as
JSON, any other path is 404. A closed `Route` type, not a path `String`, names
the endpoints. Run with `gleam run -m glibe/web/server` (port 8610) — the root
library deliberately keeps no global `main` slot, so the replay CLI is
still free. Real HTTP requests returned 200 / 200 / 404 with the configured
`binance` / `futu` / `ib` brokers and `BTCUSDT` / `SPY` / `SPY_FUTU` names.
No Lustre server components, no hand-written JS, no new browser asset. See
`.planning/phases/04-domain-cleanup/04-05-PLAN.md` and its SUMMARY.

Two compiler corrections the demos produced: Mist 6.0.3 exports `mist.start`,
not the `mist.start_http` still shown in Wisp's own doc example; Lustre 5.7.1's
`html.title` takes a `String`, not a child list. A prose review would have
shipped both wrong.

## The ingest boundary is a provider boundary (R27–R29)

A bar happens at an absolute instant. The standard `SourceBar` holds
`gleam_time.Timestamp` (unix seconds + nanoseconds) and nothing about a
provider's spelling of time. `sourcebar.unix_timestamp` converts a wire label
at the edge: epoch milliseconds, RFC3339, or an unlabelled ISO label read as
UTC by that adapter. A bad label is a typed `SourceBarTimeError`, not a
default clock.

Provider shapes stay native (R28): `binance/kline.gleam` keeps all twelve REST
kline fields in `Kline` — including `closeTime`, `quoteAssetVolume`,
`numberOfTrades` and the taker-buy volumes IB never sends — and
`to_sourcebar(kline)` is Binance's own standardisation step. `decode_klines`
returns `List(Kline)`; `binance/binance.gleam` is the only place they cross
into the standard model. The names stay native too: `kline`, `bar`, `quote`
are each provider's own words; only the standard layer is `SourceBar`.

`interval.bucket_ends` is now integer arithmetic on unix seconds (1h
`% 3600`, 4h `% 14400`, 3m `% 180`). No `string.split`, no `clock_of`, no
`normalize_date`, no handwritten civil-date algorithm.

**Known boundary (R29).** US equity sessions follow `US/Eastern` with daylight
saving: 09:30 there is HKT 22:30 in winter and 21:30 in summer, so the same
market open has different unix times. This is a market calendar rule, not a
fixed offset. `ibOptions/tradingtime.py` uses `pytz.timezone('US/Eastern')`
and `astimezone`; the Gleam counterpart is `tzif` 2.0.0 (+ `zones` or
`tzif_loader`), to be introduced at the provider/market adapter when a US
equity consumer appears (R26). Today's UTC-aligned unix grid does **not**
model a 09:30 open; that debt is explicit, not hidden.

## The web view shows local time (R30)

One absolute instant, two different conversions. R29 is the **input** side:
an exchange's local session clock (US 09:30) becomes an instant inside the
provider/market adapter, and that instant is HKT 22:30 in winter but 21:30 in
summer. R30 is the **output** side: the same `Timestamp` becomes the analyst's
local wall clock in the web view. Both need an IANA time-zone rule and daylight
saving; neither may use a fixed numeric offset or a hand-written DST table.
They are not one conversion — a market-calendar rule must not be written into
a display function, and a viewer zone is not an exchange zone.

The standard model is untouched: `SourceBar.timestamp` stays unix time
(R27), `interval.bucket_ends` stays a UTC-aligned unix grid, and
`export/csv.gleam` keeps UTC RFC3339 because it is a machine comparison
artifact, not a human analysis screen. A display zone is an IANA name
(`Asia/Hong_Kong`, `America/New_York`). On the BEAM side R29 verified
`tzif` 2.0.0 (+ `zones` / `tzif_loader`); if the time-bearing view is built
in the generated `.mjs` / `webclient/`, the browser runtime's IANA support
is the other option. Which side renders, and where the viewer zone comes
from, are settled when a real consumer exists (R26).

The owner asked for documentation in the corresponding modules, not an
implementation. The specification lives in the `////` module docs of
`src/glibe/web/server.gleam` (main), `webclient/src/webclient.gleam`,
`src/glibe/export/csv.gleam` and `src/glibe/api/sourcebar.gleam`; each links
`.planning/phases/04-domain-cleanup/04-07-PLAN.md`, and `gleam docs build`
→ `package-interface.json` in both packages carries that link. No conversion
code, no `tzif` dependency, no new type and no test were added this round.

## One addressed bar, one timeframe (04-08)

The ownership chain could already HOLD many instruments, each with many
intervals: `Desk(brokers: Dict(BrokerId, Broker))` →
`Broker(instruments: Dict(Symbol, Instrument))` →
`Instrument(timeframes: Dict(Interval, Timeframe))`, and
`config.default_config()` builds 3 brokers × 3 instruments × 2 intervals = six
independent states. What was missing was the ARRIVAL of a bar. `SourceBar`
deliberately carries no identity (R27 / R28); `binance.fetch_klines` returns
`List(SourceBar)` and leaves its request's `symbol` / `interval` behind; and
`engine.sourcebar_gate` was handed a `Timeframe` plus an `Interval` by the
caller. A BTCUSDT bar could be fed into SPY's hourly engine with no function
objecting at all.

`src/glibe/monitor.gleam` closes that gap with three types and one pure step.
`TimeframeAddress(BrokerId, Symbol, Interval)` puts the interval IN the
address, never in a `Timeframe` field (R23); `IncomingBar(address, bar)` pairs
the request identity with the standard bar once, at the ingest boundary; and
`MonitorError` carries the address plus a typed lower-level reason. `advance`
walks the three dictionaries, runs the gate, runs `databar_processing` when a
bucket closes, and puts the resulting `Timeframe` back into a NEW `Desk`. On
failure nothing is written — the caller's `Desk` is untouched because the
function is pure.

One `IncomingBar` advances ONE `Timeframe`. A kline stream is requested per
interval, so N instruments × M intervals means N×M addressed steps, not one
bar fanned out over every interval. The broker belongs in the address because
the same `Symbol` under two brokers names two different instruments.
`sourcebar.validate` and `sourcebar_gate` now return `SourceBarRejection`
instead of `String`, so the routing layer can say which address refused which
bar and why (R13).

This is a type-structure change, not a runtime one: `advance` starts no
process, opens no socket and holds no clock. `gleam_otp` is already a direct
dependency of the root package, but this module does not use it. Running many
addressed steps at once is measured in `probes/parallel-bars/` (R31) and needs
no further type work; the remaining runtime work is a live feed and the replay
CLI (section below). No `Market` / `Asset` / `Exchange` relation was invented
(R26), and neither `SourceBar` nor `Timeframe` gained a field. Six tests in `test/monitor_test.gleam` pin the isolation: the addressed
timeframe advances while the same instrument's other interval and two other
brokers' instruments stay identical; two instruments keep their own closes; a
non-boundary bar only opens a bucket; the same bar closes an hourly but not a
four-hour bucket; and both failure paths carry the address.

## Parallel addressed steps are already natural (04-09 / R31)

Owner 2026-11-09: *"gleam语言呀，是天然多线程 … 怎么实现并行任务的，非常简单啊
非常自然。因为他是一个一个严格的value，完全不住在内存里，所以根本没有那些
复杂的补救措施需要做"*. The earlier framing — "Stage F's supervised actors,
subscriptions and streams" — described concurrency as a whole mechanism still
to be built. It is not.

Official sources: `gleam.run` needs only `process.new_subject` /
`process.spawn` / `process.receive`; the v0.12 release says "there's no need
for an `async/await` syntax or callbacks", "doesn't require any special types
such as futures or promises", and "Erlang and Gleam don't have mutable state
so locks and shared mutable state is not an option". `gleam_otp`'s actor module
describes itself as "a process like any other BEAM process" — a thin wrapper
for state that survives across messages plus OTP system messages. Supervisors
are fault tolerance, not parallelism. Wisp has zero `process.` calls; glisten
spawns one process per connection; Lustre's server runtime is exactly one
actor. **An actor is not banned; it is simply not a prerequisite.**

`probes/parallel-bars/` (Erlang target, R19 RED→GREEN) measures it: six
`IncomingBar` values at six configured `TimeframeAddress` values, one
`process.spawn` each, one typed `Subject` for the replies. Measured run:
**six distinct BEAM Pids**, replies arriving in reverse spawn order,
**0 actor / 0 supervisor / 0 lock / 0 FFI**, 4 tests green. No production
logic changed: only `monitor.gleam`'s `////` module doc was synced to R31,
and no dependency was added.

The honest ownership result is the one thing worth writing down. Each parallel
worker returns a whole new `Desk` that advanced ONE address and still holds the
original state at the other five. **0 of 6 partial `Desk` values equal the
single-owner fold.** Immutable values do not merge themselves: either one owner
applies the steps in arrival order, or each address owns its own `Timeframe`
and there is no global `Desk` to merge. That is a **data-flow / ownership**
choice (R26: decide when a consumer needs it), not a synchronisation problem —
no lock, no retry, no supervisor is involved. Values do live in memory, in
each process's own heap; what does not exist is **shared mutable memory**.

Scope: **Erlang / BEAM only** (owner 2026-11-09 06:09). See `docs/RULINGS.md`
R31 and `.planning/phases/04-domain-cleanup/04-09-SUMMARY.md`.

## What glibe does not do yet

- **The live runtime** — a replay CLI over real klines, the feed that produces
  `IncomingBar` values, `DataGenerator` retirement, the minute-trading guard
  (`REVIEW_ROUND5.md` §1). **Concurrency is not on this list** (R31): six
  addressed bars already ran in six BEAM processes with `process.spawn` and a
  typed `Subject` in `probes/parallel-bars/`. Whether a long-lived state owner
  uses `gleam_otp`'s actor is a per-consumer choice (R26), not a prerequisite.
- **The catalogue tables' identities and relations** — deliberately open
  under R26, not a pending owner ruling. They get types when a consumer
  appears. The web-layer comparison (R24) and adoption (phase 04-05) are both
  **done**; the thin endpoints exist, but the chart, streaming and SPA
  interaction do not. The `Interval` closed set is already 9 values (R21).
  Plans first
  (*"计划和文档先行"*, 2026-10-28).
- **The AI strategy** — deliberately absent. glib's AI layer was deleted by
  the owner; there is nothing to port. **glibe does not wait for a feature the
  reference project removed** (`REVIEW_ROUND5.md` §1).

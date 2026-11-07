# Questions — glibe

Open items, dated. A question here is one the **code** does not yet answer,
with the ruling or measurement it is waiting on. A question the tree already
answers is **withdrawn**, not asked, and is not re-listed as open.

## Withdrawn 2026-11-07 (Round 5)

Five of the seven questions were stale; two were simply wrong about the
owner's ruling. Keeping them open was the "endless waiting" the owner named.

| was | why it is withdrawn |
|---|---|
| Q1 KDJ window `w` or `w+1` | The code already uses **`w`, including the bar in hand** (`kdj.gleam:19-22, 89-99, `batch_window` takes `w-1` settled bars). `w+1` was fixed in `b0f5f33`. The sourced value is idib's `kdjPeriod = 7`. |
| Q2 σ over what window | The code **includes the bar in hand** (`bollinger.gleam:72`) and its doc says why. It matches glib. |
| Q3 floor under the lower bands | **The question misquoted the ruling.** The owner did not say "no floor": §1.13/§1.14 (2026-10-14, settled 2026-11-02) say **one tiny positive `1e-6·bb_m` floor on the outer edge, before interpolation**. Landed in `bollinger.gleam` with an invariant test. Round 4's `0.0` clamp was wrong and is gone. |
| Q4 one alpha for K and D | Landed: single alpha `1/kdj_k_period`, `kdj_d_period` deleted (Round 4). |
| Q5 `window_kdj_size → kdj_window_size` | Renamed this round across settings, config, kdj and test. |
| Q7 the AI strategy, *"ported when glib settles"* | **False premise.** The owner ordered glib's AI layer deleted (`a99e615`); `ai_s1`, `learn`, `boost`, `knn` grep to 0 in glib's `src/`. There is nothing to port and nothing to wait for. |

## Open

### Q6 — the BEAM part, now the work (Stage F, **not** blocked on glib)

glib is one JS process with one engine; glibe is on the BEAM. This is the one
axis where glib is **not** the reference, so there is nothing to wait for.
Still unstarted:

- one `Timeframe` actor per `(symbol, interval)`, supervised (`gleam_otp`);
- a replay CLI over stored klines, so a claim about the engine is checkable;
- retire `apps/glibe_web/lib/glibe_web/data_generator.ex` (a second engine in
  another language — UC-56 says one engine);
- `no_minute_trading.sh`, the ruling as a guard.

### Q8 — `apps/glibe_web` (owner's decision, still open)

A tracked Phoenix/Elixir + JS app (23 files, `chart_live.ex`,
`data_generator.ex`, `assets/js/chart_hook.js`). It is the largest remaining
violation of *"No handwritten erlangs or even worse JS source files"*.
`scripts/no_foreign_source.sh` guards `src/` only.

**Found 2026-11-07 (`REVIEW_ROUND5.md` §10):** the *framework* was an AI's
choice (`5e91f44`, 2026-09-24) — no ruling of his names Phoenix. The *chart*
is his (UC-56/57/60). So the two options are now concrete:

- **Port:** retire `apps/`, keep the ruled chart behaviour (one stream, one
  bar at a time, event from `working_databar_archived`), rebuild the view in
  Gleam on **Mist** (HTTP/WS/SSE) + **Wisp** (request edge) + **Lustre**
  (typed UI, OTP-supervised server components) with a `shared/` Gleam types
  package. References in `DEVELOPER_GUIDE.md`, none adopted.
- **Retire:** no web layer at all.

Neither is decided. Lustre and Wisp are **not** owner rulings; he has not read
or used Wisp yet. Not silently forgiven.

**Cost measured 2026-11-07 (`REVIEW_ROUND5.md` §13):** keeping the vendored
TradingView lib needs **65–85 lines of hand-written `.mjs`** (two measured
bridge shapes), the Lustre SVG route needs **0**. But glib `RULINGS.md` §1.28
says hand-written `.mjs` on the Erlang target **is the error signal** —
*"如果手写就说明你错了"*. So the JS-lib route needs an explicit exception from
him, not just a line budget. The guard `no_foreign_source.sh` covers `src/`
only and is narrower than that ruling.

### Q9 — typed identity keys (design)

`config.gleam` keys timeframes as `List(#(String, TimeframeSettings))` with
strings like `"BTCUSDT_H1"`. The owner's phase-55 principle says identity is a
**typed Dict key**, not a field or a composite string. Adopting `Symbol` +
`Interval` as the key is an architectural change — plan first
(*"计划和文档先行，任何时候都没有例外"* [user 2026-10-28]).

### Q10 — the `Interval` closed set is 7, the owner's is 9

`api/interval.gleam:19-34` has `MIN1 MIN15 MIN30 H1 D1 W1 MO1`; glib's settled
closed set is `MIN1 MIN3 MIN15 MIN30 H1 H4 D1 W1 MO1`. Adding `MIN3`/`H4`
needs codec rows and bucket-end rules. Type-level, so it must be a type change,
not a string branch.

### Q11 — is an SVG-DSL chart as powerful as the JS chart? (deferred measurement)

His question [user 2026-11-07]: *"Does this means it will be as powerful as the
JS chart? Needs a try with actual data later, when other parts(other parts of
whole databar processing) is done."*

**Not a decision, and not attempted now.** `REVIEW_ROUND5.md` §12 corrects the
overclaim in §10.3/§11.2: *"no JS charting library"* meant no vendored or
hand-written JS, **not** feature parity. The trial is gated on the rest of
databar processing being done: the full `sourcebar_gate → databar_processing →
… → accept` path, a replay CLI over real klines producing a real
`databar_list` (Q6), and the UC-57 event path to a view.

What the trial must **measure, not assume**: the 15 series' values against
`export/csv.gleam`; DOM node count and patch latency per settled bar at the
real bar count; crosshair/tooltip responsiveness on the pure Erlang target;
and whether a bounded window is needed at all. Q8 (adopt Lustre/Wisp, or
retire the web layer) remains his call — this question does not answer it.

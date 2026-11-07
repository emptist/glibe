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
  This is the whole of the H1 bug that lived through three review rounds: an
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
| **runtime** | one JS process | **BEAM** | one actor per instrument, supervised — Stage F, unstarted |
| **dashboard** | handwritten JS + FFI | Phoenix/Elixir + JS in `apps/` | **unowned AI choice** (`5e91f44`), debt — owner decision pending; `REVIEW_ROUND5.md` §10, `RULINGS.md` R14/R16. The *chart* is the owner's (UC-56/57/60); the framework is not |
| KDJ window | `w` | **`w`** | same; idib `kdjPeriod = 7` |
| σ window | includes bar in hand | **includes it** | same |
| lower-band floor | `1e-6·bb_m`, one floor, before interpolation | **same** | owner §1.13/§1.14 (R12) |
| signal | `SignalType` custom type | **`Signal` custom type** | R13 — *"Gleam is a typed language"* |

**The three former "lags" (KDJ window, σ, floor) are closed.** They were
stale claims in this document, not states of the code. The one real imported
mistake — seib's three graded lower-band clamps — is fixed to the owner's
ruled order (R12). See `REVIEW_ROUND5.md` §5–§6.

## What glibe does not do yet

- **Stage F** — BEAM actors, the replay CLI, `DataGenerator` retirement, the
  minute-trading guard (Stage F, `REVIEW_ROUND5.md` §1). This is the work,
  and it waits on nothing.
- **Three open design points** — the web-layer decision, typed identity
  keys in `config.gleam`, and the `Interval` closed set 7 → 9. Plans first
  (*"计划和文档先行"*, 2026-10-28).
- **The AI strategy** — deliberately absent. glib's AI layer was deleted by
  the owner; there is nothing to port. **glibe does not wait for a feature the
  reference project removed** (`REVIEW_ROUND5.md` §1).

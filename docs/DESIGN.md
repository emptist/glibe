# Design — glibe

glibe is the BEAM port of glib's two-chain self-nesting yin-yang fractal. This
document is glibe's own design — what it keeps from glib, what it changes, and
why. For the rulings that bind it see `RULINGS.md`; for open questions see
`QUESTIONS.md`.

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

## The bar carries measurements, and nothing else

`DataBar` has 26 fields, every one written by a module. Fifteen that nothing
wrote were deleted — a `bias`, four crossovers and counters, four `inner_*_cma`
levels this engine does not compute, and six boolean verdicts. A verdict belongs
to whoever decides (R10); the manual one lives in `trading/strategy.gleam`.

## Deviations from glib, and why

| axis | glib | glibe | reason |
|---|---|---|---|
| module purity | argued, partly done | enforced by script | R7 |
| end bars | `Option` (ruling landed) | `Option` (same ruling) | R1 — both agree |
| unwritten bar fields | 0 | 0 (deleted 15) | R10 |
| **runtime** | one JS process | **BEAM** | one actor per instrument, supervised — glibe passes glib (Stage F) |
| **broker reach** | paper only | IBKR + Binance modules | real connectivity |
| **dashboard** | hand-written JS + FFI | Phoenix / LiveView | the live view |
| KDJ window | `w` | `w + 1` | diverges — pending Stage D5 |
| σ window | includes bar in hand | excludes it | diverges — pending Stage D6 |
| lower-band floor | none (ruling) | `0.001` clamp | contradicts ruling — pending Stage D7 |

The last three are acknowledged lags, not choices. They are Stage D, next.

## What glibe does not do yet

- The AI strategy (Q7) — ported when glib settles.
- Stage F — the BEAM concurrency, the replay CLI, the `DataGenerator` removal, the
  minute-trading guard.
- Stage D — the four numeric corrections above.

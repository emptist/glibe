# MEMORY — glibe (curated, compact)

## Authority
**Owner's current statement > Idris spec > legacy code > my inference.**
`glib/docs/` is mostly **hy4's AI prose**, not the owner's record. Owner words
appear as dated `[user …]`, `{<UC: …>}` and Chinese verbatim quotes in
`glib/docs/RULINGS.md`. Ban hy4 vocabulary: generic "gate", "price gate",
"risk gate", "ladder"/"Rung". Owner words: `sourcebar_gate` (the only gate),
**price checker**, **risk manager**. hy4 is a different model, banned from glib;
never inherit its first person or rename owner quotes.

## Direction
- *"glibe is the future, pure erlang target is the future"*; *"BEAM is great"*;
  *"No handwritten erlangs or even worse JS source files"* → `src/` Gleam only.
  **Use a type whenever a type is needed in nature** (root law); no universal
  `String` + parser + guard to repair it.
- **glibe does not wait on glib**: take the owner's rulings + glib's good code
  directly; never cite an unbuilt glib roadmap as a dependency.
- Root stays erlang. `webclient/` is the only JS-target package (R18);
  generated `.mjs` preferred (R17), small hand-written JS allowed only there.
- Web frontend exists for human eyes: spot output anomalies, read trends from
  charts, inspect tabular fractal structures, see order issue/fill points.

## Load before any Gleam judgement
`docs/gleam-thinking-core-to-memory.md` **IN FULL** (one card, git mirror of
`~/.workbuddy/skills/gleam-language/references/gleam-core.md`; keep `cmp`-equal).
Workflow (R19): `////` module doc **naming the `.planning` item** → types →
`///` on every type/function → `todo as "…"` bodies → tests → bodies → green.
`gleam docs build` → `package-interface.json` makes the plan link
machine-readable; that is the anti-drift check, **no new sh guard**.
`--warnings-as-errors` is a GREEN gate only; RED skeletons legitimately fail it.
Every AI-authored file in every project follows this docs-first order.

## Rulings — full text in `docs/RULINGS.md`
R12 one `1e-6·bb_m` lower-band floor before interpolation. R13 closed sets are
types. R14 `src/` Gleam only. R15 IB = historic stocks/ETFs only; guard fails
on `@external(javascript,…)` and `target = "javascript"`. R16 small-scope
hand-written JS already permitted. R17 JS chart lib adopted. R18 Phoenix app →
`deprecated/`, separate `webclient/` package. R19 docs-first/TDD is in-code.
R20 `Desk ▸ Broker ▸ Instrument ▸ Timeframe` ownership is **must-have**; name
is **`Desk`** (owner's 2026-11-03 "Deck" quote is a recorded spelling drift,
not a renaming instruction); dashboard = VIEW in `webclient/`.
R21 **constructors are named in full, prefixed by the type name**
(`IntervalOneDay`, `IntervalFourHour`). Short letter+digit wire codes as type
constructors are banned; wire spellings (`"1h"`) stay in codec/adapter only.
Historical review/session docs keep old codes as records; R21 says so.

## Measured facts (not inference)
- Gleam 1.19.2: `import mod.{type T, Ctor}`; **no `T(..)` form**. A function may
  have an `@external` **and** a Gleam body (fallback). v1.19.0 emits
  `.abstr → .beam`, no per-module `.erl`; only the `@@main.erl` runner stub.
- `gleam build` does **not** resolve npm deps: a green build is not a runnable
  app (`ERR_MODULE_NOT_FOUND`). LightweightCharts v5 exports `createChart`,
  `LineSeries`…; `addSeries`/`updateSeries` are **instance methods**; dotted
  `@external` names fail to compile. Add a runtime import check.
- `lpil` = Louis Pilfold (Gleam + Wisp); Mist = `rawhat`; Lustre = Hayleigh
  Thompson. Popcorn/WASM is research only, **not adopted**. psipi unverified.
- Test assertions: bool `assert … as "msg"`, `let assert`; never `panic` or
  `case Bool`. Negative guard tests use `/tmp` fixtures
  (`scripts/test_guards.sh`), **never** plant broken code in real `src/`.
- *"Needs no JS library"* is a **dependency** claim, not a capability claim.
  Series/option definitions and per-bar mapping are inherent work, **not** an
  "extra cost" of a chart lib. Real-data chart trial deferred until databar
  processing is complete.

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions live **only** in `docs/PENDING_DECISIONS.md`,
  self-contained, **one-way**: it may copy from other docs, but **no other
  document may reference it**. `docs/QUESTIONS.md` = withdrawn items only.
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`. BSD `grep` is
  unreliable — use the Grep tool or Python. Capture exit codes with
  `> log 2>&1; echo "EXIT=$?"`, never `cmd | tail`.
- Green = `gleam build` (0 errors/0 warnings) + `gleam test` + `gleam format
  --check src test` + `sh scripts/guards.sh --all`. **Build/test before
  committing**; one logical concern per commit; **do not push unless asked**;
  never `rm -rf build`.

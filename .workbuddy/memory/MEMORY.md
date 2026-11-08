# MEMORY — glibe (curated, compact)

## Authority
**Owner's current statement > Idris spec > legacy code > my inference.**
`glib/docs/` is mostly hy4's AI prose, not the owner's record; owner words appear
as dated `[user …]`, `{<UC: …>}` and verbatim Chinese quotes in
`glib/docs/RULINGS.md`. hy4 is a different model banned from glib; never inherit
its first person, its vocabulary (generic "gate", "price gate", "risk gate",
"ladder"/"Rung") or rewrite owner quotes. Owner words: `sourcebar_gate` (the only
gate), **price checker**, **risk manager**.

## Direction
- *"glibe is the future, pure erlang target is the future"*; *"BEAM is great"*;
  *"No handwritten erlangs or even worse JS source files"* → `src/` Gleam only.
  **Use a type whenever a type is needed in nature** (root law): no universal
  `String` + parser + sh/grep guard to repair it.
- **glibe does not wait on glib**: take owner rulings + glib's good code directly;
  never cite an unbuilt glib roadmap as a dependency.
- Root stays erlang. `webclient/` is the only JS-target package (R18); generated
  `.mjs` preferred (R17); small hand-written JS allowed only there (R16).
- Web frontend exists for human eyes: spot output anomalies, read trend charts,
  inspect tabular fractal structures, see order issue/fill points.

## Load before any Gleam judgement
`docs/gleam-thinking-core-to-memory.md` **IN FULL** (git mirror of
`~/.workbuddy/skills/gleam-language/references/gleam-core.md`; keep `cmp`-equal).
Workflow (R19): `////` module doc **naming the `.planning` item** → types →
`///` on every type/function → `todo as "…"` bodies → tests → bodies → green.
`gleam docs build` → `package-interface.json` makes the plan link machine-
readable; that is the anti-drift check, **no new sh guard**.
`--warnings-as-errors` is a GREEN gate only; RED skeletons legitimately fail it.
Every AI-authored file in every project follows this docs-first order.

## Rulings — full text in `docs/RULINGS.md`
R12 one `1e-6·bb_m` lower-band floor before interpolation. R13 closed sets are
types. R14 `src/` Gleam only. R15 IB = historic stocks/ETFs only; guard fails on
`@external(javascript,…)` and `target = "javascript"`. R16 small-scope hand-
written JS already permitted. R17 JS chart lib adopted. R18 Phoenix app →
`deprecated/`, separate `webclient/`. R19 docs-first/TDD in code. R20
`Desk ▸ Broker ▸ Instrument ▸ Timeframe` is **must-have**; name **`Desk`**
(owner's 2026-11-03 "Deck" quote = recorded spelling drift, not a renaming
order); dashboard = VIEW in `webclient/`. R21 **constructors named in full,
prefixed by the type name** (`IntervalOneDay`); letter+digit wire codes as type
constructors banned, wire spellings (`"1h"`) only in codec/adapter. Historical
review/session docs keep old codes as records.
R22 **`Symbol` is a name, never the `Instrument`**: a title cannot be the
entity; wrong things are corrected cleanly — no alias, no compat layer, no
workaround that makes the next correction harder. R23 **`TimeframeSettings` is not an entity**: it is the parameter
block of one `Timeframe` (`Timeframe.settings`); no second dict, no composite
`"BTCUSDT_H1"` key, no `list.find`; `Timeframe` never carries `symbol` /
`interval` / `market_type` — interval is in the key. R24 web-layer framework
choice is **the AI's demo comparison work, not an owner ruling**; adopted as
Mist+Wisp in 04-05. R25 a
recognised professional term (CPU, T+1/T+2) is **not** an abbreviation; keep
`TPlus1`/`TPlus2`. Wire codes like `H4`/`M1` are still banned.
R26 **only `Broker ▸ Instrument` is settled** (data-source argument); relations
among `Asset` / `Exchange` / `Market` and to `Instrument` are deliberately
open — add types **one at a time when a consumer needs one**, no advance
identity-typing plan, no speculative `Market` level. `assets`/`exchanges`
have 0 consumers; `Instrument = Asset on Market` is AI prose, do not revive.

## Measured facts
- Gleam 1.19.2: `import mod.{type T, Ctor}`; **no `T(..)` form**. A function may
  have an `@external` **and** a Gleam body (fallback). v1.19.0 emits
  `.abstr → .beam`, no per-module `.erl`; only the `@@main.erl` runner stub.
- `gleam build` does **not** resolve npm deps: green build ≠ runnable app
  (`ERR_MODULE_NOT_FOUND`). LightweightCharts v5 exports `createChart`,
  `LineSeries`…; `addSeries`/`updateSeries` are **instance methods**; dotted
  `@external` names fail to compile. Add a runtime import check.
- `lpil` = Louis Pilfold (Gleam + Wisp); Mist = `rawhat`; Lustre = Hayleigh
  Thompson. Popcorn/WASM research only, **not adopted**. psipi unverified.
- Tests: bool `assert … as "msg"`, `let assert`; never `panic` or `case Bool`.
  Negative guard tests use `/tmp` fixtures (`scripts/test_guards.sh`), **never**
  plant broken code in real `src/`.
- Web demos (04-04, R24): Mist+Wisp 72 lines/22 Hex vs +Lustre server
  component 124/23 vs bare Mist 82/14; all 0 hand-written JS, 0 npm, same
  generated `webclient.mjs`. **A adopted (04-05)**: root `gleam.toml` has
  `mist`+`wisp`; `src/glibe/web/server.gleam` serves the real `Desk` at `/`
  (HTML table) and `/desk` (JSON), `gleam run -m glibe/web/server` on 8610;
  54 tests green. Mist 6.0.3 = `mist.start` (Wisp doc example's
  `start_http` is stale); Lustre 5.7.1 `html.title(attrs, String)`.
  `wisp/simulate.request(method, path)` builds a real Wisp Request for
  handler tests; `wisp.Text(body)` is the response body constructor.
  `gleam run -m <module>` runs a module's `main` without a root `main` slot.
- *"Needs no JS library"* is a **dependency** claim, not a capability claim.
  Series/option definitions and per-bar mapping are inherent work, **not** extra
  cost. Real-data chart trial deferred until databar processing is complete.

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions live **only** in `docs/PENDING_DECISIONS.md`: self-contained,
  **decisions FIRST at the very top**, everything else under a clearly labelled
  `# REFERENCE` block the owner does not read (owner 2026-11-08: too long and
  messy, decided items mixed in). Never repeat decided items in the decision
  section. One-way: it may copy from other docs, but **no other document may
  reference it** — verify repo-wide after any edit. `docs/QUESTIONS.md` =
  withdrawn items only.
- **Owner 2026-11-09: "注意：.gitignore 及时更新，及时做提交".** Update ignore
  rules BEFORE generating artifacts, and commit each logical step as it lands,
  never in one batch at the end. `.gitignore` now uses a single `build/` rule
  (any package, any depth) so a new probe needs no remembered edit.
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`. BSD `grep` unreliable —
  use the Grep tool or Python. Capture exit codes with `> log 2>&1; echo
  "EXIT=$?"`, never `cmd | tail`.
- Green = `gleam build` (0 errors/0 warnings) + `gleam test` + `gleam format
  --check src test` + `sh scripts/guards.sh --all`. **Build/test before
  committing**; one logical concern per commit; **do not push unless asked**;
  never `rm -rf build`.

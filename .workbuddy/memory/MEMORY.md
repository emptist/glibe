# MEMORY — glibe project conventions (curated)

## Authority (do not invert)
**The owner's current statement > the Idris spec > legacy code > my inference.**
glib's `docs/` are mostly **hy4's AI prose**, not the owner's record. Owner
words appear as dated `[user …]` quotes, `{<UC: …>}` annotations and Chinese
verbatim quotes in `glib/docs/RULINGS.md`. hy4-invented vocabulary is banned:
generic "gate", "price gate", "risk gate", "ladder"/"Rung". Owner words:
`sourcebar_gate` (the only gate), **price checker**, **risk manager**.

## Direction (owner, 2026-11-07)
- *"glibe is the future, pure erlang target is the future."*
- *"BEAM is great. Let's build our success on it!"*
- *"No handwritten erlangs or even worse JS source files, keep the system clean
  and beautiful!"* → `scripts/no_foreign_source.sh` guards `src/`.
- *"Use types everytime a type is needed in nature, let gleam make your thinking
  correct and coding reliable!"* → closed sets are custom types, not `String`.
- **glibe stops waiting on glib.** Many features required in glib never landed
  in its `src/`; the AI layer was deleted by the owner. glibe takes the owner's
  rulings + glib's good code directly. Never cite an unbuilt glib roadmap as a
  dependency.

## Language facts (Gleam 1.19.2, verified)
- Import: `import mod.{type T}` / `import mod.{type T, CtorA, CtorB}`.
  **There is no `T(..)` constructor-import form** — it was never Gleam syntax,
  not a version change. Qualifying constructors (`mod.CtorA`) is also valid.
- A function may have BOTH `@external(erlang/js, …)` and a Gleam body; the
  Gleam body is the fallback for targets without an external. This is why no
  handwritten `.erl` is ever needed for a dual-target port.
- **v1.19.0 (2026-10-05) stopped generating Erlang source for modules.**
  Official: <https://gleam.run/news/gleam-doesnt-compile-to-erlang-source-anymore/>
  — *"Previously Gleam generated Erlang source code, now it generates Erlang
  abstract forms."* Path is `.gleam → .abstr → Erlang compiler back half →
  .beam`, NOT "straight to .beam" (that earlier claim here was wrong).
  Fresh-project probe on 1.19.2: 25 `.abstr`, 30 `.beam`, **0 `.erl` per
  module**, exactly one `@@main.erl` (`gleam run` runner stub) — delete and
  rebuild regenerates it, so it is **current, not a stale artefact**. Other
  `.erl` under `build/` = Hex-package-shipped sources (epoch 1970, for
  rebar3/mix), package FFI, or stale `build/dev/javascript/` cache.
- `lpil` = **Louis Pilfold, creator of Gleam**, and Wisp's author. Mist =
  `rawhat`, Lustre = Hayleigh Thompson. Wisp v2.2.2, BEAM/Erlang target.
- References: <https://tour.gleam.run/everything/> (authoritative),
  <https://www.kodikra.com/2026/03/the-complete-gleam-guide-from-zero-to.html>
  (learning roadmap; its `.gleam → .erl → erlc` diagram is the pre-1.19.0
  pipeline), <https://gleam-wisp.github.io/wisp/> (Wisp, evaluation only).

## Rulings with mechanisms
- **R12** lower-band floor = ONE `1e-6·bb_m` positive floor on the outer edge
  **before** interpolation (owner 2026-10-14, settled 2026-11-02). Three graded
  floors or a `0.0` clamp are wrong. The withdrawn *floor under the lower
  bands* item in `docs/QUESTIONS.md` used to misquote this as
  "no floor" — do not repeat that error.
- **R13** closed sets are types (`trading/signal.gleam`). One set, one home.
- **R14** `src/` is Gleam only; guard + CI. `apps/glibe_web` (Phoenix/Elixir +
  JS) is outside the guard and is an open owner decision; see
  `REVIEW_ROUND5.md` §10 and `RULINGS.md` R14/R16.
- **R15** IB = historic data for stocks/ETFs only; if it forces JS-target
  dependence, drop IB. Guard also fails on `@external(javascript, …)` and
  `target = "javascript"` in `gleam.toml`.
- **glib §1.28 (owner, 2026-11-01)** *"目的就是不让你手写 mjs …
  如果手写就说明你错了"*: hand-written `.mjs`/FFI on the Erlang target is the
  **error signal**, not a line cost to budget. Package-shipped FFI is not ours.
- **R16 (owner, 2026-11-07)** *"如果仅限于页面设置和更新数据的这一个小范围，
  手写js的风险是严格掌控的，可以接受"*: **scoped exception already given** —
  page/chart setup + one settled-bar update only. Not SSE, tabs, symbol switch,
  business logic, second engine. §1.28 still holds outside it; R15 guard
  unchanged. Withdraws "needs another explicit exception / SVG is the only
  compliant shape" from `REVIEW_ROUND5.md` §13.4.

## Documentation conventions (owner, 2026-11-07)
- **No bare `Qn` labels.** They read like "Question N" but also meant numbered
  questions in a chat message; one label pointed at two things (§11.2 cited it
  for live-view/JS-target while the third item in QUESTIONS.md was the band
  floor). Cite **full file path + section title**, never a bare number.
- **Pending decisions live in ONE temporary document**
  (`docs/PENDING_DECISIONS.md`), self-contained with all decision context; owner
  reads only that file. It is **one-way**: it may copy from other docs, but
  **no other document may reference it** — it is cleared and replaced after
  each decision, so reverse links would dangle. `docs/QUESTIONS.md` is now only
  a stable withdrawn-items record.
- **Generated `.mjs` is not hand-written JS** (owner's point, probed on 1.19.2):
  `@external(javascript, "lightweight-charts", "createChart")` → generated
  `probe.mjs` contains `import { createChart … } from "lightweight-charts"`,
  zero hand-written `.mjs` in `src/`. Three kinds: compiler output, package-
  shipped, and `./xxx.mjs` FFI (only the last is ours). Needs a separate
  `client/` package with `target = "javascript"`; glib's vendored file is an
  IIFE, not ESM. `@external` binds functions/types, **not constants** in 1.19.2
  (`pub const` probe failed with `expected "="`). See `REVIEW_ROUND5.md` §13.8.

## Claim discipline (owner, 2026-11-07)
- *"Needs no JS library"* is a **dependency** claim, never a **capability**
  claim. `REVIEW_ROUND5.md` §12 corrects the Lustre/SVG overclaim.
- A UI/chart comparison must be tried on **real data** before being called
  equivalent — and only after the rest of databar processing is done (the
  deferred real-data trial, `REVIEW_ROUND5.md` §12). Do not attempt it early;
  the web-layer decision stays the owner's call.

## Toolchain / workflow
- `gleam`, `erl`, `elixir` live in `/opt/homebrew/bin`; WorkBuddy's shell lacks
  it — always `export PATH="/opt/homebrew/bin:$PATH"`.
- macOS BSD `grep` breaks on `\|` alternation and `\b`; use the Grep tool or
  Python. Never trust `cmd | tail` to preserve exit codes — capture with
  `> log 2>&1; echo "EXIT=$?"`.
- Green = `gleam build` (0 errors/0 warnings) + `gleam test` + `gleam format
  --check src test` + `sh scripts/guards.sh --all`. **Build/test before
  committing**; one logical concern per commit; do not push unless asked.
- Never `rm -rf build` (owner denied a bulk delete).

## Git state note
The push attempted 2026-10-05 was interrupted and never landed;
`origin/fix-types` stayed at `4c2e280` while local advanced.

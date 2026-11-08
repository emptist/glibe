# Phase 04 Plan 04 — BEAM web-layer demos, measured (R24) — Summary

**Ruling discharged:** `docs/RULINGS.md` R24. The framework choice was mine to
make by writing demos; the owner was not asked to try frameworks. Plan:
`.planning/phases/04-domain-cleanup/04-04-PLAN.md`. Demos: `probes/web-layer/`.

## RED → GREEN (R19)

Skeletons (`////` naming this plan, types, `///`, `todo as "…"`) were written
first, then `test/*_test.gleam`, then RED was measured: all three demos
`0 passed, 1 failures`, `gleam test` exit 1, crash at the first `todo`
(`todo src/a_wisp.gleam:32 … info: 04-04 A: one settled bar`). Bodies filled
afterwards.

GREEN, with `touch src/*.gleam` to force a real recompile (not a cached pass):

| demo | `gleam format` | `gleam test` | `build --warnings-as-errors` | `gleam docs build` |
|---|---|---|---|---|
| A `a_wisp` | 0 | **1 passed** | 0 | 0 |
| B `b_lustre` | 0 | **1 passed** | 0 | 0 |
| C `c_static` | 0 | **1 passed** | 0 | 0 |

`package-interface.json` in all three carries `04-04-PLAN` and `R24` in the
module documentation (14 / 15 / 12 doc lines). No new sh guard was added.

Two compile-time corrections worth keeping: `wisp/wisp_mist.gleam`'s own doc
example calls `mist.start_http`, but Mist 6.0.3 exports only `mist.start`;
and Lustre 5.7.1's `html.title` takes `(attrs, content: String)`, not a child
list. Both were found by the compiler, not by reading prose. Importing
`gleam/erlang/process` also produced a `Transitive dependency imported`
warning, fixed by declaring `gleam_erlang` as a direct dependency in all three.

## Measured numbers

Non-blank source lines, dependencies, hand-written foreign source:

| demo | src Gleam | test Gleam | Hex packages | npm | hand-written JS | client asset |
|---|---|---|---|---|---|---|
| A Mist + Wisp | **72** | 15 | **22** | 0 | **0 lines** | generated `webclient.mjs`, 3 lines / 47 B |
| B + Lustre server component | **124** | 15 | **23** | 0 | **0 lines** | `lustre-server-component.min.mjs`, 14,191 B (Hex-shipped) |
| C bare Mist | **82** | 15 | **14** | 0 | **0 lines** | same generated `webclient.mjs` as A |

Build steps are identical: `gleam deps download` (first run) → `gleam build` →
`gleam run`, plus one shared `gleam build` in `webclient/`. No `npm install`
step exists for any demo.

Runtime checks, from real servers and real HTTP requests:

| demo | `GET /` | `GET /bar` | extra |
|---|---|---|---|
| A | 200, 170 B, contains `123.5` | 200, `{"index":42,"close":123.5}` | — |
| B | 200, 14,425 B, contains `123.5` and `<lustre-server-component` | 200, same JSON | `GET /poll` → 200, 267 B, **valid JSON `kind: 0` (Mount)** with a `vdom` carrying `123.5` |
| C | 200, 168 B, contains `123.5` | 200, same JSON | — |

Node import check: `import('file://…/webclient.mjs')` → `IMPORT_OK exports=
["main"]`, exit 0. This is the check R17's `.mjs` probe was missing: a green
`gleam build` alone does not prove the generated asset resolves at runtime.

## Conclusion (written into `docs/DESIGN.md`)

**Recommend A — Mist + Wisp for thin data endpoints, view in the generated
`webclient/` `.mjs`; do not adopt Lustre server components as the default.**

- The product's view work is a JS chart (R17) plus tabulated fractal data; a
  server component patches DOM, which does not drive a canvas chart without an
  extra custom-element bridge. B costs 52 extra Gleam lines, an OTP runtime to
  supervise and a 14 KB client runtime for a data path the chart does not use.
- A has the **least Gleam code (72 lines)** and Wisp supplies the request-edge
  work (static assets, logging, crash rescue, body limits) that C must hand-write.
- C has the fewest Hex packages (14) but more Gleam (82) and no middleware;
  the 8 extra packages in A are pure-Gleam BEAM packages, not npm deps.
- Every option has **0 lines of hand-written JS** and the same browser asset.
  Framework choice changes only the server half — it does not change R17/R18.

R24's boundary is kept: this is a recommendation, **not** an adoption. Nothing
was added to the root `gleam.toml`; the root `src/` was not touched. The
recommendation is recorded in the stable design document and takes effect only
when a plan actually builds the web layer.

## Debt, recorded not hidden

The browser half is a 3-line generated `main` returning `Nil`; visible data is
server-rendered. No chart library, no real SPA interaction, no streaming, no
supervision tree, no benchmark under load. The demos measure framework cost
only, which is what R24 asked for.

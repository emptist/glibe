# Developer Guide — glibe

The rules this project is built by, in **the owner's own words** first. A rule
without a mechanism is decoration; each one below names the thing that fails
loudly when it is broken.

## Gleam language references

1. **The Gleam Language Tour — Everything!** — <https://tour.gleam.run/everything/>
   The authoritative single-page reference: modules and imports, custom types
   and records, `case`/exhaustiveness, `Result`/`Option`, `use`, opaque types,
   `let assert`, `@external`, multi-target externals and Gleam fallbacks.
2. **The Complete Gleam Guide: From Zero to Expert** (Kodikra, 2026-03) —
   <https://www.kodikra.com/2026/03/the-complete-gleam-guide-from-zero-to.html>
   A **learning roadmap**, not a language spec. Good for the BEAM/OTP mental
   model and the chapter order; generic "v1.x", and its compilation-flow
   diagram (`.gleam → .erl → erlc → .beam`) describes the pipeline **before
   1.19.0**. When the two disagree, the tour wins.
3. **Gleam v1.19.0 — "Gleam doesn't compile to Erlang source anymore"** —
   <https://gleam.run/news/gleam-doesnt-compile-to-erlang-source-anymore/>
   The authoritative version note (2026-10-05, by Louis Pilfold). Quote:
   *"Previously Gleam generated Erlang source code, now it generates Erlang
   abstract forms."* A version fact, not a language reference.

### Measured on 1.19.2 (clean probe, 2026-11-07)

A brand-new `gleam new` project built on 1.19.2 produces `.abstr` files
(Erlang abstract forms) for every module and `.beam` for every module —
**no `.erl` per module**. It still writes **one** `@@main.erl`: the
`gleam run` runner stub. Deleting it and rebuilding makes 1.19.2 write it
again, so it is **current**, not a leftover from an older compiler. Other
`.erl` files under `build/` come from dependencies (handwritten FFI inside
Hex packages, or `gleam compile-package` output for rebar3/mix users), not
from glibe's modules and not from a human here. Module compilation goes
`.gleam → .abstr → Erlang compiler back half → .beam` — *not* "straight to
`.beam`" as an earlier round of this guide claimed.

## Web layer — references for evaluation (**none adopted**)

The owner has **not** chosen a web framework, and has not yet read or used
Wisp. The Phoenix/Elixir app an AI picked now lives in `deprecated/glibe_web/`
— kept for comparison, not in use (see `REVIEW_ROUND5.md` §10 and
`docs/RULINGS.md` R18). The active client is the separate JS-target package
`webclient/`. These three links are reference material for
the day the owner decides the web layer (`REVIEW_ROUND5.md` §10) —
**not** a commitment and **not** a dependency:

1. **Wisp — A practical web framework for Gleam** —
   <https://gleam-wisp.github.io/wisp/>
   The *request edge*: a handler is `fn(Request) -> Response`, middleware is
   composed with `use`, routing is pattern matching. It runs on the Mist HTTP
   server and the BEAM. It is **not** an HTTP server and **not** a UI framework.
   **The handle is `lpil` (lower-case L), Louis Pilfold — the creator of
   Gleam himself.** So Wisp is not a third-party guess at Gleam idiom; it is
   written by the person who defined the language. Hex publisher `lpil`, repo
   `gleam-wisp/wisp` (formerly `lpil/wisp`), sponsor `github.com/sponsors/lpil`.
   Lustre is by Hayleigh Thompson, Mist by rawhat — different authors, one
   shared set of `gleam_http` types. API docs: <https://hexdocs.pm/wisp/>,
   source/guides: <https://github.com/gleam-wisp/wisp>.
2. **Lustre** — <https://hexdocs.pm/lustre/>
   The *UI*: typed HTML as Gleam functions and MVU over a `Model` custom type.
   Server components are `gleam/otp/actor`s with `lustre.supervised` /
   `lustre.factory`. It is **not** a router and has **no built-in PubSub**.
3. **Mist** — <https://hexdocs.pm/mist/>
   The *server*: pure-Gleam BEAM HTTP with `mist.websocket`,
   `mist.server_sent_events` and chunked responses.

Lustre's own full-stack guide uses **Wisp + Mist** with a third `shared/`
Gleam package for the types both halves use:
<https://hexdocs.pm/lustre/guide/06-full-stack-applications.html>.
That is the type-driven shape worth considering; the decision is still his.

**WASM is a research question, not a framework choice.** The owner asked
whether Elixir has tried WebAssembly. It has: Software Mansion's Popcorn 1.0
(2026-10-27) runs the full OTP/BEAM compiled to WASM in the browser with
unmodified Elixir code —
<https://swmansion.com/blog/popcorn-1-0-moving-from-atom-vm-to-otp-beam>.
Gleam has no WASM backend, and browser DOM/canvas still goes through JS APIs.
Recorded as research only in `REVIEW_ROUND5.md` §15; **nothing adopted**.

## The words

> **"BEAM is great. Let's build our success on it!"** — emptist, 2026-11-07

> **"glibe is the future, pure erlang target is the future."** — emptist,
> 2026-11-07

> **"No handwritten erlangs or even worse JS source files, keep the system
> clean and beautiful!"** — emptist, 2026-11-07

> **"Use types everytime a type is needed in nature, let gleam make your
> thinking correct and coding reliable!"** — emptist, 2026-11-07

> *"target erlang 无需手写任何erlang代码，无需ffi，ffi是JS专属的"* /
> *"如果手写就说明你错了"* — emptist, 2026-11-01, glib `RULINGS.md` §1.28

> *"记住类型的事情不要偷懒，必须用type解决，其他所有替代方案迟早都会变成无用功"*
> — emptist, 2026-11-03, glib `.planning/HANDOFF-2026-11-03.md`

> *"Gleam is a typed language, don't you know?"* — emptist, 2026-10-12, glib
> `RULINGS.md` §1.11

> *"another very important thing … Gleam is all of values and types, and
> functional. Values are cheap. Don't mislead yourself to Python or JS objects
> and classes, they are WRONG in design."* — emptist, 2026-11-04

## The mechanisms

| Rule | What fails loudly |
|---|---|
| `src/` is Gleam only — **no `.erl`, `.hrl`, `.ex`, `.exs`, `.mjs`, `.js`** | `scripts/no_foreign_source.sh`, run by `scripts/guards.sh --all` and CI |
| A closed set is a **custom type**, never a `String` | the compiler's exhaustiveness check; `trading/signal.gleam` is the model |
| One type, one module; one closed set, one home | `scripts/no_banned_names.sh`-style naming review; see `NAMING.md` |
| `timeframe.gleam` holds the record and `new` only | `scripts/no_timeframe_mixture.sh` |
| Build, tests, format before a commit is called done | `scripts/compiles.sh` inside `guards.sh`; CI pins gleam **1.19.2** / OTP **29** |
| Band ordering `l3 ≤ l2 ≤ l1 ≤ m ≤ u1 ≤ u2 ≤ u3` | `bollinger_band_ordering_law_test` + the one-floor-before-interpolation test |

## Import syntax (from the tour — this is the exact form)

```gleam
import gleam/string_tree.{type StringTree}          // type only
import gleam/option.{type Option, None, Some}       // type + constructors
```

There is **no `Type(..)` constructor-import form** in Gleam. Constructors are
listed as plain names; `type` prefixes only the type. When in doubt, import the
type alone and qualify constructors (`indicator_settings.SmaForBbmTiny`).

## Multi-target externals (why glib needs no `.erl`)

A function may have **both** an `@external(erlang, ...)` implementation **and**
a Gleam body. If the current target has an external, it is used; otherwise the
Gleam body is used. That is the mechanism by which glib could keep a JS-only
boundary and give the Erlang target a plain Gleam fallback — no handwritten
Erlang file, no stub `.erl`. `@external` is for calling *existing* BEAM
modules (`"calendar"`, `"lists"`), never for writing a foreign module of your
own.

**glibe deliberately does not use this escape.** R15 (user, 2026-11-07)
scopes IB to historic stock/ETF data and rules that a JS target dependence is
grounds to drop IB entirely; `scripts/no_foreign_source.sh` fails on any
`@external(javascript, ...)` under `src/`. The mechanism is real, but on a
pure Erlang target the right answer is to **not need it**: IB historic data
is plain HTTPS + JSON reachable with `gleam_httpc` and `gleam_json`, both
already dependencies. See `RULINGS.md` R15 and `REVIEW_ROUND5.md` §11.3.

## Stop waiting on glib

glib is a moving, dual-target reference with a large documentation tree. Many
features designed and required there have never landed in its `src/`, and the
AI layer was deliberately deleted by the owner. **glibe does not wait for a
feature the reference project removed.** The authority order is:
**the owner's current statement > the Idris spec > legacy code > inference.**
See `REVIEW_ROUND5.md` §1 and §7.


## Testing: assertions and guard fixtures

The Gleam Language Tour's *Advanced features* section defines four
deliberately-failing constructs. Their use here is deliberately narrow:

| construct | official guidance | glibe (measured, 2026-11-07) |
|---|---|---|
| bool `assert expr as "msg"` | *"designed to be used in test code"*; almost never in applications or libraries | **15** primary assertions in `test/glibe_test.gleam` |
| `let assert Pattern = value as "msg"` | partial pattern; *"should be used sparingly, and likely not at all in libraries"* | **12** in tests for shape checks; **6** in `src/` for invariants that must hold (`engine`, `branch`, `leaf`) |
| `panic as "msg"` | *"This keyword should almost never be used!"* — in a library it signals a design that could improve | **0 as a test assertion**; **10 remain in `src/` string codecs** (`api/rules.gleam`, `api/asset.gleam`, `binance/kline.gleam`) — a design observation, not changed without a plan |
| `todo as "msg"` | marks unimplemented code; emits a **compiler warning**, crashes if run | **0 in the tree**. Probe: `gleam build --warnings-as-errors` fails with `error: 1 warning generated` on a single `todo`. With a 0-warning build requirement, `todo` is self-enforcing |

Before this change, `test/glibe_test.gleam` used
`case Bool { True -> Nil, False -> panic as "..." }` in nearly every test. It
now uses `assert` / `let assert` with `as "message"`: same **26 tests**, same
behaviour, fewer lines, clearer failures.

**No more "entrapment-style" negative tests.** The old way to prove a guard
worked was to write deliberately broken code into `src/`, watch the guard go
red, then remove it — fragile, manual, and a maintenance cost.
`scripts/test_guards.sh` replaces it: the guards are copied into a throwaway
fixture tree under `/tmp`, seven fixtures are built (two clean controls, a
`.mjs` under `src/`, an `@external(javascript, ...)`, a javascript target in
`gleam.toml`, an extra function in `timeframe.gleam`, and a second `Timeframe`
declarer), and each guard's exit code and failure message are asserted. The
real `src/` is **never modified, not even briefly**. It is wired into
`sh scripts/guards.sh --all` and therefore into CI.

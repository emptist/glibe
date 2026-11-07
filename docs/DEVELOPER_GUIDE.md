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
   diagram (`.gleam → .erl → erlc → .beam`) describes the old pipeline. On
   Gleam 1.19.2 the only generated `.erl` is the `@@main` runner stub inside
   `build/`; module code goes straight to `.beam`. When the two disagree, the
   tour wins.

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
Gleam body is used. So a JS-only IB boundary can keep
`@external(javascript, ...)` and give the Erlang target a plain Gleam fallback
— no handwritten Erlang file, no stub `.erl`. `@external` is for calling
*existing* BEAM modules (`"calendar"`, `"lists"`), never for writing a foreign
module of your own.

## Stop waiting on glib

glib is a moving, dual-target reference with a large documentation tree. Many
features designed and required there have never landed in its `src/`, and the
AI layer was deliberately deleted by the owner. **glibe does not wait for a
feature the reference project removed.** The authority order is:
**the owner's current statement > the Idris spec > legacy code > inference.**
See `REVIEW_ROUND5.md` §1 and §7.

# Gleam — the whole language on one card
Official sources read 2026-11-07: `tour.gleam.run/everything/`,
`gleam.run/documentation/` (the index), conventions & anti-patterns, externals,
command-line-reference, gleam-toml-reference, compatibility-reference,
language-server-reference, FAQ, writing-gleam, Python cheatsheet,
`hexdocs.pm/gleam_stdlib/`. Local toolchain: **Gleam 1.19.2 / OTP 29 / Erlang**.
This file IS the language; other `references/` files are lookup only. **Read it IN FULL before any Gleam judgement.**

## 0. The prime directive
**Model the domain in types until invalid states are unrepresentable. Then stop.**
No validation layer, no parser, no shell guard, no comment asking a human to be
careful. A `String` where a closed set exists is a debt paid later in parsers,
`panic`, catch-all branches and guard scripts. The whole fix is often:
```gleam
pub type Interval {
  IntervalOneMinute
  IntervalFifteenMinute
  IntervalThirtyMinute
  IntervalOneHour
  IntervalOneDay
  IntervalOneWeek
  IntervalOneMonth
}
pub fn to_string(i: Interval) -> String {
  case i {
    IntervalOneMinute -> "1m"
    IntervalFifteenMinute -> "15m"
    IntervalThirtyMinute -> "30m"
    IntervalOneHour -> "1h"
    IntervalOneDay -> "1d"
    IntervalOneWeek -> "1w"
    IntervalOneMonth -> "1M"
  }
}
```
Constructors are **named in full, prefixed by the type name**. Short exchange
wire codes (a unit letter plus a digit) are abbreviations — banned as type
constructors (owner R21; official "no abbreviations" anti-pattern). Wire
spellings such as `"1h"` live ONLY in the codec/adapter, never in a constructor.
A recognised professional term is NOT an abbreviation in this sense: `TPlus1`
/ `TPlus2` (T+1 / T+2) and `CPU` stay as they are (owner R25). What is banned
is an exchange wire code standing in for a type name.
Adding a constructor makes every incomplete `case` a compile error. **The
compiler does the remembering.** (Official "Make invalid states impossible";
official anti-pattern: a catch-all `_` disables exactly that help.)

## 1. What the compiler guarantees
- Static full type checking. No `null`, no implicit conversions, no exceptions.
- `case` **exhaustiveness**: missing AND redundant patterns are errors.
- Unused variable/value → warning (`_` prefix silences). `@deprecated`, `todo` → warning.
- Private by default: no `pub` = compiler error outside the module.
- `==`/`!=` on any type, but **both sides same type**; structural equality.
- Type variables are **not** `any`: one call = one concrete type throughout.
- No loops, `return`, mutation, truthiness, or `if` on anything but `Bool`.
- If it compiles, "you can be reasonably confident it does not have any
  inconsistencies that may cause bugs or crashes."
- Absent FOREVER (FAQ): exception-based errors, extensible variants, overloading,
  implicit arguments, nullable values, affine types, Lisp macros, manual memory
  management, mutation, OOP, optional arguments, type classes/traits, untagged
  unions. Do not wait for them; do not emulate them.

## 2. The type-first reflex — ask mechanically before writing anything
1. **What are all the values this thing can be?** Closed set → custom type, one
   constructor each. Two states → two variants, not a `Bool`.
2. **Can a wrong-but-well-formed value reach a consumer with no function
   objecting?** A yes means the type is wrong. "We validate it later" is a yes.
3. **Is it an identifier?** `String` lets an `AssetId` go where a `MarketId` is
   wanted. Wrap it: `pub type AssetId { AssetId(String) }`; prefer `opaque` +
   a smart constructor when construction must be controlled.
4. **Is it a time / date / duration / timezone?** Not a `String`. Use
   `gleam_time.Timestamp` — official: *"Do not create a new time type instead
   of using `gleam_time`'s `Timestamp`."* Never split a string to read a minute.
5. **Is it an error?** A custom error type, one variant per business-domain
   failure, carrying the context needed to debug it. Never `Error(String)`.
6. **Is it `Dynamic`?** Official: "Never use `Dynamic` … create a new type that
   represents exactly the expected type." Use an external type, no constructors.
7. **Is the data already Gleam source (config)?** Then there is no parsing: write
   the constructor. `from_string` + `panic` over your own config is a parser for
   a language you already own.
**`type Alias = Int` is NOT a new type** — same type, zero safety; the Tour says
aliases "should be used rarely". Use a custom type.

## 3. Types and data
```gleam
// Built-in: Int Float String Bool Nil List(a) #(a,b) Result(a,e) BitArray
// Stdlib:   Option(a) Dict(k,v)
Int                     // unbounded on BEAM; 64-bit float on JS
Float                   // +.  -.  *.  /.  >.  <.  >=.  <=.  (not overloaded!)
1_000_000  0b1010  0o17  0xF  7.0e7
"one" <> "two"          // concat; Unicode; \u{1F600}
True && False || !True  // Bool only; && || short-circuit
Nil                     // unit; NOT a value of any other type = no null
[1, 2, 3]  [0, ..rest] // immutable singly-linked list; prepend O(1)
#(1, "a")  t.0  t.1    // tuple; prefer a named custom type
<<3:size(8)>>           // bit array; JS support partial

pub type Season { Spring Summer Autumn Winter }        // enum
pub type Person { Person(name: String, age: Int) }    // record variant
pub type Shape { Circle(radius: Float)                // union
                 Rect(width: Float, height: Float) }
pub opaque type PositiveInt { PositiveInt(inner: Int) } // constructors private
pub fn new(i: Int) -> PositiveInt {                    // smart constructor
  case i >= 0 { True -> PositiveInt(i) False -> PositiveInt(0) }
}
pub type Never { Never(Never) }                        // uninhabitable
pub type ZipHandle                                     // external type
```
`Float` division by zero returns `0` by design (no exceptions, no BEAM
infinity); use stdlib result-returning division when that matters.
- Types/variants `PascalCase`; everything else `snake_case`. Constructor labels
  optional at the call site — use them; shorthand `Person(name:, age:)`.
- `record.field` works only when that field has the same name/position/type in
  **all** variants; otherwise match the variant first.
- Record update `Teacher(..t, subject: "PE")` returns a NEW record. Immutable.
- `const` is module-level and must be a literal — no function calls.
- Qualified imports for functions/constants (`io.println`); types/constructors
  may be unqualified (`import gleam/option.{type Option, Some, None}`).
- `Dict`: no literal syntax, cannot be pattern matched, unordered. Prefer custom types.

## 4. Pattern matching and control
```gleam
case x { 0 -> "zero" 1 -> "one" n -> int.to_string(n) }
case x, y { 0, 0 -> "both" 0, _ -> "first" _, _ -> "neither" }
case n { 2 | 4 | 6 -> "even" 1 | 3 -> "odd" _ -> "?" }
case list { [] -> 0  [first, ..rest] -> first + sum(rest) }
case "Hello, " <> name -> name          // string prefix pattern
case nums { [f, ..] if f > limit -> f  _ -> 0 }  // guards: no calls/case/blocks
case fish { Jellyfish(name, ..) -> name }
[[_, ..] as first, ..] -> first          // pattern alias
let IceCream(flavour) = x               // plain let: single-variant only
```
- **No catch-all `_` over a custom type** — write every variant; a new
  constructor then becomes a free to-do list from the compiler.
- Ordinary `let` rejects partial patterns; `let assert` permits them and crashes.
- No loops: recursion with a base case, accumulator for tail-call optimisation,
  public wrapper hides the accumulator. Prefer `list.map/filter/fold/find`.
- Multiple subjects need exactly as many patterns. Guards allow no function
  calls, `case`, or blocks. Alternative patterns bind the same names/types.

## 5. Functions, modules, naming
```gleam
pub fn twice(argument: a, f: fn(a) -> a) -> a { f(f(argument)) }
let add_one = fn(x) { x + 1 }
let add_one = add(1, _)                     // function capture
"hello" |> string.append("!", _) |> io.println
fn calc(value: Int, add addend: Int, multiply m: Int) -> Int { ... }
calc(1, multiply: 3, add: 2)                // labelled, order-free, zero cost
use a, b <- my_function                     // → my_function(fn(a,b){ ... })
```
- **Annotate ALL module functions** (args AND return) — official convention.
- **Subject first for `|>`; a call on the right gets the left side as its FIRST
  argument, and any number of remaining arguments are written at the call
  site.** Official tour "Pipelines"
  (`tour.gleam.run/everything/#functions-pipelines`):
  `rocket |> launch(1, 2)` = `launch(rocket, 1, 2)`; a bare right-hand name
  becomes a one-argument call (`rocket |> launch` = `launch(rocket)`);
  `f(1, _)` function capture sends the piped value to a later argument. A
  bare name is shorthand, NOT a one-argument restriction — every step of a
  pipeline may have as many parameters as it needs, as long as the subject is
  first and the subject is what comes back (measured R40-A).
- **A pipeline is a SHAPE constraint, not formatting** (owner R41): it fixes
  every step to `fn(Subject, ...extra) -> Subject`, so inventing the first
  argument's position or the return type is a compile error, while the SAME
  invented signatures written as ordinary calls compile (each call site
  hand-aligned). Measured in four throwaway packages: control 0, wrong first
  arg 1 (`Expected Int / Found Frame`), wrong return 1 (`This function does
  not accept the piped type`), no-pipe control 0. The types were always
  checked; what the pipe adds is one shared shape. Adding a step then needs no
  knowledge of the previous step's signature. **When a design lets every
  function invent its own parameter order and return type, an AI will.**
- Unlabelled args precede labelled ones; labels have no runtime cost.
- `use` flattens callback nesting; overusing it harms clarity.
- Module = file path; one per file; **singular in every segment**
  (`app/payment/invoice`). All imports are relative to `src/`.
- **Global module namespace**: put modules in a uniquely named directory
  matching the package; never trespass in another package's namespace.
- Group by **business domain**, never by design pattern (`controllers`,
  `services`, `types`, `utilities`, `constants` are all listed as Bad).
- **Do not fragment modules.** Large modules are not a problem; "This
  anti-pattern is especially common with AI-generated code." Import cycles or
  needing several imports for one simple task signal a bad split.
- `//` comment, `///` doc (before item), `////` module doc (top). Comments go on
  the line BEFORE the thing. Comment liberally, but write clear code.
- Acronyms are one word (`Json`, not `JSON` → `j_s_o_n` on BEAM). No
  abbreviations: `capacity`, never `cap`. **Closed-set constructors carry the
  type name and spell the value out** (`IntervalOneDay`, not a wire code); wire
  codes are boundary data, never model names (owner R21).
- Conversion names `x_to_y`; if the module matches the type, drop the prefix
  (`identifier.to_string`); name the encoding (`date_to_rfc3339`). Fallible
  names are domain-specific (`parse_json`, `enqueue`); `try_` only for a
  result-returning twin of an existing function. Never `monadic_bind`.

## 6. Errors — no exceptions, ever
```gleam
pub type PurchaseError {
  NotEnoughMoney(required: Int, available: Int)
  NotLuckyEnough
}
fn buy(money: Int) -> Result(Int, PurchaseError) {
  case money >= 5 {
    False -> Error(NotEnoughMoney(required: 5, available: money))
    True -> Ok(money - 5)
  }
}
use username <- result.try(get_username())
use password <- result.try(get_password())
Ok(greeting(username, password))
```
- Every fallible function returns `Result(value, error)`. **Always `Result`**,
  never `Option` for failure; `Option` is present/absent with no error. With
  nothing to say about the failure, the error type is `Nil`.
- Descriptive errors in the **business domain**, each variant carrying context;
  a lower-level error may be a field of a higher-level one. Never name the
  dependency in the error type.
- `result.map/try/unwrap/lazy_or`, pipelines, `use`.
- Anti-pattern **"Check-then-assert"**: never `result.is_ok(x)` then
  `let assert Ok(v) = x`. Match once with `case`, or use `result.try`.
- **Libraries must not `panic` or `let assert`.** Panicking at the very top
  level of an application, handling a returned `Result`, may be appropriate.

## 7. Intentional crash devices — know them, avoid them in libraries
```gleam
todo as "not implemented"       // compile warning; crashes if reached
panic as "should never happen"  // almost never correct; a type can fix it
let assert [first, ..] = xs as "list should not be empty"
assert add(1, 2) == 3 as "commutative"  // Bool assert — TEST CODE ONLY
echo value                      // debug print of any type
```
With **well designed types** invalid states are unrepresentable, so `panic`
signals a design that can be improved. `assert` is for tests; `panic` and
`let assert` sparingly, "libraries likely never".

## 8. Stdlib and core packages (use them, do not reinvent)
`gleam_stdlib` (v1.0.5 here; both targets): `io`, `int`, `float`, `string`,
`bool`, `list`, `result`, `option`, `dict`, `set`, `pair`, `order`, `function`,
`iterator`, `bytes_tree`, `string_tree`, `bit_array`, `uri`, `regexp`, `queue`,
`dynamic` + `dynamic/decode`, `javascript/array`. Prefer core-team packages over
home-grown equivalents: `gleam_stdlib`, `gleam_time` (`Timestamp`), `gleam_json`,
`gleam_http`, `gleam_erlang`, `gleam_otp`, `gleam_javascript` — **"Do not
replicate functionality provided by these packages."** Test runner `gleeunit`:
any `pub fn *_test()` in `test/`. `gleam_erlang` is where the Erlang-interop
helpers `charlist`/`atom` live — `gleam add gleam_erlang`; never hand-roll BIFs
(`erlang:binary_to_list`, `binary_to_atom`). Measured gotchas:
`multi-target-erlang.md` §8.

## 9. Targets, externals, project structure
- `gleam.toml`: `name`, `version` required; `target = "erlang" | "javascript"`
  (default erlang); `[dependencies]`, `[dev_dependencies]`, `gleam = ">= x.y"`,
  `internal_modules` (default `$NAME/internal` + `$NAME/internal/*`),
  `[javascript] runtime = "node"|"deno"|"bun"`, source maps, `.d.ts`,
  `[tools.*]`. **Never a separate tool config file.**
- `--target` overrides `gleam.toml`; otherwise it wins; otherwise Erlang.
- `src/` imports `dependencies` + `src/` only; `test/` and `dev/` import anything.
- **One target per package.** A separate package directory with its own
  `gleam.toml` is the clean way to put a JS-target client beside an Erlang-target
  engine — the target is declared by the build tool, not policed by a shell
  script inspecting file extensions.
- `@external(target, module, function)`: `target` is the COMPILATION target, not
  the source language (Elixir still uses `erlang`). Type annotations are
  **mandatory**; the compiler checks Gleam-side uses but cannot verify the
  foreign implementation exists or returns that type.
- Erlang externals: module/function names as written in Erlang; Elixir needs the
  `Elixir.` prefix. JS externals: `module` is an `import` path relative to the
  Gleam file (usually `./x.mjs`) or an npm package name.
- `@external` may appear twice (one per target), or once with a Gleam body as
  fallback. Missing implementation for the current target = compile error.
- **Externals sparingly** — prefer Gleam; most projects use none. Design the
  Gleam API with Gleam in mind; a dedicated external type stops a handle being
  passed to unrelated functions. Never `Dynamic` at the boundary.
- JS target needs ES2022+; npm deps need `package.json` + `npm install` — Gleam
  does not resolve them, so `gleam build` can be green while the import is missing.
- Erlang target supports the two most recent OTP majors (Gleam 1.18+ → OTP 29
  and 28). Gleam 1.19 compiles modules to Erlang abstract forms (`.abstr`) →
  `.beam`; no ordinary per-module `.erl` source is emitted.
- Immutable with structural sharing; side effects allowed (impure functional).
  Typed message passing lives in `gleam_otp`/`gleam_erlang`, not the core.

## 10. Toolchain, LSP, testing
```sh
gleam build                         # incremental compile
gleam build --warnings-as-errors    # CI: warnings are fatal
gleam check                         # type-check only, no codegen
gleam test                          # runs test/<pkg>_test.main
gleam format --check                # canonical formatting
gleam run -m module                 # non-default entrypoint
gleam deps list|tree|download|update|outdated
gleam docs build --open
gleam export erlang-shipment|escript|package-interface
gleam new <dir> --template javascript
gleam lsp                           # from workspace root
```
- LSP is **inside the `gleam` binary**. Diagnostics, formatting, hover,
  go-to-definition, go-to-**type**-definition, find-references, completion,
  rename, document symbols, signature help, code folding, ~38 code actions
  (add annotations / missing patterns / missing import, generate decoder / type /
  function / to-JSON, replace `_` with type, fill unused fields, remove
  redundant tuples, convert to/from pipe and use, pattern match, …).
- LSP does **not** generate code or compile Erlang/Elixir — opening a file cannot
  execute code. It uses the project's `target` from `gleam.toml`.
- Prefer LSP find-references / go-to-type-definition over `grep -rn`; use
  `gleam build` for truth about correctness.
- Tests use `assert` / `let assert` / pattern matching, not deliberately broken
  source files. Negative tests belong in throwaway fixtures.

## 11. Official conventions & anti-patterns (condensed)
- Conventions (always): qualified imports for functions/constants; annotate all
  module functions; `Result` for fallible functions; singular module names;
  acronyms as one word; `x_to_y` conversions; domain-specific fallible names;
  use core libraries; tool config under `tools.*` in `gleam.toml`; correct
  `src`/`dev`/`test`.
- Patterns (when useful): descriptive errors; comment liberally; make invalid
  states impossible; replace `Bool` with custom types; sans-IO (a request
  builder + a response parser, not an injected HTTP function); builder pattern
  (opaque type forces validated construction).
- Anti-patterns (never): abbreviations — but a professional term such as T+1
  is not one (R25); fragmented modules; panicking in
  libraries; global namespace pollution; namespace trespassing; grouping by
  design pattern; check-then-assert; `Dynamic` with FFI; catch-all `_` as a
  final `case` clause; category-theory overuse ("Solve specific problems with
  specific solutions").

## 12. Unlearn — foreign instincts that do not exist in Gleam
- `None` / `null` / truthiness → `Option(a)`, matched. `Nil` is not null.
- `try/except`, `raise`, early `return` → `Result(a, e)` + `case` / `use result.try`.
- `for`/`while`, mutable accumulator → recursion / `list.fold` / `list.map`.
- `dict` with mixed value types → custom type; one type per field.
- `str` holding an enum / date / id → custom type / `gleam_time.Timestamp`.
- `isinstance`, duck typing, `any` → variants; unknown shape = external type.
- `int | float` untagged union → custom type wrapping each case.
- Classes, methods, `self`, subclassing → plain functions in a module.
- Runtime validation + error strings → a constructor that cannot hold the error.
- `pip install` mindset → `gleam add`; commit `manifest.toml`.
- Shell scripts guarding conventions the compiler could enforce → **fix the type
  or the package boundary instead**. A grep guard describes a design that was
  never expressed in the code.

## 13. Pre-write checklist (before every Gleam change)
1. Is every closed set a custom type? Is any `String` standing in?
2. Does any `case` end in `_` over a custom type? Remove it.
3. Is any error `String` or `Dynamic`? Replace with a domain error type.
4. Did I write a parser + `panic` for data that is already Gleam source? Delete it.
5. Are all module functions annotated? Are names exact, full, domain-shaped,
   with every constructor prefixed by its type name (R21)?
6. Is the boundary (target, FFI, file format) declared by `gleam.toml` / package
   layout rather than by a guard script?
7. `gleam check` → `gleam build --warnings-as-errors` → `gleam test` →
   `gleam format --check`. Report the real exit code, never a truncated log.

## 14. Documentation-first is IN the code; tests come before bodies (owner 2026-11-07)
`////` = module doc, `///` = next item's doc, `//` = invisible to `gleam docs`.
Order for every new module: `////` naming the **`.planning` plan item** →
types → `///` + annotated signatures → `todo as "..."` bodies → **unit tests**
(`assert` / `let assert`) → fill one body → compile → repeat until green.
The `///` comment IS the spec; the test asserts the promise; the body delivers
it. A plan with no link from the code file is a toy and drifts unnoticed.
Measured 1.19.2: skeleton builds with **0 errors / 4 warnings** (2 `Todo found`,
2 unused args) and `gleam test` is RED (`todo` crashes, prints file:line).
`gleam build --warnings-as-errors` is a **FIXED gate, including the skeleton
phase**: it fails with the Todo / empty-use list; read every diagnostic to its
line, and filling one body removes one. Never classify a class of warnings as
"expected skeleton shape" (owner R48) — the ONLY warning that exposed an
AI-invented type was a single `Unused function argument`. The flag exists on
`build` alone; `check` / `test` / `docs` / `format` have none. An `_name`
parameter is a discard name and **cannot be referenced in the body** (measured:
`Found a discard name`), so bulk-silencing hints destroys the signal instead
of fixing it.
`gleam docs build` renders `////` and `///` into HTML **and**
`package-interface.json` as `"documentation"` strings — the compiler's own,
machine-readable anti-drift artifact; no grep guard is needed. Tests use
`assert`, never deliberately broken source files. Workflow: `build-new-module.md`.

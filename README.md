# glibe

Erlang-target Gleam. This branch is `doc-tdd`: a **framework rebuild in
types**, not a working system yet.

The design lives in the code's own `////` module docs and `///` item docs —
not in prose documents. Every function body is `todo as "..."`.

- Plan item: `.planning/phases/05-doc-tdd/05-01-PLAN.md`
- Rulings and owner wording: `docs/RULINGS.md`
- Current state: `docs/STATE.md` (newest section at the top)
- Compiler interface check:
  `gleam export package-interface --out /tmp/glibe-interface.json`

The pre-`doc-tdd` implementation, tests, guard scripts and notes are kept
readable under `deprecated/2026-11-12-pre-doc-tdd/` as history only. No
project-level guard script exists here; the Gleam compiler's own commands
are the check.

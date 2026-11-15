# glibe

Erlang-target Gleam. This branch is `doc-tdd`: a **framework rebuild in
types**, not a working system yet.

**Starting a new session? Read `docs/HANDOFF.md` first.**
**Before filling any `todo`, read `DEVELOPER_GUIDE.md`.**

The specification lives in the code's own `////` module docs and `///` item
docs — `gleam docs build` renders them into `package-interface.json`, so the
compiler checks them. `DEVELOPER_GUIDE.md` is a navigation aid for reading
those docs, not a second specification. Most function bodies are still
`todo as "..."`; the `Todo found` warnings are the remaining work.

## The lists are newest-first on purpose

Gleam's `List` is a singly-linked list: prepend and read the head are O(1),
while `length`, `last`, `append` and `reverse` walk it. Every data list that
grows with the stream is therefore archived **newest first** (prepend), and
every member access reads the **head**.

The count is never walked: `DataBar` carries `idx`, its position in the
stream, so `bars_listed` is `newest.idx + 1` — one head read. `SourceBar` has
no `idx`: a provider's closed candle does not know its position until
`sourcebar.to_databar(sourcebar, idx)` gives it one at the boundary. That
`idx` also turns every span and window size into subtraction instead of a
walk.

Do not guess from a name: `bars_listed` does not count, `last_bar` reads the
head, and `exited_branch` does not search.

The chart is **not** drawn backwards — in the shape the engine is meant to
have. Each output boundary projects the one newest-first list once (the
page's initial paint, or the export on quit); every live bar then travels
alone over SSE and the chart grows by one `series.update`. Chronological
order is a projection, never a second stored copy — see
`DEVELOPER_GUIDE.md` §6.

That is the design, **not** a claim that the reference implementation got
everywhere right. Owner, 2026-11-15: *"关键技术是stream模式，纵有万千条k线，
系统里面其实只有一根在工作，那就是 working_databar, you almost always only
need that one databar."* So every place that reverses the whole history is a
place somebody asked for the entire history instead of that one bar.
`DEVELOPER_GUIDE.md` §6.5 / §7(e) asks exactly that question at each of the
9 `reverse` sites found in the reference code (7 Gleam + 2 JS FFI); two of
them do run per bar / per poll. The first test for any chart library is
therefore whether it can update **one** bar — by that test `try_plushie`
currently does not qualify (§6.5).

The guide also has the full list inventory, the exceptions and boundary
cases, and a table saying how to fill each remaining `todo`.

- Plan item: `.planning/phases/05-doc-tdd/05-01-PLAN.md`
- Developer guide (list efficiency, filling the skeleton): `DEVELOPER_GUIDE.md`
- Rulings and owner wording: `docs/RULINGS.md`
- Current state: `docs/STATE.md` (newest section at the top)
- Compiler interface check:
  `gleam export package-interface --out /tmp/glibe-interface.json`

The pre-`doc-tdd` implementation, tests, guard scripts and notes are kept
readable under `deprecated/2026-11-12-pre-doc-tdd/` as history only. No
project-level guard script exists here; the Gleam compiler's own commands
are the check.

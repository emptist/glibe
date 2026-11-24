# Phase 06 Plan 01: Restore chart interaction — Summary

**Wheel zoom, press-drag pan, arrow-key navigation and a live crosshair are wired into the one chart widget; a real dispatched pointer event grows the crosshair layer from 0 to 3 shapes.**

## Accomplishments
- `dashboard.widget_handle_event` now routes Scroll / Press / Move / Release / Key to pure O(1) helpers that change only viewport, mouse and drag state — never the model, never the translated shape lists (R60 §2).
- New `DragState` custom type (DragIdle | DragActive(last_x)) makes "dragging with no last x" unrepresentable (R13).
- Corrected the dishonest comment at the old `:245-246` that claimed "the viewport moves" while the body returned state unchanged.
- 5 RED→GREEN tests in `test/dashboard_interaction_test.gleam` pin zoom-in, zoom-out, drag-pan, mouse storage and a NON-EMPTY crosshair on the real node tree. The old `a_pointer_event_moves_only_the_viewport_test` never asserted the viewport — that false-green is now covered.
- Real run (`dev/export_tree_svg.gleam`): `crosshair before move = 0`, `crosshair after move = 3` — proving a dispatched event reaches the widget through runtime routing (R82 scoped target), not just unit tests.

## Files Created/Modified
- `src/glibe/app/dashboard.gleam` — DragState type, `drag` field, interaction helpers, real handler; fixed comment.
- `test/dashboard_interaction_test.gleam` — 5 RED→GREEN interaction tests.
- `test/dashboard_test.gleam`, `test/app_shape_test.gleam` — added `drag: DragIdle` to state constructors.
- `dev/export_tree_svg.gleam` — runtime-tree SVG export + crosshair before/after probe (retained as the reusable diagnostic; see Deviation).

## Decisions Made
- Pointer/key events DO reach `chart_widget_def.handle_event` through runtime widget routing when targeted at the scoped widget id `dashboard#<widget_id>` — confirmed by the real-run crosshair 0→3, so the interaction branches belong in the widget handler (no new App-level path).
- Drag state is a custom type, not a Bool + a loose Float (R13).

## Issues Encountered
- **Deviation (auto-fix, per execute-phase Rule 1/5):** plan Task 3 said recreate-then-delete the diag module; instead it is retained under `dev/` as the repeatable runtime-tree dump that audit B4 asks for. 06-03 formalises it as the standing tool. No production behaviour change.
- `file:write_file` returns a bare `ok`; the external was declared to return `Nil` after a `let assert Ok` crashed on the raw atom.
- `default_viewport(60)` shows all 60 bars, so zoom-out/drag-pan are clamped until a zoom-in opens room; tests were corrected to zoom in first.
- `a_state_with_bars` initially pushed bars in descending idx order; `push_generating` keeps only the first (len=1). Fixed to ascending.

## Gates (real exit)
format 0 · check 0 · test **152 passed, 0 failures** · docs 0 · export 0 · WAE 0.

## Next Step
06-02 (remove the synthetic demo_feed) then 06-03 (repeatable diag + honest artifacts + ROADMAP alignment). Commit: TBD.

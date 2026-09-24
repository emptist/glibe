# Handoff Note — Phase 3 Stream Processing Complete, Next: Leaf/Branch

## What Was Done (This Session)

### Timeframe Module Split
Split `src/glibe/timeframe.gleam` into 6 focused modules:

| Module | Responsibility |
|--------|----------------|
| `indicator_settings.gleam` | Shared types: `SmaSeries`, `SmaForBbm`, `TimeframeSettings` |
| `sma.gleam` | SMA series (Tiny/Small/Medium/Large) — three-case incremental logic (Plan 31-01) |
| `kdj.gleam` | KDJ oscillator — batch LLV/HHV over 9-bar window + incremental SMA for K/D/M |
| `bollinger.gleam` | Bollinger Bands — selected SMA centre, σ from `databar_list`, Fibonacci ratios 0.382/0.618 |
| `indicator.gleam` | Pipeline: SMA×4 → KDJ → Bollinger |
| `timeframe.gleam` | Timeframe type + `sourcebar_gate` + `databar_processing` |

**No circular imports.** Dependency graph:
```
indicator_settings → sma, kdj, bollinger → indicator → timeframe
```

### Two Top-Level Functions (Per DESIGN.md §15)
1. **`sourcebar_gate(tf, sourcebar) -> #(Option(DataBar), Timeframe)`** — folds SourceBar into working_databar until bucket ends
2. **`databar_processing(tf, databar, settings) -> Timeframe`** — super function calling `indicator.run` then `accept`

### Indicators Implemented
- **SMA series** (Tiny/Small/Medium/Large) — three cases by list length, correct leaving bar
- **KDJ** — batch LLV/HHV over 9-bar window; incremental SMA for K/D/M with M = SMA(K, 10)
- **Bollinger** — selected SMA centre, σ from `databar_list`, Fibonacci ratios 0.382/0.618/1.0

### Bias (Future)
Commented in `sma.gleam` — follows SMA naming (`sma_tiny_bias` etc.), ready to uncomment when bias fields added to `DataBar`.

---

## What's Next: Leaf & Branch (Fractal Structures)

### Design Source
- `glib/docs/DESIGN.md` §4–§6 (Leaf laws, Branch laws, indices)
- `glib/docs/NAMING.md` §3 (hierarchical naming: `growing_yin_leaf`, `yin_leaf_list`, `yang_leaf_mini`, etc.)
- `glib/docs/RULINGS.md` §1.2 (four records, no `GrowingLeaf` type)
- `glib/attic/reference/batch_fractal_engine.gleam` — reference implementation (batch, O(N²))

### Key Design Points (from rulings)

**Four records, four variants** (no polarity flag):
- `DataLeaf`: `YinLeaf(start_idx, end_idx, corner_idx)` | `YangLeaf(start_idx, end_idx, corner_idx)`
- `DataBranch`: `YinBranch(start_idx, enter_idx, end_idx, exit_idx)` | `YangBranch(start_idx, enter_idx, end_idx, exit_idx)`

**Timeframe fields (10 total):**
```
working_databar: DataBar
databar_list: List(DataBar)
growing_yin_leaf: DataLeaf        // NOT Option — every bar in both
growing_yang_leaf: DataLeaf       // NOT Option
growing_yin_branch: Option(DataBranch)
growing_yang_branch: Option(DataBranch)
yin_leaf_list: List(DataLeaf)
yang_leaf_list: List(DataLeaf)
yin_branch_list: List(DataBranch)
yang_branch_list: List(DataBranch)
```

**Leaf laws:**
1. Bar 0 opens both twins (new high AND new low)
2. Every bar in current yin leaf AND yang leaf
3. SMA_tiny new high → new YinLeaf; new low → new YangLeaf. Threshold = leaf's start value. Killing bar belongs to newborn. Shortest leaf = 1 bar.

**Branch laws:**
1. Branch may not exist; bar 0 can't determine
2. New YinLeaf ⇒ YangBranch; new YangLeaf ⇒ YinBranch (opposite polarity)
3. Continuation = length test, not price test
4. exit_idx = discrimination bar; end_idx = over-long leaf's start_idx (retrospective)
5. New branch recognised as already appeared
6. Old branch end_idx = over-long leaf start_idx; new branch start_idx = that leaf's corner_idx
7. corner_idx = that leaf's last inner opposite leaf's start_idx
8. Computable from leaf alone, no inner list needed
9. Working bar index = databar_list.length; backtracked start = corner_idx of last leaf in list

**Indices only** — no values on structures. Values read from `databar_list` at indices.

**Naming:**
- `DataLeaf` / `DataBranch` (not `Leaf` / `Branch`) — rule 1.18
- `growing_*` singletons (overwritten each bar)
- `*_list` for finished (newest-first)
- Inner mini: `yin_leaf.yang_leaf_mini` — path not prefix (`mini` is role, not type)

---

## Implementation Tasks

### 1. Add Types
In `indicator_settings.gleam` or new `fractal_types.gleam`:
```gleam
pub type DataLeaf {
  YinLeaf(start_idx: Int, end_idx: Int, corner_idx: Int)
  YangLeaf(start_idx: Int, end_idx: Int, corner_idx: Int)
}

pub type DataBranch {
  YinBranch(start_idx: Int, enter_idx: Int, end_idx: Int, exit_idx: Int)
  YangBranch(start_idx: Int, enter_idx: Int, end_idx: Int, exit_idx: Int)
}
```

### 2. Extend Timeframe
Add 8 fields to `Timeframe` type (6 present, 4 missing per STATE.md §2.3).

### 3. Implement Leaf Detection (Streaming)
Per `batch_fractal_engine.gleam` `go_yin`/`go_yang` — incremental state:
- Track `start_idx`, `start_value`, `corner_idx`, `corner_value`, `end_idx`
- Update each bar: check if SMA_tiny breaks threshold
- When leaf closes → emit to list, reset growing

### 4. Implement Branch Detection
- Recognised from 2nd leaf (opposite polarity)
- Track `start_idx`, `enter_idx`, `end_idx`, `exit_idx`
- Length test for continuation (branch_exit_leaf_size = 40/8/2 by interval)
- Retrospective `end_idx`/`exit_idx`

### 5. Integrate into Pipeline
Add `leaves(timeframe, databar)` and `branches(timeframe, databar)` to `indicator.run` after KDJ, before Bollinger.

### 6. Settings
Add `branch_exit_leaf_size` per interval (already in `TimeframeSettings`).

---

## References
- `glib/docs/DESIGN.md` — authoritative design
- `glib/docs/NAMING.md` — naming rules
- `glib/docs/RULINGS.md` — all settled rulings
- `glib/attic/reference/batch_fractal_engine.gleam` — reference algorithms
- `glib/docs/STATE.md` §2.3 — current gaps

---

## Build
```bash
gleam build  # should pass
```

No tests yet for fractal layer — need to add when implementation starts.

---

**Ready to start Leaf/Branch implementation.**
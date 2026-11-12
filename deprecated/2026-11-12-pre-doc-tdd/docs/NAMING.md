# Naming — glibe

The rules glibe writes by. They are conventions, not the compiler's, except
where a script enforces one (R7).

## Module = one class

A module holds one domain type and the functions that belong to it. The one
exception that is not an exception: `timeframe.gleam` holds the state record and
its birth, and `engine.gleam` holds every step that moves it. Splitting state
from pipeline dissolves the import cycle that glib still argues about.

| module | owns |
|---|---|
| `databar` | `DataBar` — born from a `SourceBar`, folded |
| `leaf` | `DataLeaf` — grown one bar at a time |
| `branch` | `DataBranch` — grown one bar at a time, rides a leaf |
| `api/sourcebar` | the ingest boundary: `validate`, `normalize_date` |
| `api/interval` | `Interval` + its codec + the bucket-end test |
| `api/symbol`, `api/exchange`, `api/asset`, `api/market`, `api/rules` | one external concept each |
| `indicator`, `sma`, `bollinger`, `kdj`, `indicator_settings` | the measurement chain |
| `engine` | the pipeline that threads the state |
| `trading/strategy` | the manual verdict |
| `export/csv` | the one exporter |

## Records and accessors

- A type and its constructor share a name: `DataBar(..)`, `Timeframe(..)`.
- An accessor that reads one field is `thing_field`: `leaf_start_bar`,
  `branch_enter_bar`, `leaf_corner_bar`. Read off the record, O(1), no list walk.

## Growth

- A function that advances a structure one bar is `next_<thing>` and returns
  `#(Option(settled), growing)` — `settled` is `Some` only on the bar it dies.
- A structure born this bar is `init_<thing>`.

## The four words

A structure names four of its bars, and the words are never reused:

| bar | word | when |
|---|---|---|
| `start_bar` | **born** | the corner of the leaf it was recognised off (backtracked) |
| `enter_bar` | **recognised** | the bar it was identified on; the manual enter |
| `end_bar` | **ended** | the start of the leaf it was riding when it died (backtracked) |
| `exit_bar` | **recognised as dead** | `branch_exit_leaf_size` bars later; the manual exit |

## The date

- Inside the engine a date is an ISO-8601 `String` (`"2024-01-15 09:00:00"`).
- Epoch-milliseconds exist only at the boundary (`api/sourcebar`), never past it.
- The interval's spelling (`"1h"`) lives in the type. A provider's spelling
  (`binance/`) is an adapter's vocabulary, not the type's.

## Fields

- A field nobody writes is deleted, not defaulted to `0.0` / `False`. A present
  number made of nothing is worse than a missing one.
- A verdict is not a measurement; it lives beside the decision that derives it,
  not on the bar.

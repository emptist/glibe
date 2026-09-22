# glibe

Erlang/Elixir-target trading library with Interactive Brokers and Binance API support.

Port of `glib` (JavaScript-target) to BEAM with Interactive Brokers TWS/Client Portal and Binance REST API integration.

## Status

| Component | Status | Notes |
|-----------|--------|-------|
| **IB Client Portal** | ✅ Working | Client Portal Gateway on :5001, curl FFI |
| **Binance REST** | ✅ Working | testnet.binance.vision (works from China), curl FFI |
| **Stream Processing** | 🚧 Planned | Phase 3 |

## Quick Start

```bash
# Build
gleam build

# Run Binance test (testnet, works from China)
gleam run -m binance_test

# Run IB test (requires Client Portal Gateway on :5001)
gleam run -m ib_test
```

## Architecture

```
┌─────────────────────────────────────────┐
│         Business Logic (Gleam)          │
│   Stream processing, strategies, AI     │
└─────────────────┬───────────────────────┘
                  │ calls
┌─────────────────▼───────────────────────┐
│      API Wrappers (Gleam + Erlang)      │
│   IB (ibkr.gleam)  |  Binance (binance) │
└─────────────────┬───────────────────────┘
                  │ HTTP/curl
┌─────────────────▼───────────────────────┐
│      External APIs                      │
│   IB Client Portal Gateway (:5001)      │
│   Binance testnet.binance.vision        │
└─────────────────────────────────────────┘
```

## Key Design Decisions

- **SourceBar vs DataBar**: Raw API data (`SourceBar`) vs computed bars (`DataBar`) — per DESIGN.md §2
- **testnet.binance.vision**: Default Binance endpoint (works from China without VPN)
- **curl FFI**: Erlang `os:cmd("curl ...")` for reliable HTTPS (httpc SSL issues, ibkr_api Finch config bug)
- **Target**: Erlang (`target = "erlang"` in gleam.toml)

## Project Structure

```
src/
├── glibe/
│   ├── ib/
│   │   ├── ibkr.gleam       # IB public API
│   │   ├── ibkr_ffi.erl     # IB Erlang FFI (curl)
│   │   └── ibkr.ex          # IB Elixir wrapper (planned)
│   └── binance/
│       ├── types.gleam      # SourceBar, Interval, decoders
│       ├── binance_ffi.erl  # Binance Erlang FFI (curl)
│       └── binance.gleam    # Binance public API
├── binance_test.gleam       # Binance integration test
└── ib_test.gleam            # IB integration test
```

## Testing

```bash
# Binance (works from China, no VPN needed)
gleam run -m binance_test

# IB (requires Client Portal Gateway running on localhost:5001)
gleam run -m ib_test
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam build # Build the project
```

## Stream Processing (Phase 3)

The `Timeframe` module (`src/glibe/timeframe.gleam`) implements the streaming data pipeline per the design in glib's `DESIGN.md` and `NAMING.md`.

### Two Top-Level Functions

1. **`sourcebar_gate(timeframe, sourcebar) -> #(Option(DataBar), Timeframe)`**
   - Only function that touches `SourceBar`
   - Folds incoming `SourceBar`s into `working_databar` until bucket ends
   - Returns `Some(closed_databar)` when bucket completes, `None` otherwise
   - Decision `bucket_ends` uses only timestamp + interval (no chicken-egg problem)

2. **`databar_processing(timeframe, databar, settings) -> Timeframe`**
   - Super function in Timeframe module, holds no arithmetic
   - Calls indicator steps in dependency order: SMA → KDJ → Bollinger
   - Ends with `accept` putting finished bar into `databar_list` (newest-first)

### Indicators

| Indicator | Method | Key Properties |
|-----------|--------|----------------|
| **SMA series** (Tiny/Small/Medium/Large) | Three cases by list length: empty → close; warm-up → true mean `(held*prev+close)/(held+1)`; full → incremental `(size*prev+close-leaving)/size` | Always divides by window size; leaving bar via `list.drop(size-1)` |
| **KDJ** | LLV/HHV batch over `window_kdj_size` (9) window; RSV → K/D/M via approximate incremental SMA | `M = SMA(K, 10)` fixed; K/D periods configurable; RSV window = `window_kdj_size` |
| **Bollinger** | Uses selected SMA as centre (`sma_for_bbm`); σ from `databar_list` window; Fibonacci ratios 0.382/0.618/1.0 | σ divisor = actual window count (warm-up safe); lower bands floored at 0.001/0.0001/0.00001 |

### Data Flow

```
SourceBar → sourcebar_gate → working_databar (Option) 
  → bucket closes → databar_processing 
    → indicator(databar, timeframe, settings) 
      → sma() ×4 → kdj() → bollinger() 
    → accept() → databar_list (newest-first)
```

### Timeframe Structure

```gleam
pub type Timeframe {
  Timeframe(
    symbol: String,
    interval: Interval,
    market_type: MarketType,
    working_databar: Option(DataBar),  // None after close until next source bar
    databar_list: List(DataBar),       // newest-first
  )
}
```

### Settings (from `settings.json`)

```json
{
  "sma_tiny_window_size": 7,
  "sma_small_window_size": 70,
  "sma_medium_window_size": 140,
  "sma_large_window_size": 252,
  "window_kdj_size": 9,
  "kdj_k_period": 3,
  "kdj_d_period": 2,
  "bb_multiplier": 1.99,
  "sma_for_bbm": "sma_medium",
  "branch_exit_leaf_size": 40
}
```

One block per interval (multiple intervals run simultaneously).

### Usage

```gleam
let settings = TimeframeSettings(...)
let tf = Timeframe.new("BTCUSDT", H1, Crypto, settings)

// In data loop:
let #(closed, tf) = Timeframe.sourcebar_gate(tf, source_bar)
case closed {
  None -> tf  // bucket still open
  Some(databar) -> Timeframe.databar_processing(tf, databar, settings)
}
```

### Module Split

The stream processing logic is split into focused modules:

| Module | Responsibility |
|--------|----------------|
| `indicator_settings.gleam` | Shared types: `SmaSeries`, `SmaForBbm`, `TimeframeSettings` |
| `sma.gleam` | SMA series (Tiny/Small/Medium/Large) with three-case incremental logic |
| `kdj.gleam` | KDJ oscillator (LLV/HHV batch + incremental SMA for K/D/M) |
| `bollinger.gleam` | Bollinger Bands (selected SMA centre, σ from window, Fibonacci ratios) |
| `indicator.gleam` | Pipeline composition: SMA×4 → KDJ → Bollinger |
| `timeframe.gleam` | Timeframe type + `sourcebar_gate` + `databar_processing` |

Dependency graph (no cycles):
```
indicator_settings → sma, kdj, bollinger → indicator → timeframe
```

### Bias (Future)

Bias calculation for SMA series is commented in `sma.gleam`:
```gleam
// bias = 100 * (close - sma) / sma (can be positive or negative)
// let bias = case mean >. 0.0 { True -> {working.close -. mean} /. mean *. 100.0; False -> 0.0 }
// set_bias_of(working, name, bias)
```
Bias field names follow SMA naming (`sma_tiny_bias`, `sma_small_bias`, etc.) — just uncomment when bias fields are added to `DataBar`.

## Roadmap

See `.planning/ROADMAP.md` for detailed phases:
- Phase 1: IB Foundation ✅
- Phase 2: Binance API ✅
- Phase 3: Stream Processing (SMA, Bollinger, KDJ, Fractal)
- Phase 4: Strategy & AI
- Phase 5: Integration & Examples

## License

MIT
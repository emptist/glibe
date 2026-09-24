# Handoff — Phase 3 Stream Processing: Indicators + Leaf/Branch Complete

## What Was Done

### Core Types (Split from monolithic types.gleam)
- `api.gleam`: SourceBar, Interval, MarketType (Stock/Crypto/BStock), JSON decoders
- `databar.gleam`: DataBar with all indicator fields
- `indicators.gleam`: SmaSeries, SmaForBbm, TimeframeSettings, BollingerBands, KDJ

### Market Types (api.gleam)
| MarketType | Trading | Calendar | Key Features |
|------------|---------|----------|--------------|
| `Stock` | RTH 09:30-16:00 ET | NYSE | Direct ownership, voting rights |
| `Crypto` | 24/7 | continuous | Native assets (BTC, ETH) |
| `BStock` | 24/7 | continuous | 1:1 tokenized US equities, dividends via multiplier_rebase, 30% withholding, convert 1:1 during US RTH |

### Indicators (Ported from glib)
- **SMA series**: Tiny/Small/Medium/Large with 3-case incremental logic (empty → close, warm-up → true mean, full → incremental with leaving bar)
- **KDJ**: LLV/HHV batch over window_kdj_size; RSV → K/D/M via SMA (not RMA)
- **Bollinger**: Selected SMA centre, σ from window, Fibonacci ratios 0.382/0.618/1.0
- **Pipeline**: SMA×4 → KDJ → Bollinger (indicator.gleam)

### Leaf Detection (DESIGN.md §4-5)
- `DataLeaf`: YinLeaf/YangLeaf with start_idx, end_idx, corner_idx
- Streaming: update_yin_leaf/4, update_yang_leaf/4 returning (Option(closed), updated, cma)
- CMA = running mean of sma_tiny within leaf (incremental from previous bar's cma)
- Index logic: global indices, count-back for newest-first list

### Branch Detection (DESIGN.md §6)
- `DataBranch`: YinBranch/YangBranch with start_idx, end_idx, corner_idx, exit_idx
- Streaming: update_yin_branch/5, update_yang_branch/5
- All 9 branch laws implemented (length-based continuation, retrospective recognition)

### Timeframe Pipeline
```
sourcebar_gate → indicator.run → leaves → branches → strategy_signal → runtime_test → accept
```
- 4 leaf fields + 4 branch fields added to Timeframe
- strategy_signal: manual/AI/hybrid strategy after all structural facts
- runtime_test: backtest/forward-test hook before commit

## Build Status
- `gleam build` passes cleanly (zero warnings)
- IB dependency disabled (websockex incompatibility) — use Binance for testing

## What's Next (Remaining Phase 3)

### 1. Binance Live Feed Integration
- Extend `binance.gleam` to stream klines (WebSocket or polling) for Crypto + BStock symbols
- Feed `SourceBar` into `Timeframe.sourcebar_gate`

### 2. Tests
- Unit tests: SMA 3-case logic, KDJ LLV/HHV, Bollinger σ
- Property tests: leaf/branch index invariants (global ↔ count-back)
- Integration: Binance klines → Timeframe → leaves/branches → CSV verify

### 3. CSV Export Verification (Done)
- `Timeframe.to_csv/1` outputs all indicators for TradingView

## Files to Work With
- `test/` — to create
- `src/glibe/binance/binance.gleam` — extend for streaming (Crypto + BStock symbols)

## Verification
- `gleam build` must pass
- `gleam test` must pass
- Follow same index patterns (global indices, count-back access)
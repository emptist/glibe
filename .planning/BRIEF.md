# Brief: glibe - Erlang/Elixir Trading Library with IB API

## Vision

`glibe` is the Erlang/Elixir-target evolution of `glib`. It provides Interactive Brokers API access as a native data source for BEAM-based trading systems.

## Architecture

```
┌─────────────────────────────────────────┐
│         Business Logic (Gleam)          │
│   Stream processing, strategies, AI     │
└─────────────────┬───────────────────────┘
                  │ calls
┌─────────────────▼───────────────────────┐
│         IB API Wrapper (Elixir)         │
│   Auth, Market Data, Orders, Portfolio  │
│   Uses: ibkr_api, Finch, Jason          │
└─────────────────┬───────────────────────┘
                  │ HTTP/WS
┌─────────────────▼───────────────────────┐
│      Client Portal Gateway (Java)       │
│   localhost:5001, SSL, REST + WebSocket │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│       Binance API Client (Gleam)        │
│   Market Data: klines, ticker, exchange │
│   Uses: gleam_httpc, gleam_http         │
└─────────────────┬───────────────────────┘
                  │ HTTPS
┌─────────────────▼───────────────────────┐
│      Binance REST API (testnet)         │
│   testnet.binance.vision, public endpoints │
└─────────────────────────────────────────┘
```

## Current State

- **Client Portal Gateway**: Running on port 5001, authenticated, live account
- **ibkr_api** (Elixir): Available as dependency, wraps Client Portal REST API
- **TWS socket approach**: Abandoned — too complex to debug from scratch
- **glib porting**: Deferred until glib itself matures
- **Stream processing**: Removed (will be ported from glib in Phase 3)

## API Approach

- **IB Client Portal REST API** via `ibkr_api` Elixir library
- **Gateway runs locally** (Java), proxies to IB servers
- **REST for**: accounts, positions, orders, contract search, historical data
- **WebSocket for**: real-time market data streaming (future)
- **Binance Public REST API** via `gleam_httpc` (pure Gleam)
- **Testnet**: testnet.binance.vision (production blocked in this env)

## Scope (v1.0)

IB API wrapper + Binance public API only. No glib porting yet.

## Language Split

| Layer | Language | Why |
|-------|----------|-----|
| IB API Client | Elixir | `ibkr_api`, Finch, Jason ecosystem |
| IB FFI Bridge | Gleam → Elixir | Type-safe Erlang interop |
| Binance API Client | Gleam | `gleam_httpc`, pure Gleam HTTP |
| Business Logic | Gleam | Type safety, pure functions, pattern matching |

## What Will Be Ported (Future)

When glib matures:
- `types.gleam` → core types
- `stream/*.gleam` → indicators (SMA, Bollinger, KDJ, fractal)
- `trading/strategy.gleam` → strategy logic
- `execution/*.gleam` → risk management, execution
- `ai/*.gleam` → analogical reasoning, ensemble, regime

## Success Criteria (v1.0)

1. Gateway connection works from Elixir via ibkr_api
2. Account data retrievable
3. Market data snapshots work
4. Historical data retrievable
5. Order placement works
6. Clean API surface for future business logic integration
7. Binance klines/ticker/exchange_info work via gleam_httpc
8. No curl shell-outs, no hand-rolled JSON, no FFI Erlang files
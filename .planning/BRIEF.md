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
│      IB API Wrapper (Elixir)            │
│   Auth, Market Data, Orders, Portfolio  │
│   Uses: ibkr_api, Finch, Jason          │
└─────────────────┬───────────────────────┘
                  │ HTTP/WS
┌─────────────────▼───────────────────────┐
│      Client Portal Gateway (Java)       │
│   localhost:5001, SSL, REST + WebSocket │
└─────────────────────────────────────────┘
```

## Current State

- **Client Portal Gateway**: Running on port 5001, authenticated, live account
- **ibkr_api** (Elixir): Available as dependency, wraps Client Portal REST API
- **TWS socket approach**: Abandoned — too complex to debug from scratch
- **glib porting**: Deferred until glib itself matures

## API Approach

- **Client Portal REST API** via `ibkr_api` Elixir library
- Gateway runs locally (Java), proxies to IB servers
- REST for: accounts, positions, orders, contract search, historical data
- WebSocket for: real-time market data streaming (future)

## Scope (v1.0)

IB API wrapper only. No glib porting yet.

## Language Split

| Layer | Language | Why |
|-------|----------|-----|
| IB API Client | Elixir | `ibkr_api`, Finch, Jason ecosystem |
| Business Logic | Gleam | Type safety, pure functions, pattern matching |
| FFI Bridge | Erlang | Call Elixir from Gleam |

## What Will Be Ported (Future)

When glib matures:
- `types.gleam` → core types
- `stream/*.gleam` → indicators (SMA, Bollinger, KDJ, fractal)
- `trading/strategy.gleam` → strategy logic
- `execution/*.gleam` → risk management, execution
- `ai/*.gleam` → analogical reasoning, ensemble, regime

## Success Criteria (v1.0)

1. Gateway connection works from Elixir
2. Account data retrievable
3. Market data snapshots work
4. Historical data retrievable
5. Order placement works
6. Clean API surface for future business logic integration
# glibe_web - Phoenix LiveView Visualization

Real-time visualization for glibe stream processing using Phoenix LiveView + Lightweight Charts.

## Setup

```bash
cd apps/glibe_web
mix deps.get
mix assets.setup
mix phx.server
```

Then open http://localhost:4000

## Features

- Live candlestick chart with Lightweight Charts (TradingView OSS)
- SMA Tiny / Medium overlay lines
- Yin/Yang leaf markers (green/red arrows)
- Yin/Yang branch markers (circles with entry/exit indices)
- Real-time updates via Phoenix PubSub
- REST API endpoints for data export

## Architecture

```
Gleam (glibe)          Elixir (Phoenix)           Browser
─────────────────      ─────────────────         ─────────────
Timeframe              DataGenerator              Lightweight
  │                        │                         │
  │ databar_list          │                         │
  ├──────────────────────►│                         │
  │                       │ WebSocket push          │
  │                       ├────────────────────────►│
  │                       │                         │ chart.update(bars)
```

## API Endpoints

- `GET /api/bars` - All bars as JSON
- `GET /api/leaves` - All leaves as JSON
- `GET /api/branches` - All branches as JSON

## LiveView

- `/` - Main chart dashboard
- `/chart` - Chart only
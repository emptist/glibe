# State — glibe

Measured facts. Each line carries the day it was taken, so a later reader can
tell a measurement from an intention.

## 2026-10-04

| axis | value | how it was taken |
|---|---|---|
| build | clean, **0 warnings** | `gleam build` (gleam 1.18.1, OTP 29, erl/erlc/escript at `/opt/homebrew/bin`) |
| tests that run | **23 pass, 0 fail** | `gleam test` — 19 original bodies + 4 ingest-boundary tests |
| format | clean | `gleam format --check` |
| guards | **3 scripts, all green** | `sh scripts/guards.sh --all` |
| unwritten `DataBar` fields | **0** | deleted in `databar.gleam`; every remaining field is written by a module |
| module purity | enforced by a script | `scripts/no_timeframe_mixture.sh` |
| interval codec | present | `api/interval.gleam` `to_string` / `from_string` / `all()` |
| ingest boundary | present | `api/sourcebar.gleam` `validate` + `normalize_date` |

**Not taken here (environment):** CI (`.github/workflows/test.yml`) pins
gleam 1.16.0 / OTP 28. The download could not be fetched (no network in the
sandbox), so the pinned-version build is unverified. The guards scripts default
`GLEAM` to `/opt/homebrew/bin/gleam` for the same reason.

**Lagging glib on this day (open, see `QUESTIONS.md`):**
KDJ window is `w+1` (glib `w`); D uses alpha ½ (glib's is dead); σ excludes the
bar in hand; lower bands still clamped; `kdj_d_period` still a field;
`window_kdj_size` not yet renamed to `kdj_window_size`. These are Stage D, next.

## What "green" means

A stage is done only when all three are true: `gleam build` clean, `gleam test`
green, and `sh scripts/guards.sh --all` green. A stage that cannot be verified
is not done — that rule is why the guard scripts exist before the work they
guard.

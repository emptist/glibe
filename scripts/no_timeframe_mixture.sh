#!/bin/sh
# The mechanism behind the module-purity ruling (IMPROVEMENT-PLAN-2026-10-04,
# Stage B). glib is still arguing with itself about which functions belong in
# timeframe.gleam; glibe ends the argument by forbidding it:
#
#   1. timeframe.gleam holds the state record, its birth (new), and nothing
#      else. Every function that *moves* a Timeframe belongs in engine.gleam.
#   2. Exactly one module declares `pub type Timeframe`.
#
# A principle without a mechanism is decoration. This is the mechanism.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
TIMEFRAME="src/glibe/timeframe.gleam"

# 1. Allowed functions in timeframe.gleam: new. Anything else is the mixture
#    coming back and must fail the build.
VIOLATIONS="$(grep -E '^pub fn |^fn ' "$TIMEFRAME" | grep -v '^pub fn new(' || true)"
if [ -n "$VIOLATIONS" ]; then
  echo "timeframe.gleam holds functions that belong in engine.gleam:" >&2
  echo "$VIOLATIONS" >&2
  exit 1
fi

# 2. Only timeframe.gleam may declare the Timeframe type.
DECLARERS="$(grep -rl '^pub type Timeframe {' src || true)"
if [ "$DECLARERS" != "$TIMEFRAME" ]; then
  echo "pub type Timeframe is declared in more than one place:" >&2
  echo "$DECLARERS" >&2
  exit 1
fi

echo "no_timeframe_mixture: ok"

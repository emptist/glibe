#!/bin/sh
# Run every guard that has a subject. A guard with nothing to check is skipped,
# not failed.
#
#   sh scripts/guards.sh            # runs --all
#   sh scripts/guards.sh --all
#   sh scripts/guards.sh no_timeframe_mixture.sh
#
# GLEAM defaults to /opt/homebrew/bin and can be overridden:
#   GLEAM=/opt/homebrew/bin/gleam sh scripts/guards.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

run_guard() {
  guard="$1"
  if [ ! -f "$ROOT/scripts/$guard" ]; then
    echo "unknown guard: $guard" >&2
    exit 1
  fi
  echo "== $guard =="
  sh "$ROOT/scripts/$guard"
}

case "$1" in
  --all|"")
    run_guard compiles.sh
    run_guard no_timeframe_mixture.sh
    run_guard no_foreign_source.sh
    run_guard test_guards.sh
    ;;
  *)
    run_guard "$1"
    ;;
esac

echo "guards: all green"

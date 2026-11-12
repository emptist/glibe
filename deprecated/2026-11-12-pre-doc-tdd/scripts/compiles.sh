#!/bin/sh
# Build, test and format-check glibe. Exits non-zero on the first failure.
#
# The managed toolchain lives at /opt/homebrew/bin and is not on WorkBuddy's
# sandbox PATH, so GLEAM defaults there and can be overridden:
#   GLEAM=/opt/homebrew/bin/gleam sh scripts/guards.sh --all
set -e
GLEAM="${GLEAM:-/opt/homebrew/bin/gleam}"
# gleam build/test shell out to erlc/escript; expose the bin dir that holds
# GLEAM so the Erlang toolchain is on PATH too.
GLEAM_BIN="$(dirname "$GLEAM")"
export PATH="$GLEAM_BIN:$PATH"
cd "$(dirname "$0")/.."

echo "== build =="
"$GLEAM" build

echo "== test =="
"$GLEAM" test

echo "== format =="
"$GLEAM" format --check

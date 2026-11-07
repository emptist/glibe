#!/bin/sh
# Permanent negative tests for the guards, over throwaway fixture trees.
#
# This replaces the old mutation probe ("write deliberately broken code into
# src/, watch the guard go red, then remove it"): the real source tree is never
# touched, every negative case is a fixture in a temp directory, and the
# expected red/green result is asserted here. No broken code ever lives in the
# repository, not even for a moment.
#
# The guard scripts derive ROOT from their own location, so copying them into a
# fixture tree makes them inspect that tree. No guard needs a test-only branch.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d /tmp/glibe_guard_fixture.XXXXXX)"
trap 'case "$TMP" in /tmp/glibe_guard_fixture.*) rm -rf -- "$TMP";; esac' EXIT

mkdir -p "$TMP/scripts"
cp "$ROOT/scripts/no_foreign_source.sh" "$ROOT/scripts/no_timeframe_mixture.sh" "$TMP/scripts/"

reset_fixture() {
  rm -rf -- "$TMP/src" "$TMP/gleam.toml"
  mkdir -p "$TMP/src/glibe"
  printf 'name = "fixture"\nversion = "1.0.0"\ntarget = "erlang"\n' > "$TMP/gleam.toml"
  printf 'pub type Timeframe {\n  Timeframe(x: Int)\n}\n\npub fn new(x: Int) -> Timeframe {\n  Timeframe(x)\n}\n' > "$TMP/src/glibe/timeframe.gleam"
}

run_fixture_guard() {
  sh "$TMP/scripts/$1" > "$TMP/out" 2>&1
}

expect_pass() {
  label="$1"
  guard="$2"
  if run_fixture_guard "$guard"; then
    echo "  ok    $label"
  else
    echo "test_guards: expected PASS but got FAIL: $label" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
}

expect_fail() {
  label="$1"
  guard="$2"
  needle="$3"
  if run_fixture_guard "$guard"; then
    echo "test_guards: expected FAIL but got PASS: $label" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
  if ! grep -Fq "$needle" "$TMP/out"; then
    echo "test_guards: failure did not name '$needle': $label" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
  echo "  ok    $label"
}

# --- positive controls ----------------------------------------------------
reset_fixture
expect_pass "clean tree — no_foreign_source" no_foreign_source.sh
expect_pass "clean tree — no_timeframe_mixture" no_timeframe_mixture.sh

# --- no_foreign_source.sh -------------------------------------------------
reset_fixture
printf 'export function f() {}\n' > "$TMP/src/escape.mjs"
expect_fail "a hand-written .mjs under src/" no_foreign_source.sh "escape.mjs"

reset_fixture
printf '@external(javascript, "./x.mjs", "f")\npub fn f() -> Nil { Nil }\n' > "$TMP/src/escape.gleam"
expect_fail "an @external(javascript, ...) under src/" no_foreign_source.sh "@external(javascript"

reset_fixture
printf 'target = "javascript"\n' >> "$TMP/gleam.toml"
expect_fail "gleam.toml declaring the javascript target" no_foreign_source.sh "declares the javascript target"

# --- no_timeframe_mixture.sh ----------------------------------------------
reset_fixture
printf 'pub fn extra() -> Nil { Nil }\n' >> "$TMP/src/glibe/timeframe.gleam"
expect_fail "timeframe.gleam gaining a second function" no_timeframe_mixture.sh "holds functions that belong"

reset_fixture
printf 'pub type Timeframe { Timeframe(y: Int) }\n' > "$TMP/src/glibe/engine.gleam"
expect_fail "a second module declaring pub type Timeframe" no_timeframe_mixture.sh "declared in more than one place"

echo "test_guards: 7 cases passed — fixtures only, real src/ untouched"

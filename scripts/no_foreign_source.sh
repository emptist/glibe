#!/bin/sh
# Guard: the engine's src/ is Gleam and nothing else.
#
# *"No handwritten erlangs or even worse JS source files, keep the system
# clean and beautiful!"* [user 2026-11-07]
# *"target erlang 无需手写任何erlang代码，无需ffi，ffi是JS专属的"*
# [user 2026-11-01, glib RULINGS.md §1.28]
#
# On BEAM the compiler emits .beam directly; the only generated .erl is the
# `@@main` runner stub inside build/, never a file a human writes. A .mjs/.js
# under src/ means someone escaped Gleam again. This guard is the mechanism
# that makes the ruling fail loudly instead of decaying into prose.
#
# Scope: src/ — the engine. `apps/glibe_web` is a separate Phoenix app and is
# tracked as debt in docs/REVIEW_ROUND5.md; it is a decision for the owner,
# not something this guard silently forgives.
# `*.disabled` files are retired design records, not compiled source.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

found="$(
  find src -type f \( \
    -name '*.erl' -o -name '*.hrl' -o -name '*.ex' -o -name '*.exs' \
    -o -name '*.mjs' -o -name '*.js' -o -name '*.ts' \
  \) -print
)"

if [ -n "$found" ]; then
  echo "no_foreign_source: handwritten foreign source under src/:" >&2
  echo "$found" >&2
  echo "Write it in Gleam. BEAM needs no FFI file from your hand." >&2
  exit 1
fi

echo "no_foreign_source: clean — src/ is Gleam only"

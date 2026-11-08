//// The web client — a separate Gleam package compiled to JavaScript.
////
//// **Why a web front end exists at all (owner, 2026-11-07):** a human needs
//// to see the program's output, not read its logs. It is for spotting anomalies
//// and logic errors by eye; reading price trends from charts to form trading
//// ideas; inspecting non-graphical but tabulated fractal-structure data to
//// research market behaviour and new manual strategies; and seeing where an
//// order was issued and where it was filled. A Gleam GUI would be harder to
//// build than this.
////
//// **Why it is in its own folder, following the Lustre-style split:** the
//// engine is BEAM/Erlang target; a browser client is JavaScript target. Two
//// packages, two `gleam.toml` files, two targets — the build tool declares the
//// boundary, so no shell guard has to police file extensions.
////
//// The Phoenix app in `deprecated/glibe_web` is NOT this package's
//// implementation. It is kept for comparison when choosing web technology.
////
//// **Rule for this folder:** prefer Gleam source that compiles to .mjs.
//// A hand-written .mjs is allowed only here, and only if generation is
//// genuinely impractical. Nothing in `src/` may contain one.
////
//// **Local time in this view (R30, 2026-11-09).** The web interface shows
//// date-times in the analyst's LOCAL time so bars can be read while
//// analysing; that necessarily means time-zone conversion and daylight
//// saving. This package is one of the two candidate display edges. If the
//// time-bearing view is built here, convert the standard bar's absolute
//// unix-time instant (R27) using an IANA zone name through the browser
//// runtime's time-zone support — never a fixed numeric offset, never a
//// hand-written DST table. The instant itself, the UTC-aligned bucket grid
//// and the UTC RFC3339 CSV export stay unchanged. The full specification,
//// the split between the R29 market-calendar side and the R30 display side,
//// and the BEAM-side `tzif` 2.0.0 option are in `src/glibe/web/server.gleam`;
//// plan `.planning/phases/04-domain-cleanup/04-07-PLAN.md` owns the
//// implementation. This round adds documentation only.

pub fn main() -> Nil {
  Nil
}

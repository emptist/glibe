//// The one Value the system starts from. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: `Desk`.
//// WRITES: no type. This module has NO type of its own: the whole
//// configuration IS one `Desk` value.
////
//// R33 (owner, verbatim): *"Desk是顶层的唯一的一个Value，整个系统都在他里面，
//// 然后逐层嵌套，形成完整系统"*; and R33 names `config.default_config()`
//// as that one Value. R42: *"但是他上面不再有东西"* — nothing sits above
//// `Desk`, so there is no `AppConfig` wrapping it, no second dictionary
//// and no settings table. R23 struck the composite-string key tables
//// (`"BTCUSDT_H1"`, `list.find`, `get_symbol`, `config_get_tfs`).
////
//// Core §2.7: data already written as Gleam source needs no parser. A
//// constructor literal is the config; `from_string` + `panic` over a file
//// we own would be a parser for a language we already speak.
////
//// R19 status: skeleton. Body is `todo as "..."`; no working line here.

import glibe/desk.{type Desk}

/// The one top-level Value. A constructor literal, not a parsed config.
pub fn default_config() -> Desk {
  todo as "05-01: one Desk value, with nothing above it"
}

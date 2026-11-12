//// The one Value the system starts from. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: `Desk`.
//// WRITES: no type. This module has NO type of its own: the whole
//// configuration IS one `Desk` value.
////
//// R33 (owner, verbatim): *"Desk是顶层的唯一的一个Value，整个系统都在他里面，
//// 然后逐层嵌套，形成完整系统"*; R42: *"但是他上面不再有东西"* — nothing
//// sits above `Desk`, so there is no `AppConfig` wrapping it, no second
//// dictionary and no settings table.
////
//// `default_config` comes from this project's own R33 RULING TEXT (AI
//// prose), NOT from the owner's verbatim quote above: R33's quoted words
//// name `Desk` as the one Value and name no function at all (R46 / R47
//// word-source rule). R23 struck the composite-string key tables
//// (`"BTCUSDT_H1"`, `list.find`, `get_symbol`, `config_get_tfs`); R46
//// struck the settings concept. This function never took a settings
//// parameter — measured in R46's diff — and takes none now. R49: no
//// `new`-style birth function; this one says which configuration it is.
////
//// Core §2.7: data already written as Gleam source needs no parser. A
//// constructor literal is the config; `from_string` + `panic` over a file
//// we own would be a parser for a language we already speak.
////
//// R19 status: skeleton; the body is `todo as "..."`.

import glibe/desk.{type Desk}

/// Returns the one top-level `Desk` Value. Its body is a Gleam literal of
/// that Value — no parser, no `new`-style birth function (core §2.7, R49).
pub fn default_config() -> Desk {
  todo as "05-01: one Desk value, with nothing above it"
}

//// N addressed bars, N BEAM processes, no actor, no supervisor, no lock.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-09-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R19 (docs-first / TDD), R26 (no speculative
//// relations), R27 / R28 (the standard bar carries no provider identity),
//// R31 (Erlang / BEAM concurrency is `process.spawn` + a typed `Subject`).
////
//// **What this measures.** Owner 2026-11-09: *"gleam语言呀，是天然多线程，
//// 好像不需要actor那些东西 … 非常简单啊非常自然。因为他是一个一个严格的
//// value，完全不住在内存里，所以根本没有那些复杂的补救措施需要做"*.
//// `monitor.advance` is already a pure step from one `Desk` to a new `Desk`.
//// The question is not whether many bars can run at once — the official
//// `gleam_erlang/process.spawn` + typed `Subject` is three lines — but what
//// the N returned `Desk` values MEAN. Each is a partial view: it advanced
//// exactly one address and left the other five at their original state.
//// There is no shared memory to lock, but there is an OWNERSHIP decision:
//// either one owner folds the steps into one `Desk`, or each address owns its
//// own `Timeframe`. That is a data-flow shape, not a synchronisation device.
////
//// **Scope.** Erlang / BEAM only (owner 2026-11-09 06:09: *"你去看什么
//// javascript target完全不对路，我们是erlang 和 BEAM专属项目"*). This probe
//// imports no `gleam_otp` module, starts no actor and no supervisor, and
//// uses no lock, mutex, ETS or FFI. Nothing here is production code.

import gleam/erlang/process
import glibe/desk
import glibe/monitor

/// One reply from ONE spawned BEAM process: which address it computed,
/// which process did the work, and the pure result it produced.
/// `worker` is a `Pid`, not a name or a string — the compiler cannot confuse
/// it with a bar, a subject or another reply.
pub type StepReply {
  StepReply(
    address: monitor.TimeframeAddress,
    worker: process.Pid,
    outcome: Result(desk.Desk, monitor.MonitorError),
  )
}

/// The six configured `Timeframe` addresses, each paired with one well-formed
/// bar. Every bar is valid on its own; only the ADDRESS differs.
pub fn sample_arrivals() -> List(monitor.IncomingBar) {
  todo as "04-09: build six addressed bars from config.default_config()"
}

/// Run every arrival in its OWN BEAM process and collect all typed replies.
/// One `Subject` owned by the caller receives them; `Error(Nil)` means a
/// worker did not answer within the timeout.
pub fn advance_in_parallel(
  initial: desk.Desk,
  arrivals: List(monitor.IncomingBar),
) -> Result(List(StepReply), Nil) {
  todo as "04-09: spawn one process per arrival and collect the typed replies"
}

/// Apply every arrival to ONE `Desk`, in arrival order. This is the
/// single-owner shape: no merging of partial `Desk` values is needed.
pub fn advance_in_order(
  initial: desk.Desk,
  arrivals: List(monitor.IncomingBar),
) -> desk.Desk {
  todo as "04-09: fold pure steps into one Desk"
}

/// A readable name for an address, for the probe's printed report only.
pub fn describe(address: monitor.TimeframeAddress) -> String {
  todo as "04-09: render the three typed keys"
}

/// Print the measured process ids and the isolation result.
pub fn main() -> Nil {
  todo as "04-09: print the measured process ids and isolation"
}

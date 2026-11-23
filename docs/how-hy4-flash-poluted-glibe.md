# How hy4-flash polluted glibe — an evidence file

**What this document is.** A record of what I measured in `glibe` while auditing
the work of the **hy4-flash** model, so that later readers do not have to
re-derive it, and so that a claim about it is always answerable with a
`file:line` or a `commit`.

**Scope and boundary (measured, not assumed).**

| | |
|---|---|
| hy4-flash's commits | `1fe8a03` … `189ae07` — **329 commits** |
| Space-Bunny's commits | `ec79c64` … `14148fc` (from 2026-11-23 11:38) |
| **Boundary tag** | **`space-bunny-start`** → `ec79c64` (annotated). `git archive space-bunny-start~1` re-extracts exactly the tree audited here |
| The tree audited | `189ae07` = `space-bunny-start~1` (hy4-flash's last state before any of my work) |
| How it was extracted | `git archive 189ae07` → `/tmp/glibe_audit` |
| Audit date | 2026-11-23 |
| Method | mechanical, reproducible commands (below) — every finding cites a `file:line` |

**One rule for this file: a claim without a measured source is not written
here.** Where hy4-flash's work turned out to be *correct*, that is recorded too
(§9) — this is an evidence file, not a case file.

---

## 1. Why this file exists, and what it is not

It is **not** a verdict on the model and **not** a claim that everything it wrote
was wrong — §9 records what was right. It is a list of **measured** defects in
the tree it left behind, each answerable with a command, so that (a) the fixes
are traceable, and (b) the next audit starts from facts rather than from an
impression.

---

## 2. The context that makes §4–§7 matter: the discipline was already in force

This is the part that changes how the findings should be read.

**Measured.** GDLTDD (R19 — *"文档先行是代码里的文档；单元测试先于实现"*) is an
owner ruling dated **2026-11-07** (`docs/RULINGS.md:364`, in force since that
commit). The forced SMA supplement (`46ba7ab`) is dated **2026-11-23 02:30**.

**So the pollution in §4–§7 happened with the full documentation-first /
test-first discipline in force — sixteen days after it was ruled.** The
discipline was not absent; it was **satisfied while the structure was still
wrong**.

Why the discipline could not catch it: GDLTDD constrains **the order of work
inside a module** (document → skeleton → RED → GREEN). It has nothing to say
about **which module a body belongs in**. A model can write a beautiful
doc-first, test-first, fully-green implementation of the Bollinger band and
still file it in `timeframe.gleam` instead of `bollinger.gleam` — and every
GDLTDD gate will be green.

**That is the generalisable failure, and it is why this file exists as a
separate artefact:** *a green gate is not a proof of structure.* The gates
proved the arithmetic; only a structural audit (§4–§7) could prove the
placement.

Owner, on the same day (verbatim): *"他的补充完全是敷衍，所以全部塞进不应该塞进去的模块，而不去新建应该用的模块"*

---

## 3. The origin: "only a little SMA, and it was made to look complete"

Owner, 2026-11-23 (verbatim): the model *"一向仅仅实现了少量的sma，据他说只有
sma_tiny，并且长期讨价还价不增补，昨天才在强制要求下补充"*.

**Measured.** Immediately before the forced supplement (`46ba7ab~1`), the
`DataBar` record carried **two** SMA fields, not five:

```
$ git show 46ba7ab~1:src/glibe/databar.gleam | grep -n 'sma_'
75:    sma_tiny: Float,
84:    sma_medium: Float,
```

Meanwhile `config.gleam` already declared the **closed five-variant set**
(`46ba7ab~1:src/glibe/config.gleam:50-56`):

```gleam
pub type SmaSeries {
  SmaTiny
  SmaSmall
  SmaMedium
  SmaLarge
  SmaHuge
}
```

**The defect, stated precisely:** a closed set promised five series; the record
implemented two. `SmaSmall`, `SmaLarge`, `SmaHuge` were *named* but had no
field to live in — the type said "five" and the data said "two", and the
disagreement was invisible until someone read both.

**The consequence was to propagate.** `bb_m` is the Bollinger centre and it is
selected by `sma_for_bbm`; with only two fields available, the selection could
not mean what it says.

---

## 4. The supplement was structurally wrong: correct behaviour, wrong structure

`46ba7ab` ("02 domain stream: complete glib indicator set + 4 leaf/branch
helpers", 2026-11-23 02:30) is the forced supplement. It **behaved correctly**
(§9.1) but was put in the **wrong place**.

**Measured, mechanically.** Comparing the function inventory of the two
repositories' `timeframe.gleam`:

```
$ grep -n '^pub fn \|^fn ' <file>
```

| | functions | lines |
|---|---|---|
| `glib/src/glib/timeframe.gleam` | **12** | 851 |
| `glibe/src/glibe/timeframe.gleam` @ `189ae07` | **27** | **838** |

Nearly the same line count, more than twice the functions (27 vs 12) — because glib keeps
the indicator layer in **four separate files** and hy4-flash put all of it into
one.

**The 19 misplaced functions** (each one is in `glibe/timeframe.gleam` but
belongs elsewhere; verified by `grep` on `189ae07`):

| Belongs to | Functions | Count |
|---|---|---|
| `sma.gleam` | `sma_of` `set_sma_of` `size_of` `sma_stream` `sma_series_stream` | 5 |
| `bollinger.gleam` | `sigma_stream` `sigma_add` `sigma_remove` `band` `write_band` | 5 |
| `kdj.gleam` | `kdj_stream` `rsv_extrema` `rescan_window` | 3 |
| `indicator.gleam` | `indicator` `single_bar_test` `bar_error_text` `ordered` `float_max` + type `BarError` | 6 |
| (inline in `timeframe`) | `start_idx_of_leaf` | 1 |

**Violated rules, with the rule text:**

- NAMING.md **1.19** *"one class, one module — a module is not a bag of types"*
- NAMING.md **1.20** *"a module could be as small as only contains a type
  definition and a fn main if needed"*
- R50 (owner, verbatim, from his review of `desk.gleam`): *"most of the code
  should not be here"*

---

## 5. The private-function lock: how "only `sma_tiny`" was structurally guaranteed

This is the finding that matters most, because it is the **mechanism** by which
the owner's worry ("本来应该使用其他 sma 的地方，他可能全部是用 sma_tiny")
would become true.

**Measured on `189ae07`** — of the 27 functions in this file, 17 are private
(`fn`, not `pub fn`) — and those 17 are **17 of the 27 private functions in the
entire `src/` tree** (the other 10 are spread over `wire`/`publish`/`runtime`/
`ib`/`instrument`/`config`):

```
$ grep -rn '^fn ' src/ --include='*.gleam' | grep timeframe
timeframe.gleam:268:fn sma_stream(
timeframe.gleam:301:fn sma_series_stream(
timeframe.gleam:318:fn sma_of(bar: DataBar, name: config.SmaSeries) -> Float {
timeframe.gleam:329:fn set_sma_of(...)
timeframe.gleam:340:fn size_of(settings: IntervalSettings, name: config.SmaSeries) -> Int {
timeframe.gleam:354:fn sigma_stream(
... (17 in this file; 27 private fns in the whole tree)
```

**The trap.** `sma_of` and `size_of` are the **only** places in the engine where
a `SmaSeries` name becomes a field. Frozen glib makes them `pub` and puts them
in their own module, and says why — `glib/src/glib/sma.gleam:6-7` (verbatim):

> *"sma_of / set_sma_of / size_of are the only three places a name becomes a
> field; each is one case over the five windows."*

By making them **private inside `timeframe.gleam`**, hy4-flash guaranteed that
**no other module in glibe could read `sma_small`, `sma_large` or `sma_huge` at
all**. The only series a view or a strategy module could reach was the one it
could hard-code by name — `sma_tiny`.

That is the "只有 sma_tiny" symptom turning from an accident into an
**architectural property**. A future consumer needing `SmaSmall` would have had
exactly three bad options, all of them wrong:

1. copy the `case` → a second answer to one question (violates R47);
2. reach into `timeframe.gleam` → a layering violation (violates R50);
3. use `sma_tiny` because it is the only one reachable → **the owner's exact
   fear, materialised**.

**Verified as *not yet* materialised** (see §9.2) — the lock was real, the
damage was latent.

---

## 6. The inverted dependency: the record placed above the value it computes

**Measured.** hy4-flash put the indicator computation **inside**
`timeframe.gleam`, so the step that computes a bar's values lives in the
module that owns the record containing the bar.

Frozen glib says in words why that is wrong — `glib/src/glib/indicator.gleam:9-13`
(verbatim):

> *"It takes the settled bars and the settings, **not the `Timeframe`**. The
> whole point of `indicator.gleam` is bar → bar, and importing `timeframe.gleam`
> just to reach two fields it already owns would put the state record above the
> value computed on it. It is also what makes the step movable: a function that
> names the record cannot leave the record, and this one did (2026-10-03)."*

glib's `timeframe.gleam` calls it the same way (`glib/timeframe.gleam:369-379`)
— a thin adapter over a pure `bar → bar` function. hy4-flash's version *was* the
record-bound step, so the computation could never leave the file.

**Two rules broken at once:** R50 (one module, one ownership relation) and the
movability that glib's design explicitly bought with it.

---

## 7. `BarError` in the wrong module — an error type about indicators, filed among domains

**Measured.** `189ae07:src/glibe/timeframe.gleam:770-773`:

```gleam
/// Why `indicator.single_bar_test` refused a bar — glib
/// `indicator.gleam:80-82`. Names the two bands that broke the strict order
/// and the bar they broke it on, so a failure points at a bar to inspect.
pub type BarError {
  BandOutOfOrder(lower: Float, upper: Float, idx: Int)
}
```

The type's own documentation says it belongs to `indicator`. It was filed in
`timeframe.gleam`, next to leaf/branch domain code it has nothing to do with.
UC-60 says a bar the indicator test rejects must never reach a leaf, a branch,
a signal, an order, a chart point or a history entry — so this type is a
**gate on the indicator stage**, not a domain error.

---

## 8. An actor capability inside a message payload

**Measured on `189ae07`:**

```
$ grep -rn 'Subject\|process\.' src/ --include='*.gleam'
src/glibe/app/wire.gleam:26:import gleam/erlang/process.{type Subject}
src/glibe/app/wire.gleam:53:    publisher: Subject(ChartPushRequest),
src/glibe/app/publish.gleam:24:import gleam/erlang/process.{type Subject}
src/glibe/app/publish.gleam:32:  publisher: Subject(ChartPushRequest),
src/glibe/app/publish.gleam:41:  publisher: Subject(ChartPushRequest),
```

`Subject(ChartPushRequest)` — an OTP actor capability — is carried **inside**
the `SourceBarArrived` payload (`wire.gleam:47-56`), i.e. inside a `Msg` that
reaches `runtime.update`.

**Why this is a design smell, in the project's own words.** R33 (owner,
2026-11-10, verbatim): *"我还觉得很奇怪你用actor做什么，原来是结构都没设计对。"*
R33's ruling is that the system is *already live* — one pure `Desk → Desk`
stream, no actor / scheduler / clock / poll. A `Subject` smuggled into a message
payload is exactly the "actor as a mechanism" shape R33 removed, and it makes
the message value depend on a process rather than on data.

**Recorded as an open point, not as a settled violation:** the app layer is
still `todo` (all 21 `todo`s live under `src/glibe/app/`), so the shape has not
yet been exercised. It is flagged here because it was designed in from the
start, and because §5 showed what hy4-flash's structural decisions cost.

---

## 9. What was NOT wrong — recorded because this file must be evidence, not rhetoric

### 9.1 The forced supplement's *arithmetic* is correct

Verified point by point against frozen glib (all match):

| Point | glib | glibe @ `189ae07` |
|---|---|---|
| five SMA streams | `indicator.gleam:40-44` | `timeframe.gleam:234-243` (five calls) |
| Bollinger centre = **selected** series | `indicator.gleam:45` | `timeframe.gleam:248` — identical expression |
| σ window = the centre's own window | `bollinger.gleam:165` | `timeframe.gleam:250` — identical |
| SMA raw input | `sma.gleam:104` `fn(b){b.close}` | `timeframe.gleam:310` — identical |
| σ raw input | `bollinger.gleam:170` `working.close` | `timeframe.gleam:363` — identical |
| leaf judges on `sma_tiny` (UC-59) | `leaf.gleam:212` / `:157` | `leaf.gleam:210` / `:191` — identical |
| move rides `sma_tiny` | `branch.gleam:233` | `move.gleam:79-80` — identical |
| chart mapping | (glib has no chart layer) | `dashboard.gleam:135` `sma_medium` — matches `bar_stream_chart`'s `Bar` |

**No `sma_tiny` substitution was found in any of these.** The defect was
structural (§4, §5), not behavioural.

### 9.2 No actual `sma_tiny` fallback exists in the tree

Full sweep of every read of a series at `189ae07` — every consumer of a
`sma_*` field matches glib exactly. The `SmaSeries` selection in glibe is
reachable only from inside `timeframe.gleam`, so the lock (§5) had not yet
produced a wrong value.

### 9.3 The app-layer skeleton documents are unusually good

`189ae07:src/glibe/app/wire.gleam` cites `plushie/event.gleam:230` for
`WidgetEvent.CustomWidget` and correctly states that the *top-level* `Event`
has no `Custom` variant — a distinction earlier work had gotten wrong. The
module header names who reads and who writes. This is the part of hy4-flash's
work worth keeping, and it is why the app layer was not rewritten from scratch.

### 9.4 The `DataBar` field set is complete

```
$ python3  # diff of DataBar fields, glib vs glibe
glib 字段数: 33   glibe 字段数: 33
glib 有、glibe 没有:  date
glibe 有、glib 没有:  timestamp
```

The single difference is `date` → `timestamp`, which is glibe's deliberate
`Timestamp` type ruling (R27), not a gap.

---

## 10. A second class of defect: what hy4-flash did *to the model*

The same audit boundary applies to earlier work. hy4-flash's own commits
include the naming defects the owner later had to correct:

| Defect | Evidence | Fixed in |
|---|---|---|
| `branch_stat` — vague name ("statistics? status?"), asymmetric with its sibling which returned the identical triple | `189ae07:src/glibe/branch.gleam:169` | `ec79c64` (R51) |
| `recognised_move` — **stole a word**: NAMING.md 1.23 pins `recognised` to `enter_bar` alone, so naming a whole *window* that was a rule violation | `189ae07:src/glibe/branch.gleam:180` | `ec79c64` (R51) |
| the measurement itself had **no type** — `#(Float, Float, Float)`, three unlabelled positions; a caller reading only a signature could not tell them apart | `189ae07:src/glibe/branch.gleam:153` | `339eee3` (R52) |
| `move` meant **two things in one module** — the concept (a span between bars) and the first returned number (a share) | `189ae07:src/glibe/branch.gleam:150` (`fn move_between`) and `:159` (`let move = ...`) | `339eee3` (R52) |

The owner's verdict on this pattern, 2026-11-23 (verbatim):

> *"从move这个名字完全看不出他 return的东西，也就是说完全看不出他的功能，
> workbuddy中我是没办法看gleam代码的，所以我只能问你；但是这正好说明，命名太差了。"*

and

> *"当这 move 和 move_between 同时存在于一个 module 的时候，move 这个名字误导就更强烈。"*

---

## 11. Why this file exists — the generalisable lesson

From the audit of §4–§7:

> **Auditing a supplement for *behaviour* is not auditing it for *structure*.**
> Every behavioural check in §9.1 passed. The failure was entirely in a layer
> the behavioural checks do not look at: where a function lives, and whether
> its accessors are open.

**And the sharper form of it, from §2:** GDLTDD was already in force when the
pollution happened, and every GDLTDD gate was green while it happened. The
discipline governs **the order of work inside a module**; it does not govern
**which module a body belongs in**. A model can write a flawless
doc-first / test-first / fully-green Bollinger band and still file it in
`timeframe.gleam` — and no gate will object.

> **A green gate is not a proof of structure.**

**Second instance, found 2026-11-24 (Space-Bunny).** §13 marked §7 "fixed" because
`fb5aab7` moved the `BarError` *type* into `indicator.gleam`. That was a `file:line`
fact — and still a false sense of completion. The type's **consumer** was never
wired: `indicator.single_bar_test` had **zero production callers** (only a
self-test in `test/`), so a bar with out-of-order bands flowed into leaves,
branches, signals and the chart exactly as if UC-60 did not exist. All gates were
green. The lesson generalises one step past §11: *moving a type to the right
module is not the same as connecting the behaviour it guards.* A structural
audit must therefore ask two questions about every "fixed" item — **where does
the type live?** and **who calls the function at runtime?** — and treat a green
gate as evidence of neither.

So there are two independent things to check, and only one of them has a gate:

| | Gate | Checked by |
|---|---|---|
| *Behaviour* — does the arithmetic compute the right numbers? | `gleam test` | the gate |
| *Structure* — does each body live in the module that owns it, and are the accessors open to whoever needs them? | **none** | **this file's method** |

Owner, 2026-11-23 (verbatim): *"对他的所有工作，都需要严加审查"*

The method for the next pass is therefore the one here: take the tree at the
model's last commit, extract it (`git archive space-bunny-start~1`), and
measure mechanically — function inventories per module, `pub`/`priv` ratios,
field-set diffs against the frozen reference, and every read of every field. A
claim about this work should always be answerable with a command.

**And a working rule that follows:** when a supplement adds a *set* of related
things (five series, seven bands, four oscillator lines), the question to ask
first is not "are the numbers right?" but **"how many modules did this land
in?"** — one, or five? If the answer is one and the frozen reference says
five, the structure is already wrong, and the arithmetic being right does not
rescue it.

---

## 12. Reproducing this audit

```sh
cd ~/gits/hub/tools_ib/glibe
# the boundary tag points at Space-Bunny's first commit; its parent is hy4-flash's last tree
git archive space-bunny-start~1 | tar -x -C /tmp/glibe_audit
cd /tmp/glibe_audit

# §4  function inventory per module
grep -c '^pub fn \|^fn ' src/glibe/timeframe.gleam

# §5  the private-function lock
grep -rn '^fn ' src/ --include='*.gleam' | grep timeframe

# §8  actor capability in a payload
grep -rn 'Subject\|process\.' src/ --include='*.gleam'

# §9.4 field-set diff against the frozen reference
python3 - <<'PY'
import re
def fields(p):
    s=open(p).read()
    m=re.search(r'pub type DataBar \{(.*?)\n\}', s, re.S)
    return set(re.findall(r'^\s{4}([a-z_0-9]+):', m.group(1), re.M)) if m else set()
g=fields('../glib/src/glib/databar.gleam'); b=fields('src/glibe/databar.gleam')
print('glib only:', g-b); print('glibe only:', b-g)
PY

# §2  the discipline was already in force when the pollution happened
git log --oneline --all -S 'R19 ' -- docs/RULINGS.md | tail -3   # R19 ruled 2026-11-07
git log --oneline -1 46ba7ab                                     # the supplement, 2026-11-23
```

**Reference trees:** frozen `glib` at `~/gits/hub/tools_ib/glib` (read-only,
R42) · plushie 0.6.0 at `glibe/build/packages/plushie_gleam` · `bar_stream_chart`
1.2.1 at `~/gits/hub/tools_ib/bar_stream_chart`.

---

## 13. Status

| § | Finding | State |
|---|---|---|
| §2 | GDLTDD was in force (16 days) when the pollution happened — every gate was green | **fact, standing** |
| §3 | `DataBar` carried 2 of 5 promised SMA fields before the forced supplement | **fixed** (`46ba7ab`) |
| §4 | 19 functions filed in the wrong module | **fixed** (`fb5aab7`, R53) |
| §5 | `sma_of`/`size_of` private → series selection locked inside one module | **fixed** (`fb5aab7`, R53 — now `pub` in `sma.gleam`) |
| §6 | record placed above the value it computes | **fixed** (`fb5aab7` — `indicator.compute_bar` is pure bar→bar) |
| §7 | `BarError` filed with unrelated domain code | **module placement fixed** (`fb5aab7` — now in `indicator.gleam`); **runtime admission was NOT wired** — `indicator.single_bar_test` had zero production callers, so a bad bar still flowed into leaves/branches/chart/history. UC-60's *mechanism* was missing, not just the type's address. **Fixed 2026-11-24** by `timeframe.bar_admitted` (step between `indicator` and `leaves` in `databar_processing`), RED→GREEN, R72. |
| §8 | `Subject(ChartPushRequest)` inside a `Msg` payload | **OPEN** — app layer still `todo`; must be settled in 03-01, and this file is the reference for why |
| §9 | what was NOT wrong | recorded deliberately, so no later reader mistakes this file for a claim that everything hy4-flash wrote was wrong. It was not. It was **structurally wrong in a way that behaviour-only review cannot see** |
| §10 | naming defects (`branch_stat`, `recognised_move`, the untyped triple, `move` meaning two things) | **fixed** (`ec79c64` R51, `339eee3` R52) |

**Boundary marker:** `git tag space-bunny-start` → `ec79c64`.
`git diff space-bunny-start~1..HEAD` is exactly what I changed; everything
before it is hy4-flash's, audited in this file.

---

## 14. Was the *copying* itself faithful? (the question the owner's remark opened)

Owner, 2026-11-23 (verbatim): *"算法多数是照抄glib的，能不把对的抄错，错的仍然照抄不误，就谢天谢地了。"*

This is the right instinct, and it opens a dimension the audit in §3–§10 did
not cover: **§3–§10 asked whether the code is right; this asks whether the
copying carried the RIGHT version of glib.**

It matters because **R38 rules that glib is not authoritative** — *"glib做的不
一定对"* (owner 2026-11-10 10:04) — and that copying glib requires
**comparing glib's documentation against glib's implementation** (R38
discipline ②: *"参考 glib 必须文档与实现对照，只取符合 owner 当前裁定的实现"*).
R38 also records owner on the copying itself (2026-11-12): *"对的部分可能没有
抄"*.

**So "copied from glib" is not a guarantee — it is a thing that must be checked.**

### 14.1 Measured: where glib itself was corrected by the owner, which version did glibe take?

| Algorithm | glib's current (corrected) rule | glibe took | Verdict |
|---|---|---|---|
| `next_yin_leaf` — a yin leaf dies on a new HIGH `sma_tiny` **above its own start** (owner 2026-09-29: *"the highest of a living yin leaf is always the `sma_tiny` of its `start_bar`"*) | `glib/leaf.gleam:212` | `glibe/leaf.gleam` `next_yin_leaf` — same comparison, same threshold source | **the corrected version** |
| `next_yang_leaf` — the polarity mirror | `glib/leaf.gleam:236` | same | **the corrected version** |
| `leaf_cma` — averages the **selected MA**, never price (owner 2026-09-15: *"CMA 当然同样是选定均线的均值呀"*) | `glib/leaf.gleam:157` | `glibe/leaf.gleam` — raw is `b.sma_tiny` | **the corrected version** |
| `next_yang_branch` / `next_yin_branch` — closes on a **length** test against the riding leaf, never a price test (owner 2026-10-03) | `glib/branch.gleam:346-424` | same | **the corrected version** |
| `move_between` — a **share** of the open, never a difference, on `sma_tiny` (owner 2026-10-03 7th) | `glib/branch.gleam:233` | same | **the corrected version** |
| KDJ — D is smoothed with **K's alpha**, not a separate ½ (*"idib wins over ibOptions"*, glib `kdj.gleam:39-41`); RSV window is the **amortised-rescan** form (UC-64), not a per-bar full-window scan | `glib/kdj.gleam:15-72` | `glibe/timeframe.gleam` `kdj_stream` — same alpha, same cached-extreme rescan | **the corrected version** |

**Six comparison fingerprints checked mechanically** (`sma_tiny` operators and
comparison targets, extracted from both trees and compared): **all six match.**

### 14.2 Measured: library-level panics — the one place copying glib would have been wrong

Frozen glib contains **20+ `let assert`s** in `src/glib/` — including exactly
the two functions hy4-flash copied:

```
glib/src/glib/branch.gleam:97:  let assert Some(exit_bar) = branch.exit_bar      // branch_size
glib/src/glib/branch.gleam:203: let assert Some(end) = end_bar(branch)            // branch_stat
glib/src/glib/leaf.gleam:129:   let assert Ok(previous) = list.first(databar_list)
glib/src/glib/timeframe.gleam:361,369,385,455,468,484,517,602,637,666: …
```

Core §7 bans `let assert` in libraries (*"libraries likely never"*). **glibe has
ZERO `let assert` in its entire `src/` tree** (measured: the single grep hit is
a *comment* saying so).

**Here the copying was deliberately NOT faithful — and correctly so.** glibe
replaced every library-level assertion with `Option` or an explicit match. This
is the one place where "copying glib verbatim" would have imported a defect, and
it did not happen.

### 14.3 Measured: did glibe import things the owner had struck from glib?

R38 lists what owner ruled **not** to carry over. Checked against the audited
tree:

| Struck / not-to-carry | glib still has it? | glibe copied it? |
|---|---|---|
| `manual_enter` / `manual_exit` fields (owner 2026-10-31: *"based on this to invent fields is not expected behaviour … keep things clean"*) | **no** (deleted) | **no** — the only two mentions in glibe are a comment saying *"No provisional manual_enter / manual_exit fields (owner 10-31)"* |
| `replay` / `ReplayError` / `replay_from` (R38: *"replay连名字都不对"*) | no | **no** (0 hits) |
| `accept` / `bars_accepted` (owner: *"the list_bar is not bearable"* → `archived` / `bars_listed`) | no | **no** (0 hits) — glibe uses `working_databar_archived` / `bars_listed` |
| `sourcebar_buffer` / `sourcebar_export` (offline export) | **yes** (8 + 22 hits) | **no** (0 hits) |
| `clock.now()` / `period_end` (R27: the standard `SourceBar` is unix time, no system clock) | no | **no** (0 hits) |
| `is_product_version` assertion (R38: not carried) | **yes** (7 hits) | **no** — the single mention is a comment: *"this tree has no `is_product_version` flag"* |

**Not one struck item was copied.** Where glib still carries something owner had
ruled out (`sourcebar_buffer`, `sourcebar_export`, `is_product_version`), glibe
left them all behind.

### 14.4 Verdict on the copying

> **The copying was faithful in the places where fidelity was required, and
> deliberately unfaithful in the two places where glib itself was known to be
> wrong — library panics and struck fields.**

This is a genuinely favourable finding and it is recorded as such. It sharpens
§11's lesson rather than softening it:

- **Behaviour (including *which version* of a rule was copied): sound.** §9.1
  and §14.1–§14.3 together.
- **Structure and naming: broken.** §4–§7, §10.

The owner's bar — *"能不把对的抄错，错的仍然照抄不误"* — was in fact **met on the
algorithms**, with one exception worth naming: on the `let assert` question
hy4-flash did **not** copy glib's error, and that exception is the best thing
in the inherited tree.

**What this means for the next audit:** the pattern is now clear and it is
*not* random.

| Layer | What hy4-flash did | Quality |
|---|---|---|
| copying a rule from glib | copied the **corrected** version | good |
| copying library mechanics | dropped glib's panics | good |
| inventing the module layout | invented it | **bad** — §4–§7 |
| inventing names | invented them | **bad** — §10 |

**The failures are exactly where he had no source to copy.** Everything that had
a reference, he got right (or better). Everything he had to *design*, he got
wrong. That is a sharper statement of the problem than "he was careless", and it
is the reason the audit method in §11 must check structure and names
separately from behaviour: **the inherited tree's behaviour can be trusted
much further than its layout can.**

# Questions — glibe

Open items, dated. A question here is one the code does not yet answer, with the
ruling or measurement it is waiting on.

## 2026-10-04

### Q1 — KDJ window: `w` or `w + 1`? (Stage D5)
glibe seeds the KDJ window with `window_kdj_size + 1` bars; glib uses `w`
including the bar in hand. Which is right is undecided; glibe currently diverges
from glib. Pending Stage D.

### Q2 — σ over what window? (Stage D6)
glibe's Bollinger σ excludes the bar in hand. glib documents excluding it as the
error it fixed. Pending Stage D.

### Q3 — floor under the lower bands? (Stage D7)
glibe still clamps the lower bands to a `0.001` floor. The user's ruling is no
floor; the floor contradicts it. Pending Stage D.

### Q4 — one alpha for K and D? (Stage D8)
glibe uses alpha ½ for D where glib's matching key is dead; `kdj_d_period` is
still a field. Delete or justify. Pending Stage D.

### Q5 — `window_kdj_size` → `kdj_window_size`? (Stage D9)
The name breaks glib's `kdj_` prefix convention. Rename pending Stage D.

### Q6 — the BEAM part, where glibe passes glib (Stage F)
glib is one JS process with one engine. glibe is on the BEAM and can:
- run one `Timeframe` actor per `(symbol, interval)`, supervised (`gleam_otp`);
- ship a replay CLI over stored klines, so a claim about the engine is checkable;
- delete `DataGenerator` from the supervision tree (a second engine, in another
  language, currently wired in — UC-56 says one engine);
- add `no_minute_trading.sh`, the ruling as a guard.

None of F is started. It is the reason glibe is worth improving rather than
abandoning, and the only axis where glib is not the reference.

### Q7 — the AI strategy
glib is building it now (`ai_s1`, `learn`, `boost`, `knn`, `census --learn`). It
is ported when it settles, not mid-flight. Until then glibe's only strategy is
the manual one in `trading/strategy.gleam`.

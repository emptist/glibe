# Web-layer demos — measurement apparatus for R24

These three Gleam projects exist to **measure** the BEAM web-layer options, not
to become product code. Owner ruling R24: *"web层架构当然是你通过写demo对比测试
决定用哪一个呀"* — the framework choice is the AI's job, decided by running
demos, not by asking the owner.

**Boundary (R15 / R18):** all three `gleam.toml` files declare the **erlang**
target. No JavaScript-target package is added here. The product's only
JavaScript-target package remains `webclient/`; its Gleam source generates
`webclient/build/dev/javascript/webclient/webclient.mjs`. Demo B's browser
runtime is `lustre-server-component.min.mjs`, shipped inside the `lustre` Hex
package, not written by this project. Hand-written JS in all three demos:
**0 lines**.

| demo | port | server half | endpoints |
|---|---|---|---|
| `a_wisp/` | 8601 | Mist + Wisp | `GET /`, `GET /bar` |
| `b_lustre/` | 8602 | Mist + Wisp + Lustre server component | `GET /`, `GET /bar`, `GET /poll` |
| `c_static/` | 8603 | Mist only, no framework | `GET /`, `GET /bar` |

One settled bar is the same value in all three: `SettledBar(index: 42,
close: 123.5)`. `/` renders it server-side; `/bar` returns it as JSON. Demo B's
`/poll` registers a client with the Lustre runtime and returns the `Mount` DOM
patch (`kind: 0`) it sends back — the bar travels through the server-component
data path, not just the page.

## Rebuild and measure

```sh
export PATH="/opt/homebrew/bin:$PATH"
for d in a_wisp b_lustre c_static; do
  (cd probes/web-layer/$d && gleam deps download && gleam build && gleam test && gleam docs build)
done
(cd webclient && gleam build)
node --input-type=module -e \
  "import('file://$PWD/webclient/build/dev/javascript/webclient/webclient.mjs').then(m => console.log(Object.keys(m)))"
```

Each server is started with `gleam run` in its own directory. A measurement
run starts all three, waits for the ports, issues real HTTP GETs, and stops
them; the numbers and the conclusion are in `docs/DESIGN.md` ("The BEAM web
layer, measured (R24)") and
`.planning/phases/04-domain-cleanup/04-04-SUMMARY.md`.

## What these demos do NOT prove

No fractal engine, no market data, no chart library, no SSE/WebSocket stream,
no real single-page interaction. The browser half is a 3-line generated `.mjs`
whose `main` returns `Nil`; the visible bar comes from server-side rendering.
That is enough to measure framework cost, which is what R24 asked for.

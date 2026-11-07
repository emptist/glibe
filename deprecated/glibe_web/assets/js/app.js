import { LiveSocket } from "phoenix_live_view";
import { Socket } from "phoenix";
import { ChartHook } from "./chart_hook";
import "../css/app.css";

let Hooks = { ChartHook };

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: document.querySelector("meta[name='csrf-token']").getAttribute("content") }
});

liveSocket.connect();
window.liveSocket = liveSocket;
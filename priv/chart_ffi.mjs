// Chart FFI: broadcast DataBar over SSE for Lightweight Charts visualization
// This mirrors glib's server_ffi.mjs broadcast_chart function

// Export function that receives a DataBar from Gleam and broadcasts it
// via SSE to the browser for chart rendering
export function broadcast_chart(databar) {
  // Send chart data via SSE - the format expected by ChartHook phx-hook
  // databar contains: idx, open, high, low, close, sma_*, bb_*, kdj_*, leaf_*, signal, etc.
  
  // Create a minimal chart bar object for SSE transmission
  const chartData = {
    idx: databar.idx,
    open: databar.open,
    high: databar.high,
    low: databar.low,
    close: databar.close,
    sma_tiny: databar.sma_tiny,
    sma_medium: databar.sma_medium,
    bb_m: databar.bb_m,
    bb_u3: databar.bb_u3,
    bb_l3: databar.bb_l3,
    kdj_k: databar.k,
    kdj_d: databar.d,
    kdj_j: databar.j,
    yin_leaf_cma: databar.yin_leaf_cma,
    yang_leaf_cma: databar.yang_leaf_cma,
    signal: databar.signal || '',
    date: databar.date
  };
  
  // Broadcast via window.Phoenix.Socket — same mechanism glib uses
  // The glibe LiveView page subscribes to "chart_updates" topic
  // and ChartHook renders Lightweight Charts from this data
  if (window.Phoenix && window.Phoenix.Socket) {
    const socket = window.Phoenix.Socket(document.currentScript.dataset.socketId || "");
    if (socket.connected) {
      socket.channel("chart:updates").push("new_bar", chartData);
    }
  }
  
  // Fallback: also try broadcasting via event if Phoenix not available
  // In production, the LiveView page always has Phoenix connected
  // window.dispatchEvent(new CustomEvent("chart_update", { detail: chartData }));
}
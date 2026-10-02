-module(chart_ffi).
-export([broadcast_chart/1]).

-define(MODULE, chart_ffi).

broadcast_chart(Databar) ->
    %% TODO: Implement actual SSE broadcast to Lightweight Charts
    ok.
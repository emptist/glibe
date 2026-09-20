-module(binance_ffi).
-export([get_klines/3, get_ticker/1, get_exchange_info/0, set_base_url/1]).

get_klines(Symbol, Interval, Limit) when is_binary(Symbol), is_binary(Interval), is_integer(Limit) ->
    do_get(["/api/v3/klines?symbol=", Symbol, "&interval=", Interval, "&limit=", integer_to_list(Limit)]);
get_klines(Symbol, Interval, Limit) ->
    do_get(["/api/v3/klines?symbol=", binary_to_list(Symbol), "&interval=", binary_to_list(Interval), "&limit=", integer_to_list(Limit)]).

get_ticker(Symbol) when is_binary(Symbol) ->
    do_get(["/api/v3/ticker/24hr?symbol=", Symbol]);
get_ticker(Symbol) ->
    do_get(["/api/v3/ticker/24hr?symbol=", binary_to_list(Symbol)]).

get_exchange_info() ->
    do_get("/api/v3/exchangeInfo").

set_base_url(Url) when is_binary(Url) ->
    application:set_env(binance_ffi, base_url, Url),
    ok;
set_base_url(_) ->
    {error, badarg}.

do_get(PathParts) ->
    Path = list_to_binary(lists:flatten(PathParts)),
    Base = get_base_url(),
    Url = <<Base/binary, Path/binary>>,
    Args = "-X GET '" ++ binary_to_list(Url) ++ "'",
    run_curl(Args).

run_curl(Args) ->
    case os:cmd("curl -s --max-time 10 " ++ Args) of
        "" -> {error, <<"empty response">>};
        Resp when is_list(Resp) -> {ok, list_to_binary(Resp)};
        Resp when is_binary(Resp) -> {ok, Resp}
    end.

get_base_url() ->
    case application:get_env(binance_ffi, base_url) of
        {ok, Url} -> Url;
        _ -> <<"https://testnet.binance.vision">>
    end.
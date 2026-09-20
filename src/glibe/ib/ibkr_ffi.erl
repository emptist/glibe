-module(ibkr_ffi).
-export([
    setup/1,
    check_auth_status/0,
    ping_server/0,
    get_accounts/0,
    get_positions/1,
    search_contracts/1,
    get_market_snapshot/2,
    get_historical/3,
    get_orders/0,
    preview_order/2,
    place_order/2,
    cancel_order/2
]).

setup(_Port) ->
    ssl:start(),
    inets:start(),
    {ok, nil}.

check_auth_status() ->
    do_post("/iserver/auth/status", #{}).

ping_server() ->
    do_get("/tickle").

get_accounts() ->
    do_get("/iserver/accounts").

get_positions(AccountId) when is_binary(AccountId) ->
    do_get("/portfolio/" ++ AccountId ++ "/positions");
get_positions(AccountId) ->
    do_get("/portfolio/" ++ binary_to_list(AccountId) ++ "/positions").

search_contracts(Symbol) when is_binary(Symbol) ->
    Encoded = uri_encode(Symbol),
    do_get("/iserver/secdef/search?symbol=" ++ Encoded);
search_contracts(Symbol) ->
    Encoded = uri_encode(binary_to_list(Symbol)),
    do_get("/iserver/secdef/search?symbol=" ++ Encoded).

get_market_snapshot(Conids, Fields) when is_binary(Conids), is_binary(Fields) ->
    do_get("/iserver/marketdata/snapshot?conids=" ++ binary_to_list(Conids) ++ "&fields=" ++ binary_to_list(Fields));
get_market_snapshot(Conids, Fields) ->
    do_get("/iserver/marketdata/snapshot?conids=" ++ binary_to_list(Conids) ++ "&fields=" ++ binary_to_list(Fields)).

get_historical(Conid, Period, Bar) when is_binary(Conid), is_binary(Period), is_binary(Bar) ->
    do_get("/iserver/marketdata/history?conid=" ++ Conid ++ "&period=" ++ Period ++ "&bar=" ++ Bar);
get_historical(Conid, Period, Bar) ->
    do_get("/iserver/marketdata/history?conid=" ++ binary_to_list(Conid) ++ "&period=" ++ binary_to_list(Period) ++ "&bar=" ++ binary_to_list(Bar)).

get_orders() ->
    do_get("/iserver/orders").

preview_order(AccountId, Orders) when is_binary(AccountId) ->
    do_post("/iserver/account/" ++ AccountId ++ "/orders/preview", Orders);
preview_order(AccountId, Orders) ->
    do_post("/iserver/account/" ++ binary_to_list(AccountId) ++ "/orders/preview", Orders).

place_order(AccountId, Orders) when is_binary(AccountId) ->
    do_post("/iserver/account/" ++ AccountId ++ "/orders", Orders);
place_order(AccountId, Orders) ->
    do_post("/iserver/account/" ++ binary_to_list(AccountId) ++ "/orders", Orders).

cancel_order(AccountId, OrderId) when is_binary(AccountId), is_binary(OrderId) ->
    do_post("/iserver/account/" ++ AccountId ++ "/orders/" ++ OrderId ++ "/cancel", #{});
cancel_order(AccountId, OrderId) ->
    do_post("/iserver/account/" ++ binary_to_list(AccountId) ++ "/orders/" ++ binary_to_list(OrderId) ++ "/cancel", #{}).

do_get(Path) ->
    do_request(get, Path, #{}).

do_post(Path, Body) ->
    do_request(post, Path, Body).

do_request(get, Path, _Body) ->
    Url = to_list(<<"https://localhost:5001/v1/api">>) ++ Path,
    Args = "-X GET " ++ Url,
    run_curl(Args);
do_request(post, Path, Body) ->
    Url = to_list(<<"https://localhost:5001/v1/api">>) ++ Path,
    BodyJson = encode_json(Body),
    Args = "-X POST " ++ Url ++ " -H 'Content-Type: application/json' -d '" ++ BodyJson ++ "'",
    run_curl(Args).

to_list(Bin) when is_binary(Bin) -> binary_to_list(Bin);
to_list(List) when is_list(List) -> List.

run_curl(Args) ->
    case os:cmd("curl -s -k " ++ Args) of
        "" -> {error, <<"empty response">>};
        Response ->
            {ok, list_to_binary(Response)}
    end.

uri_encode(Bin) when is_binary(Bin) -> uri_encode(binary_to_list(Bin));
uri_encode(Str) when is_list(Str) ->
    lists:flatten([uri_encode_char(C) || C <- Str]).

uri_encode_char(C) when C >= $a, C =< $z -> [C];
uri_encode_char(C) when C >= $A, C =< $Z -> [C];
uri_encode_char(C) when C >= $0, C =< $9 -> [C];
uri_encode_char($.) -> ["."];
uri_encode_char($-) -> ["-"];
uri_encode_char($_) -> ["_"];
uri_encode_char($~) -> ["~"];
uri_encode_char(C) ->
    ["%", integer_to_list(C div 16, 16), integer_to_list(C rem 16, 16)].

encode_json(#{} = Map) ->
    Pairs = maps:fold(fun(K, V, Acc) ->
        Key = case K of
            A when is_atom(A) -> atom_to_list(A);
            B when is_binary(B) -> binary_to_list(B);
            L when is_list(L) -> L
        end,
        [["\"", Key, "\": ", encode_value(V)] | Acc]
    end, [], Map),
    ["{", lists:join(", ", Pairs), "}"];

encode_json(L) when is_list(L) ->
    Items = lists:map(fun encode_json/1, L),
    ["[", lists:join(", ", Items), "]"];

encode_json(V) -> encode_value(V).

encode_value(V) when is_binary(V) -> ["\"", V, "\""];
encode_value(V) when is_atom(V) -> ["\"", atom_to_list(V), "\""];
encode_value(V) when is_integer(V) -> integer_to_list(V);
encode_value(V) when is_float(V) -> io_lib:format("~p", [V]);
encode_value(true) -> "true";
encode_value(false) -> "false";
encode_value(null) -> "null";
encode_value(#{} = Map) -> encode_json(Map);
encode_value(L) when is_list(L) ->
    case io_lib:printable_list(L) of
        true -> ["\"", L, "\""];
        false ->
            Items = lists:map(fun encode_json/1, L),
            ["[", lists:join(", ", Items), "]"]
    end;
encode_value(_) -> "null".
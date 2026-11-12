-module(ib_test).
-export([test/0]).

test() ->
    io:format("Connecting to TWS on port 7496...~n"),
    case gen_tcp:connect("127.0.0.1", 7496, [binary, {packet, raw}, {active, false}], 5000) of
        {ok, Socket} ->
            io:format("Connected!~n"),
            
            %% Send connect request
            Msg = <<"API", 0, "v110..110">>,
            io:format("Sending: ~p~n", [Msg]),
            case gen_tcp:send(Socket, Msg) of
                ok -> io:format("Sent OK~n");
                {error, E1} -> io:format("Send error: ~p~n", [E1])
            end,
            
            %% Wait for response
            io:format("Waiting for response...~n"),
            case gen_tcp:recv(Socket, 0, 10000) of
                {ok, Data} ->
                    io:format("Received ~p bytes: ~p~n", [byte_size(Data), Data]),
                    
                    %% Try to parse
                    case Data of
                        <<Len:32/big, Body/binary>> ->
                            io:format("Length-prefixed: len=~p~n", [Len]),
                            Fields = binary:split(Body, <<0>>, [global, trim_all]),
                            io:format("Fields: ~p~n", [Fields]);
                        _ ->
                            Fields = binary:split(Data, <<0>>, [global, trim_all]),
                            io:format("Not length-prefixed, fields: ~p~n", [Fields])
                    end;
                {error, timeout} ->
                    io:format("Timeout~n");
                {error, E2} ->
                    io:format("Recv error: ~p~n", [E2])
            end,
            
            gen_tcp:close(Socket);
        {error, E3} ->
            io:format("Connect error: ~p~n", [E3])
    end.
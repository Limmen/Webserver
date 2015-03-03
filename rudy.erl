-module(rudy).
-compile(export_all).

start(Port) ->
    register(rudy1, spawn(fun() -> init(Port) end)),
    register(rudy2, spawn(fun() -> init(Port) end)),
    register(rudy3, spawn(fun() -> init(Port) end)),
    register(rudy4, spawn(fun() -> init(Port) end)),
    register(rudy5, spawn(fun() -> init(Port) end)).

stop() ->
    exit(whereis(rudy1), "time to die"),
    exit(whereis(rudy2), "time to die"),
    exit(whereis(rudy3), "time to die"),
    exit(whereis(rudy4), "time to die"),
    exit(whereis(rudy5), "time to die").


init(Port) ->
Opt = [list, {active, false}, {reuseaddr, true}],
case gen_tcp:listen(Port, Opt) of
{ok, Listen} ->
	handler(Listen),
	gen_tcp:close(Listen),
	ok;
    {error, Error} ->
	error
end.

handler(Listen) ->
case gen_tcp:accept(Listen) of
{ok, Client} ->
	request(Client),
	handler(Listen);
	{error, Error} ->
		     error
	     end.

request(Client) ->
    Recv = gen_tcp:recv(Client, 0),
    case Recv of
	{ok, Str} ->
	   % erlang:display("request:"),
	   % erlang:display(Str),
	   % io:format("request: ~w~n", [[Str]]),
	    Request = http:parse_request(Str),
	    Response = reply(Request),
	    gen_tcp:send(Client, Response);
	{error, Error} ->
	    io:format("rudy: error: ~w~n", [Error])
    end,
    gen_tcp:close(Client).

reply({{get,[47], _}, _, _}) ->
    timer:sleep(40),
   % erlang:display(URI),
    % file_read:readlines("bajen.txt").
    http:ok("Welcome to my simple webserver in Erlang! /Kim Hammar");

reply({{get, [47|URI], _}, _, _}) ->
    timer:sleep(40),
    erlang:display(URI),
    %http:get(URI).
    case file_read:readlines(URI) of
	{error,Reason} -> http:error("404 error: File not found");
	File -> File
		    end.
	    
    

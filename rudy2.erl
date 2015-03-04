-module(rudy2).
-compile(export_all).

start(Port) ->
   register(rudy1, spawn(fun() -> init(Port) end)).

stop() ->
    exit(whereis(rudy1), "time to die").

init(Port) ->
Opt = [list, {active, false}, {reuseaddr, true}],
case gen_tcp:listen(Port, Opt) of
{ok, Listen} ->
	register(rudy2, spawn(fun() -> handler(Listen) end)),
	handler(Listen),
	gen_tcp:close(Listen),
	ok;
    {error, Error} ->
	error
end.

handler(Listen) ->
case gen_tcp:accept(Listen) of
{ok, Client} ->
	spawn(fun()-> request(Client) end),
	handler(Listen);
	{error, Error} ->
		     error
	     end.

request(Client) ->
    erlang:display("The process handling this client request is: "),
    erlang:display(self()),
    Recv = gen_tcp:recv(Client, 0),
    case Recv of
	{ok, Str} ->
	    Request = http:parse_request(Str),
	    Response = reply(Request),
	    gen_tcp:send(Client, Response);
	{error, Error} ->
	    io:format("rudy: error: ~w~n", [Error])
    end,
    gen_tcp:close(Client).

reply({{get,[47], _},_, _}) ->
    timer:sleep(40),
    http:ok("Welcome to my simple webserver in Erlang! /Kim Hammar");

reply({{get, [47|URI], _}, _, _}) ->
    timer:sleep(40),
    case file_read:readlines(URI) of
	{error,Reason} -> http:error("404 error: File not found");
	File -> http:ok(File)
    end.
	    
    

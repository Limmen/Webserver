-module(rudy).
-compile(export_all).

%start the webserver and register it (rudy). Parameters specify port and number of processess.
start(Port,N) ->
   register(rudy, spawn(fun() -> init(Port,N) end)).
%Stopping rudy by sending a message. Stopping rudy will cause every process to terminate.
stop() ->
    rudy ! stop.

%Set up a socket to listen on port.
init(Port, N) ->
Opt = [list, {active, false}, {reuseaddr, true}],
case gen_tcp:listen(Port, Opt) of
{ok, Listen} ->
	%spawn N processes
	processPool(N, Listen),
	%wait for stop signal
	receive
	    stop -> gen_tcp:close(Listen)
			  end;
    {error, Error} ->
	error
end.

%Accept connection requests for socket Listen.
handler(Listen) ->
case gen_tcp:accept(Listen) of
{ok, Client} ->
        %io:format("Process handling this request is:  ~w ~n ",[self()]),
	request(Client,[]),
	%% request(Client),
	handler(Listen);
	{error, Error} ->
		     error
	     end.
%Receive a packet from clientsocket and send response
request(Client,Sofar) ->
    Recv = gen_tcp:recv(Client, 0),
    case Recv of
	{ok, Str} ->
	    Req = Str++Sofar,
	    case http:pre_process(Req) of
		{ok,Body} ->
		    Request = http:parse_request(Req++Body),
		    Response = reply(Request),
		    gen_tcp:send(Client,Response);

		{Body,Length} ->
		   case len(Body) == Length of
				     true ->
					 Request = http:parse_request(Req),
					 Response = reply(Request),
					 gen_tcp:send(Client,Response);
				     false -> case len(Body) > Length of
						  true -> error;
						  false-> request(Client,Body)
					      end
				 end;
		error-> 
	               request(Client,Req)
	    end;
	{error, Error} ->
	    io:format("rudy: error: ~w~n", [Error])
    end,
    gen_tcp:close(Client).

%% request(Client) ->
%%     Recv = gen_tcp:recv(Client, 0),
%%     case Recv of
%% 	{ok, Str} -> 
%% 	             Request = http:parse_request(Str),
%% 		     Response = reply(Request),
%% 		     gen_tcp:send(Client,Response);
%% 	{error, Error} ->
%% 	    io:format("rudy: error: ~w~n", [Error])
%%     end,
%%     gen_tcp:close(Client).

%Spawn N processess.
processPool(0,_)->
    ok;
processPool(N,Listen)->
    spawn_link(fun()-> handler(Listen) end),
    processPool(N-1,Listen).
		       
%Send a http reply.
reply({{get,[47], _}, _, _}) ->
    timer:sleep(40),
    http:ok("Welcome to my simple webserver in Erlang! /Kim Hammar");

reply({{get, [47|URI], _}, Headers, _}) ->
    timer:sleep(40),
    case file_read:readlines(URI) of
	{error,Reason} -> http:error("404 error: File not found");
	{File,Size} -> http:file(File,Headers,Size)
		    end;
reply({{get, URI, _}, _, _}) ->
    timer:sleep(40),
    http:ok("Welcome to my simple webserver in Erlang! /Kim Hammar").
	    
    
len([]) -> 0;
len([_|T]) -> 1 + len(T).

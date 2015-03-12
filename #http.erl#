-module(http).
-compile(export_all).

%Double CRLF means end of header section
pre_process([13,10,13,10|Body],Length)->
    erlang:display("Double CRLF is here lel"),
    {Body,Length};
pre_process([],Length)->
    error;
pre_process([H|T],Length)->
pre_process(T,Length).

%Pre processor that checks if request is complete.
pre_process([])->
    error;
%If body exists
pre_process([$C,$o,$n,$t,$e,$n,$t,45,$L,$e,$n,$g,$t,$h,58,32,Length|R])->
    erlang:display("Content length found"),
    pre_process(R,Length);
%Double CRLF means end of header section
pre_process([13,10,13,10|Body])->
   % erlang:display("Double CRLF is here lel"),
		   {ok,Body};
pre_process([H|T])->
pre_process(T).

%Parse requests (requestline, headers, body).
parse_request(R0) ->
    {Request, R1} = request_line(R0),
    {Headers, R2} = headers(R1),
    {Body, _} = message_body(R2),
    {Request, Headers, Body}.

%Parse request_line (Method, URI, httpversion)
request_line([$G, $E, $T, 32 |R0]) ->
    {URI, R1} = request_uri(R0),
    {Ver, R2} = http_version(R1),
    [13,10|R3] = R2,
    {{get, URI, Ver}, R3}.
%parse uri
request_uri([32|R0])->
    {[], R0};

request_uri([C|R0]) ->
    {Rest, R1} = request_uri(R0),
    {[C|Rest], R1}.

%parse http version 
http_version([$H, $T, $T, $P, $/, $1, $., $1 | R0]) ->
    {v11, R0};

http_version([$H, $T, $T, $P, $/, $1, $., $0 | R0]) ->
    {v10, R0}.

%parse headers
headers([13,10|R0]) ->
    {[],R0};

headers(R0) ->
    {Header, R1} = header(R0),
    {Rest, R2} = headers(R1),
    {[Header|Rest], R2}.

header([13,10|R0]) ->
    {[], R0};

header([C|R0]) ->
    {Rest, R1} = header(R0),
    {[C|Rest], R1}.

message_body(R) ->
    {R, []}.

%http responses
ok(Body) ->
"HTTP/1.1 200 OK\r\n" ++ "\r\n" ++ Body.

error(Body)->
"HTTP/1.1 404 Not Found\r\n" ++ "\r\n" ++ Body.

file(Body,Headers,Size) ->
"HTTP/1.1 200 OK\r\n" ++ Headers ++ "Content-Length:" ++ [Size] ++  "\r\n\r\n" ++ Body.

%get request
get(URI) ->
"GET " ++ URI ++ " HTTP/1.1\r\n" ++ "\r\n".



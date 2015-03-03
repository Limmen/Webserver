-module(file_read).
-export([readlines/1]).
 
readlines(FileName) ->
    case file:open(FileName, [read]) of
	{error, Reason} -> {error, Reason};
        {ok, Device} -> get_all_lines(Device, [])
			    end.
 
get_all_lines(Device, Accum) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Accum;
        Line -> get_all_lines(Device, Accum ++ [Line])
    end.

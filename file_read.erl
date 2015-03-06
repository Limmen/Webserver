-module(file_read).
-include_lib("kernel/include/file.hrl").
-export([readlines/1]).
 
readlines(FileName) ->
    case file:open(FileName, [read]) of
	{error, Reason} -> 
	    {error, Reason};
        {ok, Device} -> 
	    {ok, #file_info{size = Size}} = file:read_file_info(FileName),
            erlang:display(Size),
	   % {get_all_lines(Device, []),Size}
	    	    {get_all_lines(Device, []),Size}
			    end.
 
get_all_lines(Device, Accum) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Accum;
        Line -> get_all_lines(Device, Accum ++ [Line])
    end.

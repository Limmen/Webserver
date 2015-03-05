-module(asyncron).
-compile(export_all).

start(Host, Port,N) ->
    Start = now(),
    run(Host, Port,N),
    return(N),
    Finish = now(),
    timer:now_diff(Finish, Start).

run(_,_,0)->
    ok;
run(Host,Port,N)->
    Pid = self(),
    spawn(fun()-> test:bench(Host,Port,10, Pid) end),
    run(Host,Port,N-10).

return(0)->
    erlang:display("done! all threads returned"),
    ok;

return(N)->
   receive
	done ->  return(N-10);
	error -> erlang:display("error!!"),
		 error
		     end.
	    
		  

-module(mybank).

-export([start/0, stop/1]).
-export([main_loop/0]).

start() ->
    io:format("~n~n Opening the bank...~n~n"),
    spawn(?MODULE, main_loop, []).

stop(Pid) ->
    Pid ! terminate.

main_loop() ->
    receive
        terminate ->
            io:format("~n~n Closing the bank...~n~n")
    end.
-module(mybank_sup).

-export([start/0, stop/0, init/0]).

start() ->
    Pid = spawn(?MODULE, init, []),
    register(?MODULE, Pid).

stop() ->
    ?MODULE ! terminate.

init() ->
    process_flag(trap_exit, true),
    {ok, SupervisedPid} = mybank_atm:start_link(),
    main_loop(SupervisedPid).

main_loop(SupervisedPid) ->
    receive
        {'EXIT', SupervisedPid, _} -> 
            error_logger:error_msg("mybank_atm process terminated. restarting..."),
            {ok, SupervisedPidNew} = mybank_atm:start_link(),
            main_loop(SupervisedPidNew);
        terminate ->
            mybank_atm:stop()
    end.
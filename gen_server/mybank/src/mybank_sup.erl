-module(mybank_sup).
-behaviour(supervisor).

-export([start_link/0]).

%% supervisor callbacks
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Children = [
        {
            %% id
            mybank_atm,
            %% {module, start link, args}
            {mybank_atm, start_link, []},
            %% restart_type
            permanent,
            %% shutdown
            10000,
            %% type
            worker,
            %% modules
            [mybank_atm]
        }
    ],
    {ok, {{one_for_one, 10, 10}, Children}}.
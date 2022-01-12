-module(mybank).

-export([start/0, stop/0, deposit/2, balance/1, withdraw/2]).
-export([init/0]).

-record(state, {
    accounts
}).

%%========= API =========%%
start() ->
    io:format("~n~n Opening the bank...~n~n"),
    Pid = spawn(?MODULE, init, []),
    register(?MODULE, Pid).

stop() ->
    ?MODULE ! terminate.

deposit(AccountId, Amount) ->
    ?MODULE ! {deposit, self(), AccountId, Amount},
    receive
        Reply -> Reply
    after 5000 ->
        {error, timeout}
    end.

withdraw(AccountId, Amount) ->
    ?MODULE ! {withdraw, self(), AccountId, Amount},
    receive
        Reply -> Reply
    after 5000 ->
        {error, timeout}
    end.

balance(AccountId) ->
    ?MODULE ! {balance, self(), AccountId},
    receive
        Reply -> Reply
    after 5000 ->
        {error, timeout}
    end.

%%========= Internal =========%%
init() ->
    Accounts = dict:new(),
    State = #state{accounts = Accounts},
    main_loop(State).

main_loop(#state{
    accounts = Accounts
} = State) ->
    receive
        {deposit, CallerPid, AccountId, Amount} ->
            CurrentBalance = get_current_balance(AccountId, Accounts),
            AccountsNew = dict:store(AccountId, CurrentBalance + Amount, Accounts),
            io:format("~n~n ~p deposited ~p ~n", [AccountId, Amount]),
            CallerPid ! ok,
            main_loop(State#state{accounts = AccountsNew});
        {balance, CallerPid, AccountId} ->
            CallerPid ! {ok, get_current_balance(AccountId, Accounts)},
            main_loop(State);
        {withdraw, CallerPid, AccountId, Amount} ->
            case get_current_balance(AccountId, Accounts) < Amount of
                true ->
                    io:format("~n~n ~p cannot withdraw ~p ~n", [AccountId, Amount]),
                    CallerPid ! {error, insufficient_funds},
                    main_loop(State);
                false ->
                    CurrentBalance = get_current_balance(AccountId, Accounts),
                    AccountsNew = dict:store(AccountId, CurrentBalance - Amount, Accounts),
                    io:format("~n~n ~p withdrew ~p ~n", [AccountId, Amount]),
                    CallerPid ! ok,
                    main_loop(State#state{accounts = AccountsNew})
            end;
        terminate ->
            io:format("~n~n Closing the bank...~n~n")
    end.


get_current_balance(AccountId, Accounts) ->
    case dict:find(AccountId, Accounts) of
        error -> 0;
        {ok, Amount0} -> Amount0
    end.
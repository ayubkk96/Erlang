-module(dropboxtest).
-export([start/0, client/1]).

start() ->
	dropbox:start(),
	mutex:start(),
	register(tester_process, self()),
	loop("The concurrency", " is not working", 1),
	unregister(tester_process),
	mutex:stop(),
	dropbox:stop().

loop(_, _, 0) ->
	true;
loop(Client1, Client2, N) ->
	dropbox:write_to_file(""),
	spawn(dropboxtest, client, [Client1]),
	spawn(dropboxtest, client, [Client2]),
	receive
		done -> true
	end,
	receive
		done -> true
	end,
	io:format("Expected file contents = ~s, actual file contents = ~s~n~n",
		[Client1 ++ Client2, dropbox:read_the_file()]),
	loop(Client1, Client2, N-1).

client(Client) ->
	mutex:wait(),
	dropbox:upload(Client),
	mutex:signal(),
	tester_process ! done.
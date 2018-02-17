-module(dropbox).
-export([person/1, start/0, stop/0, upload/1, read_file/0, write_file/1]).

person(File) ->
    receive
        {set, NewFile} ->
            person(NewFile);
        {get, From} ->
            From ! {file, File},
            person(File);
        stop -> ok
    end.

start() ->
    Person_PID = spawn(dropbox, person, [0]),
    register(person_process, Person_PID).

stop() ->
    person_process ! stop,
    unregister(person_process).

write_to_file(N) ->
    person_process ! {set, N}.

read_the_file() ->
    person_process ! {get, self()},
    receive
        {fil, N} -> N
    end.

upload(File_Change) ->
    OldFile = read_the_file(),
    NewFile = OldFile ++ File_Switch,
    write_to_file(NewFile).
-module(drafts_ffi).

-export([arguments/0]).

%% Gleam strings are binaries, while Erlang's argument list is a charlist.
%% Convert at the boundary so the Gleam side stays typed.
arguments() ->
    [unicode:characters_to_binary(Argument)
     || Argument <- init:get_plain_arguments()].

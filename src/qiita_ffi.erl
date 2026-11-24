-module(qiita_ffi).

-export([arguments/0, environment/1]).

%% Gleam strings are binaries, while Erlang's argument list and os:getenv/1
%% return charlists. Convert at the boundary so the Gleam side stays typed.
arguments() ->
    [unicode:characters_to_binary(Argument)
     || Argument <- init:get_plain_arguments()].

environment(Name) ->
    case os:getenv(unicode:characters_to_list(Name)) of
        false -> <<>>;
        Value -> unicode:characters_to_binary(Value)
    end.

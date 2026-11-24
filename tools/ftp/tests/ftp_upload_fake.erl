%% Fake SFTP backend used by the ftp_upload EUnit suite. It records calls and
%% keeps directory/file state in the process dictionary so tests do not need a
%% real server.

-module(ftp_upload_fake).

-include_lib("kernel/include/file.hrl").

-export([reset/0,
         init/2,
         set_file/2,
         fail/2,
         return_ssh_apps/0,
         calls/0,
         dirs/0,
         files/0,
         ensure_ssh_started/0,
         start_channel/3,
         stop_channel/1,
         close_connection/1,
         read_file_info/2,
         make_dir/2,
         open/3,
         write/3,
         close/2,
         delete/2]).

reset() ->
    put(fake_calls, []),
    put(fake_dirs, ["/"]),
    put(fake_files, #{}),
    put(fake_open_data, #{}),
    put(fake_handle_paths, #{}),
    put(fake_handle, 0),
    put(fake_failures, #{}),
    put(fake_ssh_result, ok),
    ok.

init(Dirs, Files) ->
    put(fake_dirs, ["/" | Dirs]),
    put(fake_files, Files),
    ok.

set_file(Path, Data) ->
    put(fake_files, maps:put(Path, Data, get_or(fake_files, #{}))),
    ok.

fail(Operation, Reason) ->
    Failures = get_or(fake_failures, #{}),
    put(fake_failures, Failures#{Operation => Reason}),
    ok.

return_ssh_apps() ->
    put(fake_ssh_result, {ok, [ssh]}),
    ok.

calls() ->
    get_or(fake_calls, []).

dirs() ->
    get_or(fake_dirs, ["/"]).

files() ->
    get_or(fake_files, #{}).

ensure_ssh_started() ->
    case failure(ensure_ssh_started) of
        {ok, Reason} ->
            call({ensure_ssh_started_failed, Reason}),
            {error, Reason};
        error ->
            call(ensure_ssh_started),
            get_or(fake_ssh_result, ok)
    end.

start_channel(Host, Port, Options) ->
    case failure(start_channel) of
        {ok, Reason} ->
            call({start_channel_failed, Reason}),
            {error, Reason};
        error ->
            call({start_channel, Host, Port, Options}),
            {ok, fake_channel, fake_connection}
    end.

stop_channel(Channel) ->
    call({stop_channel, Channel}),
    ok.

close_connection(Connection) ->
    call({close_connection, Connection}),
    ok.

read_file_info(_Channel, Path) ->
    call({read_file_info, Path}),
    case failure(read_file_info) of
        {ok, Reason} ->
            {error, Reason};
        error ->
            case lists:member(Path, dirs()) of
                true ->
                    {ok, #file_info{type = directory}};
                false ->
                    Files = files(),
                    case maps:find(Path, Files) of
                        {ok, Data} ->
                            {ok, #file_info{type = regular, size = byte_size(Data)}};
                        error ->
                            {error, no_such_file}
                    end
            end
    end.

make_dir(_Channel, Path) ->
    call({make_dir, Path}),
    case failure(make_dir) of
        {ok, Reason} ->
            {error, Reason};
        error ->
            case lists:member(Path, dirs()) of
                true ->
                    {error, file_exists};
                false ->
                    put(fake_dirs, [Path | dirs()]),
                    ok
            end
    end.

open(_Channel, Path, _Options) ->
    call({open, Path}),
    case failure(open) of
        {ok, Reason} ->
            {error, Reason};
        error ->
            Number = get_or(fake_handle, 0) + 1,
            Handle = {fake_handle, Number},
            put(fake_handle, Number),
            put(fake_handle_paths,
                maps:put(Handle, Path, get_or(fake_handle_paths, #{}))),
            put(fake_open_data,
                maps:put(Handle, <<>>, get_or(fake_open_data, #{}))),
            {ok, Handle}
    end.

write(_Channel, Handle, Data) ->
    call({write, Handle, byte_size(Data)}),
    case failure(write) of
        {ok, Reason} ->
            {error, Reason};
        error ->
            Path = maps:get(Handle, get_or(fake_handle_paths, #{})),
            OpenData = get_or(fake_open_data, #{}),
            Written = maps:get(Handle, OpenData, <<>>),
            Content = <<Written/binary, Data/binary>>,
            put(fake_open_data, maps:put(Handle, Content, OpenData)),
            put(fake_files, maps:put(Path, Content, files())),
            ok
    end.

close(_Channel, Handle) ->
    call({close, Handle}),
    ok.

delete(_Channel, Path) ->
    call({delete, Path}),
    case failure(delete) of
        {ok, Reason} ->
            {error, Reason};
        error ->
            case maps:take(Path, files()) of
                {_Data, Remaining} ->
                    put(fake_files, Remaining),
                    ok;
                error ->
                    call({delete_missing, Path}),
                    {error, no_such_file}
            end
    end.

failure(Operation) ->
    maps:find(Operation, get_or(fake_failures, #{})).

call(Call) ->
    put(fake_calls, calls() ++ [Call]),
    ok.

get_or(Key, Default) ->
    case get(Key) of
        undefined -> Default;
        Value -> Value
    end.

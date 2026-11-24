%% ftp_upload - upload only the changed files from dist/ over SFTP.
%%
%% Reads one change per line on stdin, as produced by `ftp-sync plan`:
%%
%%   A<TAB>relative/path   added file
%%   M<TAB>relative/path   modified file
%%   T<TAB>relative/path   type-changed file
%%   D<TAB>relative/path   deleted file
%%
%% Environment (loaded from .env by the Taskfile):
%%   FTP_HOST, FTP_PORT, FTP_USER, FTP_ROUTE (absolute remote directory)
%%   FTP_PASSWORD (optional; empty means key-based authentication)
%%
%% SFTP calls go through a backend module so the escript can be tested without
%% a server. ftp_upload_sftp is the production backend.

-module(ftp_upload).

-export([main/1,
         run/0,
         read_config/0,
         parse_change/1,
         validate_path/1,
         ssh_options/1,
         upload/2,
         upload/3,
         apply_changes/5,
         ensure_dir/3,
         ensure_parent_dirs/4,
         ensure_dir_component/3,
         create_dir/3,
         upload_file/5,
         stream_file/5,
         new_progress/1,
         file_size/1,
         start_upload/2,
         print_progress/1,
         finish_progress/1,
         fraction/2,
         eta_string/2,
         format_duration/1,
         format_bytes/1,
         remote_join/2,
         count/2,
         format_error/1]).

-include_lib("kernel/include/file.hrl").

-define(CONNECT_TIMEOUT, 30000).
-define(CHUNK_SIZE, 65536).

%% Command line

main(_Args) ->
    try
        run(),
        halt(0)
    catch
        throw:{ftp_upload_error, Reason} ->
            io:format(standard_error, "ftp-upload: ~s~n", [format_error(Reason)]),
            halt(1)
    end.

run() ->
    Config = read_config(),
    Changes = read_changes(),
    case Changes of
        [] ->
            io:format("ftp-upload: no changes to upload~n"),
            ok;
        _ ->
            upload(Config, Changes),
            io:format("ftp-upload: ~p uploaded, ~p deleted (FTP_ROUTE: ~s)~n",
                      [count(upload, Changes), count(delete, Changes),
                       maps:get(route, Config)]),
            ok
    end.

%% Configuration and input parsing

read_config() ->
    Host = required_env("FTP_HOST"),
    Port = parse_port(required_env("FTP_PORT")),
    User = required_env("FTP_USER"),
    Route = absolute_route(required_env("FTP_ROUTE")),
    Password = optional_env("FTP_PASSWORD"),
    #{host => Host, port => Port, user => User, password => Password, route => Route}.

required_env(Name) ->
    case os:getenv(Name) of
        false -> throw({ftp_upload_error, {missing_env, Name}});
        Value ->
            case string:trim(Value) of
                "" -> throw({ftp_upload_error, {missing_env, Name}});
                Clean -> Clean
            end
    end.

optional_env(Name) ->
    case os:getenv(Name) of
        false -> "";
        Value -> string:trim(Value)
    end.

parse_port(PortString) ->
    case string:to_integer(PortString) of
        {Port, ""} when Port > 0, Port =< 65535 -> Port;
        _ -> throw({ftp_upload_error, {invalid_port, PortString}})
    end.

absolute_route(Route) ->
    Normalized =
        case string:trim(Route, trailing, "/") of
            "" -> "/";
            Trimmed -> Trimmed
        end,
    case Normalized of
        [$/ | _] -> Normalized;
        _ -> throw({ftp_upload_error, {route_not_absolute, Normalized}})
    end.

read_changes() ->
    Lines = read_lines([]),
    [parse_change(Line) || Line <- lists:reverse(Lines), Line =/= ""].

read_lines(Acc) ->
    case io:get_line(standard_io, "") of
        eof -> Acc;
        {error, Reason} -> throw({ftp_upload_error, {read_stdin, Reason}});
        Line -> read_lines([string:trim(Line, trailing, "\r\n") | Acc])
    end.

parse_change(Line) ->
    case string:split(Line, "\t") of
        ["A", Path] -> {upload, validate_path(Path)};
        ["M", Path] -> {upload, validate_path(Path)};
        ["T", Path] -> {upload, validate_path(Path)};
        ["D", Path] -> {delete, validate_path(Path)};
        _ -> throw({ftp_upload_error, {invalid_change_line, Line}})
    end.

%% Never let a change entry escape dist/ on the remote server.
validate_path(Path) ->
    Parts = string:split(Path, "/", all),
    Invalid = Path =:= "" orelse
              filename:pathtype(Path) =:= absolute orelse
              lists:member("..", Parts) orelse
              lists:member("", Parts),
    case Invalid of
        true -> throw({ftp_upload_error, {invalid_path, Path}});
        false -> Path
    end.

%% SFTP upload

upload(Config, Changes) ->
    upload(Config, Changes, ftp_upload_sftp).

upload(Config, Changes, Backend) ->
    case Backend:ensure_ssh_started() of
        ok -> ok;
        {ok, _Applications} -> ok;
        {error, StartReason} -> throw({ftp_upload_error, {start_ssh, StartReason}})
    end,
    #{host := Host, port := Port, route := Route} = Config,
    Options = ssh_options(Config),
    Uploads = [Path || {upload, Path} <- Changes],
    Progress0 = new_progress(Uploads),
    case Backend:start_channel(Host, Port, Options) of
        {ok, Channel, Connection} ->
            try
                ensure_dir(Channel, Route, Backend),
                apply_changes(Channel, Route, Changes, Progress0, Backend)
            after
                Backend:stop_channel(Channel),
                Backend:close_connection(Connection)
            end;
        {error, ConnectReason} ->
            throw({ftp_upload_error, {connect, ConnectReason}})
    end.

ssh_options(#{user := User, password := Password}) ->
    Base = [{user, User},
            {silently_accept_hosts, true},
            {user_interaction, false},
            {connect_timeout, ?CONNECT_TIMEOUT}],
    case Password of
        "" -> Base;
        _ -> [{password, Password} | Base]
    end.

apply_changes(Channel, Route, Changes, Progress, Backend) ->
    Final = lists:foldl(
              fun({Action, Path}, Acc) ->
                      apply_change(Channel, Route, Action, Path, Acc, Backend)
              end,
              Progress, Changes),
    finish_progress(Final),
    Final.

apply_change(Channel, Route, upload, Path, Progress0, Backend) ->
    Progress1 = start_upload(Path, Progress0),
    print_progress(Progress1),
    try
        ensure_parent_dirs(Channel, Route, Path, Backend),
        upload_file(Channel, Route, Path, Progress1, Backend)
    of
        Progress2 ->
            Done = maps:get(done_files, Progress2) + 1,
            Progress3 = Progress2#{done_files := Done,
                                   current_path := undefined,
                                   current_index := Done,
                                   current_size := 0,
                                   current_written := 0},
            print_progress(Progress3),
            report("~n", []),
            Progress3
    catch
        throw:Error ->
            report("~n", []),
            throw(Error)
    end;
apply_change(Channel, Route, delete, Path, Progress, Backend) ->
    Remote = remote_join(Route, Path),
    case Backend:delete(Channel, Remote) of
        ok -> ok;
        {error, no_such_file} -> ok;
        {error, Reason} -> throw({ftp_upload_error, {delete, Remote, Reason}})
    end,
    Progress.

%% Progress reporting

new_progress(Uploads) ->
    Sizes = maps:from_list([{Path, file_size(Path)} || Path <- Uploads]),
    #{total_files => length(Uploads),
      done_files => 0,
      start_ms => erlang:monotonic_time(millisecond),
      file_sizes => Sizes,
      current_path => undefined,
      current_index => 0,
      current_size => 0,
      current_written => 0}.

file_size(Path) ->
    case file:read_file_info(filename:join("dist", Path)) of
        {ok, Info} -> Info#file_info.size;
        {error, _} -> 0
    end.

start_upload(Path, Progress) ->
    Index = maps:get(done_files, Progress) + 1,
    Size = maps:get(Path, maps:get(file_sizes, Progress), 0),
    Progress#{current_path := Path,
              current_index := Index,
              current_size := Size,
              current_written := 0}.

print_progress(Progress = #{current_path := undefined,
                            done_files := Done,
                            total_files := Total}) ->
    Completed = fraction(Done, Total),
    Label = case Done >= Total of
                true -> "complete";
                false -> "file done"
            end,
    report("\r[~p/~p files, ~.1f%] eta ~s | ~s",
           [Done, Total, Completed * 100, eta_string(Progress, Completed), Label]);
print_progress(Progress) ->
    #{current_path := Path,
      current_index := Index,
      current_size := Size,
      current_written := Written,
      done_files := Done,
      total_files := Total} = Progress,
    CurrentFraction = fraction(Written, Size),
    Completed = fraction(Done + CurrentFraction, Total),
    report("\r[~p/~p files, ~.1f%] eta ~s | ~s: ~.1f% (~s/~s)",
           [Index, Total, Completed * 100, eta_string(Progress, Completed),
            Path, CurrentFraction * 100,
            format_bytes(Written), format_bytes(Size)]).

finish_progress(#{total_files := 0}) ->
    report("no files to upload~n", []);
finish_progress(#{total_files := Total}) ->
    report("\r[~p/~p files, 100.0%] eta 00:00 | upload complete~n", [Total, Total]).

report(Format, Args) ->
    case get(ftp_upload_quiet) of
        true -> ok;
        _ -> io:format(standard_io, Format, Args)
    end.

fraction(_Done, 0) ->
    1.0;
fraction(Done, Total) ->
    Value = Done / Total,
    case Value of
        V when V < 0 -> 0.0;
        V when V > 1 -> 1.0;
        V -> V
    end.

eta_string(Progress, Completed) ->
    Total = maps:get(total_files, Progress),
    Elapsed = erlang:monotonic_time(millisecond) - maps:get(start_ms, Progress),
    if
        Total =:= 0 -> "00:00";
        Completed =< 0 -> "estimating";
        Completed >= Total -> "00:00";
        true ->
            Remaining = Total - Completed,
            Ms = trunc(math:ceil(Elapsed * Remaining / Completed)),
            format_duration(Ms)
    end.

format_duration(Ms) when Ms < 1000 ->
    io_lib:format("~pms", [Ms]);
format_duration(Ms) ->
    Seconds = Ms div 1000,
    case Seconds < 60 of
        true ->
            io_lib:format("~ps", [Seconds]);
        false ->
            Minutes = Seconds div 60,
            Remaining = Seconds rem 60,
            case Minutes < 60 of
                true -> io_lib:format("~pm~2.2.0ps", [Minutes, Remaining]);
                false -> io_lib:format("~ph~2.2.0pm", [Minutes div 60, Minutes rem 60])
            end
    end.

format_bytes(Bytes) when Bytes < 1024 ->
    io_lib:format("~p B", [Bytes]);
format_bytes(Bytes) when Bytes < 1048576 ->
    io_lib:format("~.1f KB", [Bytes / 1024]);
format_bytes(Bytes) ->
    io_lib:format("~.1f MB", [Bytes / 1048576]).

%% make_dir/2 only creates a directory inside an existing one, so walk the
%% path one component at a time. Ancestors are stat-ed first because some SFTP
%% servers report MKDIR on an existing directory as a generic `failure`.
ensure_parent_dirs(Channel, Route, Path, Backend) ->
    Components = [Part || Part <- string:split(filename:dirname(Path), "/", all),
                           Part =/= "" andalso Part =/= "."],
    _ = lists:foldl(
          fun(Part, Parent) ->
                  Dir = remote_join(Parent, Part),
                  ensure_dir_component(Channel, Dir, Backend),
                  Dir
          end,
          Route,
          Components),
    ok.

ensure_dir(_Channel, "/", _Backend) ->
    ok;
ensure_dir(Channel, Route, Backend) ->
    Components = [Part || Part <- string:split(Route, "/", all), Part =/= ""],
    _ = lists:foldl(
          fun(Part, Parent) ->
                  Dir = remote_join(Parent, Part),
                  ensure_dir_component(Channel, Dir, Backend),
                  Dir
          end,
          "",
          Components),
    ok.

%% Stat before creating: an existing directory must never reach make_dir/2,
%% whose "already exists" error varies between SFTP implementations.
ensure_dir_component(Channel, Dir, Backend) ->
    case Backend:read_file_info(Channel, Dir) of
        {ok, #file_info{type = directory}} ->
            ok;
        {ok, #file_info{}} ->
            throw({ftp_upload_error, {remote_not_directory, Dir}});
        {error, no_such_file} ->
            create_dir(Channel, Dir, Backend);
        {error, no_such_path} ->
            create_dir(Channel, Dir, Backend);
        {error, enoent} ->
            create_dir(Channel, Dir, Backend);
        {error, Reason} ->
            throw({ftp_upload_error, {stat_dir, Dir, Reason}})
    end.

create_dir(Channel, Dir, Backend) ->
    case Backend:make_dir(Channel, Dir) of
        ok -> ok;
        {error, file_exists} -> ok;
        {error, file_already_exists} -> ok;
        {error, eexist} -> ok;
        {error, failure} ->
            %% A race or a server that maps EEXIST to SSH_FX_FAILURE is fine
            %% as long as the directory is present when we look again.
            case Backend:read_file_info(Channel, Dir) of
                {ok, #file_info{type = directory}} -> ok;
                _ -> throw({ftp_upload_error, {make_dir, Dir, failure}})
            end;
        {error, Reason} -> throw({ftp_upload_error, {make_dir, Dir, Reason}})
    end.

remote_join("", Part) -> "/" ++ Part;
remote_join("/", Part) -> "/" ++ Part;
remote_join(Base, Part) -> Base ++ "/" ++ Part.

upload_file(Channel, Route, Path, Progress, Backend) ->
    Local = filename:join("dist", Path),
    Remote = remote_join(Route, Path),
    case file:open(Local, [read, binary, raw]) of
        {ok, Fd} ->
            try
                %% [write] truncates an existing file on the server.
                case Backend:open(Channel, Remote, [write, binary]) of
                    {ok, Handle} ->
                        try stream_file(Channel, Handle, Fd, Progress, Backend)
                        after Backend:close(Channel, Handle) end;
                    {error, Reason} ->
                        throw({ftp_upload_error, {open_remote, Remote, Reason}})
                end
            after
                file:close(Fd)
            end;
        {error, Reason} ->
            throw({ftp_upload_error, {open_local, Local, Reason}})
    end.

stream_file(Channel, Handle, Fd, Progress, Backend) ->
    case file:read(Fd, ?CHUNK_SIZE) of
        {ok, Data} ->
            case Backend:write(Channel, Handle, Data) of
                ok ->
                    Written = maps:get(current_written, Progress) + byte_size(Data),
                    Progress1 = Progress#{current_written := Written},
                    print_progress(Progress1),
                    stream_file(Channel, Handle, Fd, Progress1, Backend);
                {error, Reason} ->
                    throw({ftp_upload_error, {write_remote, Reason}})
            end;
        eof ->
            Progress;
        {error, Reason} ->
            throw({ftp_upload_error, {read_local, Reason}})
    end.

%% Helpers

count(Action, Changes) ->
    length([ok || {Kind, _Path} <- Changes, Kind =:= Action]).

format_error({missing_env, Name}) ->
    io_lib:format("missing required environment variable ~s (load .env with task)", [Name]);
format_error({invalid_port, Port}) ->
    io_lib:format("invalid FTP_PORT: ~p", [Port]);
format_error({route_not_absolute, Route}) ->
    io_lib:format("FTP_ROUTE must be an absolute remote path, got: ~p", [Route]);
format_error({invalid_change_line, Line}) ->
    io_lib:format("invalid change line on stdin: ~p", [Line]);
format_error({invalid_path, Path}) ->
    io_lib:format("unsafe path in change list: ~p", [Path]);
format_error({read_stdin, Reason}) ->
    io_lib:format("could not read change list: ~p", [Reason]);
format_error({start_ssh, Reason}) ->
    io_lib:format("could not start the ssh application: ~p", [Reason]);
format_error({connect, timeout}) ->
    "SFTP connection timed out; check FTP_HOST and FTP_PORT (SFTP uses SSH port 22, not FTP port 21)";
format_error({connect, Reason}) ->
    io_lib:format("SFTP connection failed: ~p", [Reason]);
format_error({stat_dir, Dir, Reason}) ->
    io_lib:format("could not inspect remote directory ~p: ~p", [Dir, Reason]);
format_error({remote_not_directory, Path}) ->
    io_lib:format("remote path ~p exists but is not a directory", [Path]);
format_error({make_dir, Dir, failure}) ->
    io_lib:format("could not create remote directory ~p: failure (check FTP_ROUTE; if SFTP is chrooted to your home, use a path such as /public_html)", [Dir]);
format_error({make_dir, Dir, Reason}) ->
    io_lib:format("could not create remote directory ~p: ~p", [Dir, Reason]);
format_error({open_local, Path, Reason}) ->
    io_lib:format("could not read ~p: ~p", [Path, Reason]);
format_error({open_remote, Path, Reason}) ->
    io_lib:format("could not open remote file ~p for writing: ~p", [Path, Reason]);
format_error({read_local, Reason}) ->
    io_lib:format("could not read local file: ~p", [Reason]);
format_error({write_remote, Reason}) ->
    io_lib:format("could not write remote file: ~p", [Reason]);
format_error({delete, Path, Reason}) ->
    io_lib:format("could not delete remote file ~p: ~p", [Path, Reason]);
format_error(Reason) ->
    io_lib:format("~p", [Reason]).

%% ftp_sync - plan and commit SFTP uploads from website-manifest.json.
%%
%% plan prints one change per line for tools/ftp/ftp-upload:
%%
%%   A<TAB>relative/path   added file
%%   M<TAB>relative/path   content differs from the last uploaded hash
%%   D<TAB>relative/path   present in the cache but no longer in dist/
%%
%% Post pages are hashed per language with their random "Otras entradas"
%% section removed, home pages drop their random posts section, and Atom
%% feeds drop the build timestamp. commit advances the manifest cache only
%% after a successful upload; seed imports a legacy snapshot once.

-module(ftp_sync).

-export([main/2,
         md5_hex/1,
         stable_bytes/2,
         digest_file/1,
         digest_files/1,
         new_manifest/0,
         load_manifest/1,
         save_manifest/2,
         plan/2,
         commit/2,
         seed/2]).

-include_lib("kernel/include/file.hrl").

-define(MANIFEST_VERSION, 1).
-define(MANIFEST_NAME, "website-manifest.json").
-define(DIST_NAME, "dist").
-define(SNAPSHOT_NAME, ".ftp-upload-dist").

%% Build-only noise. The patterns match only generated markup, leaving the
%% rest of each page intact.
-define(HTML_OTHERS,
        <<"<section[^>]*class=\"rs-panel post-others\"[^>]*>.*?</section>">>).
-define(HTML_POSTS,
        <<"<section[^>]*\\bid=\"posts\"[^>]*>.*?</section>">>).
-define(XML_UPDATED, <<"<updated>.*?</updated>">>).

%% Command line

main(Args, Root) ->
    try
        run(Args, Root),
        halt(0)
    catch
        throw:{ftp_sync_error, Reason} ->
            io:format(standard_error, "ftp-sync: ~s~n", [format_error(Reason)]),
            halt(2);
        Class:Reason:_Stack ->
            io:format(standard_error, "ftp-sync: ~s~n",
                      [format_error({Class, Reason})]),
            halt(2)
    end.

run(Args, Root) ->
    {Command, Options} = parse_args(Args, #{root => Root}, undefined),
    Action = ensure_command(Command),
    Root1 = maps:get(root, Options),
    Dist = maps:get(dist, Options, filename:join([Root1, ?DIST_NAME])),
    Snapshot = maps:get(snapshot, Options, filename:join([Root1, ?SNAPSHOT_NAME])),
    case Action of
        "plan" ->
            lists:foreach(
              fun({Status, Path}) -> io:format("~s\t~s~n", [Status, Path]) end,
              plan(Root1, Dist));
        "commit" ->
            io:format("ftp-sync: cached ~p file hashes~n", [commit(Root1, Dist)]);
        "seed" ->
            io:format("ftp-sync: seeded ~p file hashes from ~s~n",
                      [seed(Root1, Snapshot), Snapshot])
    end.

parse_args([], _Options, undefined) ->
    throw({ftp_sync_error, missing_command});
parse_args([], Options, Command) ->
    {Command, Options};
parse_args(["--root", Value | Rest], Options, Command) ->
    parse_args(Rest, Options#{root => Value}, Command);
parse_args(["--dist", Value | Rest], Options, Command) ->
    parse_args(Rest, Options#{dist => Value}, Command);
parse_args(["--snapshot", Value | Rest], Options, Command) ->
    parse_args(Rest, Options#{snapshot => Value}, Command);
parse_args([Arg | Rest], Options, undefined) ->
    parse_args(Rest, Options, Arg);
parse_args([Arg | _Rest], _Options, _Command) ->
    throw({ftp_sync_error, {unexpected_argument, Arg}}).

ensure_command(Command) when Command =:= "plan";
                            Command =:= "commit";
                            Command =:= "seed" ->
    Command;
ensure_command(Command) ->
    throw({ftp_sync_error, {unknown_command, Command}}).

%% Planning and cache updates

plan(Root, Dist) ->
    Cached = ftp_files(load_manifest(manifest_path(Root))),
    Current = digest_files(Dist),
    Paths = lists:usort(maps:keys(Cached) ++ maps:keys(Current)),
    lists:reverse(lists:foldl(fun(Path, Acc) ->
                                  classify(Path, Cached, Current, Acc)
                              end, [], Paths)).

classify(Path, Cached, Current, Acc) ->
    case {maps:find(Path, Cached), maps:find(Path, Current)} of
        {{ok, _}, error} ->
            [{"D", Path} | Acc];
        {error, {ok, _}} ->
            [{"A", Path} | Acc];
        {{ok, Hash}, {ok, Hash}} ->
            Acc;
        {{ok, _}, {ok, _}} ->
            [{"M", Path} | Acc]
    end.

commit(Root, Dist) ->
    ManifestPath = manifest_path(Root),
    Manifest = load_manifest(ManifestPath),
    Files = digest_files(Dist),
    save_manifest(ManifestPath, Manifest#{<<"ftp">> => #{<<"files">> => Files}}),
    maps:size(Files).

seed(Root, Snapshot) ->
    ManifestPath = manifest_path(Root),
    Manifest = load_manifest(ManifestPath),
    case ftp_files(Manifest) of
        Files when map_size(Files) > 0 ->
            throw({ftp_sync_error, ftp_cache_already_populated});
        _ ->
            Files = digest_files(Snapshot),
            save_manifest(ManifestPath,
                          Manifest#{<<"ftp">> => #{<<"files">> => Files}}),
            maps:size(Files)
    end.

ftp_files(Manifest) ->
    maps:get(<<"files">>, maps:get(<<"ftp">>, Manifest)).

manifest_path(Root) ->
    filename:join([Root, ?MANIFEST_NAME]).

%% Hashing

digest_files(Dir) ->
    case filelib:is_dir(Dir) of
        true -> ok;
        false -> throw({ftp_sync_error, {not_a_directory, Dir}})
    end,
    lists:foldl(fun(Relative, Acc) -> digest_entry(Dir, Relative, Acc) end,
                #{}, walk(Dir, "")).

digest_entry(Dir, Relative, Acc) ->
    case filename:basename(Relative) of
        ".DS_Store" ->
            Acc;
        _ ->
            validate_relative(Relative),
            Key = list_to_binary(Relative),
            maps:put(Key, digest_file(filename:join([Dir, Relative])), Acc)
    end.

walk(Dir, Prefix) ->
    Current = case Prefix of
                  "" -> Dir;
                  _ -> filename:join([Dir, Prefix])
              end,
    case file:list_dir(Current) of
        {ok, Names} ->
            lists:foldr(fun(Name, Acc) ->
                            Relative = join_relative(Prefix, Name),
                            Full = filename:join([Dir, Relative]),
                            case file:read_link_info(Full) of
                                {ok, #file_info{type = directory}} ->
                                    walk(Dir, Relative) ++ Acc;
                                {ok, #file_info{type = regular}} ->
                                    [Relative | Acc];
                                {ok, #file_info{type = symlink}} ->
                                    Acc;
                                {ok, _} ->
                                    Acc;
                                {error, _} ->
                                    Acc
                            end
                        end, [], lists:sort(Names));
        {error, Reason} ->
            throw({ftp_sync_error, {list_dir, Current, Reason}})
    end.

join_relative("", Name) -> Name;
join_relative(Prefix, Name) -> filename:join([Prefix, Name]).

validate_relative(Relative) ->
    Invalid = lists:any(fun(C) -> C =:= $\t orelse C =:= $\r orelse C =:= $\n end,
                        Relative),
    case Invalid of
        true -> throw({ftp_sync_error, {invalid_file_name, Relative}});
        false -> ok
    end.

digest_file(Path) ->
    Data = read_file(Path),
    md5_hex(stable_bytes(Path, Data)).

stable_bytes(Path, Data) ->
    case extension(Path) of
        ".html" -> replace(?HTML_POSTS, replace(?HTML_OTHERS, Data));
        ".xml" -> replace(?XML_UPDATED, Data);
        _ -> Data
    end.

replace(Pattern, Data) ->
    re:replace(Data, Pattern, <<>>, [global, dotall, {return, binary}]).

extension(Path) ->
    string:lowercase(filename:extension(Path)).

md5_hex(Data) ->
    binary:encode_hex(erlang:md5(Data), lowercase).

read_file(Path) ->
    case file:read_file(Path) of
        {ok, Data} -> Data;
        {error, Reason} -> throw({ftp_sync_error, {read_file, Path, Reason}})
    end.

%% Manifest

new_manifest() ->
    #{<<"version">> => ?MANIFEST_VERSION,
      <<"images">> => #{},
      <<"downloads">> => #{},
      <<"covers">> => #{},
      <<"ftp">> => #{<<"files">> => #{}}}.

load_manifest(Path) ->
    case file:read_file(Path) of
        {error, enoent} ->
            new_manifest();
        {ok, Data} ->
            Manifest = json:decode(Data),
            case maps:get(<<"version">>, Manifest, undefined) of
                ?MANIFEST_VERSION -> ensure_sections(Manifest);
                1.0 -> ensure_sections(Manifest);
                Other ->
                    throw({ftp_sync_error,
                           {unsupported_manifest_version, Path, Other}})
            end;
        {error, Reason} ->
            throw({ftp_sync_error, {read_file, Path, Reason}})
    end.

ensure_sections(Manifest) ->
    Images = ensure_map(<<"images">>, Manifest),
    Downloads = ensure_map(<<"downloads">>, Manifest),
    Covers = ensure_map(<<"covers">>, Manifest),
    Ftp = ensure_map(<<"ftp">>, Manifest),
    Files = ensure_map(<<"files">>, Ftp),
    Manifest#{<<"images">> => Images,
              <<"downloads">> => Downloads,
              <<"covers">> => Covers,
              <<"ftp">> => Ftp#{<<"files">> => Files}}.

ensure_map(Key, Map) ->
    case maps:find(Key, Map) of
        {ok, Value} when is_map(Value) -> Value;
        {ok, _} -> throw({ftp_sync_error, {invalid_manifest_section, Key}});
        error -> #{}
    end.

save_manifest(Path, Manifest) ->
    atomic_write_file(Path, pretty_manifest(Manifest)).

pretty_manifest(Manifest) ->
    Ftp = maps:get(<<"ftp">>, Manifest, #{}),
    Pairs = [{<<"version">>, maps:get(<<"version">>, Manifest, ?MANIFEST_VERSION)},
             {<<"images">>, maps:get(<<"images">>, Manifest, #{})},
             {<<"downloads">>, maps:get(<<"downloads">>, Manifest, #{})},
             {<<"covers">>, maps:get(<<"covers">>, Manifest, #{})},
             {<<"ftp">>, #{<<"files">> => maps:get(<<"files">>, Ftp, #{})}}],
    iolist_to_binary([pretty_value({json_object, Pairs}, 0), $\n]).

pretty_value({json_object, Pairs}, Indent) ->
    case Pairs of
        [] ->
            <<"{}">>;
        _ ->
            Entries = [[indent(Indent + 1), encode_key(Key), <<": ">>,
                        pretty_value(Value, Indent + 1)]
                       || {Key, Value} <- Pairs],
            iolist_to_binary(["{\n", lists:join(",\n", Entries),
                              "\n", indent(Indent), "}"])
    end;
pretty_value(Map, Indent) when is_map(Map) ->
    pretty_value({json_object, lists:sort(maps:to_list(Map))}, Indent);
pretty_value(List, Indent) when is_list(List) ->
    case List of
        [] ->
            <<"[]">>;
        _ ->
            Entries = [[indent(Indent + 1), pretty_value(Value, Indent + 1)]
                       || Value <- List],
            iolist_to_binary(["[\n", lists:join(",\n", Entries),
                              "\n", indent(Indent), "]"])
    end;
pretty_value(Binary, _Indent) when is_binary(Binary) ->
    iolist_to_binary(json:encode(Binary));
pretty_value(Integer, _Indent) when is_integer(Integer) ->
    integer_to_binary(Integer);
pretty_value(true, _Indent) -> <<"true">>;
pretty_value(false, _Indent) -> <<"false">>;
pretty_value(null, _Indent) -> <<"null">>.

encode_key(Key) ->
    iolist_to_binary(json:encode(Key)).

indent(Levels) ->
    lists:duplicate(Levels * 2, $\s).

atomic_write_file(Path, Content) ->
    filelib:ensure_dir(Path),
    Temporary = Path ++ "." ++ integer_to_list(erlang:unique_integer([positive]))
                ++ ".tmp",
    try
        {ok, Handle} = file:open(Temporary, [write, binary, raw]),
        ok = file:write(Handle, Content),
        ok = file:sync(Handle),
        ok = file:close(Handle),
        ok = file:rename(Temporary, Path)
    catch
        Class:Reason ->
            _ = file:delete(Temporary),
            throw({ftp_sync_error, {write_manifest, {Class, Reason}}})
    end.

%% Errors

format_error({not_a_directory, Path}) ->
    io_lib:format("not a directory: ~s", [Path]);
format_error({unsupported_manifest_version, Path, Version}) ->
    io_lib:format("unsupported manifest version ~p in ~s", [Version, Path]);
format_error({invalid_file_name, Name}) ->
    io_lib:format("file name cannot be sent to ftp-upload: ~s", [Name]);
format_error({invalid_manifest_section, Key}) ->
    io_lib:format("invalid manifest section: ~s", [Key]);
format_error({read_file, Path, Reason}) ->
    io_lib:format("cannot read ~s: ~p", [Path, Reason]);
format_error({list_dir, Path, Reason}) ->
    io_lib:format("cannot list ~s: ~p", [Path, Reason]);
format_error({write_manifest, Reason}) ->
    io_lib:format("cannot write manifest: ~p", [Reason]);
format_error({unknown_command, Command}) ->
    io_lib:format("unknown command: ~s", [Command]);
format_error({unexpected_argument, Argument}) ->
    io_lib:format("unexpected argument: ~s", [Argument]);
format_error(missing_command) ->
    "missing command";
format_error(ftp_cache_already_populated) ->
    "ftp cache is already populated; refusing to overwrite it";
format_error({error, Reason}) ->
    io_lib:format("~p", [Reason]);
format_error({exit, Reason}) ->
    io_lib:format("~p", [Reason]);
format_error(Reason) ->
    io_lib:format("~p", [Reason]).

-module(ftp_upload_tests).

-include_lib("eunit/include/eunit.hrl").

setup() ->
    {ok, Original} = file:get_cwd(),
    Root = string:trim(os:cmd("mktemp -d")),
    ok = file:make_dir(filename:join([Root, "dist"])),
    ok = file:set_cwd(Root),
    ftp_upload_fake:reset(),
    put(ftp_upload_quiet, true),
    {Original, Root}.

cleanup({Original, Root}) ->
    ok = file:set_cwd(Original),
    os:cmd("rm -rf " ++ Root),
    ftp_upload_fake:reset(),
    erase(ftp_upload_quiet),
    ok.

write_dist(Root, Name, Content) ->
    Path = filename:join([Root, "dist", Name]),
    ok = filelib:ensure_dir(Path),
    ok = file:write_file(Path, Content),
    Path.

config(Route) ->
    #{host => "sftp.example.com",
      port => 22,
      user => "deploy",
      password => "",
      route => Route}.

has_call(Call, Calls) ->
    lists:member(Call, Calls).

parse_change_maps_plan_statuses_to_actions_test() ->
    ?assertEqual({upload, "index.html"}, ftp_upload:parse_change("A\tindex.html")),
    ?assertEqual({upload, "index.html"}, ftp_upload:parse_change("M\tindex.html")),
    ?assertEqual({upload, "index.html"}, ftp_upload:parse_change("T\tindex.html")),
    ?assertEqual({delete, "index.html"}, ftp_upload:parse_change("D\tindex.html")),
    ?assertThrow({ftp_upload_error, {invalid_change_line, "X\tindex.html"}},
                 ftp_upload:parse_change("X\tindex.html")),
    ?assertThrow({ftp_upload_error, {invalid_change_line, "A"}},
                 ftp_upload:parse_change("A")).

validate_path_rejects_paths_outside_dist_test() ->
    Invalid = ["", "/etc/passwd", "../secret", "a/../secret",
               "a//b", "a/b/", "./a/../../b"],
    lists:foreach(
      fun(Path) ->
              ?assertThrow({ftp_upload_error, {invalid_path, Path}},
                           ftp_upload:validate_path(Path))
      end,
      Invalid),
    ?assertEqual("blog/en/index.html",
                 ftp_upload:validate_path("blog/en/index.html")).

read_config_requires_and_normalizes_environment_test() ->
    Saved = save_env(),
    try
        lists:foreach(fun(Name) -> os:unsetenv(Name) end, env_names()),
        ?assertThrow({ftp_upload_error, {missing_env, "FTP_HOST"}},
                     ftp_upload:read_config()),
        os:putenv("FTP_HOST", " sftp.example.com "),
        ?assertThrow({ftp_upload_error, {missing_env, "FTP_PORT"}},
                     ftp_upload:read_config()),
        os:putenv("FTP_PORT", "22"),
        os:putenv("FTP_USER", " deploy "),
        os:putenv("FTP_ROUTE", "/public_html/"),
        os:putenv("FTP_PASSWORD", " secret "),
        ?assertEqual(#{host => "sftp.example.com",
                       port => 22,
                       user => "deploy",
                       password => "secret",
                       route => "/public_html"},
                     ftp_upload:read_config()),
        os:putenv("FTP_PORT", "21x"),
        ?assertThrow({ftp_upload_error, {invalid_port, "21x"}},
                     ftp_upload:read_config()),
        os:putenv("FTP_PORT", "22"),
        os:putenv("FTP_ROUTE", "public_html"),
        ?assertThrow({ftp_upload_error, {route_not_absolute, "public_html"}},
                     ftp_upload:read_config())
    after
        restore_env(Saved)
    end.

ssh_options_includes_password_only_when_present_test() ->
    Base = [{user, "deploy"},
            {silently_accept_hosts, true},
            {user_interaction, false},
            {connect_timeout, 30000}],
    ?assertEqual(Base, ftp_upload:ssh_options(#{user => "deploy", password => ""})),
    ?assertEqual([{password, "secret"} | Base],
                 ftp_upload:ssh_options(#{user => "deploy", password => "secret"})).

upload_creates_directories_uploads_files_and_deletes_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun({_Original, Root}) ->
             write_dist(Root, "index.html", <<"hello">>),
             write_dist(Root, "blog/en/story/index.html", <<"story">>),
             Changes = [{upload, "index.html"},
                        {upload, "blog/en/story/index.html"},
                        {delete, "old.html"}],
             ftp_upload:upload(config("/public_html"), Changes, ftp_upload_fake),

             Dirs = ftp_upload_fake:dirs(),
             ?assert(lists:member("/public_html", Dirs)),
             ?assert(lists:member("/public_html/blog", Dirs)),
             ?assert(lists:member("/public_html/blog/en", Dirs)),
             ?assertEqual(#{"/public_html/index.html" => <<"hello">>,
                            "/public_html/blog/en/story/index.html" => <<"story">>},
                          ftp_upload_fake:files()),

             Calls = ftp_upload_fake:calls(),
             ?assert(has_call(ensure_ssh_started, Calls)),
             ?assert(has_call({start_channel, "sftp.example.com", 22,
                               [{user, "deploy"},
                                {silently_accept_hosts, true},
                                {user_interaction, false},
                                {connect_timeout, 30000}]}, Calls)),
             ?assert(has_call({open, "/public_html/index.html"}, Calls)),
             ?assert(has_call({open, "/public_html/blog/en/story/index.html"}, Calls)),
             ?assert(has_call({delete, "/public_html/old.html"}, Calls)),
             ?assert(has_call({stop_channel, fake_channel}, Calls)),
             ?assert(has_call({close_connection, fake_connection}, Calls))
     end}.

upload_reuses_existing_directories_and_overwrites_files_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun({_Original, Root}) ->
             write_dist(Root, "index.html", <<"new">>),
             write_dist(Root, "blog/index.html", <<"blog">>),
             ftp_upload_fake:init(["/public_html", "/public_html/blog"],
                                  #{"/public_html/index.html" => <<"old">>}),
             Changes = [{upload, "index.html"}, {upload, "blog/index.html"}],
             ftp_upload:upload(config("/public_html"), Changes, ftp_upload_fake),

             ?assertEqual([], [Call || Call = {make_dir, _} <- ftp_upload_fake:calls()]),
             ?assertEqual(#{"/public_html/index.html" => <<"new">>,
                            "/public_html/blog/index.html" => <<"blog">>},
                          ftp_upload_fake:files())
     end}.

upload_ignores_already_missing_remote_files_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(_Fixture) ->
             ftp_upload_fake:init(["/public_html"], #{}),
             Changes = [{delete, "missing.html"}],
             ftp_upload:upload(config("/public_html"), Changes, ftp_upload_fake),
             ?assert(has_call({delete_missing, "/public_html/missing.html"},
                              ftp_upload_fake:calls()))
     end}.

upload_accepts_ssh_application_list_from_production_backend_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(_Fixture) ->
             ftp_upload_fake:return_ssh_apps(),
             ftp_upload:upload(config("/public_html"), [], ftp_upload_fake),
             ?assert(has_call(ensure_ssh_started, ftp_upload_fake:calls()))
     end}.

stream_file_writes_large_files_in_chunks_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun({_Original, Root}) ->
             Content = binary:copy(<<"x">>, 65546),
             write_dist(Root, "large.bin", Content),
             ftp_upload:upload(config("/public_html"), [{upload, "large.bin"}],
                               ftp_upload_fake),
             Sizes = [Size || {write, _Handle, Size} <- ftp_upload_fake:calls()],
             ?assertEqual([65536, 10], Sizes),
             ?assertEqual(Content,
                          maps:get("/public_html/large.bin", ftp_upload_fake:files()))
     end}.

upload_reports_start_and_connect_failures_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(_Fixture) ->
             ftp_upload_fake:fail(ensure_ssh_started, ssh_down),
             ?assertThrow({ftp_upload_error, {start_ssh, ssh_down}},
                          ftp_upload:upload(config("/public_html"), [],
                                            ftp_upload_fake)),
             ftp_upload_fake:reset(),
             ftp_upload_fake:fail(start_channel, econnrefused),
             ?assertThrow({ftp_upload_error, {connect, econnrefused}},
                          ftp_upload:upload(config("/public_html"), [],
                                            ftp_upload_fake))
     end}.

upload_aborts_on_remote_write_failure_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun({_Original, Root}) ->
             write_dist(Root, "index.html", <<"hello">>),
             ftp_upload_fake:fail(write, eio),
             ?assertThrow({ftp_upload_error, {write_remote, eio}},
                          ftp_upload:upload(config("/public_html"),
                                            [{upload, "index.html"}],
                                            ftp_upload_fake))
     end}.

ensure_dir_rejects_a_remote_file_as_route_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(_Fixture) ->
             ftp_upload_fake:init([], #{"/public_html" => <<"not a directory">>}),
             ?assertThrow({ftp_upload_error,
                           {remote_not_directory, "/public_html"}},
                          ftp_upload:ensure_dir(fake_channel, "/public_html",
                                                ftp_upload_fake))
     end}.

progress_and_path_helpers_test() ->
    ?assertEqual(0.5, ftp_upload:fraction(1, 2)),
    ?assertEqual(1.0, ftp_upload:fraction(1, 0)),
    ?assertEqual("512 B", lists:flatten(ftp_upload:format_bytes(512))),
    ?assertEqual("1.0 KB", lists:flatten(ftp_upload:format_bytes(1024))),
    ?assertEqual("1.5 MB", lists:flatten(ftp_upload:format_bytes(1572864))),
    ?assertEqual("/public_html/index.html",
                 ftp_upload:remote_join("/public_html", "index.html")),
    ?assertEqual("/index.html", ftp_upload:remote_join("/", "index.html")),
    Changes = [{upload, "a"}, {delete, "b"}],
    ?assertEqual(1, ftp_upload:count(upload, Changes)),
    ?assertEqual(1, ftp_upload:count(delete, Changes)),
    ?assertEqual(0, ftp_upload:count(upload, [{delete, "b"}])).

env_names() ->
    ["FTP_HOST", "FTP_PORT", "FTP_USER", "FTP_ROUTE", "FTP_PASSWORD"].

save_env() ->
    [{Name, os:getenv(Name)} || Name <- env_names()].

restore_env(Values) ->
    lists:foreach(
      fun({Name, false}) -> os:unsetenv(Name);
         ({Name, Value}) -> os:putenv(Name, Value)
      end,
      Values).

-module(ftp_sync_tests).

-include_lib("eunit/include/eunit.hrl").

setup() ->
    Root = string:trim(os:cmd("mktemp -d")),
    Dist = filename:join([Root, "dist"]),
    ok = file:make_dir(Dist),
    ok = ftp_sync:save_manifest(manifest_path(Root), ftp_sync:new_manifest()),
    Root.

cleanup(Root) ->
    os:cmd("rm -rf " ++ Root),
    ok.

manifest_path(Root) ->
    filename:join([Root, "website-manifest.json"]).

dist(Root) ->
    filename:join([Root, "dist"]).

write_dist(Root, Name, Content) ->
    Path = filename:join([Root, "dist", Name]),
    ok = filelib:ensure_dir(Path),
    ok = file:write_file(Path, Content),
    Path.

write_file(Root, Name, Content) ->
    Path = filename:join([Root, Name]),
    ok = filelib:ensure_dir(Path),
    ok = file:write_file(Path, Content),
    Path.

cache(Root, Files) ->
    Manifest = ftp_sync:load_manifest(manifest_path(Root)),
    ftp_sync:save_manifest(manifest_path(Root),
                           Manifest#{<<"ftp">> => #{<<"files">> => Files}}).

cached_files(Root) ->
    Manifest = ftp_sync:load_manifest(manifest_path(Root)),
    maps:get(<<"files">>, maps:get(<<"ftp">>, Manifest)).

plan_emits_only_new_changed_and_deleted_files_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(Root) ->
             write_dist(Root, "same.html", <<"same">>),
             write_dist(Root, "changed.html", <<"new">>),
             write_dist(Root, "fresh.gif", <<"GIF89a">>),
             cache(Root, #{<<"same.html">> => ftp_sync:md5_hex(<<"same">>),
                           <<"changed.html">> => ftp_sync:md5_hex(<<"old">>),
                           <<"gone.html">> => ftp_sync:md5_hex(<<"gone">>)}),
             ?assertEqual([{"M", <<"changed.html">>},
                           {"A", <<"fresh.gif">>},
                           {"D", <<"gone.html">>}],
                          ftp_sync:plan(Root, dist(Root))),
             ?assertEqual(ftp_sync:plan(Root, dist(Root)),
                          ftp_sync:plan(Root, dist(Root)))
     end}.

plan_is_empty_when_content_matches_the_cache_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(Root) ->
             write_dist(Root, "index.html", <<"<html></html>">>),
             write_dist(Root, "blog/cover.gif", <<"GIF89a">>),
             cache(Root, #{<<"index.html">> => ftp_sync:md5_hex(<<"<html></html>">>),
                           <<"blog/cover.gif">> => ftp_sync:md5_hex(<<"GIF89a">>)}),
             ?assertEqual([], ftp_sync:plan(Root, dist(Root)))
     end}.

commit_replaces_the_cache_with_dist_hashes_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(Root) ->
             write_dist(Root, "index.html", <<"page">>),
             cache(Root, #{<<"obsolete.html">> => ftp_sync:md5_hex(<<"old">>)}),
             ?assertEqual(1, ftp_sync:commit(Root, dist(Root))),
             ?assertEqual(#{<<"index.html">> => ftp_sync:md5_hex(<<"page">>)},
                          cached_files(Root)),
             ?assertEqual([], ftp_sync:plan(Root, dist(Root)))
     end}.

seed_imports_the_legacy_snapshot_once_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(Root) ->
             Snapshot = filename:join([Root, ".ftp-upload-dist"]),
             write_file(Root, ".ftp-upload-dist/blog/cover.gif", <<"GIF89a">>),
             write_dist(Root, "blog/cover.gif", <<"GIF89a">>),
             ?assertEqual(1, ftp_sync:seed(Root, Snapshot)),
             ?assertEqual([], ftp_sync:plan(Root, dist(Root))),
             ?assertThrow({ftp_sync_error, ftp_cache_already_populated},
                          ftp_sync:seed(Root, Snapshot))
     end}.

post_page_hash_ignores_random_recommendations_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(Root) ->
             Path = write_dist(
                      Root,
                      "blog/en/story/index.html",
                      <<"<html><h1>Story</h1><section class=\"rs-panel post-others\">"
                        "<ul><li>First pick</li></ul></section></html>">>),
             cache(Root, #{<<"blog/en/story/index.html">> =>
                           ftp_sync:digest_file(Path)}),
             ?assertEqual([], ftp_sync:plan(Root, dist(Root))),
             ok = file:write_file(
                    Path,
                    <<"<html><h1>Story</h1><section class=\"rs-panel post-others\">"
                      "<ul><li>Different pick</li></ul></section></html>">>),
             ?assertEqual([], ftp_sync:plan(Root, dist(Root))),
             ok = file:write_file(
                    Path,
                    <<"<html><h1>Revised story</h1><section class=\"rs-panel post-others\">"
                      "<ul><li>Different pick</li></ul></section></html>">>),
             ?assertEqual([{"M", <<"blog/en/story/index.html">>}],
                          ftp_sync:plan(Root, dist(Root)))
     end}.

home_hash_ignores_random_posts_section_test() ->
    First = ftp_sync:stable_bytes(
              "index.html",
              <<"<div id=\"hero\"></div><section class=\"rs-panel\" id=\"posts\">"
                "A</section>">>),
    Second = ftp_sync:stable_bytes(
               "index.html",
               <<"<div id=\"hero\"></div><section class=\"rs-panel\" id=\"posts\">"
                 "B</section>">>),
    Edited = ftp_sync:stable_bytes(
               "index.html",
               <<"<div id=\"hero\" data-new></div><section class=\"rs-panel\" id=\"posts\">"
                 "A</section>">>),
    ?assertEqual(First, Second),
    ?assertNotEqual(First, Edited).

feed_hash_ignores_build_timestamp_test() ->
    First = ftp_sync:stable_bytes(
              "atom.xml",
              <<"<feed><updated>2026-01-01T00:00:00Z</updated><entry/></feed>">>),
    Second = ftp_sync:stable_bytes(
               "atom.xml",
               <<"<feed><updated>2026-11-23T12:00:00Z</updated><entry/></feed>">>),
    Edited = ftp_sync:stable_bytes(
               "atom.xml",
               <<"<feed><updated>2026-01-01T00:00:00Z</updated><entry>new</entry></feed>">>),
    ?assertEqual(First, Second),
    ?assertNotEqual(First, Edited).

manifest_keeps_image_sections_when_ftp_cache_changes_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(Root) ->
             Manifest = ftp_sync:load_manifest(manifest_path(Root)),
             Images = maps:get(<<"images">>, Manifest),
             ftp_sync:save_manifest(
               manifest_path(Root),
               Manifest#{<<"images">> =>
                         Images#{<<"blog/a/cover.png">> => <<"sha256">>}}),
             write_dist(Root, "index.html", <<"page">>),
             ok = ftp_sync:commit(Root, dist(Root)),
             {ok, Data} = file:read_file(manifest_path(Root)),
             Saved = json:decode(Data),
             ?assertEqual(#{<<"blog/a/cover.png">> => <<"sha256">>},
                          maps:get(<<"images">>, Saved)),
             ?assertEqual(#{}, maps:get(<<"downloads">>, Saved)),
             ?assertEqual(#{}, maps:get(<<"covers">>, Saved))
     end}.

manifest_keeps_post_dates_when_ftp_cache_changes_test() ->
    {setup, fun setup/0, fun cleanup/1,
     fun(Root) ->
             Posts = #{<<"newest">> => <<"2026-11-16T03:00:00Z">>,
                       <<"older">> => <<"2026-01-01T00:00:00Z">>},
             Latest = #{<<"slug">> => <<"newest">>,
                        <<"date">> => <<"2026-11-16T03:00:00Z">>},
             Manifest = ftp_sync:load_manifest(manifest_path(Root)),
             ftp_sync:save_manifest(
               manifest_path(Root),
               Manifest#{<<"posts">> => Posts, <<"latest_post">> => Latest}),
             write_dist(Root, "index.html", <<"page">>),
             ok = ftp_sync:commit(Root, dist(Root)),
             {ok, Data} = file:read_file(manifest_path(Root)),
             Saved = json:decode(Data),
             ?assertEqual(Posts, maps:get(<<"posts">>, Saved)),
             ?assertEqual(Latest, maps:get(<<"latest_post">>, Saved))
      end}.

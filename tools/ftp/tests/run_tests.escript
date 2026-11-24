#!/usr/bin/env escript
%%! -noshell

%% Compile the FTP modules and their EUnit suites directly from source, so no
%% .beam files are needed in the repository.

main(_Args) ->
    Directory = filename:dirname(filename:absname(escript:script_name())),
    FtpDirectory = filename:absname(filename:join([Directory, ".."])),
    load_module(filename:join([FtpDirectory, "ftp_sync.erl"])),
    load_module(filename:join([FtpDirectory, "ftp_upload_sftp.erl"])),
    load_module(filename:join([FtpDirectory, "ftp_upload.erl"])),
    load_module(filename:join([Directory, "ftp_sync_tests.erl"])),
    load_module(filename:join([Directory, "ftp_upload_fake.erl"])),
    load_module(filename:join([Directory, "ftp_upload_tests.erl"])),
    case eunit:test([ftp_sync_tests, ftp_upload_tests], [verbose]) of
        ok -> halt(0);
        _ -> halt(1)
    end.

load_module(Source) ->
    Module = list_to_atom(filename:basename(Source, ".erl")),
    case compile:file(Source, [binary, return_errors, return_warnings]) of
        {ok, Module, Binary, _Warnings} ->
            code:load_binary(Module, Source, Binary);
        {error, Errors, Warnings} ->
            io:format(standard_error, "cannot compile ~s:~n~p~n~p~n",
                      [Source, Errors, Warnings]),
            halt(1)
    end.

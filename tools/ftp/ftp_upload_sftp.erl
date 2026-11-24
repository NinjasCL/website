%% Production SFTP backend for ftp_upload. Keeping these calls behind a module
%% lets the EUnit suite inject a fake backend without a real server.

-module(ftp_upload_sftp).

-export([ensure_ssh_started/0,
         start_channel/3,
         stop_channel/1,
         close_connection/1,
         read_file_info/2,
         make_dir/2,
         open/3,
         write/3,
         close/2,
         delete/2]).

ensure_ssh_started() ->
    application:ensure_all_started(ssh).

start_channel(Host, Port, Options) ->
    ssh_sftp:start_channel(Host, Port, Options).

stop_channel(Channel) ->
    ssh_sftp:stop_channel(Channel).

close_connection(Connection) ->
    ssh:close(Connection).

read_file_info(Channel, Path) ->
    ssh_sftp:read_file_info(Channel, Path).

make_dir(Channel, Path) ->
    ssh_sftp:make_dir(Channel, Path).

open(Channel, Path, Options) ->
    ssh_sftp:open(Channel, Path, Options).

write(Channel, Handle, Data) ->
    ssh_sftp:write(Channel, Handle, Data).

close(Channel, Handle) ->
    ssh_sftp:close(Channel, Handle).

delete(Channel, Path) ->
    ssh_sftp:delete(Channel, Path).

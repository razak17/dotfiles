local mp = require "mp"
local utils = require "mp.utils"

local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
if not runtime_dir or runtime_dir == "" then
    mp.msg.warn("XDG_RUNTIME_DIR is unset; session IPC is disabled")
    return
end

local socket_dir = utils.join_path(runtime_dir, "mpvSockets")
local mkdir = utils.subprocess({
    args = { "mkdir", "-p", "-m", "700", "--", socket_dir },
    cancellable = false,
})

if mkdir.status ~= 0 then
    mp.msg.error("could not create MPV IPC directory: " .. socket_dir)
    return
end

local socket_path = utils.join_path(socket_dir, tostring(utils.getpid()))
os.remove(socket_path)
mp.set_property("input-ipc-server", socket_path)

mp.register_event("shutdown", function()
    os.remove(socket_path)
end)

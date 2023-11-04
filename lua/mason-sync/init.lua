local registry = require("mason-registry")
local memory = require("mason-sync.memory")
local options = require("mason-sync.options")
local serde = require("mason-sync.serde")
local json = require("JSON")

local M = {}

local on_install_success_handler = function (pkg, handler)
    if not vim.tbl_contains(memory.serverlist, pkg.name) then
        table.insert(memory.serverlist, pkg.name)
    end
    serde.export(memory.filepath, memory.serverlist)
    vim.notify(("Added %s to servers.json"):format(pkg.name))
end

local on_uninstall_success_handler = function (pkg)
    memory.serverlist = vim.tbl_filter(
        function (value)
            return value ~= pkg.name
        end,
        memory.serverlist)

    serde.export(memory.filepath, memory.serverlist)
    vim.notify(("Removed %s from servers.json"):format(pkg.name))
end

M.setup = function (opts)
    options.parse_options(opts)

    memory.filepath = vim.fs.normalize(vim.fs.joinpath(options.options.root_dir, options.options.file))
    memory.filename = vim.fs.basename(memory.filepath)
    local fd, errstr = io.open(memory.filepath, "r")

    if fd ~= nil then
        local decoded_table = json:decode(fd:read("a"))
        if type(decoded_table) == "table" then
            memory.serverlist = decoded_table
        else
            warn(("Contents of '%s' did not parse to a table. In memory server list is empty"):format(memory.filename))
        end
        fd:close()
    elseif errstr ~= nil then
        warn(errstr)
    else
        warn(("An unknown issue occurred when trying to open '%s'"):format(memory.filename))
    end

    registry:on("package:install:success", vim.schedule_wrap(on_install_success_handler))
    registry:on("package:uninstall:success", vim.schedule_wrap(on_uninstall_success_handler))

    -- Function to handle syncing from Servers to the file
    vim.api.nvim_create_user_command("MasonSync", function (args_table)

        local all_servers = registry.get_installed_package_names()
        serde.export(memory.filepath, all_servers)
        vim.notify(("Synced %s"):format(memory.filename))
    end, {})
end


M.ensure_servers = function ()
    return memory.serverlist
end

return M

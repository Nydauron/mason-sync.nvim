local registry = require("mason-registry")
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then mason_lspconfig = nil end

local memory = require("mason-sync.memory")
local options = require("mason-sync.options")
local serde = require("mason-sync.serde")
local JSON = require("JSON")

local M = {}

local on_install_success_handler = function (pkg, handler)
    if not vim.tbl_contains(memory.serverlist, pkg.name) then
        table.insert(memory.serverlist, pkg.name)
    end
    serde.export(memory.filepath, memory.serverlist)
    vim.notify(("Added %s to %s"):format(pkg.name, memory.filename))
end

local on_uninstall_success_handler = function (pkg)
    memory.serverlist = vim.tbl_filter(
        function (value)
            return value ~= pkg.name
        end,
        memory.serverlist)

    serde.export(memory.filepath, memory.serverlist)
    vim.notify(("Removed %s from %s"):format(pkg.name, memory.filename))
end

M.setup = function (opts)
    options.parse_options(opts)

    if vim.version.lt(vim.version(), {0, 10, 0}) then
        -- < v0.10.0
        memory.filepath = vim.fs.normalize(options.options.root_dir .. "/" .. options.options.file)
    else
        -- >= v0.10.0
        -- vim.fs.joinpath is a v0.10 sepc
        memory.filepath = vim.fs.normalize(vim.fs.joinpath(options.options.root_dir, options.options.file))
    end
    memory.filename = vim.fs.basename(memory.filepath)

    local serverlist, err = serde.import(memory.filepath)
    if err == nil then
        memory.serverlist = serverlist
    end

    if options.options.sync_on_mason_change.on_install then
        registry:on("package:install:success", vim.schedule_wrap(on_install_success_handler))
    end
    if options.options.sync_on_mason_change.on_uninstall then
        registry:on("package:uninstall:success", vim.schedule_wrap(on_uninstall_success_handler))
    end

    -- Function to handle syncing from Servers to the file
    vim.api.nvim_create_user_command("MasonSync", function (args_table)
        -- local name, args, fargs = table.unpack(args_table, 1, 3)

        local all_servers = registry.get_installed_package_names()
        serde.export(memory.filepath, all_servers)
        vim.notify(("Synced %s"):format(memory.filename))
    end, {})
    -- vim.api.nvim_create_user_command("MasonSyncDiff", , {})
end

M.ensure_installed_servers = function ()
    return vim.tbl_map(function (mason_name)
        local name = mason_name
        if mason_lspconfig then
            name = mason_lspconfig.get_mappings().mason_to_lspconfig[name] or name
        end
        return name
    end, memory.serverlist)
end

M.get_serverlist = function ()
    return memory.serverlist
end

return M

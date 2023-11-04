local plenary_ok, plenary = pcall(require, "plenary")
if not plenary_ok then
    error("Make sure you have plenary installed!", 1)
end
local options = require("mason-sync.options")
local json = require("JSON")

local M = {}

-- Assuming all options are of valid types
-- This function is synchronous
M.export = function (filepath, serverlist)
    local filetype = plenary.filetype.detect_from_extension(filepath)

    if filetype == "json" then
        local servers_json_str = JSON:encode(serverlist, nil, { pretty = true, indent = "    ", array_newline = true })

        if options.options.git.enable then
            error("Not implemented yet")
        else
            if filepath == nil then
                error("Joining of paths root_dir and file failed")
            end

            local fd = io.open(filepath, "w")

            if fd == nil then
                error(("File '%s' could not be opened"):format(filepath))
            end

            local status = fd:write(servers_json_str)

            if status == nil then
                error(("Error occurred when writing to '%s' (Code: %d)"):format(filepath, status))
            end

            fd:close()
        end
    end
end

return M

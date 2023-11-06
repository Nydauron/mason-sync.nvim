local plenary_ok, plenary = pcall(require, "plenary")
if not plenary_ok then
    error("Make sure you have plenary installed!", 1)
end
local JSON = require("JSON")
local options = require("mason-sync.options")

local M = {}

-- A synchronous importer. Deserializes based on the file's extension
---@param filepath string
---@return table<string>, string | nil
M.import = function(filepath)
    local fd, errstr = io.open(filepath, "r")

    local decoder = function(fd)
        local filetype = plenary.filetype.detect_from_extension(filepath)
        if filetype == "json" then
            return JSON:decode(fd:read("a"))
        end
        return nil
    end

    if fd ~= nil then
        local decoded_table = decoder(fd)
        fd:close()
        if type(decoded_table) == "table" then
            return decoded_table, nil
        else
            errstr = ("Contents of '%s' did not parse to a table. In memory server list is empty"):format(
                filepath
            )
            vim.notify(errstr)
            return {}, errstr
        end
    elseif errstr ~= nil then
        vim.notify(errstr)
        return {}, errstr
    else
        errstr = ("An unknown issue occurred when trying to open '%s'"):format(filepath)
        vim.notify(errstr)
        return {}, errstr
    end
end

-- A synchronous exporter. Serializes based on the file's extension
---@param filepath string
---@param serverlist table<string>
---@return nil
M.export = function(filepath, serverlist)
    local filetype = plenary.filetype.detect_from_extension(filepath)

    if filetype == "json" then
        local servers_json_str =
            JSON:encode(serverlist, nil, { pretty = true, indent = "    ", array_newline = true })

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

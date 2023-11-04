local M = {}

local default_opts = {
    -- The file used for storing all installed Mason servers. Defaults to root of git repo (if git
    -- option is enabled) or root of neovim config
    -- TODO: look to add option to export to different filetypes (JSON, YAML, TOML)
    file = "servers.json",
    -- Root directory where file will reside. Defaults to where ever stdpath("config") returns
    root_dir = vim.fn.stdpath("config"),
    git = {
        -- Enables Git integration
        enable = false,
        -- git (default): Runs git with CLI commands
        -- fugitive: Uses the vim plugin fugitive
        -- TODO: Check again how well fugitive will work
        -- Maybe by attaching listeners to the commit buffer
        flavor = 'git',
        -- Branch you want to commit to
        branch = 'master',
        -- The absolute path to the Git repo. If none specified, uses root_dir
        work_tree = "",
        -- The absolute path to the .git folder associated with the repo. If not specified, it will
        -- assume `${work_tree}/.git` as the path
        git_dir = "",
        -- function that generates a commit message. If set to nil or returns nil, it will fallback
        -- to manual prompt
        commit_message = function ()
            return nil
        end
    },
}

if type(default_opts.root_dir) ~= "string" then
    error("vim.fn.stdpath(\"config\") did not return a string type", 1)
end

local options_acceptable_types = {
    file = { "string" },
    root_dir = { "string" },
    git = {
        enable = { "bool" },
        flavor = { "string" },
        branch = { "string" },
        work_tree = { "string", "nil" },
        git_dir = { "string", "nil" },
        commit_message = { "string", "function", "nil" }
    },
}

M.options = default_opts

M.set_options = function (opts)
    for key, value in pairs(opts) do
        -- TODO: this is def not covering nested tables
        M.options[key] = value
    end
end

M.parse_options = function (opts)
    if opts == nil or type(opts) ~= "table" or opts == {} then
        M.options = default_opts
        return
    end

    local parser
    parser = function (default_opts, user_opts)
        local opts = default_opts
        for key, default_value in pairs(default_opts) do
            if vim.tbl_contains(vim.tbl_keys(user_opts), key) then
                if type(default_value) == "table" and not vim.tbl_islist(default_value) then
                    -- recurse
                    local sub_options = parser(default_value, user_opts[key])
                    opts[key] = sub_options
                    goto continue
                end
                if vim.tbl_contains(options_acceptable_types[key], type(user_opts[key])) then
                    opts[key] = user_opts[key]
                end
            end
            ::continue::
        end
        return opts
    end

    M.options = parser(default_opts, opts)
end

return M

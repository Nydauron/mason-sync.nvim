local M = {}

local default_opts = {
    -- The file used for storing all installed Mason servers. Defaults
    -- to root of git repo (if git option is enabled) or root of neovim
    -- config
    ---@type string
    file = "servers.json",
    -- The root directory where `file` will reside. Defaults to whereever
    -- `stdpath("config")` returns
    ---@type string
    root_dir = vim.fn.stdpath("config"),
    sync_on_mason_change = {
        -- After each sucessful Mason install, mason-sync will sync the
        -- current list of plugins to `file`
        ---@type boolean
        on_install = true,
        -- After each sucessful Mason uninstall, mason-sync will sync the
        -- current list of plugins to `file`
        ---@type boolean
        on_uninstall = true,
    },
    git = {
        -- Enables Git integration
        ---@type boolean
        enable = false,
        -- git (default): Runs git with CLI commands
        -- fugitive: Uses the vim plugin fugitive
        -- TODO: Check again how well fugitive will work
        -- Maybe by attaching listeners to the commit buffer
        ---@type "git" | "fugitive"
        flavor = "git",
        -- Branch you want to commit to
        ---@type string
        branch = "master",
        -- The absolute path to the Git repo. If none specified, uses root_dir
        ---@type string | nil
        work_tree = "",
        -- The absolute path to the .git folder associated with the repo. If not specified, it will
        -- assume `${work_tree}/.git` as the path
        ---@type string | nil
        git_dir = "",
        -- function that generates a commit message. If set to nil or returns nil, it will fallback
        -- to manual prompt
        ---@type string | function | nil
        commit_message = function ()
            return nil
        end
    },
}

local options_acceptable_types = {
    file = { "string" },
    root_dir = { "string" },
    sync_on_mason_change = {
        on_install = { "boolean" },
        on_uninstall = { "boolean" },
    },
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

M.parse_options = function (opts)
    if opts == nil or type(opts) ~= "table" or opts == {} then
        M.options = default_opts
        return
    end

    local parser
    parser = function (default_opts, user_opts, acceptable_types)
        local opts = default_opts
        for key, default_value in pairs(default_opts) do
            if vim.tbl_contains(vim.tbl_keys(user_opts), key) then
                if type(default_value) == "table" and not vim.tbl_islist(default_value) then
                    -- recurse
                    local sub_options = parser(default_value, user_opts[key], acceptable_types[key])
                    opts[key] = sub_options
                    goto continue
                end
                if vim.tbl_contains(acceptable_types[key], type(user_opts[key])) then
                    opts[key] = user_opts[key]
                end
            end
            ::continue::
        end
        return opts
    end

    M.options = parser(default_opts, opts, options_acceptable_types)
end

return M

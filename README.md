# mason-sync.nvim
A NeoVim plugin that saves your Mason installs to your nvim configuration

## Installation

Packer:

```lua
    use {
        '/home/jareth/Git/neovim-plugins/mason-sync.nvim/',
        requires = {'nvim-lua/plenary.nvim'},
    }
```

## Default configuration

```lua
require("mason-sync").setup({
    -- A relative file path pointing to where mason-sync should write all installed Mason servers.
    -- This will be joined with respect to root_dir.
    file = "servers.json",
    -- Root directory where file will reside.
    root_dir = vim.fn.stdpath("config"),
})
```

## Commands

- `MasonSync`: Hard refreshes the server file list with all the current server installs that are
tracked by Mason.

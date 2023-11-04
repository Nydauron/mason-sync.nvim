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
    sync_on_mason_change = {
        -- After each sucessful Mason install, mason-sync will sync the current list of plugins to
        -- the file specified
        on_install = true,
        -- After each sucessful Mason uninstall, mason-sync will sync the current list of plugins
        -- to the file specified
        on_uninstall = true,
    },
})
```

## Commands

- `MasonSync`: Hard refreshes the server file list with all the current server installs that are
tracked by Mason.

## Why?

When configuring my neovim rice, I liked having Mason as an option to quickly install LSPs, linters,
and formatters. However, I found it a bit annoying that if I wanted to quickly set up my config on
another machine, not all the LSP servers would install because they were missing in my
`ensure_installed` list. On top of that, uninstalling servers that were in your `ensure_installed`
list didn't really serve a purpose if since they would reinstall upon the next neovim session (if you
forgot to remove the item.)

The purpose of `mason-sync.nvim` is to provide a quick way of keeping your list of Mason servers in
your config up-to-date after every install and uninstall.

## Who might find this plugin useful?

Those who use their neovim config across multiple machines and/or are actively learning new
languages will find this plugin beneficial.

# Neovim Configuration Notes

This is a personal reference document for my Neovim setup. Its purpose is to track the structure, installed plugins, and key configurations for my own use.

## 1. Configuration Structure

My setup is organized into logical directories to keep things clean and maintainable.

```
~/.config/nvim
├── lua/
│   ├── config/      -- Core Neovim settings (options, keymaps, etc.)
│   └── plugins/     -- Plugin specifications, one file per category.
└── init.lua         -- The main entry point.
```

## 2. Core Configuration (`lua/config/`)

These files control the fundamental behavior of Neovim.

* `options.lua`: Global settings like line numbers, indentation, and search behavior (`vim.opt`).
* `keymaps.lua`: Global key mappings that aren't specific to a plugin (`vim.keymap.set`). My `<leader>` key is `Space`.
* `autocmds.lua`: Automation rules, like formatting on save or highlighting yanked text.
* `lazy.lua`: The bootstrap and setup file for the `lazy.nvim` plugin manager.

## 3. Installed Plugins (`lua/plugins/`)

Plugins are managed by `lazy.nvim` and are defined in files within this directory.

### UI Enhancements

* **`nvim-lualine/lualine.nvim`**: A fast and highly configurable statusline.
* **`catppuccin/nvim`**: The colorscheme for the editor.
* **`nvim-tree/nvim-web-devicons`**: Adds file-type icons to various plugins like Lualine.

### Editing & Functionality

* **`nvim-telescope/telescope.nvim`**: A powerful fuzzy finder for files, text, buffers, and more.
* **`nvim-treesitter/nvim-treesitter`**: Provides advanced syntax highlighting and code parsing.
* **`numToStr/Comment.nvim`**: Easy commenting with `gcc` (line) and `gc` (block).

### LSP & Autocompletion

* **`williamboman/mason.nvim`**: Manages LSP servers, formatters, and linters.
* **`neovim/nvim-lspconfig`**: The base configuration for setting up LSP servers.
* **`hrsh7th/nvim-cmp`**: The autocompletion engine.

## 4. Key Mappings Log

I have not set any custom keybindings yet.

As I create mappings in `lua/config/keymaps.lua`, I will document the important ones here for my own reference.

## 5. External Dependencies

List of tools that need to be installed on the system for everything to work correctly.

* A **Nerd Font** is required for icons.
* `ripgrep`: For Telescope's `live_grep`.
* `fd`: For faster file finding in Telescope.

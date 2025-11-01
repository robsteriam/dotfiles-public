return {
  "nvim-treesitter/nvim-treesitter",
  branch = 'master',
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require'nvim-treesitter.configs'.setup {
      modules = {},
      sync_install = false,
      ignore_install = {},
      ensure_installed = {
        "c", "css", "go", "html", "javascript", "lua", "markdown", "markdown_inline", "php", "python", "query", "rust", "typescript", "vim", "vimdoc"
      },
      auto_install = false,
      indent = {
        enable = true,
      },
      highlight = {
        enable = true,
        disable = function(_, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
    }
  end,
}

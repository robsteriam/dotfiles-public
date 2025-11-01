return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "auto",
			background = {
				light = "latte",
				dark = "macchiato",
			},
			transparent_background = false,
      float = {
        transparent = false,
        solid = false,
      },
			auto_integrations = true,
	})
	vim.cmd.colorscheme "catppuccin"
end,
}

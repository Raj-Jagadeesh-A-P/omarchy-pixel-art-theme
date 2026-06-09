return {
	{
		"sainnhe/pixel-art",
		priority = 1000,
		config = function()
			vim.g.pixel_art_background = "hard"
			vim.g.pixel_art_transparent_background = 1
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "pixel-art",
		},
	},
}

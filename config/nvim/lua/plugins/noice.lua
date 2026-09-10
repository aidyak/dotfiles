return {
	-- nvim-notify のみ使用（noice.nvimは不安定なため無効）
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			local notify = require("notify")
			notify.setup({
				stages = "fade_in_slide_out",
				timeout = 3000,
				background_colour = "#000000",
			})
			vim.notify = notify
		end,
	},
}

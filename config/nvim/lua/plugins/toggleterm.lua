return {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = {
		{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		{ "<C-t>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		{ "<C-t>", "<cmd>ToggleTerm<cr>", mode = "t", desc = "Toggle terminal" },
	},
	opts = {
		direction = "float",
		float_opts = {
			border = "curved",
		},
	},
}

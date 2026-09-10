return {
	"aidyak/nautilus",
	lazy = true,
	config = function()
		require("nautilus").setup({
			transparent = false,
		})
	end,
}

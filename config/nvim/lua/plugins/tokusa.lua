return {
	"aidyak/tokusa",
	lazy = true,
	opts = {},
	config = function(_, opts)
		require("tokusa").setup(opts)
	end,
}

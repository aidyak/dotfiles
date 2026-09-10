return {
  "aidyak/parthenon",
  cmd = { "Parthenon" },
  keys = {
    { "<leader>tc", "<cmd>Parthenon<CR>", desc = "Pick colorscheme" },
  },
  config = function()
    require("parthenon").setup({
      schemes = {
        "tokusa",
        "habamax",
        "cyberdream",
        "hitotose-spring",
        "hitotose-summer",
      },
    })
  end,
}

return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- "default" / "light" / "auto"
      variant = "default",

      transparent = true,
      saturation = 1, -- 0.0-1.0
      italic_comments = false,

      hide_fillchars = false,
      borderless_pickers = false,

      terminal_colors = true,

      -- :CyberdreamBuildCache / :CyberdreamClearCache
      cache = false,

      highlights = {
        -- Example: Comment = { fg = "#aaaaaa", bg = "NONE", italic = true },
      },

      -- Using overrides disables highlights
      overrides = function(colors)
        -- Example:
        -- return {
        --   Comment = { fg = colors.green, bg = "NONE", italic = true },
        --   ["@property"] = { fg = colors.magenta, bold = true },
        -- }
      end,

      colors = {
        -- Applies to both variants
        -- bg = "#000000",
        -- green = "#00ff00",

        -- Variant-specific overrides
        -- dark = { magenta = "#ff00ff", fg = "#eeeeee" },
        -- light = { red = "#ff5c57", cyan = "#5ef1ff" },
      },

      extensions = {
        -- telescope = true,
        -- notify = true,
        -- mini = true,
      },

      -- Alternative style for bulk configuration:
      -- extensions = {
      --   default = false,
      --   base = true,
      --   telescope = true,
      --   cmp = true,
      --   gitsigns = true,
      -- },
    },
    config = function(_, opts)
      require("cyberdream").setup(opts)
      -- Uncomment to set as the default colorscheme
      vim.cmd.colorscheme("cyberdream")
    end,
  },
}

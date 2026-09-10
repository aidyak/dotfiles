return {
    {
        "vzze/cmdline.nvim",
        enabled = false, -- noice.nvimを使用するため無効化
        config = function()
        require("cmdline").setup({
            -- 設定例
            cmdtype = ":",
            window = {
            matchFuzzy = true,
            offset = 1,
            debounceMs = 10,
            },
            hl = {
            default = "Pmenu",
            selection = "PmenuSel",
            directory = "Directory",
            substr = "LineNr",
            },
            column = {
            maxNumber = 6,
            minWidth = 20,
            },
            binds = {
            next = "<Tab>",
            back = "<S-Tab>",
            },
        })
        end
    }
}

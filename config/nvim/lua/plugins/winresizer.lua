return {
    {
        "simeji/winresizer",
        keys = {
          { "<C-e>", "<cmd>WinResizerStartResize<CR>", desc = "Start window resize mode" },
        },
        config = function()
          -- オプション設定（必要に応じて）
          vim.g.winresizer_start_key = "<C-e>"  -- デフォルトは <C-e>
          -- vim.g.winresizer_vert_resize = 1   -- 垂直リサイズの幅
          -- vim.g.winresizer_horiz_resize = 1  -- 水平リサイズの高さ
        end,
    }
}

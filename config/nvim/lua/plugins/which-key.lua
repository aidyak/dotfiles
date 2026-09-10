return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        -- リーダーキーのプレフィックス
        { "<leader>f", group = "📁 Find" },
        { "<leader>g", group = "📋 Git" },
        { "<leader>l", group = "🔧 LSP" },
        { "<leader>b", group = "📄 Buffer" },
        { "<leader>w", group = "🪟 Window" },
        { "<leader>q", group = "🚪 Quit" },
        { "<leader>s", group = "🔍 Search" },
        { "<leader>t", group = "🌳 Toggle" },
        
        -- Find/Telescope関連
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
        { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
        { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find word under cursor" },
        { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
        { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "LSP references" },
        { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
        
        -- Git関連
        { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        { "<leader>gc", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit current file" },
        { "<leader>gf", "<cmd>LazyGitFilter<cr>", desc = "LazyGit filter" },
        { "<leader>gl", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit filter current" },
        
        -- LSP関連
        { "<leader>lr", vim.lsp.buf.rename, desc = "Rename symbol" },
        { "<leader>la", vim.lsp.buf.code_action, desc = "Code action" },
        { "<leader>lf", vim.lsp.buf.format, desc = "Format document" },
        { "<leader>ld", vim.lsp.buf.definition, desc = "Go to definition" },
        { "<leader>lD", vim.lsp.buf.declaration, desc = "Go to declaration" },
        { "<leader>lI", vim.lsp.buf.implementation, desc = "Go to implementation" },
        { "<leader>lt", vim.lsp.buf.type_definition, desc = "Go to type definition" },
        { "<leader>lh", vim.lsp.buf.hover, desc = "Hover documentation" },
        { "<leader>ls", vim.lsp.buf.signature_help, desc = "Signature help" },
        { "<leader>le", vim.diagnostic.open_float, desc = "Show diagnostics" },
        { "<leader>ll", _G.show_linter_formatter_info, desc = "Show linter/formatter info" },
        { "<leader>lq", vim.diagnostic.setloclist, desc = "Diagnostics to loclist" },
        
        -- Buffer関連
        { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
        { "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
        { "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous buffer" },
        { "<leader>bl", "<cmd>Telescope buffers<cr>", desc = "List buffers" },
        { "<leader>ba", "<cmd>%bdelete|edit#|bdelete#<cr>", desc = "Delete all but current" },
        
        -- Window関連
        { "<leader>wv", "<cmd>vsplit<cr>", desc = "Vertical split" },
        { "<leader>wh", "<cmd>split<cr>", desc = "Horizontal split" },
        { "<leader>wc", "<cmd>close<cr>", desc = "Close window" },
        { "<leader>wo", "<cmd>only<cr>", desc = "Close other windows" },
        { "<leader>w=", "<C-w>=", desc = "Balance windows" },
        
        -- Quick actions
        { "<leader>qq", "<cmd>qa<cr>", desc = "Quit all" },
        { "<leader>qw", "<cmd>wq<cr>", desc = "Save and quit" },
        { "<leader>q!", "<cmd>q!<cr>", desc = "Quit without saving" },
        
        -- Search関連
        { "<leader>sc", "<cmd>nohlsearch<cr>", desc = "Clear search highlight" },
        { "<leader>sr", "<cmd>%s//gc<left><left><left>", desc = "Search and replace" },
        
        -- Toggle関連
        { "<leader>tn", "<cmd>set number!<cr>", desc = "Toggle line numbers" },
        { "<leader>tr", "<cmd>set relativenumber!<cr>", desc = "Toggle relative numbers" },
        { "<leader>tw", "<cmd>set wrap!<cr>", desc = "Toggle line wrap" },
        { "<leader>ts", "<cmd>set spell!<cr>", desc = "Toggle spell check" },
        { "<leader>tc", "<cmd>Parthenon<cr>", desc = "Toggle colorscheme" },
        
        -- その他よく使うもの
        { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Search in project" },
        
        -- Normal mode navigation hints
        { "g", group = "Go to" },
        { "gd", vim.lsp.buf.definition, desc = "Go to definition" },
        { "gr", vim.lsp.buf.references, desc = "Go to references" },
        { "gD", vim.lsp.buf.declaration, desc = "Go to declaration" },
        { "gi", vim.lsp.buf.implementation, desc = "Go to implementation" },
        
        { "[", group = "Previous" },
        { "[d", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
        { "[b", "<cmd>bprevious<cr>", desc = "Previous buffer" },
        { "[h", desc = "Previous hunk" },

        { "]", group = "Next" },
        { "]d", vim.diagnostic.goto_next, desc = "Next diagnostic" },
        { "]b", "<cmd>bnext<cr>", desc = "Next buffer" },
        { "]h", desc = "Next hunk" },
      },
    },
  },
}

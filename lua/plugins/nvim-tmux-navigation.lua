return {
  "alexghergh/nvim-tmux-navigation",
  config = function()
    require('nvim-tmux-navigation').setup({})
    vim.keymap.set("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", {})
    vim.keymap.set("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", {})
    vim.keymap.set("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", {})
    vim.keymap.set("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", {})

        vim.api.nvim_create_augroup("neotree", {})
        vim.api.nvim_create_autocmd("UiEnter", {
            desc = "Open Neotree automatically",
            group = "neotree",
            callback = function()
                if vim.fn.argc() == 0 then
                    vim.cmd "Neotree toggle"
                end
            end,
        })
    end,
}

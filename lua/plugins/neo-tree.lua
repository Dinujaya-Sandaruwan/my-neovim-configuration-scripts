return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        -- Toggle file tree with Ctrl+N
        vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true })
        -- Float buffer list
        vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", { silent = true })

        require("neo-tree").setup({
            -- Don't show on startup
            close_if_last_window = true,
            window = {
                width = 30,
                auto_expand_width = false,
            },
            filesystem = {
                -- Auto-refresh when files change on disk
                use_libuv_file_watcher = true,
                follow_current_file = {
                    enabled = true,       -- highlight current file in tree
                    leave_dirs_open = true,
                },
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            },
        })
    end,
}

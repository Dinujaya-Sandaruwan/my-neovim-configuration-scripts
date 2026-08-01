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

        -- Open Neo-tree automatically on startup
        vim.api.nvim_create_autocmd("VimEnter", {
            desc = "Open Neo-tree automatically",
            callback = function()
                require("neo-tree.command").execute({ action = "show" })
            end,
        })

        -- use_libuv_file_watcher only watches expanded directories and often
        -- misses git-status decoration updates from external edits, so also
        -- force a refresh whenever focus returns to Neovim.
        vim.api.nvim_create_autocmd("FocusGained", {
            desc = "Refresh Neo-tree on focus (picks up external file changes)",
            callback = function()
                local ok, manager = pcall(require, "neo-tree.sources.manager")
                if ok then
                    manager.refresh("filesystem")
                end
            end,
        })

        require("neo-tree").setup({
            close_if_last_window = true,
            window = {
                width = 30,
                auto_expand_width = false,
            },
            filesystem = {
                -- Auto-refresh when files change on disk
                use_libuv_file_watcher = true,
                enable_git_status = true,
                git_status_async = true,
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

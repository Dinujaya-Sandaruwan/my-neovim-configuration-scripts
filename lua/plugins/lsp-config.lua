return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "pmizio/typescript-tools.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require("lspconfig")

      -- Replace tsserver setup with typescript-tools
      require("typescript-tools").setup({
        capabilities = capabilities,
        settings = {
          -- Enable separate diagnostic server for better performance
          separate_diagnostic_server = true,
          -- Show diagnostics only when not in insert mode
          publish_diagnostic_on = "insert_leave",
          -- Typescript-specific settings
          tsserver_file_preferences = {
            importModuleSpecifierPreference = "relative",
            includeInlayParameterNameHints = "all",
            includeCompletionsForModuleExports = true,
          },
        }
      })

      -- Other language servers remain the same
      lspconfig.solargraph.setup({
        capabilities = capabilities
      })
      lspconfig.html.setup({
        capabilities = capabilities
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })

      -- Add these TypeScript-specific keymaps
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>tr", "<cmd>TSToolsRenameFile<cr>", {})
      vim.keymap.set("n", "<leader>ti", "<cmd>TSToolsOrganizeImports<cr>", {})
      vim.keymap.set("n", "<leader>tf", "<cmd>TSToolsFixAll<cr>", {})
    end,
  },
}

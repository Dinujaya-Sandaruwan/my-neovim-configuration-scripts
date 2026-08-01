return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- v6 requires Neovim >= 0.11; this machine runs 0.10.2
    lazy = false,
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
    },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          default_settings = {
            ["rust-analyzer"] = {
              checkOnSave = true,
              check = {
                command = "clippy",
              },
              cargo = {
                features = "all",
              },
            },
          },
        },
      }
    end,
    config = function()
      vim.keymap.set("n", "<leader>rr", "<cmd>RustLsp runnables<cr>", {})
      vim.keymap.set("n", "<leader>rt", "<cmd>RustLsp testables<cr>", {})
      vim.keymap.set("n", "<leader>re", "<cmd>RustLsp expandMacro<cr>", {})
      vim.keymap.set("n", "<leader>rd", "<cmd>RustLsp debug<cr>", {})
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()

      vim.keymap.set("n", "<leader>cu", function() require("crates").update_crate() end, {})
      vim.keymap.set("n", "<leader>cU", function() require("crates").upgrade_all_crates() end, {})
    end,
  },
}

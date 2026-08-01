return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-web-devicons" },
  ft = { "markdown" },
  config = function()
    require("render-markdown").setup({
      enabled = true,
      anti_conceal = { enabled = false },
    })
    vim.keymap.set("n", "<leader>mp", ":RenderMarkdown toggle<CR>", { desc = "Toggle markdown preview/code mode" })
  end,
}

 return {
   "jonroosevelt/gemini-cli.nvim",
   config = function()
     require("gemini").setup({
       split_direction = "vertical",
     })

     -- OPTION A: Ctrl + g
     vim.keymap.set("n", "<C-g>", function()
       require("gemini").toggle_gemini_cli()
     end, { desc = "Toggle Gemini" })

     -- OPTION B: Space + g
     vim.keymap.set("n", "<leader>g", function()
       require("gemini").toggle_gemini_cli()
     end, { desc = "Toggle Gemini" })

     -- For visual mode (highlighting code), let's use Ctrl + g too
     vim.keymap.set("v", "<C-g>", function()
       require("gemini").send_to_gemini()
     end, { desc = "Send to Gemini" })
   end,
 }

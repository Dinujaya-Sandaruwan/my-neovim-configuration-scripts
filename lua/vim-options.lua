vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "
vim.g.background = "light"

vim.opt.swapfile = false
vim.opt.mouse = "a"

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')

-- Move lines up and down
vim.keymap.set('n', 'K', ':m-2<CR>==', { noremap = true })
vim.keymap.set('n', 'J', ':m+1<CR>==', { noremap = true })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true })

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true

-- Automatically refresh buffers when files change on disk
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})

-- Auto-copy a mouse-drag visual selection to the system clipboard on release,
-- since terminal mouse reporting (mouse=a) blocks the terminal's own
-- native selection-to-clipboard copy.
vim.keymap.set("v", "<LeftRelease>", function()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return "<LeftRelease>"
  end

  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  local dragged = start_pos[2] ~= end_pos[2] or start_pos[3] ~= end_pos[3]
  if not dragged then
    return "<LeftRelease>"
  end

  vim.schedule(function()
    vim.cmd('normal! "+y')
    local text = vim.fn.getreg("+")
    local lines = vim.split(text, "\n")
    if #lines > 1 then
      vim.notify(("Copied %d lines to clipboard"):format(#lines), vim.log.levels.INFO)
    else
      vim.notify(("Copied %d chars to clipboard"):format(#text), vim.log.levels.INFO)
    end
  end)

  return ""
end, { expr = true, silent = true, desc = "Auto-copy mouse-drag visual selection to clipboard" })

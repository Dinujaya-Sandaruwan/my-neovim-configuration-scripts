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

-- Shared top-right "toast" popup: a plain vim.notify() wouldn't auto-dismiss
-- (it just sits in the message area until overwritten), so this uses its own
-- floating window + a timer instead. Multiple toasts stack downward below
-- each other instead of overlapping.
local active_toasts = {}

local function show_toast(text, duration)
  duration = duration or 10000
  local width = math.min(vim.fn.strdisplaywidth(text) + 2, vim.o.columns - 4)

  local row = 1
  for _, t in ipairs(active_toasts) do
    if vim.api.nvim_win_is_valid(t.win) then
      row = row + 3
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = vim.o.columns - width - 2,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 300,
  })
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local entry = { win = win }
  table.insert(active_toasts, entry)

  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    for i, t in ipairs(active_toasts) do
      if t == entry then
        table.remove(active_toasts, i)
        break
      end
    end
  end, duration)
end

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
      show_toast(("Copied %d lines to clipboard"):format(#lines))
    else
      show_toast(("Copied %d chars to clipboard"):format(#text))
    end
  end)

  return ""
end, { expr = true, silent = true, desc = "Auto-copy mouse-drag visual selection to clipboard" })

-- :Pwd — show the full path of the current project root (cwd) as a toast.
vim.api.nvim_create_user_command("Pwd", function()
  show_toast(vim.fn.getcwd())
end, { desc = "Show the current project root path for 10 seconds" })

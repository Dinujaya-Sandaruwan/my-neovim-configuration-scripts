local MAP_WIDTH = 20

-- mini.map always opens as a floating window (relative='editor') and never
-- shrinks the main buffer's window, so wrapped long lines run underneath it.
-- Reserve a real, empty, fixed-width window on the right that the map floats
-- over instead — this shrinks the main buffer's actual window width, so
-- Neovim's own line-wrap stops before reaching the map.
local function open_map_gutter()
    if vim.t.minimap_gutter_win and vim.api.nvim_win_is_valid(vim.t.minimap_gutter_win) then
        return
    end

    local cur_win = vim.api.nvim_get_current_win()
    local ok = pcall(vim.cmd, "botright " .. MAP_WIDTH .. "vsplit")
    if not ok then
        return
    end
    vim.cmd("enew")

    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "minimap-gutter"
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].cursorline = false
    vim.wo[win].winfixwidth = true
    vim.t.minimap_gutter_win = win

    vim.api.nvim_set_current_win(cur_win)
end

return {
    'echasnovski/mini.map',
    version = '*',
    config = function()
        require('mini.map').setup({
            window = {
                side = 'right',
                focusable = false,
                width = MAP_WIDTH,
            },
            symbols = {
                encode = require('mini.map').gen_encode_symbols.dot('4x2'),
                scroll_line = '█',
                scroll_view = '┃'
            }
        })

        -- Auto-open minimap for all buffers
        vim.api.nvim_create_autocmd("BufRead", {
            callback = function()
                require('mini.map').open()
            end
        })

        -- Reserve the gutter once per tab, after startup/tab windows settle.
        vim.api.nvim_create_autocmd({ "VimEnter", "TabNewEntered" }, {
            callback = function()
                vim.schedule(open_map_gutter)
            end,
        })
    end,
}

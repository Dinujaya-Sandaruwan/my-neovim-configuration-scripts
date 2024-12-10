return {
    'echasnovski/mini.map',
    version = '*',
    config = function()
        require('mini.map').setup({
            window = {
                side = 'right',
                focusable = false,
                width = 20,
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
    end,
}

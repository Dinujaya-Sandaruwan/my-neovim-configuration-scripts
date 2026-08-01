-- vim.diagnostic (and therefore Trouble's "diagnostics" source) only knows
-- about files the LSP has actually loaded into a buffer, so it can't show
-- errors for a project you haven't opened files in yet. ":Err all" instead
-- runs tsc + eslint as real CLI processes across the whole project and loads
-- the results into the quickfix list, which Trouble can also display.
local function scan_project()
    local root = vim.fn.getcwd()
    local qf_entries = {}
    local pending = 0
    local errors = {}

    local function finish()
        pending = pending - 1
        if pending > 0 then
            return
        end
        vim.schedule(function()
            if #qf_entries == 0 then
                local msg = "No project-wide errors found."
                if #errors > 0 then
                    msg = msg .. " (" .. table.concat(errors, "; ") .. ")"
                end
                vim.notify(msg, vim.log.levels.INFO)
                return
            end
            table.sort(qf_entries, function(a, b)
                return a.filename < b.filename
            end)
            vim.fn.setqflist(qf_entries, "r")
            vim.cmd("Trouble qflist toggle")
        end)
    end

    vim.notify("Scanning project for TypeScript/ESLint errors...", vim.log.levels.INFO)

    pending = pending + 1
    vim.fn.jobstart({ "npx", "--no-install", "tsc", "--noEmit", "--pretty", "false" }, {
        cwd = root,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                local file, l, c, code, msg = line:match("^(.-)%((%d+),(%d+)%): error TS(%d+): (.*)$")
                if file then
                    table.insert(qf_entries, {
                        filename = root .. "/" .. file,
                        lnum = tonumber(l),
                        col = tonumber(c),
                        text = ("[tsc TS%s] %s"):format(code, msg),
                        type = "E",
                    })
                end
            end
        end,
        on_stderr = function(_, data)
            local text = table.concat(data, " "):gsub("^%s+", ""):gsub("%s+$", "")
            if text ~= "" then
                table.insert(errors, "tsc: " .. text)
            end
        end,
        on_exit = finish,
    })

    pending = pending + 1
    vim.fn.jobstart({ "npx", "--no-install", "eslint", ".", "-f", "unix" }, {
        cwd = root,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                local file, l, c, msg = line:match("^(.-):(%d+):(%d+): (.*)$")
                if file then
                    table.insert(qf_entries, {
                        filename = file,
                        lnum = tonumber(l),
                        col = tonumber(c),
                        text = "[eslint] " .. msg,
                        type = "W",
                    })
                end
            end
        end,
        on_stderr = function(_, data)
            local text = table.concat(data, " "):gsub("^%s+", ""):gsub("%s+$", "")
            if text ~= "" then
                table.insert(errors, "eslint: " .. text)
            end
        end,
        on_exit = finish,
    })
end

vim.api.nvim_create_user_command("Err", function(opts)
    if opts.args == "here" then
        vim.cmd("Trouble diagnostics toggle filter.buf=0")
    elseif opts.args == "all" then
        scan_project()
    else
        vim.notify("Usage: :Err here (current file) | :Err all (whole project)", vim.log.levels.WARN)
    end
end, {
    nargs = 1,
    complete = function()
        return { "here", "all" }
    end,
    desc = "Show diagnostics: :Err here (current file) | :Err all (whole project)",
})

return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
    keys = {
        { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics: whole project (open buffers only)" },
        { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics: current document" },
    },
}

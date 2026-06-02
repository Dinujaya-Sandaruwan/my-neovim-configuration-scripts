-- nvim-ask.lua
-- Drop this into your ~/.config/nvim/lua/ directory and require it,
-- or paste the contents directly into your init.lua.

local M = {}

local script_path = vim.fn.stdpath("config") .. "/scripts/nvim-ask.sh"

--- Strip ALL ANSI escape sequences from a string.
local function strip_ansi(s)
    s = s:gsub("\27%[[%d;]*[A-Za-z]", "")
    s = s:gsub("\27%].-\27\\", "")
    s = s:gsub("\27%].-\a", "")
    s = s:gsub("\27[%(%)#][A-Za-z]", "")
    s = s:gsub("\27.", "")
    return s
end

function M.ask_agent()
    if vim.fn.filereadable(script_path) == 0 then
        vim.notify(
            "nvim-ask.sh not found at: " .. script_path,
            vim.log.levels.ERROR
        )
        return
    end

    -- Create ONE buffer and ONE window that persists through the entire flow
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.min(70, vim.o.columns - 4)
    local row = math.floor((vim.o.lines - 3) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = 1,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " Ask Nvim Agent ",
        title_pos = "center",
    })

    -- Start in insert mode so user can type immediately
    vim.cmd("startinsert")

    -- Helper: close and clean up
    local function cleanup()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Helper: resize the window for new content
    local function resize_for_content(lines)
        if not vim.api.nvim_win_is_valid(win) then return end
        local new_width = math.min(80, vim.o.columns - 4)
        local new_height = math.min(#lines + 2, vim.o.lines - 4)
        new_height = math.max(new_height, 1)
        vim.api.nvim_win_set_config(win, {
            relative = "editor",
            width = new_width,
            height = new_height,
            row = math.floor((vim.o.lines - new_height) / 2),
            col = math.floor((vim.o.columns - new_width) / 2),
        })
    end

    -- Submit on Enter: keep the window, show loading, run the agent
    vim.keymap.set("i", "<CR>", function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local question = vim.fn.trim(table.concat(lines, " "))
        vim.cmd("stopinsert")

        if question == "" then
            cleanup()
            return
        end

        -- Replace input text with loading message, keep window open
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  Loading... please wait" })
        vim.api.nvim_win_set_config(win, {
            relative = "editor",
            width = width,
            height = 1,
            row = row,
            col = col,
            title = " Nvim Agent ",
            title_pos = "center",
        })

        -- Remove the insert-mode keymaps (no longer needed)
        pcall(vim.keymap.del, "i", "<CR>", { buffer = buf })
        pcall(vim.keymap.del, "i", "<Esc>", { buffer = buf })

        -- Allow closing during loading too
        vim.keymap.set("n", "q", cleanup, { buffer = buf, noremap = true, silent = true })
        vim.keymap.set("n", "<Esc>", cleanup, { buffer = buf, noremap = true, silent = true })

        local stdout_lines = {}
        local stderr_lines = {}

        local job_id = vim.fn.jobstart({ script_path, question }, {
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = function(_, data)
                if data then
                    for _, line in ipairs(data) do
                        table.insert(stdout_lines, line)
                    end
                end
            end,
            on_stderr = function(_, data)
                if data then
                    for _, line in ipairs(data) do
                        table.insert(stderr_lines, line)
                    end
                end
            end,
            on_exit = function(_, exit_code)
                vim.schedule(function()
                    -- If user already closed the window, bail out
                    if not vim.api.nvim_buf_is_valid(buf) then return end

                    local ok, err = pcall(function()
                        -- Clean and filter stdout
                        local result = {}
                        for _, line in ipairs(stdout_lines) do
                            local clean = strip_ansi(line)
                            if clean ~= "" and not clean:match("^%s*>%s") then
                                table.insert(result, clean)
                            end
                        end

                        -- Fallback: try stderr if stdout was empty
                        if #result == 0 then
                            for _, line in ipairs(stderr_lines) do
                                local clean = strip_ansi(line)
                                if clean ~= "" and not clean:match("^%s*>%s") then
                                    table.insert(result, clean)
                                end
                            end
                        end

                        if #result > 0 then
                            -- Update the SAME buffer/window with the response
                            vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
                            vim.bo[buf].filetype = "markdown"
                            vim.api.nvim_win_set_config(win, {
                                relative = "editor",
                                width = math.min(80, vim.o.columns - 4),
                                height = math.min(#result + 2, vim.o.lines - 4),
                                row = math.floor((vim.o.lines - math.min(#result + 2, vim.o.lines - 4)) / 2),
                                col = math.floor((vim.o.columns - math.min(80, vim.o.columns - 4)) / 2),
                                title = " Agent Response ",
                                title_pos = "center",
                            })
                        elseif exit_code ~= 0 then
                            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
                                "  Agent failed (exit code " .. exit_code .. ")"
                            })
                        else
                            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
                                "  Agent returned an empty response."
                            })
                        end
                    end)

                    if not ok then
                        pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, {
                            "  Error: " .. tostring(err)
                        })
                    end
                end)
            end,
        })

        if job_id <= 0 then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
                "  Failed to start agent (job_id=" .. job_id .. ")"
            })
        end
    end, { buffer = buf, noremap = true, silent = true })

    -- Cancel on Esc (during input phase)
    vim.keymap.set("i", "<Esc>", function()
        vim.cmd("stopinsert")
        cleanup()
    end, { buffer = buf, noremap = true, silent = true })
end

-- Map it to <leader>k (or any key you prefer)
vim.keymap.set('n', '<leader>k', M.ask_agent, { desc = "Ask Nvim Agent" })

return M

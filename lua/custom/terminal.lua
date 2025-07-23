local M = {}

local buffer = -1
local window = -1

function M.toggle()
    if vim.api.nvim_win_is_valid(window) then
        vim.api.nvim_win_hide(window)
    else
        if not vim.api.nvim_buf_is_valid(buffer) then
            buffer = vim.api.nvim_create_buf(false, true)
        end

        window = vim.api.nvim_open_win(buffer, true, {
            relative = "editor",
            width = math.floor(vim.o.columns * 0.8),
            height = math.floor(vim.o.lines * 0.8),
            col = math.floor((vim.o.columns - vim.o.columns * 0.8) / 2),
            row = math.floor((vim.o.lines - vim.o.lines * 0.8) / 2),
            style = "minimal",
            border = "rounded",
        })

        if vim.bo[buffer].buftype ~= "terminal" then
            vim.cmd.term()
        end

        vim.api.nvim_feedkeys("i", "n", false)
    end
end

return M

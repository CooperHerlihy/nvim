local M = {}

function M.setup(opts)
    opts = opts or {}
end

local palette = {
}

local colors = {
}

local groups = {
}

function M.load()
    if vim.g.colors_name ~= "custom-color" then
        vim.cmd("hi clear")
    end
    vim.g.colors_name = "custom-color"

    vim.o.background = "dark"
    vim.o.termguicolors = true

    for group, hl in pairs(groups) do
        vim.api.nvim_set_hl(0, group, hl)
    end

end

return M

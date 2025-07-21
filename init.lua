--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

--]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.updatetime = 150
vim.opt.timeoutlen = 500

-- vim.schedule(function()
    vim.opt.clipboard:append("unnamedplus")
-- end)
vim.opt.undofile = true
vim.opt.confirm = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.mouse = "a"
vim.opt.scrolloff = 10

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.colorcolumn = { "120", "180" }
vim.opt.list = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

local function map(lhs, rhs, mode)
    vim.keymap.set(mode or { "n", "v", "o" }, lhs, rhs, { noremap = true, silent = true })
end

map("kj", "<esc>", "i")
map("<enter>", "<enter><c-g>u", "i")

map("kj", "<c-\\><c-n>", "t")
map("<esc>", "<c-\\><c-n>", "t")

map("<c-d>", "<c-d>zz")
map("<c-u>", "<c-u>zz")
map("n", "nzz")
map("N", "Nzz")

map("<esc>", vim.cmd.nohlsearch)

require("plugins")

vim.cmd.colorscheme "custom-color"

local oil = require("oil")
map("-", oil.open)

local toggleterm = require("toggleterm")
map("<leader>t", function() toggleterm.toggle(nil, 20, nil, nil, nil) end)

local telescope = require("telescope.builtin")
map("<leader>/", function()
    telescope.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ winblend = 10, previewer = false, }))
end)
map("<leader>f", telescope.find_files)
map("<leader>s.", telescope.resume)
map("<leader>so", telescope.oldfiles)
map("<leader>sb", telescope.buffers)
map("<leader>sg", telescope.live_grep)
map("<leader>sd", telescope.diagnostics)
map("<leader>sh", telescope.help_tags)
map("<leader>sk", telescope.keymaps)
map("<leader>st", telescope.builtin)
map("<leader>sc", telescope.colorscheme)
map("<leader>sn", function() telescope.find_files { cwd = vim.fn.stdpath "config" } end)

map("<leader>r", vim.lsp.buf.rename)
map("gd", telescope.lsp_definitions)
map("<leader>gd", vim.lsp.buf.declaration)
map("<leader>gi", telescope.lsp_implementations)
map("<leader>gt", telescope.lsp_type_definitions)
map("<leader>gr", telescope.lsp_references)
map("<leader>ga", vim.lsp.buf.code_action, { "n", "x" })
-- "<leader>h" toggles LSP hints, if available

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- vim: ts=4 sts=4 sw=4 et

vim.opt.confirm = true
vim.schedule(function()
    vim.opt.clipboard:append("unnamedplus")
end)
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.updatetime = 150
vim.opt.timeoutlen = 500

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.winborder = "rounded"

vim.opt.mouse = "a"
vim.opt.scrolloff = 16
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 80

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.colorcolumn = "81,121"
vim.opt.list = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.maplocalleader = " "
vim.g.mapleader = " "
vim.g.have_nerd_font = true

local function map(lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(opts.mode or {"n", "v", "o"}, lhs, rhs, {
        noremap = opts.noremap or true,
        silent = opts.silent or true,
        desc = opts.desc,
    })
end

map("jk", "<esc>", {mode = "i", desc = "Esc in insert mode"})
map("kj", "<esc>", {mode = "i", desc = "Esc in insert mode"})
map("<enter>", "<enter><c-g>u", {mode = "i", desc = "Insert break for undo"})

map("<c-d>", "<c-d>zz", {desc = "Scroll down and center"})
map("<c-u>", "<c-u>zz", {desc = "Scroll up and center"})
map("n", "nzzzv", {desc = "Next match and center"})
map("N", "Nzzzv", {desc = "Previous match and center"})

map("<esc>", vim.cmd.nohlsearch, {desc = "Clear search highlight"})
map("<leader>e", vim.cmd.Ex, {desc = "Open Netrw"})
map("<leader>l", function()
    vim.cmd.source(vim.fn.stdpath('config') .. '/init.lua')
end, {desc = "reload config"})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight on yank",
    group = vim.api.nvim_create_augroup("highlight-yank", {}),
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.pack.add({
    "https://github.com/tpope/vim-sleuth",
    "https://github.com/tpope/vim-surround",
    "https://github.com/tpope/vim-repeat",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/neovim/nvim-lspconfig",
})

require("mini.comment").setup()
require("mini.icons").setup()
require("mini.pick").setup()
require("mini.extra").setup()

map("<leader>.", MiniPick.builtin.resume, {desc = "Resume search/grep"})
map("<leader>f", MiniPick.builtin.files, {desc = "Fuzzy find files"})
map("<leader>t", MiniPick.builtin.buffers, {desc = "Search tabs (open buffers)"})
map("<leader>g", MiniPick.builtin.grep_live, {desc = "Grep in cwd"})
map("<leader>h", MiniPick.builtin.help, {desc = "Search help"})
map("<leader>d", MiniExtra.pickers.diagnostic, {desc = "Search diagnostics"})
map("<leader>s", MiniExtra.pickers.spellsuggest, {desc = "Search help"})

map("<leader>n", function()
    MiniPick.builtin.files(nil, {source = {cwd = "~/notes/", name = "Notes"}})
end, {desc = "Search notes"})
map("<leader>c", function()
    MiniPick.builtin.files(nil, {source = {cwd = "~/.config/nvim/", name = "Config"}})
end, {desc = "Search Neovim config"})

require("nvim-treesitter.configs").setup({
    auto_install = true,
    highlight = {enable = true},
})

require("render-markdown").setup({
    render_modes = true,
    heading = {sign = false},
    pipe_table = {border_virtual = true},
})

vim.lsp.enable("clangd")
vim.lsp.enable("lua_ls")

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
})

map("<leader>r", vim.lsp.buf.rename, {desc = "Rename (change) symbol"})
map("<leader>a", vim.lsp.buf.code_action, {desc = "Perform LSP action"})
map("gd", vim.lsp.buf.definition, {desc = "Goto definition"})

require("mason").setup()

vim.cmd.colorscheme("custom-color")

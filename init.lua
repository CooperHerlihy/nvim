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

-- ===============================================================================================================
-- = Options
-- ===============================================================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.updatetime = 150
vim.opt.timeoutlen = 500

vim.opt.undofile = true
vim.opt.confirm = true
vim.schedule(function()
    vim.opt.clipboard:append("unnamedplus")
end)

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.mouse = "a"
vim.opt.scrolloff = 16
vim.opt.wrap = true
vim.opt.wrapmargin = 5
vim.opt.linebreak = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.colorcolumn = { "120", "180" }
vim.opt.list = true
vim.opt.termguicolors = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ===============================================================================================================
-- = Mappings
-- ===============================================================================================================

local function map(lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set( opts.mode or { "n", "v", "o" }, lhs, rhs, {
        noremap = opts.noremap or true,
        silent = opts.silent or true,
        desc = opts.desc,
    })
end

map("kj", "<esc>", { mode = "i", desc = "Esc in insert mode" })
map("<enter>", "<enter><c-g>u", { mode = "i", desc = "Insert break for undo" })

map("kj", "<c-\\><c-n>", { mode = "t", desc = "Esc in terminal mode" })
map("<esc>", "<c-\\><c-n>", { mode = "t", desc = "Esc in terminal mode" })

map("<c-d>", "<c-d>zz", { desc = "Scroll down and center" })
map("<c-u>", "<c-u>zz", { desc = "Scroll up and center" })
map("n", "nzz", { desc = "Next match and center" })
map("N", "Nzz", { desc = "Previous match and center" })

map("<esc>", vim.cmd.nohlsearch, { desc = "Clear search highlight" })

map("t", ":! tr -s \" \" | column -t -s '|' -o '|'<cr>", { mode = "v", desc = "Format table" })

-- ===============================================================================================================
-- = Plugin Mappings
-- ===============================================================================================================

require("plugins")

vim.cmd.colorscheme("custom-color")
map("<leader>cc", function() vim.cmd.colorscheme("custom-color") end, { desc = "Custom color theme" })
map("<leader>cd", function() vim.cmd.colorscheme("default") end, { desc = "Default color theme" })
map("<leader>ci", vim.cmd.Inspect, { desc = "Inspect color" })

map("-", require("oil").open, { desc = "Open Oil file browser" })
map("<leader>t", require("custom.terminal").toggle, { desc = "Toggle terminal" })
map("<leader>m", require("render-markdown").toggle, { desc = "Toggle markdown render" })
map("<leader>z", require("zen-mode").toggle, { desc = "Toggle zen mode" })

local telescope = require("telescope.builtin")
map("gd", telescope.lsp_definitions, { desc = "Go to definition" })
map("gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("gt", telescope.lsp_type_definitions, { desc = "Go to type definition" })
map("gr", telescope.lsp_references, { desc = "References" })
map("<leader>r", vim.lsp.buf.rename, { desc = "Rename" })
map("<leader>a", vim.lsp.buf.code_action, { mode = { "n", "x" }, desc = "Code action" })
-- "<leader>h" toggles LSP hints, if available

map("<leader>f", telescope.find_files, { desc = "Find file" })
map("<leader>s.", telescope.resume, { desc = "Resume last search" })
map("<leader>so", telescope.oldfiles, { desc = "Search old files" })
map("<leader>sb", telescope.buffers, { desc = "Search buffers" })
map("<leader>sg", telescope.live_grep, { desc = "Search grep" })
map("<leader>sd", telescope.diagnostics, { desc = "Search diagnostics" })
map("<leader>sh", telescope.help_tags, { desc = "Search help tags" })
map("<leader>sk", telescope.keymaps, { desc = "Search keymaps" })
map("<leader>st", telescope.builtin, { desc = "Search builtin" })
map("<leader>sc", telescope.colorscheme, { desc = "Search colorscheme" })
map("<leader>sn", function()
    telescope.find_files({ cwd = vim.fn.stdpath "config" })
end, { desc = "Search config files" })
map("<leader>/", function()
    telescope.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ winblend = 10, previewer = false, }))
end, { desc = "Fuzzy find in current buffer" })


vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

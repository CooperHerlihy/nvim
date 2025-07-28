-- ===============================================================================================================
-- = Options
-- ===============================================================================================================

vim.cmd.colorscheme("custom-color")

vim.g.maplocalleader = " "
vim.g.mapleader = " "
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
vim.opt.textwidth = 120

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.colorcolumn = "120"
vim.opt.list = true
vim.opt.termguicolors = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

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

map("<esc>", vim.cmd.nohlsearch, { desc = "Clear search highlight" })

map("kj", "<esc>", { mode = "i", desc = "Esc in insert mode" })
map("<enter>", "<enter><c-g>u", { mode = "i", desc = "Insert break for undo" })

map("kj", "<c-\\><c-n>", { mode = "t", desc = "Esc in terminal mode" })
map("<esc>", "<c-\\><c-n>", { mode = "t", desc = "Esc in terminal mode" })

map("<c-d>", "<c-d>zz", { desc = "Scroll down and center" })
map("<c-u>", "<c-u>zz", { desc = "Scroll up and center" })
map("n", "nzz", { desc = "Next match and center" })
map("N", "Nzz", { desc = "Previous match and center" })

map("t", ":! tr -s \" \" | column -t -s '|' -o '|'<cr>", { mode = "v", desc = "Format table" })

-- ===============================================================================================================
-- = Plugins
-- ===============================================================================================================

local terminal_buffer = -1
local terminal_window = -1

local function toggle_terminal()
    if vim.api.nvim_win_is_valid(terminal_window) then
        vim.api.nvim_win_hide(terminal_window)
        return
    end

    if not vim.api.nvim_buf_is_valid(terminal_buffer) then
        terminal_buffer = vim.api.nvim_create_buf(false, true)
    end

    terminal_window = vim.api.nvim_open_win(terminal_buffer, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        col = math.floor((vim.o.columns - vim.o.columns * 0.8) / 2),
        row = math.floor((vim.o.lines - vim.o.lines * 0.8) / 2),
        style = "minimal",
        border = "rounded",
    })

    if vim.bo[terminal_buffer].buftype ~= "terminal" then
        vim.cmd.term()
    end
    vim.api.nvim_feedkeys("i", "n", false)
end

map("<leader>t", toggle_terminal, { desc = "Toggle terminal" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    spec = {
        {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = { 'nvim-lua/plenary.nvim' },
            opts = {
                defaults = {
                    vimgrep_arguments = vimgrep_arguments,
                },
                pickers = {
                    find_files = {
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                },
            }
        },
        {
            'saghen/blink.cmp',
            version = '1.*',
            ---@module 'blink.cmp'
            ---@type blink.cmp.Config
            opts = {
                keymap = {
                    preset = "none",
                    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
                    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

                    ['<CR>'] = { 'accept', 'fallback' },
                    ['<C-c>'] = { 'hide', 'fallback' },
                    ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
                    ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
                },
                appearance = { nerd_font_variant = "mono", },
                completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },

                sources = { default = { "lsp", "path", "buffer" } },
                fuzzy = { implementation = "prefer_rust" },
                signature = { enabled = true },
            },
            opts_extend = { "sources.default" }
        },
        {
            'neovim/nvim-lspconfig',
            dependencies = { 'saghen/blink.cmp' },
            config = function()
                vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                    callback = function(event)
                        ---@param client vim.lsp.Client
                        ---@param method vim.lsp.protocol.Method
                        ---@param bufnr? integer some lsp support methods only in specific files
                        ---@return boolean
                        local function client_supports_method(client, method, bufnr)
                            return client:supports_method(method, bufnr)
                        end

                        local client = vim.lsp.get_client_by_id(event.data.client_id)
                        if client and client_supports_method(
                            client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf
                        ) then
                            local highlight_augroup = vim.api.nvim_create_augroup(
                                "lsp-highlight", { clear = false }
                            )
                            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                                buffer = event.buf,
                                group = highlight_augroup,
                                callback = vim.lsp.buf.document_highlight,
                            })

                            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                                buffer = event.buf,
                                group = highlight_augroup,
                                callback = vim.lsp.buf.clear_references,
                            })

                            vim.api.nvim_create_autocmd("LspDetach", {
                                group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                                callback = function(event2)
                                    vim.lsp.buf.clear_references()
                                    vim.api.nvim_clear_autocmds { group = "lsp-highlight", buffer = event2.buf }
                                end,
                            })
                        end

                        if client and client_supports_method(
                            client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf
                        ) then
                            vim.keymap.set("n", "<leader>h", function()
                                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                            end, { desc = "Toggle LSP inlay hints" })
                        end
                    end,
                })

                vim.diagnostic.config {
                    severity_sort = true,
                    float = { border = "rounded", source = "if_many" },
                    underline = { severity = vim.diagnostic.severity.ERROR },
                    signs = vim.g.have_nerd_font and {
                        text = {
                            [vim.diagnostic.severity.ERROR] = "󰅚 ",
                            [vim.diagnostic.severity.WARN] = "󰀪 ",
                            [vim.diagnostic.severity.INFO] = "󰋽 ",
                            [vim.diagnostic.severity.HINT] = "󰌶 ",
                        },
                    } or {},
                    virtual_text = {
                        source = "if_many",
                        spacing = 2,
                        format = function(diagnostic)
                            local diagnostic_message = {
                                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                                [vim.diagnostic.severity.WARN] = diagnostic.message,
                                [vim.diagnostic.severity.INFO] = diagnostic.message,
                                [vim.diagnostic.severity.HINT] = diagnostic.message,
                            }
                            return diagnostic_message[diagnostic.severity]
                        end,
                    },
                }

                local servers = {
                    lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
                    clangd = {},
                    glsl_analyzer = {},
                    markdown_oxide = {},
                }
                for server, config in pairs(servers) do
                    config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
                    require('lspconfig')[server].setup(config)
                end
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            main = "nvim-treesitter.configs",
            opts = {
                auto_install = true,
                highlight = { enable = true },
            },
        },
        { "supermaven-inc/supermaven-nvim", opts = { ignore_filetypes = { "markdown", "org" } } },
        { "folke/zen-mode.nvim", opts = { window = { width = 126 } } },
        { 'echasnovski/mini.nvim', version = false },
        { "tpope/vim-repeat" },
        { "tpope/vim-surround" },
        { "tpope/vim-sleuth" },
    },
    checker = { enabled = true },
})

require("mini.ai").setup()
require("mini.comment").setup()
require("mini.pairs").setup()
require("mini.move").setup()

map("-", vim.cmd.Ex, { desc = "Open Netrw" })
map("<leader>z", vim.cmd.ZenMode, { desc = "Toggle zen mode" })

local telescope = require("telescope.builtin")
map("gd", telescope.lsp_definitions, { desc = "Goto definition" })
map("gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
map("gt", telescope.lsp_type_definitions, { desc = "Goto type definition" })
map("gr", telescope.lsp_references, { desc = "Goto references" })
map("<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("<leader>a", vim.lsp.buf.code_action, { mode = { "n", "x" }, desc = "Code action" })

map("<leader>f", telescope.find_files, { desc = "Find file" })
map("<leader>s.", telescope.resume, { desc = "Resume last search" })
map("<leader>so", telescope.oldfiles, { desc = "Search old files" })
map("<leader>sb", telescope.buffers, { desc = "Search buffers" })
map("<leader>sg", telescope.live_grep, { desc = "Search grep" })
map("<leader>sd", telescope.diagnostics, { desc = "Search diagnostics" })
map("<leader>sk", telescope.keymaps, { desc = "Search keymaps" })

map("<leader>sc", function() telescope.find_files({ cwd = vim.fn.stdpath "config" }) end, { desc = "Search config" })
map("<leader>sn", function() telescope.find_files({ cwd = "~/notes/" }) end, { desc = "Search notes" })


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

vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"
end)
vim.opt.undofile = true
vim.opt.confirm = true
vim.opt.path:append "**"

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

map("<c-c>", ":bdelete<enter>")
map("<esc>", ":nohlsearch<enter>")

map("-", ":Oil<enter>")
map("<leader>t", ":ToggleTerm<enter>")
map("<leader>q", vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
-- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
-- Alternatively, use `config = function() ... end` for full control over the configuration.
require("lazy").setup({
    { "NMAC427/guess-indent.nvim" }, -- Detect tabstop and shiftwidth automatically
    { -- Fuzzy Finder (files, lsp, etc)
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable "make" == 1
                end,
            },
            { "nvim-telescope/telescope-ui-select.nvim" },
            { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
        },
        config = function()
            require("telescope").setup {
                -- defaults = {
                --   mappings = {
                --     i = { ["<c-enter>"] = "to_fuzzy_refine" },
                --   },
                -- },
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            }
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")

            local builtin = require "telescope.builtin"
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
            vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
            vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
            vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files (\".\" for repeat)" })
            vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
            vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
            vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
            vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })

            vim.keymap.set("n", "<leader>/", function()
                builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, { desc = "[/] Fuzzily search in current buffer" })

            vim.keymap.set("n", "<leader>s/", function()
                builtin.live_grep {
                    grep_open_files = true,
                    prompt_title = "Live Grep in Open Files",
                }
            end, { desc = "[S]earch [/] in Open Files" })

            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files { cwd = vim.fn.stdpath "config" }
            end, { desc = "[S]earch [N]eovim files" })
        end,
    },
    { -- LSP Plugins
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    { -- Main LSP Configuration
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            "saghen/blink.cmp",
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map_lsp = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    map_lsp("<leader>r", vim.lsp.buf.rename, "[R]ename")
                    map_lsp("<c-]>", require("telescope.builtin").lsp_definitions, "Goto Definition")
                    map_lsp("<leader>gt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")
                    map_lsp("<leader>gd", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                    map_lsp("<leader>gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                    map_lsp("<leader>gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                    map_lsp("<leader>gs", require("telescope.builtin").lsp_document_symbols, "[G]oto [S]ymbols")
                    map_lsp("<leader>gw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[G]oto [W]orkspace Symbols")
                    map_lsp("<leader>ga", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

                    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                    ---@param client vim.lsp.Client
                    ---@param method vim.lsp.protocol.Method
                    ---@param bufnr? integer some lsp support methods only in specific files
                    ---@return boolean
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has "nvim-0.11" == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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
                            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
                            end,
                        })
                    end

                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map_lsp("<leader>h", function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, "Toggle LSP Inlay [H]ints")
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

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            local servers = {
                clangd = {
                    filetypes = {
                        ".c",
                        ".cpp",
                        ".cc",
                        ".h",
                        ".hpp",
                    },
                },
                glsl_analyzer = {
                    filetypes = {
                        ".vert",
                        ".frag",
                        ".comp",
                    },
                },
                rust_analyzer = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                            diagnostics = { disable = { "missing-fields" } },
                        },
                    },
                },
            }

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                "stylua",
            })
            require("mason-tool-installer").setup { ensure_installed = ensure_installed }

            require("mason-lspconfig").setup {
                ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
                automatic_installation = false,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        -- by the server configuration above. Useful when disabling
                        -- certain features of an LSP (for example, turning off formatting for ts_ls)
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            }
        end,
    },
    { -- Autocompletion
        "saghen/blink.cmp",
        event = "VimEnter",
        version = "1.*",
        dependencies = { "folke/lazydev.nvim" },
        --- @module 'blink.cmp'
        --- @type blink.cmp.Config
        opts = {
            keymap = {
                -- 'default' (recommended) for mappings similar to built-in completions
                --   <c-y> to accept ([y]es) the completion.
                --    This will auto-import if your LSP supports it.
                --    This will expand snippets if the LSP sent a snippet.
                -- 'super-tab' for tab to accept
                -- 'enter' for enter to accept
                -- 'none' for no mappings
                --
                -- All presets have the following mappings:
                -- <tab>/<s-tab>: move to right/left of your snippet expansion
                -- <c-space>: Open menu or open docs if already open
                -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
                -- <c-e>: Hide menu
                -- <c-k>: Toggle signature help
                --
                -- See :h blink-cmp-config-keymap for defining your own keymap
                preset = "enter",
                ["<tab>"] = {},
                ["<s-tab>"] = {},
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                nerd_font_variant = "mono",
            },

            completion = {
                -- By default, you may press `<c-space>` to show the documentation.
                -- Optionally, set `auto_show = true` to show the documentation after a delay.
                documentation = { auto_show = false, auto_show_delay_ms = 500 },
            },

            sources = {
                default = { "lsp", "path", "lazydev" },
                providers = {
                    lazydev = {
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },

            -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
            -- which automatically downloads a prebuilt binary when enabled.
            --
            -- By default, we use the Lua implementation instead, but you may enable
            -- the rust implementation via `'prefer_rust_with_warning'`
            --
            -- See :h blink-cmp-config-fuzzy for more information
            -- fuzzy = { implementation = 'lua' },
            fuzzy = { implementation = "prefer_rust" },

            signature = { enabled = true },
        },
    },
    { -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs", -- Sets main module to use for opts
        -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        opts = {
            ensure_installed = { "bash", "c", "cpp", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline", "query", "vim", "vimdoc" },
            auto_install = true,
            highlight = {
                enable = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                additional_vim_regex_highlighting = { "ruby" },
            },
            indent = { enable = true, disable = { "ruby" } },
        },
        -- There are additional nvim-treesitter modules that you can use to interact
        -- with nvim-treesitter. You should go explore a few and see what interests you:
        --
        --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
        --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
        --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    },
    { -- Collection of various small independent plugins/modules
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup()
            require("mini.bracketed").setup()
            require("mini.comment").setup()
            require("mini.pairs").setup()
            require("mini.surround").setup()
            require("mini.tabline").setup()
        end,
    },
    {
        "stevearc/oil.nvim",
        opts = {},
        dependencies = { "nvim-tree/nvim-web-devicons" },
        lazy = false,
    },
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = {
            size = 20,
        },
    },
    { -- Highlight todo, notes, etc in comments
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
    },
    {
        "custom-color",
        dir = vim.fn.stdpath "config" .. "/lua/custom-color",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "custom-color"
        end,
    },
    -- {
    --     -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    --     "folke/tokyonight.nvim",
    --     priority = 1000, -- Make sure to load this before all the other start plugins.
    --     config = function()
    --         ---@diagnostic disable-next-line: missing-fields
    --         require("tokyonight").setup {
    --             styles = {
    --                 comments = { italic = false }, -- Disable italics in comments
    --             },
    --         }
    --
    --         vim.cmd.colorscheme "tokyonight-night"
    --     end,
    -- },
    {
        "supermaven-inc/supermaven-nvim",
        opts = {},
    },
}, {
    ui = {
        icons = vim.g.have_nerd_font and {} or {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            require = "🌙",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 ",
        },
    },
})

-- vim: ts=4 sts=4 sw=4 et

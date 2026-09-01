-- TODOs
-- set leader to space
-- configure double space to switch to last file/buffers
-- set up fzf shortcuts for files, and active buffers
-- use NCM2 for autocomplete
-- install vim-highlightedyank
-- test vim-rooter
--

-- Setup global options
vim.g.mapleader = " "

local opt = vim.opt
local fn = vim.fn

opt.clipboard = 'unnamed', 'unnamedplus'
opt.mouse = 'r'
opt.termguicolors = true
opt.syntax = 'on'
opt.smartcase = true
opt.showmode = false
opt.autoread = true
opt.cursorline = true
opt.encoding = 'utf-8'
opt.expandtab = true
opt.number = true
opt.relativenumber = true
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.shiftround = true
opt.shiftwidth = 4
opt.smartindent = true
opt.wildmode = {'list', 'longest'}
opt.wrap = false
opt.colorcolumn = '81'
opt.spellfile = fn.stdpath('config') .. '/spell/en.utf-8.add'

------------------------------------------------------------- tabs v. spaces ---

-- Set display width of tab ('\t') char to 4
opt.tabstop = 4
-- Set indents to width of 4
opt.shiftwidth = 4
-- Set column width of a tab to 4
opt.softtabstop = 4
-- Expand tabs into spaces
opt.expandtab = true

----------------------------------------------------------------- completion ---

-- menuone:  popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force user to select one from the menu
opt.completeopt = { 'menuone', 'noinsert', 'noselect' }

-- Avoid showing extra messages when using completion
-- opt.shortmess += 'c' // How do you append in lua??

-------------------------------------------------------------------- keymaps ---

-- Disable arrow keys in favor of hjkl
local key_mapper = function(mode, key, result)
  vim.api.nvim_set_keymap(
    mode,
    key,
    result,
    {noremap = true, silent = true}
  )
end

key_mapper('', '<up>', '<nop>')
key_mapper('', '<down>', '<nop>')
key_mapper('', '<left>', '<nop>')
key_mapper('', '<right>', '<nop>')


--------------------------------------------------------------- load plugins ---

-- boostrap packer if not yet installed
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
  vim.fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim', install_path
  })
  vim.cmd [[packadd packer.nvim]]
  packer_bootstrap = true
end

-- Load plugins defined in separate file
require('plugins')

-- On first run packer was only just cloned above: no plugins are on disk yet,
-- so every `require` of a plugin below would error (E5113: module 'cmp' not
-- found). Install the plugins and stop here — `bootstrap.sh` follows up with a
-- headless `:PackerSync`, and an interactive launch kicks the sync off now.
-- Re-open nvim once it finishes to load the full config.
if packer_bootstrap then
  if #vim.api.nvim_list_uis() > 0 then
    require('packer').sync()
    vim.notify('Installing plugins — reopen nvim once :PackerSync completes')
  end
  return
end

----------------------------------------------------------------- Treesitter ---

local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if ok then
  treesitter.setup({
    sync_install = true,
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  })
end

------------------------------------------------------------- NERDTree setup ---

vim.g.NERDTreeWinPos = 'right'

----------------------------------------------------------------- rust-tools ---

if vim.lsp.config then
  vim.lsp.config.rust_analyzer = {
    settings = {
      on_attach = on_attach,
      flags = lsp_flags,
    }
  }
  vim.lsp.enable('rust_analyzer')
end

vim.g.rustfmt_autosave = 1

----------------------------------------------------------------- lsp config ---

local lsp_key_opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, lsp_key_opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, lsp_key_opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, lsp_key_opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, lsp_key_opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, bufopts)
end

local lsp_flags = {
  debounce_text_changes = 150,
}

----------------------------------------------------------------- completion ---

local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<down>'] = cmp.mapping.select_next_item(),
    ['<up>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true })
  },

  complection = {
    completeopt = 'menu,menuone,noinsert'
  },
  -- disable in comments
  enabled = function()
    local ctx = require('cmp.config.context')
    return not ctx.in_syntax_group("Comment")
  end,
  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
  },
})
end

----------------------------------------------------- preservim/vim-markdown ---

vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0

--------------------------------------------------------------- color scheme ---

local catppuccin_ok, catppuccin = pcall(require, 'catppuccin')
if catppuccin_ok and os.getenv("TERM") ~= 'linux' then
  -- only set colorsheme if term is likely to have 256 color
  vim.g.catppuccin_flavour = 'mocha'
  local colors = require("catppuccin.palettes").get_palette()
  catppuccin.setup({
    custom_highlights = {
      -- Disable italic display for comments
      Comment = { fg = colors.surface2, style = { } },
      ["@type"] = { fg = colors.flamingo },
      ["@function.macro"] = { fg = colors.peach },
    }
  })
  vim.cmd [[colorscheme catppuccin]]
end

------------------------------------------------------------------ lightline ---

opt.showmode = false

------------------------------------------------------------------- autocmds ---

local function setup_autocmds(working)
  vim.cmd [[
    autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

    autocmd FileType gitcommit setlocal spell textwidth=72

    autocmd FileType rust setlocal spell textwidth=80

    autocmd FileType markdown
        \ setlocal spell textwidth=80 |
        \ setlocal formatoptions-=q |
        \ setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*\[-*+]\\s\\+

    autocmd FileType make set softtabstop=0 noexpandtab

    autocmd BufRead * autocmd FileType <buffer> ++once
      \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$")
      \ | exe 'normal! g`"'
      \ | endif

    autocmd BufWritePre * :%s/\s\+$//e
  ]]
end

-- TODO: shift more configuration inside local functions
local function main()
    setup_autocmds()
end

main()

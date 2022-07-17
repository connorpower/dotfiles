-- Setup gloval options
local opt = vim.opt
local fn = vim.fn

opt.clipboard = 'unnamedplus'
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


-- Setup Plugins
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({
      'git', 'clone', '--depth', '1', 
      'https://github.com/wbthomason/packer.nvim', install_path
  })
end

require('plugins')

-- Configure preservim/vim-markdown
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0

-- Setup Color Scheme
vim.g.catppuccin_flavour = 'mocha'
vim.cmd [[colorscheme catppuccin]]


local function setup_autocmds(working)
  vim.cmd [[
    autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
    autocmd FileType gitcommit setlocal spell textwidth=72
    autocmd FileType markdown 
        \ setlocal spell textwidth=80 |
        \ setlocal formatoptions-=q |
        \ setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*\[-*+]\\s\\+
  ]]
end

-- TODO: shift more configuration inside local functions
local function main()
    setup_autocmds()
end

main()

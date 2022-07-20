vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'rust-lang/rust.vim'
  use 'junegunn/fzf'
  use 'godlygeek/tabular'
  use 'preservim/vim-markdown'
  use 'chrisbra/csv.vim'
  use({
    'catppuccin/nvim',
    as = 'catppuccin'
  })
  end
)


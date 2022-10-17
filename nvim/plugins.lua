vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)

  ------------------------------------------------------------ nvim, general ---

  -- nvim package management
  use 'wbthomason/packer.nvim'

  -- Completion framework
  use 'hrsh7th/nvim-cmp'

  -- Snippet completion source for nvim-cmp
  use 'hrsh7th/cmp-vsnip'

  -- Useful path completions
  use 'hrsh7th/cmp-path'

  -- Useful buffer completions
  use 'hrsh7th/cmp-buffer'

  use({
       'nvim-treesitter/nvim-treesitter',
       run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  })

  ---------------------------------------------------------------------- git ---

  -- git status gutter
  use 'lewis6991/gitsigns.nvim'

  -------------------------------------------------------------- project org ---

  -- fuzzy finder
  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'

  -- file controls and explorer
  use 'preservim/nerdtree'

  -- simple statusline plugin
  use 'itchyny/lightline.vim'

  ---------------------------------------------------------------------- LSP ---

  -- Common LSP tools
  use 'neovim/nvim-lspconfig'

  -- LSP completion source for nvim-cmp
  use 'hrsh7th/cmp-nvim-lsp'

  -- Tree-like view for LSP Symbols
  use 'simrat39/symbols-outline.nvim'

  --------------------------------------------------------------------- Rust ---

  -- file detection, syntax highlighting, formatting
  use 'rust-lang/rust.vim'

  -- Enable more of the features of rust-analyzer, such as inlay hints
  use 'simrat39/rust-tools.nvim'

  ---------------------------------------------------------------------- csv ---

  use 'godlygeek/tabular'
  use 'chrisbra/csv.vim'

  ------------------------------------------------------------------markdown ---

  -- GitHub markdwon compatible syntax that doesn't confuse deeply
  -- nested lists with codeblocks.
  use 'preservim/vim-markdown'

  ------------------------------------------------------------------- colors ---

  use({
    'catppuccin/nvim',
    as = 'catppuccin'
  })

  end
)


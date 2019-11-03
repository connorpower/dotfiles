" plugins
call plug#begin('~/.vim/plugged')

Plug 'keith/swift.vim'
Plug 'rust-lang/rust.vim'

" Initialize plugin system
call plug#end()

" highligting
syntax on
set hlsearch

" ruler settings
set ruler
set number
set colorcolumn=100
highlight ColorColumn ctermbg=0 guibg=lightgrey

" tab settings
set tabstop:4
set expandtab
set shiftwidth=4
set softtabstop=4

" enable automatic title setting for terminals
set title
set titleold="Terminal"
let &titlestring=expand("%:t")

" filetypes
autocmd BufNewFile,BufRead *.gcov setlocal ft=gcov
autocmd FileType make set noexpandtab

" rust
let g:rustfmt_autosave = 1


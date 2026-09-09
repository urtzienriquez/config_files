" set no compatible
set nocompatible

" Leader key
let mapleader = " "
let maplocalleader = " "

" turn relative line numbers on
set nu
set rnu

" Change cursor shape in different modes
let &t_SI = "\e[6 q"  " INSERT mode - vertical bar
let &t_SR = "\e[4 q"  " REPLACE mode - underscore
let &t_EI = "\e[2 q"  " NORMAL mode - block

" For tmux compatibility
if exists('$TMUX')
    let &t_SI = "\e[6 q"
    let &t_SR = "\e[4 q"
    let &t_EI = "\e[2 q"
endif

set ttimeout
set ttimeoutlen=1
set ttyfast

" Split navigation
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

" Split navigation from terminal mode
tnoremap <M-h> <C-\><C-N><C-w>h
tnoremap <M-j> <C-\><C-N><C-w>j
tnoremap <M-k> <C-\><C-N><C-w>k
tnoremap <M-l> <C-\><C-N><C-w>l

colorscheme habamax

" Call the .vimrc.plug file
if filereadable(expand("~/.vimrc.plug"))
	source ~/.vimrc.plug
endif

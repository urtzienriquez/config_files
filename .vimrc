" set no compatible
set nocompatible

" turn relative line numbers on
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

colorscheme habamax

" Call the .vimrc.plug file
if filereadable(expand("~/.vimrc.plug"))
	source ~/.vimrc.plug
endif

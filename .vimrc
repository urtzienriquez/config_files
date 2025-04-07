" set no compatible
set nocompatible

" turn relative line numbers on
set rnu

" Call the .vimrc.plug file
if filereadable(expand("~/.vimrc.plug"))
	source ~/.vimrc.plug
endif

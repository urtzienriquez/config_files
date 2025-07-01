# ls aliases
alias ls='ls -F --color=auto'
alias ll='ls -lhA'
alias la='ls -hA'

# dir aliases
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# grep aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
    
# matlab alias
# cd-s to MATLAB folder so that pathdef.m is included
# which allows to use functions from DEBTools_M and AmPtool
ml() {
	cd /home/urtzi/Documents/MATLAB
	matlab
	cd -
}

# neovim alias
alias nv='nvim'

# julia connected to server to use in neovim
alias jl='julia -i /home/urtzi/.julia_scripts/nvjulia.jl'
alias jl18='julia +1.8 -i /home/urtzi/.julia_scripts/nvjulia.jl'

# qstat alias for metacentrum
alias qs='ssh meta qstat -u urtzien'

# image viewer
alias iv='imv-x11'

# alias for ranger 
alias rn='ranger'

# alias for bat
alias bt='bat -p --theme="tokyonight_night"'

#calcurse
alias cl='calcurse'

# fzf with preview
alias fzf="fzf --preview 'bat -p --theme=tokyonight_night --color=always {}'"
		
# by default ff searches for files in the current dir
# optionally I can pass a path ($1) to search within that path
# or use the fh alias to search in $HOME
ff() {
	local ofile
	ofile=$(find $1 -type f | fzf) || return
	open "$ofile"
}
alias fh="ff ~"
# by default fd searches for directories in the $HOME dir
# optionally I can pass a path ($1) to search within that path
fd() {
	local to_dir
  if [ $# -eq 0 ]
    then
    to_dir=$(find $HOME -type d | fzf) || return
	else
    to_dir=$(find $1 -type d | fzf) || return
  fi
	cd "$to_dir"
}

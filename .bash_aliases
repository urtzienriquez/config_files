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
alias fo="fzf | xargs open"
fd() {
	local to_dir
  to_dir=$(find ~ -type d | fzf) || return
	cd $to_dir
}

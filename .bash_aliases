
# ls aliases
alias ls='ls --color=auto'
alias ll='ls -lAhF'
alias la='ls -AhF'
alias l='ls -CF'

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
alias nv='nvim2'

# julia connected to server to use in neovim
alias jl='julia -i /home/urtzi/.julia_scripts/nvjulia.jl'
alias jl18='julia +1.8 -i /home/urtzi/.julia_scripts/nvjulia.jl'

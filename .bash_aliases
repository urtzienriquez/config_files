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

# python
alias py='python3'

# julia
alias jl='julia'
# julia connected to server to use in neovim
alias jlc='julia -i /home/urtzi/.julia_scripts/nvjulia.jl'
alias jlc18='julia +1.8 -i /home/urtzi/.julia_scripts/nvjulia.jl'

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

# fzf 
		
# by default ff searches for files in the current dir
# optionally I can pass a path ($1) to search within that path
# or use the fh alias to search in $HOME
ff() {
	local ofile
	ofile=$(find $1 \( -path $1/node_modules -prune -o -path */.git -prune -o -path $HOME/go -prune \) -o -type f | fzf) || return
	mime=$(file -b --mime-type "$ofile")
	if [[ $mime = text/@(plain|x-*) ]] || [[ $mime = application/javascript ]]; then
		nvim "$ofile"
  else
		gio open "$ofile"
	fi
}
alias fh="ff ~"
# by default fd searches for directories in the $HOME dir
# optionally I can pass a path ($1) to search within that path
fd() {
	local to_dir
  if [ $# -eq 0 ]
    then
    to_dir=$(find $HOME \( -path $HOME/node_modules -prune -o -path */.git -prune -o -path $HOME/go -prune \) -o -type d | fzf --no-preview) || return
	else
    to_dir=$(find $1 \( -path $1/node_modules -prune -o -path */.git -prune -o -path $HOME/go -prune \) -o -type d | fzf --no-preview) || return
  fi
	cd "$to_dir"
}
# # (find) live grep [function taken and slightly modified from https://junegunn.github.io/fzf/tips/ripgrep-integration/]
# lg() (
#   RELOAD='reload:rg -i -g "!{node_modules,.git,go}" --column --color=always {q} || :'
#   OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
#             nvim {1} +{2}     # No selection. Open the current line in Vim.
#           else
#             nvim +cw -q {+f}  # Build quickfix list for the selected items.
#           fi'
#   fzf --disabled --ansi --multi \
# 		  --walker-skip .git,node_modules,go,.npm,.cpanm,.fnmt,.pki,target \
#       --bind "start:$RELOAD" --bind "change:$RELOAD" \
#       --bind "enter:become:$OPENER" \
#       --bind "ctrl-o:execute:$OPENER" \
#       --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-v:toggle-preview' \
#       --delimiter : \
#       --preview 'bat -p --color=always --theme=tokyonight_night --highlight-line {2} {1}' \
#       --preview-window '~4,+{2}+4/3,<75(up)' \
#       --query "$*"
# )

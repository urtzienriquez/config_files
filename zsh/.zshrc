HISTFILE=~/.config/zsh/.histfile
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS          # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicate entries from history
setopt HIST_SAVE_NO_DUPS         # Don't save duplicates to history file
setopt HIST_IGNORE_SPACE         # Don't record commands that start with space
setopt HIST_VERIFY               # Show command with history expansion to user before running it
setopt SHARE_HISTORY             # Share history between all sessions
setopt APPEND_HISTORY            # Append to history file, don't overwrite
setopt INC_APPEND_HISTORY        # Write to history file immediately, not when shell exits
setopt HIST_REDUCE_BLANKS        # Remove unnecessary blanks from history

bindkey -v 
bindkey "^H" backward-delete-char 
bindkey "^?" backward-delete-char 
# End of lines configured by zsh-newuser-install 
# The following lines were added by compinstall
zstyle :compinstall filename '/home/urtzi/.config/zsh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

source ~/.config/zsh/.zsh_aliases
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# proper colors for ghostty in ssh
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    export TERM=xterm-256color
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
	export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
fi

# neovim path export
export PATH="/opt/nvim/bin:$PATH"

# go path export
export PATH="/usr/local/go/bin:$PATH"
export PATH="$(go env GOPATH)/bin:$PATH"

RANGER_LOAD_DEFAULT_RC=FALSE

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/urtzi/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/urtzi/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

# fzf 
# enable keybinds
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh
# deafults
export FZF_DEFAULT_COMMAND='rg --files --hidden --no-ignore-vcs -l -g "!{node_modules,.git,go}"'
export FZF_DEFAULT_OPTS="
		--no-height 
		--no-reverse
    --preview 'bat -p --theme=tokyonight_night --color=always {}'
    --preview-window '~4,+{2}+4/3,<75(up)'
    --bind 'ctrl-v:toggle-preview'"
export FZF_CTRL_T_OPTS="
    --preview 'bat -p --theme=tokyonight_night --color=always {}'
    --bind 'ctrl-v:toggle-preview'"
export FZF_CTRL_R_OPTS="--no-preview"
export FZF_ALT_C_OPTS="--no-preview"


export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# -------------------------------
# History configuration
# -------------------------------
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS

# -------------------------------
# man with bat
# -------------------------------
export BAT_THEME=tokyonight_night
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# -------------------------------
# Vim mode and keybindings
# -------------------------------
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey -M viins "^I" expand-or-complete
autoload edit-command-line; zle -N edit-command-line
bindkey -M vicmd e edit-command-line

# -------------------------------
# Editor
# -------------------------------
export VISUAL=nvim
export EDITOR=nvim

# -------------------------------
# Autocompletion
# -------------------------------
zstyle :compinstall filename '/home/urtzi/.config/zsh/.zshrc'
zstyle ':completion:*' menu select
ZLS_COLORS="di=34:fi=0:ex=32:ln=36"
zstyle ':completion:*' list-colors "${(s.:.)ZLS_COLORS}"

autoload -Uz compinit
compinit

# -------------------------------
# Aliases
# -------------------------------
source ~/.config/zsh/.zsh_aliases

# -------------------------------
# Plugins
# -------------------------------

source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------------------------
# Terminal compatibility
# -------------------------------
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    export TERM=xterm-256color
fi

# -------------------------------
# Prompt colors
# -------------------------------
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# -------------------------------
# Misc
# -------------------------------
export RANGER_LOAD_DEFAULT_RC=FALSE

# -------------------------------
# PATH Setup
# -------------------------------
if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]; then
	export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
fi

export PATH="/home/urtzi/.local/bin:$PATH"

# Neovim path
export PATH="/opt/nvim/bin:$PATH"

# go path export
export PATH="/usr/local/go/bin:$PATH"
export PATH="$(go env GOPATH)/bin:$PATH"

# >>> juliaup initialize >>>
case ":$PATH:" in
    *:/home/urtzi/.juliaup/bin:*) ;;
    *) export PATH=/home/urtzi/.juliaup/bin${PATH:+:${PATH}} ;;
esac
# <<< juliaup initialize <<<

# -------------------------------
# fzf
# -------------------------------
if [[ "$HOST" == "debian" ]]; then
	source /usr/share/doc/fzf/examples/key-bindings.zsh
	source /usr/share/doc/fzf/examples/completion.zsh
elif [[ "$HOST" == "archlinux" ]]; then
	source /usr/share/fzf/key-bindings.zsh
	source /usr/share/fzf/completion.zsh
fi

export FZF_DEFAULT_COMMAND='rg --files --hidden --no-ignore-vcs -g "!node_modules" -g "!.git" -g "!go"'
export FZF_DEFAULT_OPTS="
  --no-height 
  --no-reverse
  --preview 'bat -p --color=always {}'
  --preview-window '~4,+{2}+4/3,<75(up)'
  --bind 'ctrl-v:toggle-preview'"
export FZF_CTRL_T_OPTS="
  --preview 'bat -p --color=always {}'
  --bind 'ctrl-v:toggle-preview'"
export FZF_CTRL_R_OPTS="--no-preview"
export FZF_ALT_C_OPTS="--no-preview"

# -------------------------------
# Zoxide
# -------------------------------
eval "$(zoxide init zsh)"

# -------------------------------
# Starship prompt
# -------------------------------
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"


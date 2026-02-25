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

# rm: for confirmation use a custom alias
setopt RM_STAR_SILENT

# extended globing patterns
setopt extended_glob

# -------------------------------
# man with bat
# -------------------------------
export BAT_THEME=nightfox
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# -------------------------------
# Vim mode and keybindings
# -------------------------------
bindkey -v
autoload edit-command-line; zle -N edit-command-line
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
autoload -Uz edit-command-line
edit-command-line-at-end() {
  zle edit-command-line
  zle end-of-line
}
zle -N edit-command-line-at-end
bindkey -M vicmd '^E' edit-command-line-at-end
bindkey -M viins '^E' edit-command-line-at-end
# Widget to close completion menu
_close_completion_menu() {
  zle -M ""
  zle reset-prompt
}
zle -N _close_completion_menu
bindkey -M viins '^X' _close_completion_menu

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
# Terminal compatibility for Ghostty + tmux
# -------------------------------
# Let Ghostty and tmux handle TERM automatically
# Ghostty sets TERM=xterm-ghostty, tmux will use tmux-256color
# Only override if we detect we're in a problematic environment
if [[ -z "$TMUX" && "$TERM" != "xterm-ghostty" && "$TERM" != "xterm-256color" ]]; then
    export TERM=xterm-256color
fi

# -------------------------------
# Prompt colors
# -------------------------------
case "$TERM" in
    xterm-color|*-256color|xterm-ghostty|tmux-256color) color_prompt=yes;;
esac

# -------------------------------
# Prompt theme
# -------------------------------
source ~/.config/zsh/.zsh_prompt_theme

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
# opt path (e.g. for matlab
export PATH="/opt:$PATH"
# go path export
export PATH="/usr/local/go/bin:$PATH"
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
# cargo path
export PATH=$PATH:$HOME/.cargo/bin
. "$HOME/.cargo/env"
# ZVM
export ZVM_INSTALL="$HOME/.zvm/self"
export PATH="$PATH:$HOME/.zvm/bin"
export PATH="$PATH:$ZVM_INSTALL/"
# perl paths
export PERL_LOCAL_LIB_ROOT="$HOME/.perl5"
export PERL_MB_OPT="--install_base $HOME/.perl5"
export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"
export PERL5LIB="$HOME/.perl5/lib/perl5"
export PATH="$HOME/.perl5/bin:$PATH"
# juliaup 
case ":$PATH:" in
    *:/home/urtzi/.juliaup/bin:*) ;;
    *) export PATH=/home/urtzi/.juliaup/bin${PATH:+:${PATH}} ;;
esac
# luarocks paths
export PATH="$HOME/.luarocks/bin:$PATH"
eval "$(luarocks path)"

# -------------------------------
# R configuration
# -------------------------------
export RENV_CONFIG_USER_PROFILE=TRUE

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

export FZF_TMUX=1
export FZF_TMUX_OPTS="--reverse --info=right -p 85%,85%"

export FZF_THEME_OPTS="--color=fg:#cdcecf,bg:#192330,hl:#719cd6 \
--color=fg+:#cdcecf,bg+:#29394f,hl+:#82b3f4,gutter:#192330 \
--color=info:#39506d,prompt:#719cd6,pointer:#dbc074 \
--color=marker:#81b29a,spinner:#63cdcf,header:#81b29a \
--color=border:#39506d,preview-border:#39506d,scrollbar:#39506d \
--color=separator:#39506d"

export FZF_DEFAULT_COMMAND='rg --files --hidden --no-ignore-vcs -g "!node_modules" -g "!.git" -g "!go"'

export FZF_DEFAULT_OPTS="
  $FZF_THEME_OPTS
  --no-height 
  --no-reverse
  --preview-window '+{2}+4/3,<60(up),border-sharp'
  --scrollbar='█'
  --bind 'ctrl-v:toggle-preview'
  --bind 'alt-K:preview-up,alt-J:preview-down'
  --bind 'ctrl-t:first,ctrl-b:last'"

export FZF_CTRL_T_OPTS="
  --preview 'bat -p --color=always {}'
  --preview-window 'border-sharp'
  --bind 'ctrl-v:toggle-preview'"

export FZF_CTRL_R_OPTS="--no-preview"
export FZF_ALT_C_OPTS="--no-preview"

# -------------------------------
# Zoxide
# -------------------------------
eval "$(zoxide init --cmd cd zsh)"

# -------------------------------
# tmux
# -------------------------------
# always start in a tmux session
if [ -z "$TMUX" ]; then
  tty_id=$(basename "$(tty)")
  session="term_${tty_id}"
  tmux new-session -A -s "$session"
fi

# -------------------------------
# venv
# -------------------------------
# re-activate python virtual environments in new panes/windows
if [ -n "$VIRTUAL_ENV" ]; then
    source $VIRTUAL_ENV/bin/activate;
fi

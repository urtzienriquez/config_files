# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Path to your oh-my-zsh installation (in .config!)
export ZSH="$HOME/.config/zsh/oh-my-zsh"

# Set theme to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    git-auto-fetch
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# -------------------------------
# Your custom configurations from old .zshrc
# Copy everything AFTER the "source $ZSH/oh-my-zsh.sh" line
# -------------------------------

# History configuration
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
setopt RM_STAR_SILENT
setopt extended_glob

# autofetch interval
GIT_AUTO_FETCH_INTERVAL=1

# Vim mode
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey -M viins "^I" expand-or-complete
autoload edit-command-line; zle -N edit-command-line
autoload -Uz edit-command-line
edit-command-line-at-end() {
  zle edit-command-line
  zle end-of-line
}
zle -N edit-command-line-at-end
bindkey -M vicmd '^E' edit-command-line-at-end
bindkey -M viins '^E' edit-command-line-at-end

# Editor
export VISUAL=nvim
export EDITOR=nvim

# man with bat
export BAT_THEME=tokyonight_night
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# Aliases
source ~/.config/zsh/.zsh_aliases

# Terminal compatibility
if [[ -z "$TMUX" && "$TERM" != "xterm-ghostty" && "$TERM" != "xterm-256color" ]]; then
    export TERM=xterm-256color
fi

# PATH Setup (all your PATH exports)
export PATH="/home/urtzi/.local/bin:$PATH"
export PATH="/opt/nvim/bin:$PATH"
export PATH="/opt:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin
. "$HOME/.cargo/env"
export ZVM_INSTALL="$HOME/.zvm/self"
export PATH="$PATH:$HOME/.zvm/bin"
export PATH="$PATH:$ZVM_INSTALL/"
export PERL_LOCAL_LIB_ROOT="$HOME/.perl5"
export PERL_MB_OPT="--install_base $HOME/.perl5"
export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"
export PERL5LIB="$HOME/.perl5/lib/perl5"
export PATH="$HOME/.perl5/bin:$PATH"
case ":$PATH:" in
    *:/home/urtzi/.juliaup/bin:*) ;;
    *) export PATH=/home/urtzi/.juliaup/bin${PATH:+:${PATH}} ;;
esac

# R configuration
export R_HOME="/usr/lib/R"
export RENV_CONFIG_USER_PROFILE=TRUE
export RANGER_LOAD_DEFAULT_RC=FALSE

# fzf
if [[ "$HOST" == "debian" ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
elif [[ "$HOST" == "archlinux" ]]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
fi
export FZF_THEME_OPTS="--color=fg:#c0caf5,bg:#222436,hl:#7dcfff \
--color=fg+:#c0caf5,bg+:#35274a,hl+:#bb9af7 \
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#bb9af7 \
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
export FZF_DEFAULT_COMMAND='rg --files --hidden --no-ignore-vcs -g "!node_modules" -g "!.git" -g "!go"'
export FZF_DEFAULT_OPTS="
  $FZF_THEME_OPTS
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

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# tmux auto-start
if [ -z "$TMUX" ]; then
  tty_id=$(basename "$(tty)")
  session="term_${tty_id}"
  tmux new-session -A -s "$session"
fi

# venv functions
function sv() {
    local venv_path="${1:-.}"
    source $venv_path/bin/activate &&
    tmux set-environment VIRTUAL_ENV $VIRTUAL_ENV &&
    alias deactivate='\deactivate && tmux set-environment -u VIRTUAL_ENV && unalias deactivate'
}
if [ -n "$VIRTUAL_ENV" ]; then
    source $VIRTUAL_ENV/bin/activate;
fi

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

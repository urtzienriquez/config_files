#!/usr/bin/env bash
TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins"
"$TMUX_PLUGIN_MANAGER_PATH/tpm/scripts/install_plugins.sh"
read -p "Press Enter to close..." -n 1 -r

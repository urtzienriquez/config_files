#!/bin/bash

# ===== Define your shortcuts here =====
# Format: 'Name|Command|Keybinding'
declare -a SHORTCUTS=(
  'Open Terminal|gnome-terminal|<Primary><Alt>T'
  'Open Files|nautilus|<Primary><Alt>F'
  'Open Browser|firefox|<Primary><Alt>B'
  'Open Web|alacritty --class web -e "qutebrowser --args bla"|<Primary><Alt>W'
)

# ===== Setup paths =====
BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# ===== Clear all existing custom shortcuts =====
EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
EXISTING=${EXISTING//[\[\]\' ]/}  # Remove brackets, quotes, spaces
IFS=',' read -r -a CURRENT <<< "$EXISTING"

for PATH in "${CURRENT[@]}"; do
  gsettings reset-recursively "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH" 2>/dev/null
done

# Clear top-level list
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"

# ===== Apply new shortcuts =====
NEW_BINDINGS=()

for i in "${!SHORTCUTS[@]}"; do
  ENTRY="${SHORTCUTS[$i]}"
  NAME=$(echo "$ENTRY" | cut -d'|' -f1)
  CMD=$(echo "$ENTRY" | cut -d'|' -f2)
  KEY=$(echo "$ENTRY" | cut -d'|' -f3)

  KEY_PATH="$BASE_PATH/custom$i/"
  NEW_BINDINGS+=("$KEY_PATH")

  # Create the new shortcut
  gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" name "$NAME"
  gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" command "$CMD"
  gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" binding "$KEY"

  echo "✅ Assigned: '$NAME' → $KEY → $CMD"
done

# ===== Update GNOME with new shortcut list =====
BINDING_LIST="["
for index in "${!NEW_BINDINGS[@]}"; do
  BINDING_LIST+="'${NEW_BINDINGS[$index]}'"
  if [[ $index -lt $((${#NEW_BINDINGS[@]} - 1)) ]]; then
    BINDING_LIST+=", "
  fi
done
BINDING_LIST+="]"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$BINDING_LIST"

echo "🎉 All shortcuts overwritten and applied successfully!"

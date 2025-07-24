#!/bin/bash

# ===== Define your shortcuts here =====
# Format: 'Name|Command|Keybinding'
declare -a SHORTCUTS=(
  'Open Terminal|gnome-terminal|<Primary><Alt>T'
  'Open Files|nautilus|<Primary><Alt>F'
  'Open Browser|firefox|<Primary><Alt>B'
  'Open Web|alacritty --class web -e "qutebrowser --args bla"|<Primary><Alt>W'
)

# ===== Setup paths and get existing bindings =====
BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
EXISTING=${EXISTING//[\[\]\' ]/}  # Remove brackets, quotes, spaces
IFS=',' read -r -a CURRENT <<< "$EXISTING"

# ===== Start assigning shortcuts =====
NEW_BINDINGS=()
i=0

for ENTRY in "${SHORTCUTS[@]}"; do
  NAME=$(echo "$ENTRY" | cut -d'|' -f1)
  CMD=$(echo "$ENTRY" | cut -d'|' -f2)
  KEY=$(echo "$ENTRY" | cut -d'|' -f3)

  # Generate unique customX path
  while [[ " ${CURRENT[*]} " == *"custom$i/"* ]] || [[ " ${NEW_BINDINGS[*]} " == *"custom$i/"* ]]; do
    ((i++))
  done

  KEY_PATH="$BASE_PATH/custom$i/"
  NEW_BINDINGS+=("$KEY_PATH")

  # Assign settings safely (command may have complex quoting)
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH name "$NAME"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH command "$(printf "%s" "$CMD")"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH binding "$KEY"

  echo "✅ Assigned: '$NAME' → $KEY → $CMD"
done

# ===== Merge old and new bindings =====
ALL_BINDINGS=("${CURRENT[@]}" "${NEW_BINDINGS[@]}")

# Reconstruct the list for gsettings
BINDING_LIST="['"
BINDING_LIST+=$(IFS="', '"; echo "${ALL_BINDINGS[*]}")
BINDING_LIST+="']"

# Apply to GNOME
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$BINDING_LIST"

echo "🎉 All shortcuts applied successfully!"

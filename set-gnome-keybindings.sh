#!/bin/bash

# Ensure PATH is correctly set
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Check dependencies
command -v gsettings >/dev/null || { echo "❌ gsettings not found in PATH"; exit 1; }
command -v cut >/dev/null || { echo "❌ cut not found in PATH"; exit 1; }

# Commands (optional full path resolution)
CUT_CMD=$(command -v cut)
GSETTINGS_CMD=$(command -v gsettings)

# ===== Define your shortcuts here =====
# Format: 'Name|Command|Keybinding'
declare -a SHORTCUTS=(
  'Open Terminal|alacritty|<Alt>Return'
  'Open Files|nautilus|<Alt>F'
  'Open Browser|qutebrowser|<Alt>J'
  'Open Browser|librewolf|<Alt>B'
	'Close Window|xdotool getwindowfocus windowkill|<Alt>Q'
	'Open Settings|gnome-control-center|<Alt>S'
  # 'Open Web|alacritty --class web -e "qutebrowser --args bla"|<Primary><Alt>W'
)

# ===== Setup paths =====
BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# ===== Clear all existing custom shortcuts =====
EXISTING=$($GSETTINGS_CMD get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
EXISTING=${EXISTING//[\[\]\' ]/}
IFS=',' read -r -a CURRENT <<< "$EXISTING"

for PATH in "${CURRENT[@]}"; do
  $GSETTINGS_CMD reset-recursively "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$PATH" 2>/dev/null
done

$GSETTINGS_CMD set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"

# ===== Apply new shortcuts =====
NEW_BINDINGS=()

for i in "${!SHORTCUTS[@]}"; do
  ENTRY="${SHORTCUTS[$i]}"
  NAME=$(echo "$ENTRY" | $CUT_CMD -d'|' -f1)
  CMD=$(echo "$ENTRY" | $CUT_CMD -d'|' -f2)
  KEY=$(echo "$ENTRY" | $CUT_CMD -d'|' -f3)

  KEY_PATH="$BASE_PATH/custom$i/"
  NEW_BINDINGS+=("$KEY_PATH")

  $GSETTINGS_CMD set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" name "$NAME"
  $GSETTINGS_CMD set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" command "$CMD"
  $GSETTINGS_CMD set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" binding "$KEY"

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

$GSETTINGS_CMD set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$BINDING_LIST"

echo "🎉 All shortcuts overwritten and applied successfully!"

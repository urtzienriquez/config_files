#!/usr/bin/env sh
# Ghostty ligature toggler
# Toggles font-feature ligature settings in ghostty config

config_file="$HOME/.config/ghostty/local.config"

# Check if config file exists
if [ ! -f "$config_file" ]; then
    echo "Error: Ghostty config file not found at $config_file"
    exit 1
fi

# Check if ghostty command is available
if ! command -v ghostty >/dev/null 2>&1; then
    echo "Error: ghostty command not found"
    exit 1
fi

# Check if the font-feature line is currently commented out
if grep -q "^#font-feature = " "$config_file"; then
    # Uncomment it
    sed -i "s/^#font-feature = /font-feature = /" "$config_file"
    echo "Ligatures disabled"
else
    # Comment it out
    sed -i "s/^font-feature = /#font-feature = /" "$config_file"
    echo "Ligatures enabled"
fi

# Reload ghostty config
xdotool key --clearmodifiers shift+ctrl+comma

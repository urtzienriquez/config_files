# Configuration files (dotfiles)

Linux setup to avoid using the mouse as much as possible and trying to stay in the terminal for most of the tasks.

Setup for Debian/Arch with:

- qtile as the window manager (with polybar)
- alacritty as the terminal emulator
  - zsh as the shell
- tmux + neovim
  - tmux with a modified tmux-resurrect session manager to load and save session by name
  - neovim config for a repl workflow for R, julia, python, matlab and various markdown formats
- ranger as file manager
- qutebrowser as internet browser
- fzf: both inside alacritty and as a flotting window for several utilities (e.g., connect to wifi)
- keyd to remap some keys (e.g., caps-lock as escape)

## how to use

1. Option 1: Copy paste folders/files or make symbolic links to those files under e.g. $HOME/.config

2. Option 2: Install Debian/Arch and run \*\_postinstall.sh

3. Option 3: Install debian with the gnome desktop environment and run the debian_gnome_postinstall.sh script

## todo

Update post-installation script for latest updates


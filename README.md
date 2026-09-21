# Configuration files (dotfiles)

Linux setup to avoid using the mouse as much as possible and trying to stay in the terminal for most of the tasks.

Setup for Debian with:

- ly as the display manager
- qtile as the window manager
- ghostty as the terminal emulator
  - zsh as the shell
- neovim as the main editor
  - neovim config for a repl workflow for R, julia, python, matlab and various markdown formats
- tmux, installed and available (e.g. for the `lg`/lazygit popup and the `tm` helper), but not the core session workflow anymore
- yazi as file manager
- qutebrowser (built from source) as internet browser
- fzf: both inside ghostty and as a flotting window for several utilities (e.g., connect to wifi)
- zotero, run headless as a systemd --user service (`zotero start`/`stop`/`status`/`restart`, see zsh/.zsh_aliases)

## how to use

1. Option 1: Copy paste folders/files or make symbolic links to those files under e.g. $HOME/.config

2. Option 2: Install Debian with no desktop task selected and run debian_postinstall.sh

3. Option 3: Install Debian with the desktop task selected (GNOME) and run debian_gnome_postinstall.sh instead
   - either way, ly ends up as the display manager and offers both the qtile and GNOME sessions at login

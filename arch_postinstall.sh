#!/bin/bash


# HOW TO USE
#
# install git as an additional package during arch installation
# once os installation finishes clone the repo with config files and this script:
# git clone https://github.com/urtzienriquez/config_files
#
# Then, run the script from $HOME
# ./config_files/arch_postinstall.sh


# NOTES
#
# ranger is not displaying previews


####################
# GENERAL
#

# yay aur helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

# installed with yay
yay -S ghostty qutebrowser-git unzip nvim python-pynvim \
	xclip xorg-xrandr zsh fzf zathura mpv inkscape gimp imv \
	juliaup r-base polybar zoxide lazygit bat \
	brightnessctl alsa-utils man python-pip \
	libreoffice ranger ueberzugpp tmux ttf-hack-nerd

# clone and install keyd
git clone https://github.com/rvaiya/keyd
cd keyd
make && sudo make install
sudo systemctl enable --now keyd
cd ..
mv keyd .keyd

# clone and install bat theme
git clone https://github.com/0xTadash1/bat-into-tokyonight
cd bat-into-tokyonight
./bat-into-tokyonight
cd ..
rm -rf bat-into-tokyonight

# install starship
curl -sS https://starship.rs/install.sh | sh


####################
# config files
#

# make links of config files to .config
for i in ghostty zsh starship tmux lazygit nvim polybar qtile qutebrowser ranger
do 
	rm -rf "$HOME/.config/$i"
	ln -s "$HOME/config_files/$i" "$HOME/.config/$i"
done

# make link to keyd remaps to /etc/keyd
sudo ln -s "$HOME/config_files/keyd/default.conf" /etc/keyd/
sudo keyd reload

# make links in $HOME
for i in .gitconfig .zshenv .julia_scripts
do 
	rm -rf "$HOME/$i"
	ln -s "$HOME/config_files/$i" "$HOME/$i"
done

# clone zsh plugins
cd "$HOME/.config/zsh/plugins"
rm -rf *
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting
cd "$HOME"


####################
# MATLAB
#

# install with mpm; matlab product manager
wget https://www.mathworks.com/mpm/glnxa64/mpm 
chmod +x mpm
sudo ./mpm install --release=R2020b --products=MATLAB 
# You can change the installation destination from default to another directory by adding this flag:
#  --destination=/path/to/desired/installation/directory

# to be able to launch matlab
yay -S libxcrypt-compat

# to activate
# cd /usr/local/MATLAB/R2020b/bin/
# ./activate_matlab.sh


####################
# Additional
#

# install zotero by downloading the tarball
# https://www.zotero.org/
# tar -xf Zotero-7.xxxxxxxxxx.tar.bz2
# follow the instruction in zotero.org

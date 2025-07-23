#!/bin/bash


# HOW TO USE
#
# as root install git, sudo, vim and neovim
# clone this repo:
# Clone this repo with config files and this script:
# git clone https://github.com/urtzienriquez/config_files
#
# Change /etc/sudoers to add user to sudoer group
#
# Then run the script from $HOME
# ./config_files/debian_postinstall.sh



####################
# GENERAL
#

# # installed with yay
# yay --noconfirm -S ghostty qutebrowser-git unzip nvim python-pynvim \
# 	xclip xorg-xrandr zsh fzf zathura mpv inkscape gimp imv \
# 	juliaup r-base polybar zoxide lazygit bat \
# 	brightnessctl alsa-utils man python-pip ytdl \
# 	libreoffice ranger ueberzugpp tmux ttf-hack-nerd \
# 	ripgrep unclutter xautolock betterlockscreen jdk-openjdk gcc-fortran \
# 	netcdf gdal git-lfs udunits

sudo apt install xorg xserver-xorg polybar \
	alacritty qtile lightdm gpg curl wget qutebrowser \
	unzip zsh fzf zathura mpv inkscape gimp imv libreoffice \
	bat lazygit zoxide ranger unclutter r-base

# i3lock-color
sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
	libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev \
	libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev \
	libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev \
	libjpeg-dev libgif-dev

git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
./build.sh
./install-i3lock-color.sh
cd ..
rm -rf i3lock-color

# betterlockscreen
wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system

# juliaup
curl -fsSL https://install.julialang.org | sh

# xautolock
# install from repos once it is there
wget http://deb.debian.org/debian/pool/main/x/xautolock/xautolock_2.2-8_amd64.deb
sudo dpkg -i xautolock_2.2-8_amd64.deb
rm xautolock_2.2-8_amd64.deb


wget -P /usr/share/fonts/truetype https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
wget -P /usr/share/fonts/truetype https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
cd /usr/share/fonts/truetype
unzip JetBrainsMono.zip
rm JetBrainsMono.zip
fc-cache -fv

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
for i in alacritty zsh starship tmux lazygit nvim polybar qtile qutebrowser ranger
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


# ####################
# # MATLAB
# #
#
# # install with mpm; matlab product manager
# wget https://www.mathworks.com/mpm/glnxa64/mpm 
# chmod +x mpm
# sudo ./mpm install --release=R2020b --products=MATLAB Simulink
# sudo mv mpm /opt
# # You can change the installation destination from default to another directory by adding this flag:
# #  --destination=/path/to/desired/installation/directory
#
# # to be able to launch matlab
# yay --noconfirm -S libxcrypt-compat
#
# # to activate
# # cd /usr/local/MATLAB/R2020b/bin/
# # ./activate_matlab.sh
#
#
# ####################
# # Additional
# #
#
# # install zotero by downloading the tarball
# # https://www.zotero.org/
# # tar -xf Zotero-7.xxxxxxxxxx.tar.bz2
# # follow the instruction in zotero.org

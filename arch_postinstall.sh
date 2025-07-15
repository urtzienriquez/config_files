#!/bin/bash

# ####################
# # MATLAB
# #
#
# ## NOTES:
# # Remember to deactivate the license after doing the tests. If not, I won't be able to deactivate
# # that license to get an active matlab copy in the "real" machine!
#
# # Unable to install matlab R2020b
#
# # solution!
# # install with mpm; matlab product manager
# wget https://www.mathworks.com/mpm/glnxa64/mpm 
# chmod +x mpm
# sudo ./mpm install --release=R2020b --products=MATLAB 
# # You can change the installation destination from default to another directory by adding this flag:
# #  --destination=/path/to/desired/installation/directory
#
# # to be able to launch matlab
# yay -S libxcrypt-compat
#
# # still problems activating matlab
# # it was due to the license being active in my old mac
# # to activate
# cd /usr/local/MATLAB/R2020b/bin/
# ./activate_matlab.sh


####################
# GENERAL
#

# # packages from pacman
# sudo pacman -S git
# git clone https://github.com/urtzienriquez/config_files
# ./config_files/arch_postinstall.sh

sudo pacman -S --noconfirm man python-pip

# yay aur helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

# installed with yay
# yay -S qutebrowser-git
# yay -S ghostty-git
# yay -S unzip
# yay -S nvim
# yay -S python-pynvim xclip
# yay -S xorg-xrandr
# yay -S zsh fzf zathura mpv
# yay -S inkscape gimp imv
# yay -S juliaup
# yay -S r-base
# yay -S polybar
# yay -S zoxide
# yay -S lazygit
# yay -S bat
yay -S qutebrowser-git unzip nvim python-pynvim \
	xclip xorg-xrandr zsh fzf zathura mpv inkscape gimp imv \
	juliaup r-base polybar zoxide lazygit bat \
	brightnessctl alsa-utils

yay -S ghostty-git

git clone https://github.com/0xTadash1/bat-into-tokyonight
cd bat-into-tokyonight
./bat-into-tokyonight
cd ..
rm -rf bat-into-tokyonight

curl -sS https://starship.rs/install.sh | sh

#####
# config files
cd config_files
for i in ghostty zsh starship tmux lazygit nvim polybar qtile qutebrowser ranger
do 
	rm -rf "$HOME/.config/$i"
	ln -s "$(pwd)/$i" "$HOME/.config/$i"
done


for i in .gitconfig .zshenv .julia_scripts
do 
	rm -rf "$HOME/$i"
	ln -s "$(pwd)/$i" "$HOME/$i"
done


cd "$HOME/.config/zsh/plugins"
rm -rf *
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting

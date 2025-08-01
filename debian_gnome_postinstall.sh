#!/bin/bash


# HOW TO USE
#
# as root install git, sudo and vim
# clone this repo:
# git clone https://github.com/urtzienriquez/config_files
#
# Change /etc/sudoers to add user to sudoer group
#
# Then, as your user (ie, not root) run the script from $HOME
# ./config_files/debian_postinstall.sh



####################
# GENERAL
#

home="/home/urtzi"

sudo apt install -y alacritty gpg curl wget qutebrowser \
	unzip zsh fzf zathura mpv imv libreoffice \
	bat lazygit zoxide qbittorrent vlc

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

export PATH="$home/.local/bin:$PATH"

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim && sudo mv nvim-linux-x86_64 /opt/nvim
rm nvim-linux-x86_64.tar.gz

# install librewolf
sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo apt update && sudo apt install librewolf -y

# nerd fonts
sudo wget -P /usr/share/fonts/truetype https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
sudo wget -P /usr/share/fonts/truetype https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
cd /usr/share/fonts/truetype
sudo mkdir -p JetBrains
sudo mkdir -p HackNerdFont
sudo unzip JetBrainsMono.zip -d JetBrains
sudo unzip Hack.zip -d HackNerdFont
sudo rm JetBrainsMono.zip
sudo rm Hack.zip
sudo fc-cache -fv
cd "$home"

# clone and install keyd
git clone https://github.com/rvaiya/keyd
cd keyd
make && sudo make install
sudo systemctl enable --now keyd
cd "$home"
mv keyd .keyd

# install starship
curl -sS https://starship.rs/install.sh | sh


####################
# config files
#
mkdir "$home/.config"

# clone and install bat theme
git clone https://github.com/0xTadash1/bat-into-tokyonight
cd bat-into-tokyonight
mkdir "$home/.config/bat"
bash ./bat-into-tokyonight
cd "$home"
rm -rf bat-into-tokyonight

# make links of config files to .config
for i in alacritty zsh starship tmux lazygit nvim qutebrowser
do 
	rm -rf "$home/.config/$i"
	ln -s "$home/config_files/$i" "$home/.config/$i"
done

# make link to keyd remaps to /etc/keyd
sudo ln -s "$home/config_files/keyd/default.conf" /etc/keyd/
sudo keyd reload

# make links in $HOME
for i in .gitconfig .zshenv
do 
	rm -rf "$home/$i"
	ln -s "$home/config_files/$i" "$home/$i"
done

# clone zsh plugins
cd "$home/.config/zsh/plugins"
rm -rf *
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting
cd "$home"



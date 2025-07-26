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

sudo apt install -y xorg xserver-xorg polybar \
	alacritty qtile lightdm gpg curl wget qutebrowser \
	unzip zsh fzf zathura mpv inkscape gimp imv libreoffice \
	bat lazygit zoxide ranger unclutter r-base \
	libcurl4-openssl-dev libharfbuzz-dev libfribidi-dev \
	libxml2-dev libtiff5-dev libtool libgdal-dev libudunits2-dev \
	libabsl-dev brightnessctl network-manager lua5.4 luarocks \
	golang ripgrep xclip pulseaudio alsa-utils bc rfkill \
	autorandr i3lock feh udisks2 poppler-utils

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

export PATH="$home/.local/bin:$PATH"

# i3lock-color
sudo apt install -y autoconf gcc make pkg-config libpam0g-dev \
	libcairo2-dev libfontconfig1-dev libxcb-composite0-dev \
	libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev \
	libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev \
	libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev \
	libjpeg-dev libgif-dev

git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
./build.sh
./install-i3lock-color.sh
cd ..
rm -rf i3lock-color

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim && sudo mv nvim-linux-x86_64 /opt/nvim
rm nvim-linux-x86_64.tar.gz

# betterlockscreen
wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system

# juliaup
curl -fsSL https://install.julialang.org | sh

# xautolock
# install from repos once it is there
wget http://deb.debian.org/debian/pool/main/x/xautolock/xautolock_2.2-8_amd64.deb
sudo dpkg -i xautolock_2.2-8_amd64.deb
rm xautolock_2.2-8_amd64.deb

# install ueberzugpp
sudo apt install cmake libssl-dev libvips-dev libsixel-dev libchafa-dev libtbb-dev libxcb-res0-dev libopencv-dev
git clone https://github.com/jstkdng/ueberzugpp.git
cd ueberzugpp
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DENABLE_OPENCV=ON \
      -DENABLE_WAYLAND=OFF \
      -DENABLE_X11=ON ..
cmake --build . -- -j$(nproc)
sudo cmake --install .
cd ../..
rm -rf ueberzugpp

# install librewolf
sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo apt update && sudo apt install librewolf -y

# nerd fonts
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
for i in alacritty zsh starship tmux lazygit nvim polybar qtile qutebrowser ranger
do 
	rm -rf "$home/.config/$i"
	ln -s "$home/config_files/$i" "$home/.config/$i"
done

# make link to keyd remaps to /etc/keyd
sudo ln -s "$home/config_files/keyd/default.conf" /etc/keyd/
sudo keyd reload

# make link for mount options
sudo ln -s "$home/config_files/mount_options.conf" /etc/udisks2/
# make links in $HOME
for i in .gitconfig .zshenv .julia_scripts
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
# # to activate
# # cd /usr/local/MATLAB/R2020b/bin/
# # ./activate_matlab.sh


####################
# Additional
#

# install zotero by downloading the tarball
# https://www.zotero.org/
# tar -xf Zotero-7.xxxxxxxxxx.tar.bz2
# follow the instruction in zotero.org


####################
# WiFi configuration
#

echo ">>> Configuring WiFi for NetworkManager..."

# Clean up /etc/network/interfaces (remove old Wi-Fi configs)
# Leave only loopback to prevent ifupdown from managing Wi-Fi
sudo tee /etc/network/interfaces > /dev/null <<EOF
auto lo
iface lo inet loopback
EOF

# Enable NetworkManager to manage all interfaces
sudo tee /etc/NetworkManager/NetworkManager.conf > /dev/null <<EOF
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no
EOF

# Disable and stop system-level wpa_supplicant (NM will use its own instance)
sudo systemctl stop wpa_supplicant.service
sudo systemctl disable wpa_supplicant.service

# Disable any per-interface wpa_supplicant instances
for iface in $(ls /sys/class/net | grep '^wl'); do
    sudo systemctl stop "wpa_supplicant@$iface.service" 2>/dev/null
    sudo systemctl disable "wpa_supplicant@$iface.service" 2>/dev/null
done

# Restart NetworkManager and ensure Wi-Fi is enabled
sudo systemctl restart NetworkManager
sudo rfkill unblock wifi
nmcli radio wifi on

echo ">>> WiFi setup complete. Use 'nmtui' or 'nmcli' to connect to a network."

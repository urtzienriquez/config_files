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
#
# This script assumes a base Debian install with NO desktop task selected
# during install (no GNOME, no gdm3). It builds the whole qtile setup from
# scratch, including the display manager (ly). See debian_gnome_postinstall.sh
# for the variant that starts from a Debian install where the desktop task
# was already selected.



####################
# GENERAL
#

home="/home/urtzi"

sudo apt install -y xorg xserver-xorg qtile picom dunst gpg curl wget git \
	build-essential unclutter r-base \
	libcurl4-openssl-dev libharfbuzz-dev libfribidi-dev \
	libxml2-dev libtiff-dev libtool libgdal-dev libudunits2-dev \
	libabsl-dev brightnessctl network-manager lua5.4 luarocks \
	golang ripgrep xclip xsel pipewire-audio pipewire-pulse wireplumber alsa-utils bc rfkill \
	autorandr feh udisks2 poppler-utils locate jq xdotool fd-find libglib2.0-bin \
	file openssh-client x11-xkb-utils \
	unzip zsh fzf zathura mpv inkscape gimp imv libreoffice \
	bat lazygit calcurse fastfetch screenkey

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

export PATH="$home/.local/bin:$PATH"

# zoxide (not packaged the way we use it here, installed as a standalone binary)
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash


####################
# zig, via zvm (needed to build ghostty and ly)
#

curl https://www.zvm.app/install.sh | bash
export PATH="$home/.zvm/bin:$home/.zvm/self:$PATH"
zvm install 0.16.0
zvm use 0.16.0


####################
# ly (display manager)
#

sudo apt install -y libpam0g-dev libxcb-xkb-dev xauth

git clone https://codeberg.org/fairyglade/ly.git "$home/Documents/GitHub/ly"
cd "$home/Documents/GitHub/ly"
zig build
sudo zig build installexe -Dinit_system=systemd
cd "$home"

sudo ln -sf "$home/config_files/ly/config.ini" /etc/ly/config.ini
sudo systemctl enable ly@tty2.service
sudo systemctl disable getty@tty2.service


####################
# i3lock-color
#

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


####################
# neovim (built from source, kept under Documents/GitHub)
#

git clone https://github.com/neovim/neovim "$home/Documents/GitHub/neovim"
cd "$home/Documents/GitHub/neovim"
make CMAKE_BUILD_TYPE=Release
sudo make install
cd "$home"


####################
# tmux (built from source, kept under Documents/GitHub)
#

sudo apt install -y libevent-dev libncurses-dev bison pkg-config

git clone https://github.com/tmux/tmux "$home/Documents/GitHub/tmux"
cd "$home/Documents/GitHub/tmux"
sh autogen.sh
./configure
make
sudo make install
cd "$home"


####################
# ghostty (terminal emulator, built from a release source tarball with zig)
#

ghostty_version="1.3.2"
wget "https://release.files.ghostty.org/${ghostty_version}/ghostty-${ghostty_version}.tar.gz"
tar -xzf "ghostty-${ghostty_version}.tar.gz"
cd "ghostty-${ghostty_version}"
zig build -p "$home/.local" -Doptimize=ReleaseFast
cd "$home"
rm -rf "ghostty-${ghostty_version}" "ghostty-${ghostty_version}.tar.gz"


####################
# ueberzugpp (image previews, eg. in yazi/ranger-style pickers)
#

sudo apt install -y cmake libssl-dev libvips-dev libsixel-dev libchafa-dev libtbb-dev libxcb-res0-dev libopencv-dev
git clone https://github.com/jstkdng/ueberzugpp.git
cd ueberzugpp
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DENABLE_OPENCV=ON \
      -DENABLE_WAYLAND=OFF \
      -DENABLE_X11=ON ..
cmake --build . -- -j"$(nproc)"
sudo cmake --install .
cd ../..
rm -rf ueberzugpp


####################
# yazi (file manager, downloaded as a prebuilt release binary)
#

yazi_version="$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -oP '"tag_name": "\K[^"]+')"
wget "https://github.com/sxyazi/yazi/releases/download/${yazi_version}/yazi-x86_64-unknown-linux-gnu.zip"
unzip "yazi-x86_64-unknown-linux-gnu.zip"
cp yazi-x86_64-unknown-linux-gnu/yazi yazi-x86_64-unknown-linux-gnu/ya ~/.local/bin/
rm -rf yazi-x86_64-unknown-linux-gnu "yazi-x86_64-unknown-linux-gnu.zip"


####################
# qutebrowser (built from source into /opt, linked against system PyQt6)
#

sudo apt install -y --no-install-recommends python3 python3-venv \
	libgl1 libxkbcommon-x11-0 libegl1 libfontconfig1 libglib2.0-0 \
	libdbus-1-3 libxcb-cursor0 libxcb-icccm4 libxcb-keysyms1 libxcb-shape0 \
	libnss3 libxcomposite1 libxdamage1 libxrender1 libxrandr2 libxtst6 libxi6 \
	libasound2t64 python3-pyqt6 python3-pyqt6.qtwebengine

sudo mkdir -p /opt/qutebrowser
sudo chown "$(id -un):$(id -gn)" /opt/qutebrowser
git clone https://github.com/qutebrowser/qutebrowser.git /opt/qutebrowser
cd /opt/qutebrowser
python3 scripts/mkvenv.py --pyqt-type link
cd "$home"

mkdir -p ~/.local/bin
tee ~/.local/bin/qutebrowser > /dev/null <<'EOF'
#!/bin/bash
/opt/qutebrowser/.venv/bin/python3 -m qutebrowser "$@"
EOF
chmod +x ~/.local/bin/qutebrowser


####################
# rust toolchain, via rustup
#

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$home/.cargo/env"
rustup component add clippy rustfmt rust-analyzer miri
cargo install --locked cargo-cache tree-sitter-cli viu


####################
# perl (cpanm + local::lib, matches PERL5LIB setup in zsh/.zshrc)
#

sudo apt install -y cpanminus
mkdir -p "$home/.perl5"
eval "$(perl -I"$home/.perl5/lib/perl5" -Mlocal::lib="$home/.perl5")"
cpanm --local-lib="$home/.perl5" local::lib


####################
# TeX Live 2026 (official installer, not the apt package -- keeps a current release)
#

tl_tmp="$(mktemp -d)"
wget -O "$tl_tmp/install-tl.tar.gz" https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf "$tl_tmp/install-tl.tar.gz" -C "$tl_tmp"
cat > "$tl_tmp/texlive.profile" <<EOF
selected_scheme scheme-medium
TEXDIR /usr/local/texlive/2026
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/2026/texmf-config
TEXMFSYSVAR /usr/local/texlive/2026/texmf-var
TEXMFHOME ~/.texmf
instopt_adjustpath 1
instopt_letter 0
tlpdbopt_autobackup 0
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
EOF
sudo perl "$tl_tmp"/install-tl-*/install-tl -profile "$tl_tmp/texlive.profile"
rm -rf "$tl_tmp"

export PATH="$PATH:/usr/local/texlive/2026/bin/x86_64-linux"


####################
# wtwitch (twitch notifier, symlinked from a persistent clone)
#

git clone https://github.com/krathalan/wtwitch "$home/Documents/GitHub/wtwitch"
sudo ln -sf "$home/Documents/GitHub/wtwitch/src/wtwitch" /usr/local/bin/wtwitch


####################
# Zotero, run headless via a systemd --user service
#

sudo apt install -y gpg
wget -qO- https://zotero.retorque.re/file/apt-package-archive/deb.asc | \
	gpg --dearmor | sudo tee /usr/share/keyrings/zotero-archive-keyring.gpg > /dev/null
sudo tee /etc/apt/sources.list.d/zotero.list > /dev/null <<EOF
deb [signed-by=/usr/share/keyrings/zotero-archive-keyring.gpg by-hash=force] https://zotero.retorque.re/file/apt-package-archive ./
EOF
sudo apt update
sudo apt install -y zotero

mkdir -p "$home/.config/systemd/user"
ln -sf "$home/config_files/systemd/user/zotero.service" "$home/.config/systemd/user/zotero.service"
systemctl --user daemon-reload
# left disabled/stopped on purpose -- start with the `zotero start` zsh function


####################
# librewolf
#

sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo apt update && sudo apt install librewolf -y


####################
# quarto (used by the quarto-hugo zsh function)
#

quarto_version="1.8.27"
wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${quarto_version}/quarto-${quarto_version}-linux-amd64.tar.gz"
sudo mkdir -p /opt/quarto
sudo tar -xzf "quarto-${quarto_version}-linux-amd64.tar.gz" -C /opt/quarto --strip-components=1
sudo ln -sf /opt/quarto/bin/quarto /usr/local/bin/quarto
rm "quarto-${quarto_version}-linux-amd64.tar.gz"


####################
# nerd fonts
#

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


####################
# bat theme (nightfox/dayfox, from the nightfox.nvim fork used for neovim)
#

mkdir -p "$home/.config/bat/themes"
git clone https://github.com/urtzienriquez/nightfox.nvim
cp nightfox.nvim/extra/nightfox/nightfox.tmTheme "$home/.config/bat/themes/"
cp nightfox.nvim/extra/dayfox/dayfox.tmTheme "$home/.config/bat/themes/"
rm -rf nightfox.nvim
bat cache --build


####################
# juliaup
#

curl -fsSL https://install.julialang.org | sh


####################
# config files
#

# make links of config files to .config
for i in nvim qutebrowser zsh lazygit picom ghostty qtile dunst tmux
do
	rm -rf "$home/.config/$i"
	ln -s "$home/config_files/$i" "$home/.config/$i"
done

# make links in $HOME
for i in .gitconfig .zshenv .lintr .Rprofile .Renviron .vimrc .vimrc.plug
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

# set natural scrolling and click on tap
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/40-libinput.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "touchpad defaults"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "on"
EndSection
EOF


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

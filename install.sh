#!/bin/sh
set -e

USER_NAME="${SUDO_USER:-$USER}"
DOTFILES_REPO="https://github.com/sujitbalasubramanian/.dotfiles"

sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base base-devel git man openssh unzip acpi

if ! command -v yay &> /dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

if [ ! -d "$HOME/.dotfiles" ]; then
  git clone --bare "$DOTFILES_REPO" "$HOME/.dotfiles.git"
  git --git-dir="$HOME" --work-tree="$HOME" checkout
  git --git-dir="$HOME" --work-tree="$HOME" config --local status.showUntrackedFiles no
fi

yay -S --noconfirm \
  sway i3status nwg-look wmenu grim slurp brightnessctl dunst wl-clipboard \
  wlsunset waylock xdg-user-dirs swayhide nwg-displays \
  networkmanager network-manager-applet bluez bluez-utils \
  pop-gtk-theme pop-icon-theme ttf-fira-sans ttf-firacode-nerd \
  pipewire pipewire-pulse mpv gimp obs-studio xdg-desktop-portal xdg-desktop-portal-wlr \
  ghostty zsh zsh-syntax-highlighting tmux bottom \
  brave-bin chromium \
  yazi jq 7zip ffmpeg fd ripgrep fzf poppler zoxide imagemagick chafa trash-cli gvfs gvfs-mtp \
  neovim tree-sitter tree-sitter-cli cargo rustup clang nvm pyenv fvm go \
  zig gdb jdk17-openjdk dbeaver cmake bun nodejs \
  fastfetch bat bc glow downgrade aria2 \
  texlive-basic zathura zathura-pdf-poppler zathura-pdf-djvu rnote libreoffice-still \
  pulsemixer newsboat neomutt lazygit lazydocker mpd ncmpcpp \
  wshowkeys scrcpy \
  dropbox dropbox-cli \
  fcitx5 fcitx5-configtool \
  qemu-base virt-manager dmidecode dnsmasq \
  visual-studio-code-bin aws-cli google-cloud-cli postman-bin android-studio \
  am

am -i kdenlive arduino-ide

sudo usermod -aG docker,libvirt,plugdev "$USER_NAME"

xdg-user-dirs-update

sudo sed -i '/^firewall_backend *=/d' /etc/libvirt/network.conf
echo 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf

echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"' | sudo tee -a /etc/udev/rules.d/99-hidraw.rules

sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

curl -fsSL https://bun.sh/install | bash

rustup toolchain install stable

mkdir ~/.local/share/gnupg

echo "Installation done reboot your system"

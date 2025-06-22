#!/bin/sh
set -e

USER_NAME="${SUDO_USER:-$USER}"
DOTFILES_REPO="https://github.com/sujitbalasubramanian/.dotfiles"

sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base base-devel git curl

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

xargs yay -S < $(curl https://setup.sujitbalasubramanian.in/programs)

sudo usermod -aG docker,libvirt,plugdev "$USER_NAME"

xdg-user-dirs-update

sudo sed -i '/^firewall_backend *=/d' /etc/libvirt/network.conf
echo 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf

echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"' | sudo tee -a /etc/udev/rules.d/99-hidraw.rules

sudo systemctl enable --now docker
sudo systemctl enable --now libvirtd
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

mkdir ~/.local/share/gnupg

echo "installation done reboot your system"

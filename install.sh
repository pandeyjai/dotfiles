#!/bin/bash
# zJairO-style i3 + polybar rice - one-shot installer (fresh Arch Minimal -> desktop)
# Maintainer: Prashant Pandey
# Upstream: https://github.com/zJairO/dotfiles
# Usage: git clone https://github.com/pandey-ps/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
set -e
RICE="$(cd "$(dirname "$0")" && pwd)"

PACMAN_PKGS="xorg xorg-xinit xorg-xauth xterm i3-wm polybar rofi feh xcompmgr dex xss-lock i3lock network-manager-applet networkmanager mate-terminal caja libpulse maim git base-devel wget python psmisc ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts"
AUR_PKGS="spotify polybar-spotify"

echo "==> removing old-rice lockers (conflict with i3lock)"
sudo pacman -Rns --noconfirm i3lock-color betterlockscreen 2>/dev/null || true

echo "==> installing pacman packages"
sudo pacman -Syu --needed --noconfirm $PACMAN_PKGS

if ! command -v yay >/dev/null; then
  echo "==> installing yay"
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
fi
echo "==> installing AUR packages (spotify now-playing)"
yay -S --needed --noconfirm $AUR_PKGS || echo "!! AUR step failed, continuing without spotify module"

echo "==> installing configs (backups kept as *.bak)"
mkdir -p ~/.config/i3 ~/.config/polybar ~/Pictures/Wallpapers ~/Pictures/Screenshots
[ -f ~/.config/i3/config ] && cp ~/.config/i3/config ~/.config/i3/config.bak
[ -f ~/.config/polybar/config ] && cp ~/.config/polybar/config ~/.config/polybar/config.bak
cp "$RICE/i3/config" ~/.config/i3/config
cp "$RICE/polybar/config" ~/.config/polybar/config
cp "$RICE/wallpaper/1182325.jpg" ~/Pictures/Wallpapers/
[ -f ~/.xinitrc ] || printf 'exec i3\n' > ~/.xinitrc

echo "==> enabling network"
sudo systemctl enable --now NetworkManager 2>/dev/null || true

echo "done. notes:"
echo " - dead keybinds (helpers not in repo): Win+d rofi text launcher, Print/Shift+Print scregcp, Win+Esc/Win+E use undefined \$Mod (should be \$mod)"
echo " - dropbox autostart will fail unless you install it; comment it out in ~/.config/i3/config if unwanted"
echo "run: startx"

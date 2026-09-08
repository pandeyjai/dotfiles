#!/bin/bash
set -e
RICE="$(cd "$(dirname "$0")" && pwd)"
PACMAN_PKGS="xorg xorg-xinit xorg-xauth i3-wm polybar rofi feh picom dex xss-lock i3lock-color network-manager-applet networkmanager kitty nautilus gvfs libpulse git base-devel python psmisc ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts autorandr arandr xorg-xrandr libnotify dunst adw-gtk-theme gnome-themes-extra power-profiles-daemon upower fastfetch xsettingsd brightnessctl"
AUR_PKGS="betterlockscreen"

echo "==> installing packages"
sudo pacman -Syu --needed --noconfirm $PACMAN_PKGS

if ! command -v yay >/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
fi
if [ -n "${AUR_PKGS:-}" ]; then yay -S --needed --noconfirm $AUR_PKGS 2>/dev/null || true; fi

echo "==> installing configs"
mkdir -p ~/.config/i3 ~/.config/polybar ~/Pictures/Wallpapers ~/Pictures/Screenshots ~/.local/bin ~/.config/rofi
[ -f ~/.config/i3/config ] && cp ~/.config/i3/config ~/.config/i3/config.bak
[ -f ~/.config/polybar/config ] && cp ~/.config/polybar/config ~/.config/polybar/config.bak
[ -f ~/.config/rofi/config.rasi ] && cp ~/.config/rofi/config.rasi ~/.config/rofi/config.rasi.bak
cp "$RICE/i3/config" ~/.config/i3/config
cp "$RICE/polybar/config" ~/.config/polybar/config
cp "$RICE/polybar/launch.sh" ~/.config/polybar/launch.sh; chmod +x ~/.config/polybar/launch.sh
cp "$RICE/picom/picom.conf" ~/.config/picom/picom.conf
cp "$RICE/scripts/display-menu.sh" ~/.local/bin/display-menu; chmod +x ~/.local/bin/display-menu
cp "$RICE/scripts/audio-menu.sh" ~/.local/bin/audio-menu; chmod +x ~/.local/bin/audio-menu
cp "$RICE/scripts/pkg-menu.sh" ~/.local/bin/pkg-menu; chmod +x ~/.local/bin/pkg-menu
cp "$RICE/scripts/idle-toggle.sh" ~/.local/bin/idle-toggle.sh; chmod +x ~/.local/bin/idle-toggle.sh
cp "$RICE/scripts/workspaces.sh" ~/.local/bin/workspaces.sh; chmod +x ~/.local/bin/workspaces.sh
cp "$RICE/scripts/power-menu.sh" ~/.local/bin/power-menu.sh; chmod +x ~/.local/bin/power-menu.sh
cp "$RICE/scripts/battery.sh" ~/.local/bin/battery.sh; chmod +x ~/.local/bin/battery.sh
cp "$RICE/scripts/clip.sh" ~/.local/bin/clip.sh; chmod +x ~/.local/bin/clip.sh
cp "$RICE/scripts/fix-interlaced.sh" ~/.local/bin/fix-interlaced.sh; chmod +x ~/.local/bin/fix-interlaced.sh
cp "$RICE/rofi/config.rasi" ~/.config/rofi/config.rasi
mkdir -p ~/.config/dunst; cp "$RICE/dunst/dunstrc" ~/.config/dunst/dunstrc
mkdir -p ~/.config/kitty; cp "$RICE/kitty/kitty.conf" ~/.config/kitty/kitty.conf
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/xsettingsd
cp "$RICE/gtk-3.0/settings.ini" ~/.config/gtk-3.0/settings.ini
cp "$RICE/gtk-4.0/settings.ini" ~/.config/gtk-4.0/settings.ini
cp "$RICE/xsettingsd/xsettingsd.conf" ~/.config/xsettingsd/xsettingsd.conf
cp "$RICE/wallpaper/1182325.jpg" ~/Pictures/Wallpapers/
mkdir -p ~/.local/share/applications; cp "$RICE/applications/install.desktop" ~/.local/share/applications/install.desktop
update-desktop-database ~/.local/share/applications 2>/dev/null || true
# betterlockscreen cache (blur from wallpaper)
betterlockscreen -u ~/Pictures/Wallpapers/1182325.jpg 2>/dev/null || true
[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak
[ -f ~/.bash_profile ] && cp ~/.bash_profile ~/.bash_profile.bak
cp "$RICE/.bashrc" ~/.bashrc
cp "$RICE/.bash_profile" ~/.bash_profile
[ -f ~/.xinitrc ] && [ ! -L ~/.xinitrc ] && cp ~/.xinitrc ~/.xinitrc.bak
cp "$RICE/.xinitrc" ~/.xinitrc

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
gsettings set org.mate.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || gsettings set org.mate.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf >/dev/null <<'EOF'
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lmr"
    Option "TappingDrag" "on"
    Option "DisableWhileTyping" "on"
EndSection
EOF

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I \$TERM
EOF
sudo systemctl daemon-reload
sudo systemctl enable getty@tty1.service 2>/dev/null || true

# --- Network stability fix: disable systemd-networkd which conflicts with NetworkManager (caused 20s disconnect cycle on wlo1/rtw88_8723de) ---
echo "==> fixing network (disable systemd-networkd, install NetworkManager + modprobe configs)"
sudo systemctl disable --now systemd-networkd 2>/dev/null || true
sudo systemctl mask systemd-networkd 2>/dev/null || true
sudo systemctl disable --now systemd-networkd.socket systemd-networkd-varlink.socket systemd-networkd-varlink-metrics.socket systemd-networkd-resolve-hook.socket 2>/dev/null || true
sudo systemctl mask systemd-networkd-varlink.socket systemd-networkd-varlink-metrics.socket 2>/dev/null || true
if ls /etc/systemd/network/20-*.network >/dev/null 2>&1; then sudo mkdir -p /etc/systemd/network/backup; sudo mv /etc/systemd/network/20-*.network /etc/systemd/network/backup/ 2>/dev/null || true; fi
sudo mkdir -p /etc/NetworkManager/conf.d
sudo cp "$RICE/networkmanager/conf.d/wifi-powersave.conf" /etc/NetworkManager/conf.d/wifi-powersave.conf
sudo cp "$RICE/networkmanager/conf.d/wifi-rand-mac.conf" /etc/NetworkManager/conf.d/wifi-rand-mac.conf
sudo cp "$RICE/networkmanager/conf.d/dns-resolved.conf" /etc/NetworkManager/conf.d/dns-resolved.conf
sudo mkdir -p /etc/modprobe.d
sudo cp "$RICE/modprobe.d/rtw88_8723de.conf" /etc/modprobe.d/rtw88_8723de.conf 2>/dev/null || true
sudo systemctl daemon-reload

sudo systemctl enable --now NetworkManager 2>/dev/null || true
sudo systemctl enable --now power-profiles-daemon 2>/dev/null || true
sudo timedatectl set-timezone Asia/Kolkata 2>/dev/null || sudo ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime 2>/dev/null || true
echo "done."

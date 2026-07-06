#!/usr/bin/env bash
#
# install.sh — deploys this rice onto an Arch/Arch-based Hyprland setup.
# Run from inside the extracted hypr-rice/ folder: ./install.sh
#
set -e

echo "== Installing packages (requires yay for AUR) =="
PACMAN_PKGS=(hyprland hyprlock hypridle \
    kitty grim slurp wl-clipboard cliphist brightnessctl pavucontrol \
    ttf-jetbrains-mono-nerd papirus-icon-theme polkit-gnome nautilus \
    cava jq socat qt6ct networkmanager upower)
AUR_PKGS=(swww bibata-cursor-theme-bin catppuccin-cursors-mocha wlogout quickshell-git matugen swayosd-git)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
else
    echo "yay not found — install these manually from the AUR: ${AUR_PKGS[*]}"
fi

echo "== Backing up existing configs (if any) =="
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
for dir in hypr quickshell kitty cava; do
    if [ -d "$HOME/.config/$dir" ]; then
        mv "$HOME/.config/$dir" "$HOME/.config/${dir}.bak.$TIMESTAMP"
        echo "Backed up ~/.config/$dir -> ~/.config/${dir}.bak.$TIMESTAMP"
    fi
done

echo "== Copying new configs =="
mkdir -p "$HOME/.config"
cp -r hypr quickshell kitty cava "$HOME/.config/"
chmod +x "$HOME/.config/hypr/scripts/wallpaper.sh"
chmod +x "$HOME/.config/hypr/scripts/gamemode.sh"
chmod +x "$HOME/.config/hypr/scripts/overview.sh"
chmod +x "$HOME/.config/hypr/scripts/theme-from-wallpaper.sh"
chmod +x "$HOME/.config/hypr/scripts/install-overview-plugin.sh"
chmod +x "$HOME/.config/quickshell/hypr-rice/scripts/cava.sh"

echo "== Installing Hyprland Plugins (this may take a while) =="
if command -v hyprpm &>/dev/null; then
    echo "Updating hyprpm headers..."
    hyprpm update
    
    echo "Installing hyprtrails..."
    hyprpm add https://github.com/hyprwm/hyprland-plugins || true
    hyprpm enable hyprtrails || true

    echo "Installing hypr-dynamic-cursors..."
    hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors || true
    hyprpm enable hypr-dynamic-cursors || true
    
    echo "Installing hyprexpo..."
    hyprpm add https://github.com/sandwichfarm/hyprexpo || true
    hyprpm enable hyprexpo || true
else
    echo "hyprpm not found; skipping plugin installation."
fi

mkdir -p "$HOME/Pictures/Wallpapers"
echo "Drop some wallpaper images into ~/Pictures/Wallpapers before logging in."

echo "== Done =="
echo "Log out and select Hyprland from your display manager, or run 'Hyprland' from a TTY."

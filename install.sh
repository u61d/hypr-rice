#!/usr/bin/env bash
#
# install.sh — deploys this rice onto an Arch/Arch-based Hyprland setup.
# Run from inside the extracted hypr-rice/ folder: ./install.sh
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "== Installing packages (requires yay for AUR) =="
PACMAN_PKGS=(hyprland hyprlock hypridle \
    kitty grim slurp wl-clipboard cliphist brightnessctl pavucontrol \
    ttf-jetbrains-mono-nerd inter-font ttf-material-symbols-variable papirus-icon-theme polkit-gnome nautilus \
    cava jq socat qt6ct networkmanager upower curl wf-recorder hyprpicker)
AUR_PKGS=(swww bibata-cursor-theme-bin catppuccin-cursors-mocha quickshell-git matugen)

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
chmod +x "$HOME/.config/hypr/scripts/"*.sh
chmod +x "$HOME/.config/quickshell/hypr-rice/scripts/"*.sh

echo "== Installing Hyprland Plugins (this may take a while) =="
if command -v hyprpm &>/dev/null; then
    install_hypr_plugin() {
        local repo_url="$1"
        local plugin_name="$2"
        local label="${3:-$plugin_name}"

        echo "Setting up ${label}..."
        if hyprpm add "$repo_url"; then
            echo "  added or updated repository"
        else
            echo "  repository already present (continuing)"
        fi
        if hyprpm enable "$plugin_name"; then
            echo "  enabled ${plugin_name}"
        else
            echo "  WARNING: could not enable ${plugin_name}"
        fi
    }

    echo "Updating hyprpm headers..."
    hyprpm update

    # hyprtrails was removed from hyprland-plugins in May 2026 — no longer installable via hyprpm.
    install_hypr_plugin "https://github.com/VirtCode/hypr-dynamic-cursors" "dynamic-cursors"
    install_hypr_plugin "https://github.com/sandwichfarm/hyprexpo" "hyprexpo"

    echo "Reloading plugins..."
    hyprpm reload -n || hyprpm reload || true

    echo "Installed plugins:"
    hyprpm list || true
else
    echo "hyprpm not found; skipping plugin installation."
    echo "Optional eye-candy plugins (dynamic cursors, overview) will not be available."
fi

mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots" "$HOME/Videos/Recordings"
echo "Drop some wallpaper images into ~/Pictures/Wallpapers before logging in."

echo "== Done =="
echo "Log out and select Hyprland from your display manager, or run 'Hyprland' from a TTY."
#!/usr/bin/env bash
#
# ~/.config/hypr/scripts/wallpaper.sh
# Sets the wallpaper via swww with a fancy transition on every load.
# Drop your wallpapers into ~/Pictures/Wallpapers and edit WALLPAPER below,
# or leave WALLPAPER unset to pick a random one from that folder each launch.

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WALLPAPER="${1:-$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' \) | shuf -n 1)}"

# Give swww-daemon a moment to be ready on first launch
for _ in {1..10}; do
    swww query &>/dev/null && break
    sleep 0.2
done

if [ -z "$WALLPAPER" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR — add some images there."
    exit 1
fi

"$HOME/.config/hypr/scripts/theme-from-wallpaper.sh" "$WALLPAPER" || true

swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-duration 1.2 \
    --transition-fps 60 \
    --transition-step 90

#!/usr/bin/env bash
set -euo pipefail

# Without -c backlight, brightnessctl grabs the first brightness-capable
# device it finds, which can be a keyboard LED (e.g. numlock) instead of the
# actual screen backlight if no backlight-class device sorts first. Pin it.
CLASS="backlight"

if ! brightnessctl -c "$CLASS" info >/dev/null 2>&1; then
    notify-send -u critical "Brightness" "No backlight-class device found. Run 'brightnessctl -l' to see what's available (you may need ddcutil for an external monitor instead)."
    exit 1
fi

case "$1" in
    up)
        brightnessctl -c "$CLASS" set +5%
        ;;
    down)
        brightnessctl -c "$CLASS" set 5%-
        ;;
esac

val=$(brightnessctl -c "$CLASS" -m | awk -F, '{print int($4)}')
qs -c hypr-rice ipc call hypr-rice showOsd "brightness" "$val"

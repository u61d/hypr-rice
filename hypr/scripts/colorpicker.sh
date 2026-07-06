#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprpicker >/dev/null 2>&1; then
    notify-send "Color Picker" "hyprpicker is not installed." -u critical
    exit 1
fi

notify-send "Color Picker" "Select a color on screen..." -u low -t 2000
color=$(hyprpicker)

if [ -n "$color" ]; then
    echo -n "$color" | wl-copy
    notify-send "Color Picker" "Copied $color to clipboard!" -u normal
fi

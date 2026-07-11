#!/usr/bin/env bash
set -euo pipefail

case "$1" in
    up)
        brightnessctl set +5%
        ;;
    down)
        brightnessctl set 5%-
        ;;
esac

val=$(brightnessctl -m | awk -F, '{print int($4)}')
qs -c hypr-rice ipc call hypr-rice showOsd "brightness" "$val"

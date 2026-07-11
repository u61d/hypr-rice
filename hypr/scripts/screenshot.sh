#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/Pictures/Screenshots"
file="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"

if [ "$1" == "area" ]; then
    grim -g "$(slurp)" "$file"
else
    grim "$file"
fi

wl-copy < "$file"
qs -c hypr-rice ipc call hypr-rice showScreenshot "$file"

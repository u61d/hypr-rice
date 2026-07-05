#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-rice-gamemode"

notify() {
    hyprctl notify 1 2500 "$1" "$2" >/dev/null 2>&1 || true
}

if [[ -f "$state_file" ]]; then
    rm -f "$state_file"
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:shadow:enabled true
    hyprctl keyword decoration:rounding 14
    hyprctl keyword decoration:inactive_opacity 0.92
    hyprctl keyword general:gaps_in 5
    hyprctl keyword general:gaps_out 12
    hyprctl keyword general:border_size 2
    notify "rgb(a6e3a1)" "hypr-rice gamemode off"
else
    : > "$state_file"
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword decoration:rounding 4
    hyprctl keyword decoration:inactive_opacity 1
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword general:border_size 1
    notify "rgb(f9e2af)" "hypr-rice gamemode on"
fi

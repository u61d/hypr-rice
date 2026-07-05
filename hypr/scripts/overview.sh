#!/usr/bin/env bash
set -euo pipefail

candidates=(
    "hyprspace:toggle"
    "hyprspace overview"
    "hyprexpo:expo toggle"
    "expo toggle"
    "overview:toggle"
)

for candidate in "${candidates[@]}"; do
    read -r -a dispatch_args <<< "$candidate"
    if hyprctl dispatch "${dispatch_args[@]}" >/dev/null 2>&1; then
        exit 0
    fi
done

hyprctl notify 3 4000 "rgb(f38ba8)" "No overview plugin dispatcher found. Install/enable Hyprspace or hyprexpo with hyprpm." >/dev/null 2>&1 || true

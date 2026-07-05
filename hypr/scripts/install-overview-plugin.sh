#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprpm >/dev/null 2>&1; then
    echo "hyprpm not found; install Hyprland's plugin manager first." >&2
    exit 1
fi

hyprpm update
hyprpm add https://github.com/KZDKM/Hyprspace.git || true
hyprpm enable Hyprspace
hyprpm reload

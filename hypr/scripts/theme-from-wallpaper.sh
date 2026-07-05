#!/usr/bin/env bash
set -euo pipefail

wallpaper="${1:-}"
if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
    echo "usage: theme-from-wallpaper.sh /path/to/wallpaper" >&2
    exit 2
fi

if ! command -v matugen >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

json="$(matugen image "$wallpaper" \
    --mode dark \
    --type scheme-vibrant \
    --prefer saturation \
    --fallback-color '#cba6f7' \
    --dry-run \
    --json hex \
    --quiet)"

color() {
    jq -r --arg key "$1" --arg fallback "$2" '.colors[$key].default.color // $fallback' <<< "$json"
}

base="$(color surface '#1e1e2e')"
mantle="$(color background '#181825')"
surface="$(color surface_container '#313244')"
surface_high="$(color surface_container_high '#45475a')"
text="$(color on_surface '#cdd6f4')"
muted="$(color on_surface_variant '#9399b2')"
primary="$(color primary '#cba6f7')"
secondary="$(color secondary '#89b4fa')"
tertiary="$(color tertiary '#f5c2e7')"
green="$(color primary_fixed '#a6e3a1')"
yellow="$(color tertiary_fixed '#f9e2af')"
red="$(color error '#f38ba8')"

mkdir -p "$HOME/.config/hypr" "$HOME/.config/quickshell/hypr-rice"

cat > "$HOME/.config/hypr/colors.lua" <<EOF
return {
    base = "$base",
    mantle = "$mantle",
    surface = "$surface",
    surface_high = "$surface_high",
    text = "$text",
    muted = "$muted",
    primary = "$primary",
    secondary = "$secondary",
    tertiary = "$tertiary",
    green = "$green",
    yellow = "$yellow",
    red = "$red",
}
EOF

cat > "$HOME/.config/quickshell/hypr-rice/Theme.qml" <<EOF
import QtQuick

QtObject {
    readonly property color base: "$base"
    readonly property color mantle: "$mantle"
    readonly property color surface: "$surface"
    readonly property color surfaceHigh: "$surface_high"
    readonly property color text: "$text"
    readonly property color muted: "$muted"
    readonly property color primary: "$primary"
    readonly property color secondary: "$secondary"
    readonly property color tertiary: "$tertiary"
    readonly property color green: "$green"
    readonly property color yellow: "$yellow"
    readonly property color red: "$red"
}
EOF

if [[ "${HYPR_RICE_NO_RELOAD:-0}" != "1" ]]; then
    hyprctl reload >/dev/null 2>&1 || true
    quickshell ipc call hypr-rice reloadTheme >/dev/null 2>&1 || true
fi

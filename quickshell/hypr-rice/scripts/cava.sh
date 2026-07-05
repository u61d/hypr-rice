#!/usr/bin/env bash
set -euo pipefail

BARS="▁▂▃▄▅▆▇█"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/cava/config"

if ! command -v cava >/dev/null 2>&1 || [[ ! -f "$CONFIG" ]]; then
    while true; do
        printf '%s\n' "▁▂▃▄▅▆▇█▇▆▅▄"
        sleep 1
    done
fi

cava -p "$CONFIG" | while IFS=';' read -ra values; do
    line=""
    for v in "${values[@]}"; do
        [[ -z "$v" ]] && continue
        line+="${BARS:$v:1}"
    done
    [[ -n "$line" ]] && printf '%s\n' "$line"
done

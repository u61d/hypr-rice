#!/usr/bin/env bash
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/cava/config"

if ! command -v cava >/dev/null 2>&1 || [[ ! -f "$CONFIG" ]]; then
    while true; do
        printf '%s\n' "▁▂▃▄▅▆▇█▇▆▅▄"
        sleep 1
    done
fi

stdbuf -oL cava -p "$CONFIG" | awk -F';' '
{
    line = ""
    for (i = 1; i < NF; i++) {
        if ($i != "") line = line (line=="" ? "" : ",") $i
    }
    if (line != "") print line
    fflush()
}'
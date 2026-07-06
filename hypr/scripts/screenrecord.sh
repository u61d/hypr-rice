#!/usr/bin/env bash
set -euo pipefail

PIDFILE="$XDG_RUNTIME_DIR/wf-recorder.pid"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Stop recording
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Screen Recording" "Recording saved." -u normal -i video-x-generic
else
    # Start recording
    mkdir -p "$HOME/Videos/Recordings"
    file="$HOME/Videos/Recordings/$(date +'%Y-%m-%d_%H-%M-%S').mp4"
    
    notify-send "Screen Recording" "Select area to record." -u normal -i video-x-generic
    
    area=$(slurp) || exit 1
    
    wf-recorder -g "$area" -f "$file" &
    echo $! > "$PIDFILE"
    notify-send "Screen Recording" "Recording started." -u normal -i media-record
fi

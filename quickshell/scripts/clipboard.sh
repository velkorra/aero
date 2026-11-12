#!/usr/bin/env bash
# Clipboard history picker: cliphist entries shown in rofi, the choice goes back
# to the clipboard. Needs `wl-paste --watch cliphist store` running in the session.
set -uo pipefail

THEME="${XDG_CACHE_HOME:-$HOME/.cache}/aero-shell/rofi.rasi"

if pkill -x rofi; then
    exit 0
fi

args=(-dmenu -display-columns 2 -p "Буфер обмена")
[ -s "$THEME" ] && args+=(-theme "$THEME")

choice="$(cliphist list | rofi "${args[@]}")" || exit 0
[ -n "$choice" ] || exit 0

printf '%s' "$choice" | cliphist decode | wl-copy

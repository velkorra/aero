#!/usr/bin/env bash
# Application launcher behind the start orb. A second click closes it.
set -uo pipefail

THEME="${XDG_CACHE_HOME:-$HOME/.cache}/aero-shell/rofi.rasi"

if pkill -x rofi; then
    exit 0
fi

if [ -s "$THEME" ]; then
    exec rofi -show drun -show-icons -theme "$THEME"
fi
exec rofi -show drun -show-icons

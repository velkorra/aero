#!/usr/bin/env bash
# Sets a wallpaper through mpvpaper (video or still image) and regenerates the
# shell palette from it with matugen.
#
#   set-wallpaper.sh <file>     apply a wallpaper
#   set-wallpaper.sh --restore  bring back the last wallpaper and palette
set -uo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/aero-shell"
TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"
STATE="$CACHE/current-wallpaper"
FRAME="$CACHE/frame.png"
DEFAULT_COLOR="#2a9fd6"

mkdir -p "$CACHE"

is_video() {
    shopt -s nocasematch
    local result=1
    case "$1" in
        *.mp4 | *.mkv | *.webm | *.mov | *.avi | *.m4v | *.gif) result=0 ;;
    esac
    shopt -u nocasematch
    return "$result"
}

start_wallpaper() {
    local file="$1" options old

    if is_video "$file"; then
        options="no-audio loop hwdec=auto panscan=1.0"
    else
        options="no-audio image-display-duration=inf panscan=1.0"
    fi

    old="$(pgrep -x mpvpaper || true)"
    setsid -f mpvpaper -o "$options" ALL "$file" >/dev/null 2>&1 </dev/null

    # The old instance is stopped only after the new one is on screen, so there is no blank frame.
    if [ -n "$old" ]; then
        sleep 1
        # shellcheck disable=SC2086
        kill $old 2>/dev/null || true
    fi
}

extract_frame() {
    local file="$1"
    rm -f "$FRAME"

    if is_video "$file"; then
        ffmpeg -nostdin -loglevel error -y -ss 2 -i "$file" -frames:v 1 -vf "scale=512:-2" "$FRAME" || true
        # Clips shorter than two seconds produce nothing with the seek above.
        [ -s "$FRAME" ] || ffmpeg -nostdin -loglevel error -y -i "$file" -frames:v 1 -vf "scale=512:-2" "$FRAME" || true
    else
        ffmpeg -nostdin -loglevel error -y -i "$file" -frames:v 1 -vf "scale=512:-2" "$FRAME" || true
    fi

    [ -s "$FRAME" ]
}

# matugen resolves template paths from its config, so the config is written with
# absolute paths on every run instead of being shipped as a static file.
write_matugen_config() {
    cat >"$CACHE/matugen.toml" <<EOF
[config]
version_check = false

[templates.shell]
input_path = '$TEMPLATES/colors.json'
output_path = '$CACHE/colors.json'

[templates.rofi]
input_path = '$TEMPLATES/rofi.rasi'
output_path = '$CACHE/rofi.rasi'
EOF
}

generate_palette() {
    write_matugen_config
    local common=(-c "$CACHE/matugen.toml" -m dark -t scheme-vibrant -q)

    if [ -s "$FRAME" ]; then
        # --source-color-index keeps matugen 4 from asking which source colour to use;
        # matugen 3 does not know the flag and never asks, hence the second attempt.
        matugen image "$FRAME" "${common[@]}" --source-color-index 0 </dev/null && return 0
        matugen image "$FRAME" "${common[@]}" </dev/null && return 0
    fi
    matugen color hex "$DEFAULT_COLOR" "${common[@]}" </dev/null
}

apply() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "set-wallpaper: no such file: $file" >&2
        return 1
    fi

    start_wallpaper "$file"
    printf '%s\n' "$file" >"$STATE"
    extract_frame "$file" || echo "set-wallpaper: could not read a frame from $file, using the default palette" >&2
    generate_palette
}

restore() {
    local file=""
    [ -f "$STATE" ] && file="$(cat "$STATE")"

    if [ -n "$file" ] && [ -f "$file" ] && ! pgrep -x mpvpaper >/dev/null; then
        start_wallpaper "$file"
    fi

    if [ ! -s "$CACHE/colors.json" ] || [ ! -s "$CACHE/rofi.rasi" ]; then
        if [ -n "$file" ] && [ -f "$file" ]; then
            extract_frame "$file" || true
        fi
        generate_palette
    fi
}

case "${1:-}" in
    --restore) restore ;;
    "")
        echo "usage: set-wallpaper.sh <file> | --restore" >&2
        exit 2
        ;;
    *) apply "$1" ;;
esac

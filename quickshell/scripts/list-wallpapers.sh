#!/usr/bin/env bash
# Prints the wallpaper list for the picker, one tab-separated line per entry:
#
#   current <TAB> path of the active wallpaper
#   image   <TAB> path <TAB> preview path   (pictures are their own preview)
#   video   <TAB> path <TAB> preview path   (generated on demand, cached)
set -uo pipefail

PICTURES="${AERO_PICTURES_DIR:-$HOME/Pictures}"
VIDEOS="${AERO_VIDEOS_DIR:-$HOME/Videos}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/aero-shell"
THUMBS="$CACHE/thumbs"

mkdir -p "$THUMBS"

current=""
[ -f "$CACHE/current-wallpaper" ] && current="$(cat "$CACHE/current-wallpaper")"
printf 'current\t%s\n' "$current"

make_thumb() {
    local video="$1" thumb="$2"

    if command -v ffmpegthumbnailer >/dev/null 2>&1; then
        ffmpegthumbnailer -i "$video" -o "$thumb" -s 384 -q 8 >/dev/null 2>&1 && [ -s "$thumb" ] && return 0
    fi
    ffmpeg -nostdin -loglevel error -y -ss 2 -i "$video" -frames:v 1 -vf "scale=384:-2" "$thumb" >/dev/null 2>&1
    [ -s "$thumb" ] || ffmpeg -nostdin -loglevel error -y -i "$video" -frames:v 1 -vf "scale=384:-2" "$thumb" >/dev/null 2>&1
    [ -s "$thumb" ]
}

if [ -d "$PICTURES" ]; then
    # Screenshots land in ~/Pictures/Screenshots by default and are not wallpapers.
    find "$PICTURES" -maxdepth 3 -type f -not -path '*/Screenshots/*' \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) -print0 |
        sort -z |
        while IFS= read -r -d '' file; do
            printf 'image\t%s\t%s\n' "$file" "$file"
        done
fi

if [ -d "$VIDEOS" ]; then
    find "$VIDEOS" -maxdepth 3 -type f \
        \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' -o -iname '*.avi' -o -iname '*.m4v' -o -iname '*.gif' \) -print0 |
        sort -z |
        while IFS= read -r -d '' file; do
            key="$(printf '%s' "$file" | sha1sum | cut -c1-16)"
            thumb="$THUMBS/$key.jpg"
            if [ ! -s "$thumb" ] || [ "$file" -nt "$thumb" ]; then
                make_thumb "$file" "$thumb" || continue
            fi
            printf 'video\t%s\t%s\n' "$file" "$thumb"
        done
fi

#!/usr/bin/env bash
# Prints key=value lines for the control center: uptime, host, niri version and
# the state of the wired network interface.
set -uo pipefail

read -r uptime _ </proc/uptime
printf 'uptime=%s\n' "${uptime%.*}"
printf 'host=%s\n' "$(cat /proc/sys/kernel/hostname)"
printf 'niri=%s\n' "$(niri --version 2>/dev/null | head -n 1)"

# Wired interface: a physical ARPHRD_ETHER device without a wireless directory.
# A connected one wins over a disconnected one.
iface=""
for dir in /sys/class/net/*; do
    [ -e "$dir/device" ] || continue
    [ -d "$dir/wireless" ] && continue
    [ "$(cat "$dir/type" 2>/dev/null)" = "1" ] || continue
    name="${dir##*/}"
    if [ -z "$iface" ] || [ "$(cat "$dir/operstate" 2>/dev/null)" = "up" ]; then
        iface="$name"
    fi
done

state=""
address=""
speed=""
if [ -n "$iface" ]; then
    state="$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)"
    address="$(ip -4 -o addr show dev "$iface" scope global 2>/dev/null | awk '{print $4; exit}')"
    address="${address%%/*}"
    if [ "$state" = "up" ]; then
        speed="$(cat "/sys/class/net/$iface/speed" 2>/dev/null || true)"
        # The kernel reports -1 when the speed is unknown.
        [ "${speed:-0}" -gt 0 ] 2>/dev/null || speed=""
    fi
fi

printf 'lan_iface=%s\n' "$iface"
printf 'lan_state=%s\n' "$state"
printf 'lan_address=%s\n' "$address"
printf 'lan_speed=%s\n' "$speed"

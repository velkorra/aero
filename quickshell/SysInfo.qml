pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Uptime, host, niri version and wired network state, read by scripts/sysinfo.sh.
Singleton {
    id: root

    // Set to true while something that shows this data is visible.
    property bool active: false

    readonly property string user: Quickshell.env("USER") || "user"
    property string host: ""
    property string niri: ""
    property int uptime: 0
    property string lanIface: ""
    property string lanState: ""
    property string lanAddress: ""
    property string lanSpeed: ""

    readonly property bool lanUp: lanState === "up"

    readonly property string uptimeText: {
        const days = Math.floor(uptime / 86400);
        const hours = Math.floor((uptime % 86400) / 3600);
        const minutes = Math.floor((uptime % 3600) / 60);
        if (days > 0)
            return days + " д " + hours + " ч";
        if (hours > 0)
            return hours + " ч " + minutes + " мин";
        return minutes + " мин";
    }

    readonly property string lanText: {
        if (lanIface === "")
            return "Сетевой адаптер не найден";
        if (!lanUp)
            return "Кабель не подключён";
        const parts = ["Подключено"];
        if (lanAddress !== "")
            parts.push(lanAddress);
        if (lanSpeed !== "")
            parts.push(lanSpeed + " Мбит/с");
        return parts.join(" · ");
    }

    function refresh() {
        if (!reader.running)
            reader.running = true;
    }

    function apply(line) {
        const split = line.indexOf("=");
        if (split < 0)
            return;
        const key = line.slice(0, split);
        const value = line.slice(split + 1);
        switch (key) {
        case "uptime": uptime = parseInt(value) || 0; break;
        case "host": host = value; break;
        case "niri": niri = value; break;
        case "lan_iface": lanIface = value; break;
        case "lan_state": lanState = value; break;
        case "lan_address": lanAddress = value; break;
        case "lan_speed": lanSpeed = value; break;
        }
    }

    Process {
        id: reader

        command: ShellState.scriptCommand("sysinfo.sh")
        stdout: SplitParser {
            onRead: line => root.apply(line)
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}

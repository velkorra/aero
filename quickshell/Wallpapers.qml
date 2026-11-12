pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper list and switching. The heavy lifting is in scripts/list-wallpapers.sh
// and scripts/set-wallpaper.sh.
Singleton {
    id: root

    readonly property alias model: entries
    property string current: ""
    property bool loading: false
    readonly property bool applying: setter.running

    function refresh() {
        if (lister.running)
            return;
        entries.clear();
        loading = true;
        lister.running = true;
    }

    function apply(path) {
        if (setter.running)
            return;
        setter.target = path;
        setter.command = ShellState.scriptCommand("set-wallpaper.sh", [path]);
        setter.running = true;
    }

    // Brings back the last wallpaper and palette after login or a shell restart.
    function restore() {
        restorer.running = true;
    }

    function parse(line) {
        const fields = line.split("\t");
        if (fields[0] === "current") {
            current = fields[1] ?? "";
        } else if (fields.length >= 3) {
            const path = fields[1];
            entries.append({
                kind: fields[0],
                path: path,
                thumb: fields[2],
                name: path.slice(path.lastIndexOf("/") + 1)
            });
        }
    }

    ListModel {
        id: entries
    }

    Process {
        id: lister

        command: ShellState.scriptCommand("list-wallpapers.sh")
        stdout: SplitParser {
            onRead: line => root.parse(line)
        }
        onExited: root.loading = false
    }

    Process {
        id: setter

        property string target: ""

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.current = target;
            Theme.reloadColors();
        }
    }

    Process {
        id: restorer

        command: ShellState.scriptCommand("set-wallpaper.sh", ["--restore"])
        onExited: Theme.reloadColors()
    }
}

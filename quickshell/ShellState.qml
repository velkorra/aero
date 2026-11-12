pragma Singleton

import Quickshell
import Quickshell.Io

// Which popup is open ("control", "wallpaper", "history", "tray" or ""), plus script launching.
Singleton {
    id: root

    property string popup: ""
    // Screen y of the tray button, so the tray flyout opens beside it.
    property real trayY: 300

    function toggle(name) {
        popup = popup === name ? "" : name;
    }

    function close() {
        popup = "";
    }

    function scriptCommand(name, args) {
        return ["bash", Quickshell.shellPath("scripts/" + name)].concat(args || []);
    }

    function runScript(name, args) {
        close();
        Quickshell.execDetached(scriptCommand(name, args));
    }

    // Entry points for compositor key bindings: `qs ipc call shell toggle control`.
    IpcHandler {
        target: "shell"

        function toggle(name: string): void {
            root.toggle(name);
        }

        function close(): void {
            root.close();
        }

        function dnd(): void {
            NotificationService.dnd = !NotificationService.dnd;
        }
    }
}

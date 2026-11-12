pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Niri state from `niri msg --json event-stream`. The stream sends the full state
// on connect and incremental events after that, so nothing is ever polled.
Singleton {
    id: root

    property var workspaces: []

    property var layoutNames: []
    property int layoutIndex: 0
    readonly property string layoutName: layoutNames[layoutIndex] ?? ""
    // Two letters like the Windows language bar: "Russian" -> "RU", "English (US)" -> "EN".
    readonly property string layoutCode: layoutName !== "" ? layoutName.slice(0, 2).toUpperCase() : "--"

    function action(args) {
        Quickshell.execDetached(["niri", "msg", "action"].concat(args));
    }

    function patchWorkspace(id, changes) {
        workspaces = workspaces.map(w => w.id === id ? Object.assign({}, w, changes) : w);
    }

    function handle(line) {
        let event;
        try {
            event = JSON.parse(line);
        } catch (error) {
            return;
        }

        if (event.WorkspacesChanged) {
            workspaces = event.WorkspacesChanged.workspaces;
        } else if (event.WorkspaceActivated) {
            const id = event.WorkspaceActivated.id;
            const focused = event.WorkspaceActivated.focused;
            const target = workspaces.find(w => w.id === id);
            if (!target)
                return;
            workspaces = workspaces.map(w => {
                const copy = Object.assign({}, w);
                if (w.output === target.output)
                    copy.is_active = w.id === id;
                if (focused)
                    copy.is_focused = w.id === id;
                return copy;
            });
        } else if (event.WorkspaceActiveWindowChanged) {
            patchWorkspace(event.WorkspaceActiveWindowChanged.workspace_id, {
                active_window_id: event.WorkspaceActiveWindowChanged.active_window_id
            });
        } else if (event.WorkspaceUrgencyChanged) {
            patchWorkspace(event.WorkspaceUrgencyChanged.id, { is_urgent: event.WorkspaceUrgencyChanged.urgent });
        } else if (event.KeyboardLayoutsChanged) {
            layoutNames = event.KeyboardLayoutsChanged.keyboard_layouts.names;
            layoutIndex = event.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
        } else if (event.KeyboardLayoutSwitched) {
            layoutIndex = event.KeyboardLayoutSwitched.idx;
        }
    }

    Process {
        id: stream

        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => root.handle(line)
        }
        onExited: reconnect.start()
    }

    Timer {
        id: reconnect

        interval: 2000
        onTriggered: stream.running = true
    }
}

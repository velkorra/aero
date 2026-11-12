pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Owns the notification server. Every notification stays tracked (this is the
// history) until dismissed; `toasts` lists the ids currently shown as popups.
Singleton {
    id: root

    property bool dnd: false
    property int unread: 0

    readonly property var list: server.trackedNotifications.values
    readonly property alias toasts: toastModel

    // id -> "HH:mm" arrival time. Plain lookup table, read once per card.
    property var arrivals: ({})

    function find(id) {
        return list.find(n => n.id === id) ?? null;
    }

    function arrival(id) {
        return arrivals[id] ?? "";
    }

    function hideToast(id) {
        for (let i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).nid === id) {
                toastModel.remove(i);
                return;
            }
        }
    }

    // Click on a notification: bring the sender's window forward and run the
    // notification's default action. Quickshell does not hand out activation
    // tokens, so the app cannot raise itself; niri is asked to focus it instead.
    function activate(n) {
        if (n === null)
            return;
        const names = [n.desktopEntry, n.appName].filter(s => s !== "").map(s => s.toLowerCase());
        if (names.length > 0 && !windowQuery.running) {
            windowQuery.names = names;
            windowQuery.running = true;
        }
        const action = Array.from(n.actions).find(a => a.identifier === "default");
        if (action)
            action.invoke();
    }

    function activateToast(id) {
        const n = find(id);
        hideToast(id);
        activate(n);
    }

    // How well a niri window's app id matches the notification's sender names.
    function matchScore(appId, names) {
        const id = (appId ?? "").toLowerCase();
        if (id === "")
            return 0;
        let best = 0;
        for (const name of names) {
            if (id === name)
                best = Math.max(best, 3);
            else if (id.endsWith("." + name) || name.endsWith("." + id))
                best = Math.max(best, 2);
            else if (id.includes(name) || name.includes(id))
                best = Math.max(best, 1);
        }
        return best;
    }

    function focusSender(json, names) {
        let windows;
        try {
            windows = JSON.parse(json);
        } catch (error) {
            return;
        }
        let target = null;
        let targetScore = 0;
        for (const w of windows) {
            const score = matchScore(w.app_id, names);
            if (score > targetScore) {
                target = w;
                targetScore = score;
            }
        }
        if (target !== null)
            Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(target.id)]);
    }

    function clearAll() {
        for (const n of list.slice())
            n.dismiss();
    }

    ListModel {
        id: toastModel
    }

    Process {
        id: windowQuery

        property var names: []

        command: ["niri", "msg", "--json", "windows"]
        stdout: StdioCollector {
            id: windowList

            onStreamFinished: root.focusSender(windowList.text, windowQuery.names)
        }
    }

    NotificationServer {
        id: server

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            const id = n.id;
            root.arrivals[id] = Qt.formatDateTime(new Date(), "HH:mm");
            n.closed.connect(() => {
                root.hideToast(id);
                delete root.arrivals[id];
            });
            n.tracked = true;

            // Notifications carried over a shell reload go to the history only.
            if (n.lastGeneration)
                return;

            if (ShellState.popup !== "history")
                root.unread += 1;
            // An updated notification reuses its id, so drop the stale toast first.
            root.hideToast(id);
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                toastModel.append({ nid: id });
        }
    }
}

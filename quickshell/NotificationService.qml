pragma Singleton

import QtQuick
import Quickshell
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

    function clearAll() {
        for (const n of list.slice())
            n.dismiss();
    }

    ListModel {
        id: toastModel
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

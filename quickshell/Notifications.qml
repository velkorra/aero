import QtQuick
import Quickshell
import Quickshell.Wayland

// Toast notifications in the top-left corner. With no exclusive zone of its own
// the window is laid out next to the bar, so toasts never cover it.
PanelWindow {
    id: window

    property bool shown: false

    anchors {
        top: true
        left: true
    }
    margins {
        top: Theme.gap
        left: Theme.gap
    }
    exclusiveZone: 0
    implicitWidth: 380
    implicitHeight: screen ? Math.round(screen.height * 0.75) : 640
    color: "transparent"
    visible: shown

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aero-toasts"

    // The window is taller than its content so that enter/leave animations are
    // not clipped; input and blur are limited to the stack of cards.
    mask: Region {
        item: stack
    }
    BackgroundEffect.blurRegion: Region {
        item: stack
        radius: Theme.radius
    }

    Connections {
        target: NotificationService.toasts

        function onCountChanged() {
            if (NotificationService.toasts.count > 0) {
                linger.stop();
                window.shown = true;
            } else {
                linger.restart();
            }
        }
    }

    // Keeps the window mapped long enough for the last card to fade out.
    Timer {
        id: linger

        interval: 320
        onTriggered: window.shown = NotificationService.toasts.count > 0
    }

    Item {
        id: stack

        width: parent.width
        height: Math.min(list.contentHeight, parent.height)
    }

    ListView {
        id: list

        anchors.fill: parent
        interactive: false
        spacing: 8
        model: NotificationService.toasts

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: -120; to: 0; duration: 260; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220 }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; to: -80; duration: 220; easing.type: Easing.InCubic }
                NumberAnimation { property: "opacity"; to: 0; duration: 220 }
            }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 220; easing.type: Easing.OutCubic }
            NumberAnimation { property: "opacity"; to: 1; duration: 120 }
        }

        delegate: NotificationCard {
            id: toast

            required property int nid

            width: list.width
            notification: NotificationService.find(nid)
            onBodyClicked: NotificationService.hideToast(nid)
            onCloseClicked: {
                if (notification !== null)
                    notification.dismiss();
                else
                    NotificationService.hideToast(nid);
            }

            // Critical notifications stay until closed; hovering pauses the countdown.
            Timer {
                interval: toast.notification !== null && toast.notification.expireTimeout > 0
                    ? toast.notification.expireTimeout * 1000 : 6000
                running: !toast.hovered && !toast.critical
                onTriggered: NotificationService.hideToast(toast.nid)
            }
        }
    }
}

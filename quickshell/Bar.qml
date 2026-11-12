import QtQuick
import Quickshell
import Quickshell.Wayland

// Left vertical bar.
PanelWindow {
    id: bar

    anchors {
        left: true
        top: true
        bottom: true
    }
    implicitWidth: Theme.barWidth
    exclusiveZone: Theme.barWidth
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "aero-bar"
    BackgroundEffect.blurRegion: Region {
        item: glass
        radius: glass.radius
    }

    AeroBox {
        id: glass

        anchors.fill: parent
        anchors.margins: 6
        radius: 12
        sideGloss: true

        Column {
            id: topSection

            anchors {
                top: parent.top
                topMargin: 8
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 10

            StartOrb {
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: ShellState.runScript("launcher.sh")
            }

            Clock {
                anchors.horizontalCenter: parent.horizontalCenter
            }

            AeroButton {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: Icons.sliders
                active: ShellState.popup === "control"
                onClicked: ShellState.toggle("control")
            }

            AeroButton {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: Icons.image
                active: ShellState.popup === "wallpaper"
                onClicked: ShellState.toggle("wallpaper")
            }

            KeyboardLayout {
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Opens the tray flyout, like the "show hidden icons" arrow in Windows 7.
            AeroButton {
                id: trayButton

                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: 28
                implicitHeight: 28
                iconSize: 12
                icon: active ? Icons.caretLeft : Icons.caretRight
                active: ShellState.popup === "tray"
                onClicked: {
                    ShellState.trayY = trayButton.mapToItem(null, 0, 0).y - 9;
                    ShellState.toggle("tray");
                }
            }
        }

        // Inset groove holding the workspace beads.
        AeroBox {
            anchors.centerIn: parent
            width: 38
            height: workspaces.implicitHeight + 20
            radius: 19
            tint: Theme.alpha(Theme.ink, 0.42)
            borderColor: "#50ffffff"
            glossStrength: 0.35

            NiriWorkspaces {
                id: workspaces

                anchors.centerIn: parent
                output: bar.screen ? bar.screen.name : ""
            }
        }

        Column {
            id: bottomSection

            anchors {
                bottom: parent.bottom
                bottomMargin: 8
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 10

            AeroButton {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: Icons.clipboard
                onClicked: ShellState.runScript("clipboard.sh")
            }

            VolumeControl {
                anchors.horizontalCenter: parent.horizontalCenter
            }

            AeroButton {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: NotificationService.dnd ? Icons.bellSlash : Icons.bell
                iconColor: NotificationService.dnd ? "#ffb0a8" : Theme.text
                badge: NotificationService.unread
                active: ShellState.popup === "history"
                onClicked: ShellState.toggle("history")
                onRightClicked: NotificationService.dnd = !NotificationService.dnd
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Wayland

// Base for the glass popups (control center, wallpapers, notification history).
// A full-screen transparent layer catches outside clicks and Escape; the glass
// panel itself sits next to the bar. Children of a PopupLayer go into the panel.
PanelWindow {
    id: root

    property bool open: false
    property int panelWidth: 400
    property int panelHeight: 400
    property bool alignBottom: false

    default property alias content: panel.content

    signal dismissed()

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: open || fade.running

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "aero-popup"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // The bar stays clickable while a popup is open, so its buttons can toggle or switch popups.
    mask: Region {
        x: Theme.barWidth
        y: 0
        width: Math.max(0, root.width - Theme.barWidth)
        height: root.height
    }
    BackgroundEffect.blurRegion: Region {
        item: panel
        radius: panel.radius
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.dismissed()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: root.dismissed()
        }

        AeroBox {
            id: panel

            x: Theme.barWidth + 4
            y: root.alignBottom ? parent.height - height - Theme.gap : Theme.gap
            width: root.panelWidth
            height: Math.min(root.panelHeight, parent.height - 2 * Theme.gap)
            radius: 12
            tint: Theme.glassStrong
            glossSize: 46
            opacity: root.open ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    id: fade

                    duration: 170
                    easing.type: Easing.OutQuad
                }
            }

            // Clicks inside the panel must not reach the dismiss area behind it.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
            }
        }
    }
}

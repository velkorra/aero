import QtQuick
import QtQuick.Effects

// Vertical workspace list. The state comes from the Niri singleton.
Item {
    id: root

    // Output (monitor) name to show workspaces for; empty shows every workspace.
    property string output: ""

    readonly property var shown: {
        const all = Niri.workspaces;
        const own = all.filter(w => root.output === "" || w.output === root.output);
        const list = own.length > 0 ? own : all;
        return list.slice().sort((a, b) => a.idx - b.idx);
    }

    implicitWidth: 30
    implicitHeight: column.implicitHeight

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: event => Niri.action([event.angleDelta.y > 0 ? "focus-workspace-up" : "focus-workspace-down"])
    }

    Column {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 7

        Repeater {
            // An integer model keeps the delegates alive across state updates,
            // which is what lets the size and colour changes animate.
            model: root.shown.length

            Item {
                id: slot

                required property int index
                readonly property var ws: root.shown[index] ?? null
                readonly property bool active: ws !== null && ws.is_active
                readonly property bool occupied: ws !== null && ws.active_window_id !== null
                readonly property bool urgent: ws !== null && ws.is_urgent
                readonly property bool hovered: hit.containsMouse
                readonly property color core: urgent ? "#ff8a3c" : Theme.accent

                anchors.horizontalCenter: parent.horizontalCenter
                width: 30
                height: active ? 40 : occupied ? 20 : 12

                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                RectangularShadow {
                    anchors.fill: pill
                    radius: pill.radius
                    blur: 16
                    spread: 2
                    color: Theme.alpha(slot.core, slot.active || slot.urgent ? 0.9 : slot.hovered ? 0.6 : 0)

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Rectangle {
                    id: pill

                    anchors.centerIn: parent
                    width: slot.active ? 20 : slot.occupied ? 18 : 10
                    height: parent.height
                    radius: width / 2
                    border.width: 1
                    border.color: slot.active || slot.occupied ? "#d0ffffff" : "#70ffffff"
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: slot.active || slot.urgent ? Qt.lighter(slot.core, 1.6)
                                : slot.occupied ? "#f0ffffff" : "#50ffffff"

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        GradientStop {
                            position: 0.55
                            color: slot.active || slot.urgent ? slot.core
                                : slot.occupied ? "#90d8ecf8" : "#28ffffff"

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        GradientStop {
                            position: 1.0
                            color: slot.active || slot.urgent ? Qt.darker(slot.core, 1.5)
                                : slot.occupied ? "#70a8c8dc" : "#18ffffff"

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    // Specular highlight that makes the pill read as a glass bead.
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 2
                        width: parent.width * 0.62
                        height: Math.min(parent.height * 0.42, 12)
                        radius: height / 2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#e8ffffff" }
                            GradientStop { position: 1.0; color: "#10ffffff" }
                        }
                    }
                }

                MouseArea {
                    id: hit

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (slot.ws !== null)
                            Niri.action(["focus-workspace", String(slot.ws.idx)]);
                    }
                }
            }
        }
    }
}

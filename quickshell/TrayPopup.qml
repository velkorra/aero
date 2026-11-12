import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// System tray in the style of the Windows 7 hidden icons flyout: a glass frame
// around a white well with a grid of icons. The flyout grows with the number of
// icons, four to a row.
PopupLayer {
    id: root

    readonly property var items: SystemTray.items.values
    readonly property int cell: 36
    readonly property int maxColumns: 4
    readonly property int columns: Math.max(1, Math.min(maxColumns, items.length))
    readonly property int rows: Math.max(1, Math.ceil(items.length / maxColumns))
    readonly property int frame: 9

    // The icon under the pointer, for the name label.
    property var hoveredSlot: null

    open: ShellState.popup === "tray"
    panelY: ShellState.trayY
    panelWidth: (items.length === 0 ? emptyLabel.implicitWidth + 24 : columns * cell + 8) + 2 * frame
    panelHeight: rows * cell + 8 + 2 * frame
    onDismissed: ShellState.close()
    onOpenChanged: {
        hoveredSlot = null;
        menu.close();
    }

    // White well under the icons.
    Rectangle {
        anchors.fill: parent
        anchors.margins: root.frame
        radius: 3
        border.width: 1
        border.color: "#8ea1b5"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#eef3f9" }
        }

        Text {
            id: emptyLabel

            anchors.centerIn: parent
            visible: root.items.length === 0
            text: "Нет значков"
            color: "#5b6b7b"
            font.family: Theme.font
            font.pixelSize: 12
        }

        Grid {
            x: 4
            y: 4
            columns: root.maxColumns

            Repeater {
                model: root.items

                Item {
                    id: slot

                    required property var modelData
                    readonly property bool hovered: hit.containsMouse
                    readonly property string name: modelData.tooltipTitle || modelData.title || modelData.id

                    width: root.cell
                    height: root.cell

                    // Windows 7 hot-track highlight.
                    Rectangle {
                        visible: slot.hovered
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 3
                        border.width: 1
                        border.color: "#84acdd"
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#f6fbff" }
                            GradientStop { position: 1.0; color: "#cfe3fb" }
                        }
                    }

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 22
                        source: slot.modelData.icon
                    }

                    MouseArea {
                        id: hit

                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onContainsMouseChanged: {
                            if (containsMouse)
                                root.hoveredSlot = slot;
                            else if (root.hoveredSlot === slot)
                                root.hoveredSlot = null;
                        }
                        onClicked: event => {
                            const item = slot.modelData;
                            if (event.button === Qt.MiddleButton) {
                                item.secondaryActivate();
                            } else if (event.button === Qt.RightButton || item.onlyMenu) {
                                if (item.hasMenu) {
                                    const corner = slot.mapToItem(menu, slot.width - 4, slot.height - 4);
                                    menu.open(item.menu, corner.x, corner.y);
                                }
                            } else {
                                item.activate();
                                ShellState.close();
                            }
                        }
                        onWheel: event => slot.modelData.scroll(event.angleDelta.y, false)
                    }
                }
            }
        }
    }

    overlay: [
        // Name of the hovered icon, shown beside the flyout like a tooltip.
        AeroBox {
            id: nameTip

            readonly property var slot: root.hoveredSlot

            visible: slot !== null && !menu.shown
            x: root.panelItem.x + root.panelItem.width + 6
            y: slot !== null ? slot.mapToItem(parent, 0, 0).y + (root.cell - height) / 2 : 0
            width: nameLabel.implicitWidth + 20
            height: 26
            radius: 6
            tint: Theme.glassStrong
            glossSize: 12

            Text {
                id: nameLabel

                anchors.centerIn: parent
                text: nameTip.slot !== null ? nameTip.slot.name : ""
                textFormat: Text.PlainText
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 11
                style: Text.Raised
                styleColor: Theme.textShadow
            }
        },

        TrayMenu {
            id: menu

            onActivated: ShellState.close()
        }
    ]
}

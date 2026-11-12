import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets

// Context menu of a tray icon, drawn like a Windows 7 menu. Fills the popup
// layer so that a click outside the menu closes it. Submenus open in place,
// with a "back" row on top.
Item {
    id: root

    // QsMenuHandle of the level being shown; null hides the menu.
    property var handle: null
    // Parent levels, for the "back" row.
    property var trail: []
    property real originX: 0
    property real originY: 0

    readonly property bool shown: handle !== null

    // An entry was activated and the whole tray can close.
    signal activated()

    function open(menuHandle, x, y) {
        trail = [];
        originX = x;
        originY = y;
        handle = menuHandle;
    }

    function close() {
        handle = null;
        trail = [];
    }

    function enter(entry) {
        trail = trail.concat([handle]);
        handle = entry;
    }

    function back() {
        const levels = trail.slice();
        handle = levels.pop();
        trail = levels;
    }

    anchors.fill: parent
    visible: shown

    component Line: Item {
        id: line

        property string text: ""
        property string iconSource: ""
        property string glyph: ""
        property bool separator: false
        property bool submenu: false
        property bool active: true

        signal clicked()

        width: parent ? parent.width : 0
        height: separator ? 7 : 26

        Rectangle {
            visible: line.separator
            x: 30
            y: 3
            width: parent.width - 32
            height: 1
            color: "#d7d7d7"
        }

        // Hover highlight.
        Rectangle {
            visible: !line.separator && line.active && hit.containsMouse
            anchors.fill: parent
            radius: 3
            border.width: 1
            border.color: "#aecff7"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#f4f9ff" }
                GradientStop { position: 1.0; color: "#d7e8fc" }
            }
        }

        IconImage {
            visible: !line.separator && line.iconSource !== ""
            x: 5
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 16
            source: line.iconSource
            opacity: line.active ? 1 : 0.4
        }

        Text {
            visible: !line.separator && line.iconSource === "" && line.glyph !== ""
            x: 5
            width: 16
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: line.glyph
            color: line.active ? "#1a1a1a" : "#9a9a9a"
            font.family: Theme.iconFont
            font.pixelSize: 11
        }

        Text {
            visible: !line.separator
            anchors {
                left: parent.left
                leftMargin: 34
                right: parent.right
                rightMargin: line.submenu ? 22 : 10
                verticalCenter: parent.verticalCenter
            }
            text: line.text
            textFormat: Text.PlainText
            color: line.active ? "#1a1a1a" : "#9a9a9a"
            font.family: Theme.font
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        Text {
            visible: !line.separator && line.submenu
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text: Icons.chevronRight
            color: line.active ? "#1a1a1a" : "#9a9a9a"
            font.family: Theme.iconFont
            font.pixelSize: 9
        }

        MouseArea {
            id: hit

            anchors.fill: parent
            hoverEnabled: true
            enabled: !line.separator && line.active
            onClicked: line.clicked()
        }
    }

    QsMenuOpener {
        id: opener

        menu: root.handle
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: root.close()
    }

    RectangularShadow {
        anchors.fill: box
        radius: box.radius
        blur: 14
        offset: Qt.vector2d(2, 3)
        color: "#70000000"
    }

    Rectangle {
        id: box

        x: Math.max(4, Math.min(root.originX, root.width - width - 4))
        y: Math.max(4, Math.min(root.originY, root.height - height - 4))
        width: 260
        height: column.implicitHeight + 6
        radius: 3
        color: "#f4f4f4"
        border.width: 1
        border.color: "#979797"

        // Clicks on the menu frame must not reach the dismiss area.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        // Icon gutter with the etched divider.
        Rectangle {
            x: 1
            y: 1
            width: 29
            height: parent.height - 2
            color: "#ececec"
        }
        Rectangle {
            x: 30
            y: 1
            width: 1
            height: parent.height - 2
            color: "#dcdcdc"
        }
        Rectangle {
            x: 31
            y: 1
            width: 1
            height: parent.height - 2
            color: "#ffffff"
        }

        Column {
            id: column

            x: 3
            y: 3
            width: parent.width - 6

            Line {
                visible: root.trail.length > 0
                height: visible ? 26 : 0
                text: "Назад"
                glyph: Icons.chevronLeft
                onClicked: root.back()
            }

            Line {
                visible: root.trail.length > 0
                separator: true
                height: visible ? 7 : 0
            }

            Repeater {
                id: entries

                model: opener.children

                Line {
                    required property var modelData

                    text: modelData.text
                    iconSource: modelData.icon
                    glyph: modelData.checkState !== Qt.Checked ? ""
                        : modelData.buttonType === QsMenuButtonType.RadioButton ? Icons.dot : Icons.check
                    separator: modelData.isSeparator
                    submenu: modelData.hasChildren
                    active: modelData.enabled
                    onClicked: {
                        if (modelData.hasChildren) {
                            root.enter(modelData);
                        } else {
                            modelData.triggered();
                            root.activated();
                        }
                    }
                }
            }

            Text {
                visible: entries.count === 0
                x: 34
                height: 26
                verticalAlignment: Text.AlignVCenter
                text: "Меню пустое"
                color: "#9a9a9a"
                font.family: Theme.font
                font.pixelSize: 12
            }
        }
    }
}

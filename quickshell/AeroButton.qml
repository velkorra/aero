import QtQuick

// Glossy button with an icon glyph, an optional label and an optional badge.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property real iconSize: 17
    property color iconColor: Theme.text
    property bool round: false
    property bool active: false
    property color tint: Theme.card
    property color activeTint: Theme.accent
    property int badge: 0

    // When false, wheel events pass through to a flickable underneath.
    property bool scrollable: false

    readonly property bool hovered: mouse.containsMouse
    readonly property bool pressed: mouse.pressed

    signal clicked()
    signal rightClicked()
    signal scrolled(int delta)

    implicitWidth: label ? Math.max(40, row.implicitWidth + 26) : 40
    implicitHeight: label ? 32 : 40

    scale: pressed ? 0.93 : 1
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

    AeroBox {
        anchors.fill: parent
        radius: root.round ? height / 2 : Theme.radius
        glowColor: root.activeTint
        tint: root.active ? Theme.alpha(root.activeTint, 0.72)
            : root.hovered ? Theme.alpha(Qt.lighter(root.tint, 1.25), Math.min(1, root.tint.a + 0.16))
            : root.tint
        glow: root.active ? 0.75 : root.hovered ? 0.5 : 0

        Behavior on tint { ColorAnimation { duration: 160 } }
        Behavior on glow { NumberAnimation { duration: 160 } }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 7

        Text {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.iconColor
            font.family: Theme.iconFont
            font.pixelSize: root.iconSize
            style: Text.Raised
            styleColor: Theme.textShadow
        }

        Text {
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 12
            font.weight: Font.DemiBold
            style: Text.Raised
            styleColor: Theme.textShadow
        }
    }

    Rectangle {
        visible: root.badge > 0
        anchors { top: parent.top; right: parent.right; topMargin: -3; rightMargin: -3 }
        width: Math.max(16, badgeText.implicitWidth + 8)
        height: 16
        radius: 8
        border.width: 1
        border.color: "#c0ffffff"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ff9a8a" }
            GradientStop { position: 0.5; color: "#e23b2e" }
            GradientStop { position: 1.0; color: "#b81d12" }
        }

        Text {
            id: badgeText

            anchors.centerIn: parent
            text: root.badge > 99 ? "99+" : root.badge
            color: "#ffffff"
            font.family: Theme.font
            font.pixelSize: 10
            font.bold: true
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.rightClicked();
            else
                root.clicked();
        }
        onWheel: event => {
            if (root.scrollable)
                root.scrolled(event.angleDelta.y);
            else
                event.accepted = false;
        }
    }
}

import QtQuick
import QtQuick.Effects

// Windows 7 style caption close button: red glossy box with a white cross.
Item {
    id: root

    readonly property bool hovered: mouse.containsMouse
    readonly property color halo: "#ff5a3c"

    signal clicked()

    implicitWidth: 30
    implicitHeight: 18

    RectangularShadow {
        anchors.fill: box
        radius: box.radius
        blur: 14
        spread: 1
        color: Theme.alpha(root.halo, root.hovered ? 0.95 : 0)

        Behavior on color { ColorAnimation { duration: 140 } }
    }

    Rectangle {
        id: box

        anchors.fill: parent
        radius: 4
        border.width: 1
        border.color: root.hovered ? "#f0ffffff" : "#90ffffff"
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.hovered ? "#ffb9a6" : "#e9a093" }
            GradientStop { position: 0.48; color: root.hovered ? "#f0553a" : "#cf4a36" }
            GradientStop { position: 0.52; color: root.hovered ? "#d92a12" : "#b52a18" }
            GradientStop { position: 1.0; color: root.hovered ? "#ff8a4a" : "#c9583f" }
        }
    }

    Text {
        anchors.centerIn: parent
        text: Icons.close
        color: "#ffffff"
        font.family: Theme.iconFont
        font.pixelSize: 11
        style: Text.Raised
        styleColor: "#90000000"
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

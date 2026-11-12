import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// Launcher button: a glass sphere in a chrome ring that lights up on hover.
Item {
    id: root

    readonly property bool hovered: mouse.containsMouse

    signal clicked()

    implicitWidth: 48
    implicitHeight: 48

    scale: mouse.pressed ? 0.92 : root.hovered ? 1.06 : 1
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

    RectangularShadow {
        anchors.fill: ring
        radius: ring.width / 2
        blur: root.hovered ? 28 : 14
        spread: root.hovered ? 5 : 1
        color: Theme.alpha(Qt.lighter(Theme.accent, 1.25), root.hovered ? 0.95 : 0.5)

        Behavior on blur { NumberAnimation { duration: 200 } }
        Behavior on spread { NumberAnimation { duration: 200 } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Chrome ring.
    Rectangle {
        id: ring

        anchors.fill: parent
        radius: width / 2
        border.width: 1
        border.color: "#c0ffffff"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f4fbff" }
            GradientStop { position: 0.5; color: "#8fa9b8" }
            GradientStop { position: 1.0; color: "#e6f4fb" }
        }
    }

    // Sphere body, lit from below like the Vista orb.
    Shape {
        id: sphere

        anchors.fill: parent
        anchors.margins: 3
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            fillGradient: RadialGradient {
                centerX: sphere.width / 2
                centerY: sphere.height * 0.72
                centerRadius: sphere.width * 0.78
                focalX: sphere.width / 2
                focalY: sphere.height * 0.9
                GradientStop { position: 0.0; color: Qt.lighter(Theme.accent, root.hovered ? 1.7 : 1.45) }
                GradientStop { position: 0.4; color: Theme.source }
                GradientStop { position: 1.0; color: Qt.darker(Theme.accentDeep, 1.8) }
            }

            PathAngleArc {
                centerX: sphere.width / 2
                centerY: sphere.height / 2
                radiusX: sphere.width / 2
                radiusY: sphere.height / 2
                startAngle: 0
                sweepAngle: 360
            }
        }
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1
        text: Icons.arch
        color: "#ffffff"
        font.family: Theme.iconFont
        font.pixelSize: 21
        style: Text.Raised
        styleColor: "#90002040"
    }

    // Top reflection.
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: sphere.y + 1
        width: sphere.width * 0.8
        height: sphere.height * 0.48
        radius: height / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e6ffffff" }
            GradientStop { position: 1.0; color: "#0cffffff" }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

import QtQuick
import QtQuick.Effects

// Glossy slider: inset groove, candy-like fill and a pearl knob.
Item {
    id: root

    property real value: 0
    property bool vertical: false
    property color fillColor: Theme.accent

    signal moved(real value)

    readonly property real position: Math.max(0, Math.min(1, value))
    readonly property real thickness: vertical ? width : height
    readonly property real length: vertical ? height : width
    readonly property real knobSize: thickness + 6
    readonly property real travel: Math.max(1, length - knobSize)
    readonly property bool hovered: mouse.containsMouse || mouse.pressed

    implicitWidth: vertical ? 12 : 160
    implicitHeight: vertical ? 90 : 12

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    Rectangle {
        anchors.fill: parent
        radius: root.thickness / 2
        border.width: 1
        border.color: "#66ffffff"
        gradient: Gradient {
            orientation: root.vertical ? Gradient.Horizontal : Gradient.Vertical
            GradientStop { position: 0.0; color: "#8a000000" }
            GradientStop { position: 1.0; color: "#30000000" }
        }
    }

    Rectangle {
        id: fill

        visible: root.position > 0.005
        radius: (root.thickness - 4) / 2
        x: 2
        y: root.vertical ? knob.y + root.knobSize / 2 : 2
        width: root.vertical ? root.width - 4 : Math.max(height, knob.x + root.knobSize / 2 - 2)
        height: root.vertical ? Math.max(width, root.height - 2 - y) : root.height - 4
        gradient: Gradient {
            orientation: root.vertical ? Gradient.Horizontal : Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.lighter(root.fillColor, 1.7) }
            GradientStop { position: 0.45; color: root.fillColor }
            GradientStop { position: 0.55; color: Qt.darker(root.fillColor, 1.3) }
            GradientStop { position: 1.0; color: Qt.lighter(root.fillColor, 1.2) }
        }
    }

    RectangularShadow {
        anchors.fill: knob
        radius: root.knobSize / 2
        blur: 12
        spread: 1
        color: Theme.alpha(root.fillColor, root.hovered ? 0.9 : 0)

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Rectangle {
        id: knob

        width: root.knobSize
        height: root.knobSize
        radius: root.knobSize / 2
        x: root.vertical ? (root.width - width) / 2 : root.position * root.travel
        y: root.vertical ? (1 - root.position) * root.travel : (root.height - height) / 2
        border.width: 1
        border.color: "#b0ffffff"
        scale: mouse.pressed ? 0.9 : root.hovered ? 1.12 : 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 0.5; color: "#dcecf6" }
            GradientStop { position: 1.0; color: "#a9c6d8" }
        }

        Behavior on scale { NumberAnimation { duration: 110 } }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        anchors.margins: -7
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.PointingHandCursor

        function report(event) {
            const p = mapToItem(root, event.x, event.y);
            const along = root.vertical ? 1 - (p.y - root.knobSize / 2) / root.travel : (p.x - root.knobSize / 2) / root.travel;
            root.moved(root.clamp(along));
        }

        onPressed: event => report(event)
        onPositionChanged: event => {
            if (pressed)
                report(event);
        }
        onWheel: event => root.moved(root.clamp(root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
    }
}

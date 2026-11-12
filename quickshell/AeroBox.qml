import QtQuick
import QtQuick.Effects

// Reusable Aero glass surface: tinted body, bright outer border, dark inner
// hairline, white gloss sheet and a soft light pooled at the bottom.
Item {
    id: root

    property real radius: Theme.radius
    property color tint: Theme.glass
    property color borderColor: Theme.border

    // 0..1, outer halo used for hover and active states.
    property real glow: 0
    property color glowColor: Theme.accent

    // Tall surfaces (the vertical bar) get the gloss as a side sheet instead of a top sheet.
    property bool sideGloss: false
    property real glossSize: sideGloss ? width * 0.5 : Math.min(height * 0.5, 56)
    property real glossStrength: 1

    default property alias content: holder.data

    RectangularShadow {
        anchors.fill: body
        radius: root.radius
        blur: 20
        spread: 2
        color: Theme.alpha(root.glowColor, 0.8 * root.glow)
        visible: root.glow > 0.01
    }

    Rectangle {
        id: body

        anchors.fill: parent
        radius: root.radius
        border.width: 1
        border.color: root.borderColor
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha(Qt.lighter(root.tint, 1.55), root.tint.a) }
            GradientStop { position: 0.5; color: root.tint }
            GradientStop { position: 1.0; color: Theme.alpha(Qt.darker(root.tint, 1.4), Math.min(1, root.tint.a + 0.12)) }
        }
    }

    // Inner shadow line right under the bright border.
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, root.radius - 1)
        color: "transparent"
        border.width: 1
        border.color: "#38000000"
    }

    // Top gloss sheet.
    Rectangle {
        visible: !root.sideGloss
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 2 }
        height: Math.max(0, root.glossSize - 2)
        topLeftRadius: Math.max(0, root.radius - 2)
        topRightRadius: Math.max(0, root.radius - 2)
        bottomLeftRadius: Math.min(root.radius, height * 0.35)
        bottomRightRadius: Math.min(root.radius, height * 0.35)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.58 * root.glossStrength) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.07 * root.glossStrength) }
        }
    }

    // Side gloss sheet.
    Rectangle {
        visible: root.sideGloss
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; margins: 2 }
        width: Math.max(0, root.glossSize - 2)
        topLeftRadius: Math.max(0, root.radius - 2)
        bottomLeftRadius: Math.max(0, root.radius - 2)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.42 * root.glossStrength) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.05 * root.glossStrength) }
        }
    }

    // Light pooled at the bottom edge, tinted by the accent.
    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: 2 }
        height: Math.min(parent.height * 0.4, 40)
        bottomLeftRadius: Math.max(0, root.radius - 2)
        bottomRightRadius: Math.max(0, root.radius - 2)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.alpha(Qt.lighter(root.glowColor, 1.4), 0.2) }
        }
    }

    Item {
        id: holder

        anchors.fill: parent
    }
}

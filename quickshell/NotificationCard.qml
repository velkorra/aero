import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// One notification as an Aero glass card. Used by both the toasts and the history.
AeroBox {
    id: card

    // Quickshell Notification object; becomes null once the notification is closed.
    property var notification: null

    readonly property bool hovered: hover.hovered
    readonly property bool critical: notification !== null && notification.urgency === NotificationUrgency.Critical
    readonly property color criticalTint: "#7a1f1a"

    readonly property string iconSource: {
        const n = notification;
        if (n === null)
            return "";
        if (n.image !== "")
            return n.image;
        const icon = n.appIcon;
        if (icon === "")
            return "";
        if (icon.startsWith("/"))
            return Theme.fileUrl(icon);
        if (icon.includes("://"))
            return icon;
        return Quickshell.iconPath(icon, true);
    }

    signal closeClicked()
    signal bodyClicked()

    implicitHeight: Math.max(68, texts.implicitHeight + 24)
    tint: critical ? Theme.alpha(criticalTint, 0.7) : Theme.glassStrong
    glowColor: critical ? "#ff6a4a" : Theme.accent
    glow: hovered ? 0.45 : 0
    glossSize: Math.min(height * 0.5, 34)

    Behavior on glow { NumberAnimation { duration: 160 } }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: card.bodyClicked()
    }

    // App icon in an inset glass well.
    AeroBox {
        id: well

        x: 12
        y: 12
        width: 44
        height: 44
        radius: 8
        tint: Theme.alpha(Theme.ink, 0.35)
        glossStrength: 0.5

        Image {
            id: picture

            anchors.fill: parent
            anchors.margins: 5
            source: card.iconSource
            sourceSize.width: 68
            sourceSize.height: 68
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: !picture.visible
            text: Icons.bell
            color: Theme.text
            font.family: Theme.iconFont
            font.pixelSize: 20
            style: Text.Raised
            styleColor: Theme.textShadow
        }
    }

    Column {
        id: texts

        x: 68
        y: 11
        width: card.width - x - 14
        spacing: 3

        Text {
            width: parent.width - closeButton.width - 6
            text: {
                if (card.notification === null)
                    return "";
                const time = NotificationService.arrival(card.notification.id);
                const app = card.notification.appName;
                return time !== "" && app !== "" ? app + " · " + time : app + time;
            }
            color: Theme.textDim
            font.family: Theme.font
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: card.notification?.summary ?? ""
            textFormat: Text.PlainText
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 13
            font.weight: Font.DemiBold
            style: Text.Raised
            styleColor: Theme.textShadow
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: card.notification?.body ?? ""
            textFormat: Text.StyledText
            color: Theme.textDim
            linkColor: Qt.lighter(Theme.accent, 1.3)
            font.family: Theme.font
            font.pixelSize: 12
            wrapMode: Text.Wrap
            maximumLineCount: 5
            elide: Text.ElideRight
            onLinkActivated: link => Qt.openUrlExternally(link)
        }

        Flow {
            width: parent.width
            spacing: 6
            topPadding: 4
            visible: actions.count > 0

            Repeater {
                id: actions

                // "default" is what a click on the card does; unlabeled actions have nothing to show.
                model: card.notification === null ? []
                    : Array.from(card.notification.actions).filter(a => a.identifier !== "default" && a.text !== "")

                AeroButton {
                    required property var modelData

                    label: modelData.text
                    onClicked: modelData.invoke()
                }
            }
        }
    }

    CloseButton {
        id: closeButton

        anchors {
            top: parent.top
            right: parent.right
            topMargin: 7
            rightMargin: 9
        }
        onClicked: card.closeClicked()
    }
}

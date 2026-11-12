import QtQuick
import Quickshell

// Vertical clock: hours, minutes, then a compact date.
AeroBox {
    id: root

    implicitWidth: 46
    implicitHeight: column.implicitHeight + 14
    tint: Theme.alpha(Theme.ink, 0.38)
    glossSize: 22

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Column {
        id: column

        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 21
            font.weight: Font.DemiBold
            style: Text.Raised
            styleColor: Theme.textShadow
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 22
            height: 1
            color: "#70ffffff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "mm")
            color: Qt.lighter(Theme.accent, 1.35)
            font.family: Theme.font
            font.pixelSize: 21
            font.weight: Font.DemiBold
            style: Text.Raised
            styleColor: Theme.textShadow
        }

        Item {
            width: 1
            height: 4
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clock.date.toLocaleDateString(Theme.locale, "ddd")
            color: Theme.textDim
            font.family: Theme.font
            font.pixelSize: 10
            font.capitalization: Font.AllUppercase
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dd.MM")
            color: Theme.textDim
            font.family: Theme.font
            font.pixelSize: 10
        }
    }
}

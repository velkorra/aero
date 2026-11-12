import QtQuick

// Notification history popup, opened from the bell button on the bar.
PopupLayer {
    id: root

    open: ShellState.popup === "history"
    alignBottom: true
    panelWidth: 410
    panelHeight: 580
    onDismissed: ShellState.close()
    onOpenChanged: {
        if (open)
            NotificationService.unread = 0;
    }

    Item {
        anchors.fill: parent
        anchors.margins: 14

        Item {
            id: headerRow

            width: parent.width
            height: 34

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Уведомления"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 16
                font.weight: Font.DemiBold
                style: Text.Raised
                styleColor: Theme.textShadow
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                AeroButton {
                    icon: Icons.bellSlash
                    iconSize: 13
                    label: "Не беспокоить"
                    active: NotificationService.dnd
                    onClicked: NotificationService.dnd = !NotificationService.dnd
                }

                AeroButton {
                    icon: Icons.trash
                    iconSize: 13
                    label: "Очистить"
                    enabled: NotificationService.list.length > 0
                    opacity: enabled ? 1 : 0.45
                    onClicked: NotificationService.clearAll()
                }
            }
        }

        ListView {
            id: list

            anchors {
                top: headerRow.bottom
                topMargin: 12
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            clip: true
            spacing: 8
            boundsBehavior: Flickable.StopAtBounds
            // Newest first.
            model: NotificationService.list.slice().reverse()

            delegate: NotificationCard {
                required property var modelData

                width: list.width
                notification: modelData
                onCloseClicked: modelData.dismiss()
                onBodyClicked: {
                    ShellState.close();
                    NotificationService.activate(modelData);
                }
            }
        }

        Column {
            anchors.centerIn: list
            visible: list.count === 0
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Icons.bell
                color: Theme.textDim
                font.family: Theme.iconFont
                font.pixelSize: 34
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Нет уведомлений"
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: 13
            }
        }
    }
}

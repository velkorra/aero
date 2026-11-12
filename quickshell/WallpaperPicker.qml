import QtQuick
import QtQuick.Effects
import Quickshell.Widgets

// Wallpaper manager: a grid of previews for pictures and videos.
PopupLayer {
    id: root

    open: ShellState.popup === "wallpaper"
    panelWidth: 780
    panelHeight: 580
    onDismissed: ShellState.close()
    onOpenChanged: {
        if (open)
            Wallpapers.refresh();
    }

    Item {
        anchors.fill: parent
        anchors.margins: 14

        Item {
            id: headerRow

            width: parent.width
            height: 34

            Text {
                id: title

                anchors.verticalCenter: parent.verticalCenter
                text: "Обои"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 16
                font.weight: Font.DemiBold
                style: Text.Raised
                styleColor: Theme.textShadow
            }

            Text {
                anchors {
                    left: title.right
                    leftMargin: 12
                    baseline: title.baseline
                }
                text: Wallpapers.applying ? "Применяю и подбираю цвета…"
                    : Wallpapers.loading ? "Собираю превью…"
                    : grid.count + " шт."
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: 12
            }

            AeroButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                icon: Icons.refresh
                iconSize: 13
                label: "Обновить"
                enabled: !Wallpapers.loading
                opacity: enabled ? 1 : 0.45
                onClicked: Wallpapers.refresh()
            }
        }

        GridView {
            id: grid

            readonly property int columns: 4

            anchors {
                top: headerRow.bottom
                topMargin: 10
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            cellWidth: Math.floor(width / columns)
            cellHeight: Math.round(cellWidth * 0.62)
            model: Wallpapers.model
            enabled: !Wallpapers.applying
            opacity: enabled ? 1 : 0.55

            Behavior on opacity { NumberAnimation { duration: 160 } }

            delegate: Item {
                id: cell

                required property string kind
                required property string path
                required property string thumb
                required property string name

                readonly property bool selected: path === Wallpapers.current
                readonly property bool hovered: hit.containsMouse

                width: grid.cellWidth
                height: grid.cellHeight
                // The hovered tile scales up and must paint over its neighbours.
                z: hovered ? 1 : 0

                Item {
                    id: tile

                    anchors.fill: parent
                    anchors.margins: 7
                    scale: hit.pressed ? 0.97 : cell.hovered ? 1.04 : 1

                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                    RectangularShadow {
                        anchors.fill: parent
                        radius: 8
                        blur: 18
                        spread: 2
                        color: Theme.alpha(Qt.lighter(Theme.accent, 1.2), cell.selected ? 0.95 : cell.hovered ? 0.7 : 0)

                        Behavior on color { ColorAnimation { duration: 160 } }
                    }

                    ClippingRectangle {
                        anchors.fill: parent
                        radius: 8
                        color: Theme.alpha(Theme.ink, 0.6)

                        Image {
                            anchors.fill: parent
                            source: Theme.fileUrl(cell.thumb)
                            sourceSize.width: 384
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            opacity: status === Image.Ready ? 1 : 0

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        // Glass reflection over the preview.
                        Rectangle {
                            width: parent.width
                            height: parent.height * 0.45
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#66ffffff" }
                                GradientStop { position: 1.0; color: "#05ffffff" }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 26
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: "#c8000000" }
                            }

                            Text {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                    margins: 5
                                }
                                text: cell.name
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: 10
                                elide: Text.ElideMiddle
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "transparent"
                        border.width: cell.selected ? 2 : 1
                        border.color: cell.selected ? Qt.lighter(Theme.accent, 1.5) : Theme.border
                    }

                    // Badge that marks live (video) wallpapers.
                    AeroBox {
                        visible: cell.kind === "video"
                        x: 6
                        y: 6
                        width: 24
                        height: 24
                        radius: 12
                        tint: Theme.alpha(Theme.accent, 0.7)

                        Text {
                            anchors.centerIn: parent
                            text: Icons.film
                            color: Theme.text
                            font.family: Theme.iconFont
                            font.pixelSize: 11
                        }
                    }
                }

                MouseArea {
                    id: hit

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wallpapers.apply(cell.path)
                }
            }
        }

        // Scroll position indicator.
        Rectangle {
            visible: grid.visibleArea.heightRatio < 1
            anchors.right: grid.right
            anchors.rightMargin: -8
            y: grid.y + grid.visibleArea.yPosition * grid.height
            width: 4
            height: Math.max(24, grid.visibleArea.heightRatio * grid.height)
            radius: 2
            color: "#90ffffff"
        }

        Text {
            anchors.centerIn: grid
            visible: grid.count === 0 && !Wallpapers.loading
            horizontalAlignment: Text.AlignHCenter
            text: "Ничего не найдено.\nПоложи картинки в ~/Pictures, а видео в ~/Videos."
            color: Theme.textDim
            font.family: Theme.font
            font.pixelSize: 13
        }
    }
}

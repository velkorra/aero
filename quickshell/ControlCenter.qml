import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

// Control center: profile, power, wired network, volume and the media player.
PopupLayer {
    id: root

    // The player that is playing right now, otherwise the first known one.
    readonly property var player: {
        const players = Mpris.players.values;
        return players.find(p => p.isPlaying) ?? players[0] ?? null;
    }

    readonly property string powerHint: logoutButton.armed ? "Ещё раз — выйти из сеанса"
        : rebootButton.armed ? "Ещё раз — перезагрузить"
        : shutdownButton.armed ? "Ещё раз — выключить"
        : ""

    open: ShellState.popup === "control"
    panelWidth: 430
    panelHeight: layout.implicitHeight + 28
    onDismissed: ShellState.close()
    onOpenChanged: SysInfo.active = open

    // Power actions need a second click within three seconds.
    component PowerButton: AeroButton {
        id: power

        property var command: []
        property bool armed: false

        round: true
        implicitWidth: 36
        implicitHeight: 36
        iconSize: 15
        active: armed
        activeTint: Theme.danger
        onClicked: {
            if (armed) {
                armed = false;
                ShellState.close();
                Quickshell.execDetached(command);
            } else {
                armed = true;
                disarm.restart();
            }
        }

        Timer {
            id: disarm

            interval: 3000
            onTriggered: power.armed = false
        }
    }

    component SectionTitle: Text {
        color: Theme.textDim
        font.family: Theme.font
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1
    }

    Column {
        id: layout

        x: 14
        y: 14
        width: parent.width - 28
        spacing: 12

        // Header with the power buttons.
        Item {
            width: parent.width
            height: 38

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "Центр управления"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    style: Text.Raised
                    styleColor: Theme.textShadow
                }

                Text {
                    visible: root.powerHint !== ""
                    text: root.powerHint
                    color: "#ffc9c0"
                    font.family: Theme.font
                    font.pixelSize: 11
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                PowerButton {
                    id: logoutButton

                    icon: Icons.logout
                    command: ["niri", "msg", "action", "quit", "--skip-confirmation"]
                }

                PowerButton {
                    id: rebootButton

                    icon: Icons.reboot
                    command: ["systemctl", "reboot"]
                }

                PowerButton {
                    id: shutdownButton

                    icon: Icons.power
                    tint: Theme.alpha(Theme.danger, 0.45)
                    command: ["systemctl", "poweroff"]
                }
            }
        }

        // Profile card.
        AeroBox {
            width: parent.width
            height: 132
            tint: Theme.card
            glossSize: 40

            Item {
                id: avatar

                x: 18
                anchors.verticalCenter: parent.verticalCenter
                width: 96
                height: 96

                RectangularShadow {
                    anchors.fill: parent
                    radius: width / 2
                    blur: 20
                    spread: 1
                    color: Theme.alpha(Theme.accent, 0.75)
                }

                // Glass ring around the picture.
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    border.width: 1
                    border.color: "#d0ffffff"
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(Theme.accent, 1.7) }
                        GradientStop { position: 0.5; color: Theme.accent }
                        GradientStop { position: 1.0; color: Qt.darker(Theme.accent, 1.6) }
                    }
                }

                ClippingRectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: width / 2
                    color: Theme.alpha(Theme.ink, 0.7)

                    Image {
                        id: face

                        anchors.fill: parent
                        source: Theme.fileUrl(Theme.home + "/.face")
                        sourceSize.width: 192
                        sourceSize.height: 192
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !face.visible
                        text: Icons.user
                        color: Theme.text
                        font.family: Theme.iconFont
                        font.pixelSize: 42
                    }

                    // Reflection across the top of the picture.
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 2
                        width: parent.width * 0.82
                        height: parent.height * 0.42
                        radius: height / 2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#73ffffff" }
                            GradientStop { position: 1.0; color: "#05ffffff" }
                        }
                    }
                }
            }

            Column {
                anchors {
                    left: avatar.right
                    leftMargin: 18
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                spacing: 3

                Text {
                    width: parent.width
                    text: SysInfo.user
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    style: Text.Raised
                    styleColor: Theme.textShadow
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: SysInfo.host !== "" ? SysInfo.user + "@" + SysInfo.host : SysInfo.user
                    color: Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: "Аптайм — " + SysInfo.uptimeText
                    color: Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: SysInfo.niri !== ""
                    text: SysInfo.niri
                    color: Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }
        }

        // Wired network.
        AeroBox {
            width: parent.width
            height: 62
            tint: Theme.card
            glossSize: 24

            Text {
                id: lanIcon

                x: 18
                anchors.verticalCenter: parent.verticalCenter
                text: Icons.network
                color: Theme.text
                font.family: Theme.iconFont
                font.pixelSize: 20
                style: Text.Raised
                styleColor: Theme.textShadow
            }

            Column {
                anchors {
                    left: lanIcon.right
                    leftMargin: 14
                    right: led.left
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                spacing: 2

                SectionTitle {
                    text: SysInfo.lanIface !== "" ? "Ethernet · " + SysInfo.lanIface : "Ethernet"
                }

                Text {
                    width: parent.width
                    text: SysInfo.lanText
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
            }

            // Status LED.
            Item {
                id: led

                anchors {
                    right: parent.right
                    rightMargin: 18
                    verticalCenter: parent.verticalCenter
                }
                width: 14
                height: 14

                RectangularShadow {
                    anchors.fill: parent
                    radius: 7
                    blur: 12
                    spread: 2
                    color: Theme.alpha(Theme.ok, SysInfo.lanUp ? 0.95 : 0)
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    border.width: 1
                    border.color: "#b0ffffff"
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: SysInfo.lanUp ? "#e4ffd8" : "#d7dde2" }
                        GradientStop { position: 0.5; color: SysInfo.lanUp ? Theme.ok : "#8d979f" }
                        GradientStop { position: 1.0; color: SysInfo.lanUp ? "#2a9a2a" : "#59626a" }
                    }
                }
            }
        }

        // Volume.
        AeroBox {
            width: parent.width
            height: 62
            tint: Theme.card
            glossSize: 24

            AeroButton {
                id: muteButton

                x: 12
                anchors.verticalCenter: parent.verticalCenter
                round: true
                implicitWidth: 38
                implicitHeight: 38
                icon: Audio.icon
                iconColor: Audio.muted ? "#ffb0a8" : Theme.text
                active: Audio.muted
                activeTint: Theme.danger
                onClicked: Audio.toggleMute()
            }

            AeroSlider {
                anchors {
                    left: muteButton.right
                    leftMargin: 16
                    right: volumeLabel.left
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                value: Audio.volume
                fillColor: Audio.muted ? "#8c9aa3" : Theme.accent
                onMoved: value => Audio.setVolume(value)
            }

            Text {
                id: volumeLabel

                anchors {
                    right: parent.right
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                width: 38
                horizontalAlignment: Text.AlignRight
                text: Math.round(Audio.volume * 100) + "%"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 13
            }
        }

        // Media player.
        AeroBox {
            width: parent.width
            height: 100
            tint: Theme.card
            glossSize: 34

            ClippingRectangle {
                id: cover

                x: 14
                anchors.verticalCenter: parent.verticalCenter
                width: 72
                height: 72
                radius: 8
                color: Theme.alpha(Theme.ink, 0.55)

                Image {
                    id: art

                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    sourceSize.width: 144
                    sourceSize.height: 144
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    visible: !art.visible
                    text: Icons.music
                    color: Theme.textDim
                    font.family: Theme.iconFont
                    font.pixelSize: 26
                }

                Rectangle {
                    width: parent.width
                    height: parent.height * 0.45
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#59ffffff" }
                        GradientStop { position: 1.0; color: "#05ffffff" }
                    }
                }
            }

            Rectangle {
                anchors.fill: cover
                radius: cover.radius
                color: "transparent"
                border.width: 1
                border.color: "#90ffffff"
            }

            Column {
                anchors {
                    left: cover.right
                    leftMargin: 14
                    right: controls.left
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                spacing: 3

                SectionTitle {
                    width: parent.width
                    text: root.player?.identity ?? "Плеер"
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: root.player === null ? "Ничего не играет" : (root.player.trackTitle || "Без названия")
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    style: Text.Raised
                    styleColor: Theme.textShadow
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: root.player?.trackArtist ?? ""
                    color: Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }

            Row {
                id: controls

                anchors {
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                spacing: 6
                enabled: root.player !== null
                opacity: enabled ? 1 : 0.4

                AeroButton {
                    anchors.verticalCenter: parent.verticalCenter
                    round: true
                    implicitWidth: 32
                    implicitHeight: 32
                    iconSize: 12
                    icon: Icons.previous
                    enabled: root.player?.canGoPrevious ?? false
                    onClicked: root.player.previous()
                }

                AeroButton {
                    anchors.verticalCenter: parent.verticalCenter
                    round: true
                    implicitWidth: 42
                    implicitHeight: 42
                    iconSize: 15
                    icon: root.player?.isPlaying ? Icons.pause : Icons.play
                    tint: Theme.alpha(Theme.accent, 0.4)
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: root.player.togglePlaying()
                }

                AeroButton {
                    anchors.verticalCenter: parent.verticalCenter
                    round: true
                    implicitWidth: 32
                    implicitHeight: 32
                    iconSize: 12
                    icon: Icons.next
                    enabled: root.player?.canGoNext ?? false
                    onClicked: root.player.next()
                }
            }
        }
    }
}

import QtQuick

// Bar volume widget: vertical slider with a mute button underneath.
Column {
    id: root

    spacing: 8

    AeroSlider {
        anchors.horizontalCenter: parent.horizontalCenter
        vertical: true
        implicitHeight: 84
        value: Audio.volume
        fillColor: Audio.muted ? "#8c9aa3" : Theme.accent
        onMoved: value => Audio.setVolume(value)
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Math.round(Audio.volume * 100)
        color: Theme.textDim
        font.family: Theme.font
        font.pixelSize: 10
        style: Text.Raised
        styleColor: Theme.textShadow
    }

    AeroButton {
        anchors.horizontalCenter: parent.horizontalCenter
        round: true
        icon: Audio.icon
        iconColor: Audio.muted ? "#ffb0a8" : Theme.text
        scrollable: true
        onClicked: Audio.toggleMute()
        onScrolled: delta => Audio.setVolume(Audio.volume + (delta > 0 ? 0.05 : -0.05))
    }
}

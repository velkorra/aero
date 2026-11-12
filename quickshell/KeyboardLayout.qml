import QtQuick

// Keyboard layout indicator in the style of the Windows language bar.
// Left click or wheel down: next layout. Right click or wheel up: previous.
AeroButton {
    implicitWidth: 40
    implicitHeight: 28
    label: Niri.layoutCode
    scrollable: true
    onClicked: Niri.action(["switch-layout", "next"])
    onRightClicked: Niri.action(["switch-layout", "prev"])
    onScrolled: delta => Niri.action(["switch-layout", delta > 0 ? "prev" : "next"])
}

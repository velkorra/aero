import QtQuick
import Quickshell

ShellRoot {
    Bar {}
    Notifications {}
    NotificationHistory {}
    ControlCenter {}
    WallpaperPicker {}
    TrayPopup {}

    Component.onCompleted: Wallpapers.restore()
}

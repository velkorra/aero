import QtQuick
import Quickshell

ShellRoot {
    Bar {}
    Notifications {}
    NotificationHistory {}
    ControlCenter {}
    WallpaperPicker {}

    Component.onCompleted: Wallpapers.restore()
}

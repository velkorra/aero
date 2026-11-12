pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME") || ""
    readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || (home + "/.cache")) + "/aero-shell"

    // Wallpaper-driven palette. The values animate when colors.json is regenerated.
    property color accent: palette.accent
    property color accentDeep: palette.container
    property color secondary: palette.secondary
    property color tertiary: palette.tertiary
    property color source: palette.source

    Behavior on accent { ColorAnimation { duration: 700; easing.type: Easing.InOutQuad } }
    Behavior on accentDeep { ColorAnimation { duration: 700; easing.type: Easing.InOutQuad } }
    Behavior on secondary { ColorAnimation { duration: 700; easing.type: Easing.InOutQuad } }
    Behavior on tertiary { ColorAnimation { duration: 700; easing.type: Easing.InOutQuad } }
    Behavior on source { ColorAnimation { duration: 700; easing.type: Easing.InOutQuad } }

    readonly property color ink: "#06202f"

    // Glass tints: the gloss overlay in AeroBox stays white, only the body follows the palette.
    readonly property color glass: alpha(accentDeep, 0.46)
    readonly property color glassStrong: alpha(mix(accentDeep, ink, 0.35), 0.64)
    readonly property color card: Qt.rgba(1, 1, 1, 0.10)
    readonly property color cardHover: Qt.rgba(1, 1, 1, 0.20)

    readonly property color text: "#ffffff"
    readonly property color textDim: "#c8ffffff"
    readonly property color textShadow: "#a0000000"
    readonly property color border: "#80ffffff"
    readonly property color danger: "#e04343"
    readonly property color ok: "#6fe36a"

    readonly property int barWidth: 66
    readonly property int radius: 10
    readonly property int gap: 10

    readonly property string font: "Noto Sans"
    readonly property string iconFont: "Symbols Nerd Font"
    readonly property var locale: Qt.locale("ru_RU")

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    // Paths may contain '#', '%' or spaces, which break a naive "file://" + path.
    function fileUrl(path) {
        return "file://" + path.split("/").map(encodeURIComponent).join("/");
    }

    function reloadColors() {
        colorsFile.reload();
    }

    FileView {
        id: colorsFile

        path: root.cacheDir + "/colors.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()

        JsonAdapter {
            id: palette

            // Defaults are the classic aqua look, used until the first wallpaper is applied.
            property string accent: "#7fd4ff"
            property string container: "#0b4f73"
            property string secondary: "#8ee6c8"
            property string tertiary: "#a8f08c"
            property string source: "#2a9fd6"
        }
    }
}

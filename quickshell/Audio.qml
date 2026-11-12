pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool available: sink !== null && sink.audio !== null
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available ? sink.audio.muted : false

    readonly property string icon: muted || volume < 0.005 ? Icons.volumeOff
        : volume < 0.5 ? Icons.volumeLow
        : Icons.volumeHigh

    function setVolume(value) {
        if (!available)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute() {
        if (available)
            sink.audio.muted = !sink.audio.muted;
    }

    // Node properties such as volume are only valid while the node is tracked.
    PwObjectTracker {
        objects: [root.sink]
    }
}

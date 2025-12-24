pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Services.Pipewire

Singleton {
    id: root
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}

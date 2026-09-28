import QtQuick
import qs.components
import Quickshell.Services.Pipewire

Rectangle {
    id: root
    color: 'transparent'

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: root.sink && root.sink.ready && root.sink.audio ? root.sink.audio.volume : 0
    readonly property bool muted: !root.sink || !root.sink.ready || !root.sink.audio ? true : root.sink.audio.muted

    CustomIcon {
        iconName: {
            if (root.muted)
                return 'volume/volume-muted';
            if (root.volume <= 0.01)
                return 'volume/volume-no';
            if (root.volume < 0.4)
                return 'volume/volume-low';
            return 'volume/volume';
        }
        height: 15
        width: 15
    }
}

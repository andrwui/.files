import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire
import qs.config

Slider {
    id: root

    required property var node

    readonly property bool hasAudio: root.node && root.node.ready && root.node.audio

    from: 0
    to: 1.5
    stepSize: 0.01

    enabled: root.hasAudio

    // NOTE: plain `value: ...` bindings are disconnected by Slider the
    // first time the user drags it, freezing the slider forever. A
    // guarded Binding keeps two-way sync: live writes while dragging,
    // backend truth otherwise.
    Binding on value {
        value: root.hasAudio ? root.node.audio.volume : 0
        when: !root.pressed
    }

    onMoved: {
        if (root.node && root.node.audio)
            root.node.audio.volume = value;
    }

    background: Rectangle {
        implicitHeight: 6
        radius: Config.constants.fullRadius
        color: Config.colors.secondaryDark

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Config.colors.foreground
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 14
        height: 14
        radius: Config.constants.fullRadius
        color: Config.colors.foreground
    }
}

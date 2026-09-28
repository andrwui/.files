pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import qs.components
import qs.config
import qs.state
import qs.modules.notch.panels.components
import qs.modules.notch.panels.sound as SoundModule

Rectangle {
    id: root
    color: 'transparent'

    // NOTE: no anchors.fill here on purpose – this item is placed directly
    // in notchStack and explicit width/height are set in Panels.qml.
    // Anchors on a StackView item break the scale transition
    // ("conflicting anchors") and the open animation glitches.

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    function nodeLabel(node) {
        if (!node)
            return 'No device';
        return node.nickname || node.description || node.name || 'Unknown device';
    }

    function streamLabel(node) {
        if (!node)
            return 'Unknown app';
        var props = node.properties;
        if (props && props['application.name'])
            return props['application.name'];
        return node.nickname || node.description || node.name || 'Unknown app';
    }

    function nodeVolume(node) {
        if (!node || !node.ready || !node.audio)
            return 0;
        return node.audio.volume;
    }

    function isDefault(node, other) {
        return node && other && node.id === other.id;
    }

    ScriptModel {
        id: sinksModel
        values: Pipewire.nodes.values.filter(n => n && !n.isStream && n.isSink && n.audio)
    }

    ScriptModel {
        id: sourcesModel
        values: Pipewire.nodes.values.filter(n => n && !n.isStream && !n.isSink && n.audio)
    }

    ScriptModel {
        id: streamsModel
        values: Pipewire.nodes.values.filter(n => n && n.isStream && n.audio)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Config.constants.spacing
        spacing: Config.constants.spacing / 2

        RowLayout {
            Layout.fillWidth: true

            BackButton {
                text: 'Sound'
                Layout.fillWidth: true
            }

            Text {
                text: root.sink && root.sink.ready && root.sink.audio && root.sink.audio.muted ? 'Muted' : 'Mute'
                font.pixelSize: 13
                color: Config.colors.secondaryLight
                Layout.alignment: Qt.AlignVCenter
            }

            CustomSwitch {
                Layout.alignment: Qt.AlignVCenter
                checked: root.sink && root.sink.ready && root.sink.audio ? root.sink.audio.muted : false
                onToggled: {
                    if (root.sink && root.sink.audio)
                        root.sink.audio.muted = checked;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 96
            radius: 8
            color: Config.colors.base
            border.color: Config.colors.secondaryDark
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Config.constants.spacing / 2
                spacing: Config.constants.spacing / 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Config.constants.spacing / 2

                    CustomIcon {
                        Layout.alignment: Qt.AlignVCenter
                        iconName: 'volume/volume'
                        width: 16
                        height: 16
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: root.nodeLabel(root.sink)
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        color: Config.colors.foreground
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: `${Math.round(root.nodeVolume(root.sink) * 100)}%`
                        font.pixelSize: 14
                        font.bold: true
                        color: Config.colors.foreground
                    }
                }

                SoundModule.VolumeSlider {
                    Layout.fillWidth: true
                    node: root.sink
                }
            }
        }

        Text {
            text: 'Output'
            font.pixelSize: 13
            color: Config.colors.secondaryLight
        }

        ListView {
            id: sinksList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.constants.spacing / 2
            clip: true

            model: sinksModel

            delegate: Rectangle {
                required property var modelData

                width: sinksList.width
                height: 48
                radius: 8
                color: Config.colors.base
                border.color: Config.colors.secondaryDark
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Config.constants.spacing / 2
                    spacing: Config.constants.spacing / 2

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: root.nodeLabel(modelData)
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        color: Config.colors.foreground
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        visible: root.isDefault(modelData, root.sink)
                        text: 'Default'
                        font.pixelSize: 12
                        color: Config.colors.secondaryLight
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: `${Math.round(root.nodeVolume(modelData) * 100)}%`
                        font.pixelSize: 12
                        color: Config.colors.secondaryLight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.constants.spacing / 2

            Text {
                text: 'Input'
                font.pixelSize: 13
                color: Config.colors.secondaryLight
                Layout.alignment: Qt.AlignVCenter
            }

            SoundModule.VolumeSlider {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                node: root.source
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: `${Math.round(root.nodeVolume(root.source) * 100)}%`
                font.pixelSize: 12
                color: Config.colors.secondaryLight
            }
        }

        ListView {
            id: sourcesList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.constants.spacing / 2
            clip: true

            model: sourcesModel

            delegate: Rectangle {
                required property var modelData

                width: sourcesList.width
                height: 48
                radius: 8
                color: Config.colors.base
                border.color: Config.colors.secondaryDark
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Config.constants.spacing / 2
                    spacing: Config.constants.spacing / 2

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: root.nodeLabel(modelData)
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        color: Config.colors.foreground
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        visible: root.isDefault(modelData, root.source)
                        text: 'Default'
                        font.pixelSize: 12
                        color: Config.colors.secondaryLight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Pipewire.preferredDefaultAudioSource = modelData
                }
            }
        }

        Text {
            text: 'Applications'
            font.pixelSize: 13
            color: Config.colors.secondaryLight
        }

        ListView {
            id: streamsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.constants.spacing / 2
            clip: true

            model: streamsModel

            delegate: Rectangle {
                required property var modelData

                width: streamsList.width
                height: 72
                radius: 8
                color: Config.colors.base
                border.color: Config.colors.secondaryDark
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Config.constants.spacing / 2
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Config.constants.spacing / 2

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: root.streamLabel(modelData)
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            color: Config.colors.foreground
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: modelData.audio && modelData.audio.muted ? 'Muted' : `${Math.round(root.nodeVolume(modelData) * 100)}%`
                            font.pixelSize: 12
                            color: Config.colors.secondaryLight
                        }
                    }

                    SoundModule.VolumeSlider {
                        Layout.fillWidth: true
                        node: modelData
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.audio)
                            modelData.audio.muted = !modelData.audio.muted;
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: sinksList.count === 0
        text: Pipewire.ready ? 'No output devices' : 'Loading audio…'
        font.pixelSize: 13
        color: Config.colors.secondaryLight
    }
}

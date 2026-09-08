pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.config
import qs.components
import QtQuick.Layouts
import Quickshell.Services.UPower
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import qs.state
import qs.modules.notch.panels.components

Rectangle {
    id: root

    property bool expanded: false

    readonly property int smallWidth: Config.constants.spacing * 2.5
    readonly property int smallHeight: 35
    readonly property int bigWidth: Config.constants.spacing * 17
    readonly property int bigHeight: Config.constants.spacing * 10
    readonly property int smallRadius: 20
    readonly property int bigRadius: 40

    width: expanded ? bigWidth : smallWidth
    height: expanded ? bigHeight : smallHeight
    radius: expanded ? bigRadius : smallRadius
    clip: true
    color: Config.colors.base

    anchors.right: parent.right
    anchors.top: parent.top

    Behavior on width {
        Anim {}
    }
    Behavior on height {
        Anim {}
    }
    Behavior on radius {
        Anim {}
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return '—';
        var hours = Math.floor(seconds / 3600);
        var mins = Math.round((seconds % 3600) / 60);
        return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
    }

    function expand() {
        if (root.expanded)
            return;
        root.expanded = true;
        stack.replace(expandedView);
    }

    function collapse() {
        if (!root.expanded)
            return;
        root.expanded = false;
        stack.replace(smallView);
    }

    HoverHandler {
        onHoveredChanged: {
            if (!hovered && root.expanded)
                root.collapse();
        }
    }

    Rectangle {
        id: roundedMask
        anchors.fill: parent
        radius: root.radius
        color: 'white'
        visible: false
    }

    MultiEffect {
        id: blurFx
        anchors.fill: parent
        source: blurBg
        blurEnabled: true
        blur: 0
        blurMax: 50
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: roundedMask
        }

        Rectangle {
            id: blurBg
            anchors.fill: parent
            radius: root.radius
            color: Config.colors.base

            StackView {
                id: stack
                initialItem: smallView
                anchors.fill: parent

                replaceEnter: Transition {
                    SpringAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                    SpringAnimation {
                        property: "scale"
                        from: 0.8
                        to: 1
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                    SpringAnimation {
                        target: blurFx
                        property: "blur"
                        from: 1
                        to: 0
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                }

                replaceExit: Transition {
                    SpringAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                    SpringAnimation {
                        property: "scale"
                        from: 1
                        to: 0.8
                        spring: Config.animations.spring
                        damping: Config.animations.damping
                    }
                }
            }
        }
    }

    Component {
        id: smallView
        Item {
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expand()
            }

            Item {
                width: Config.constants.spacing * 1.5
                height: Config.constants.spacing * 1.5
                anchors.centerIn: parent

                Rectangle {
                    anchors.fill: parent
                    color: 'transparent'

                    Image {
                        source: 'root:/icons/battery/battery.svg'
                        sourceSize: Qt.size(48, 48)
                        fillMode: Image.PreserveAspectFit
                        antialiasing: true
                        smooth: true
                        anchors.fill: parent
                        z: 5
                    }

                    Rectangle {
                        color: Config.colors.foreground
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.leftMargin: 4
                        z: 2
                        height: parent.height - 20
                        width: UPower.displayDevice ? (parent.width - 10) * UPower.displayDevice.percentage : 0

                        Behavior on width {
                            Anim {}
                        }
                    }
                }

                Image {
                    source: 'root:/icons/battery/ray.svg'
                    sourceSize: Qt.size(48, 48)
                    fillMode: Image.PreserveAspectFit
                    antialiasing: true
                    smooth: true
                    width: Config.constants.spacing * 0.55
                    height: Config.constants.spacing * 0.55
                    anchors.centerIn: parent
                    opacity: UPower.onBattery ? 0 : 1
                    scale: UPower.onBattery ? 0.5 : 1
                    z: 10

                    Behavior on opacity {
                        Anim {}
                    }
                    Behavior on scale {
                        Anim {}
                    }
                }
            }
        }
    }

    Component {
        id: expandedView
        Item {
            Component.onCompleted: BatteryState.refresh()

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Config.constants.spacing
                spacing: Config.constants.spacing / 2

                BackButton {
                    text: 'Battery'
                    Layout.fillWidth: true
                    onClicked: root.collapse()
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Config.constants.spacing

                    Item {
                        width: Config.constants.spacing * 4
                        height: Config.constants.spacing * 4

                        Image {
                            source: 'root:/icons/battery/battery.svg'
                            sourceSize: Qt.size(128, 128)
                            fillMode: Image.PreserveAspectFit
                            antialiasing: true
                            smooth: true
                            anchors.fill: parent
                            z: 5
                        }

                        Rectangle {
                            color: Config.colors.foreground
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.topMargin: parent.height / 3 - 2
                            anchors.leftMargin: parent.width * 0.15
                            z: 2
                            height: parent.height / 3 + 4
                            width: UPower.displayDevice ? (parent.width * 0.7) * UPower.displayDevice.percentage : 0

                            Behavior on width {
                                Anim {}
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: UPower.displayDevice ? `${Math.round(UPower.displayDevice.percentage * 100)}%` : '—'
                            font.pixelSize: 44
                            font.bold: true
                            color: Config.colors.foreground
                        }

                        Text {
                            text: {
                                if (!UPower.displayDevice)
                                    return '';
                                return UPower.onBattery ? `Time remaining: ${root.formatTime(UPower.displayDevice.timeToEmpty)}` : `Time to full: ${root.formatTime(UPower.displayDevice.timeToFull)}`;
                            }
                            font.pixelSize: 14
                            color: Config.colors.secondaryLight
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Config.constants.spacing / 2

                    Text {
                        text: 'Power saving'
                        font.pixelSize: 14
                        color: Config.colors.foreground
                    }

                    CustomSwitch {
                        checked: BatteryState.powerSaving
                        onToggled: BatteryState.setPowerSaving(checked)
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}

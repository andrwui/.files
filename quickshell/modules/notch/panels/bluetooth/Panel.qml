pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.components
import qs.config
import qs.state
import qs.modules.notch.panels.components

Rectangle {
    id: root
    color: 'transparent'

    anchors.fill: parent
    anchors.topMargin: Config.constants.spacing
    anchors.leftMargin: Config.constants.spacing
    anchors.rightMargin: Config.constants.spacing

    function batteryText(value) {
        return value > 1 ? `${Math.round(value)}%` : `${Math.round(value * 100)}%`;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.constants.spacing / 2

        RowLayout {
            Layout.fillWidth: true

            BackButton {
                text: 'Bluetooth'
                Layout.fillWidth: true
            }

            Text {
                text: 'Scan'
                font.pixelSize: 13
                color: Config.colors.secondaryLight
            }

            CustomSwitch {
                checked: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering
                onToggled: {
                    if (Bluetooth.defaultAdapter)
                        Bluetooth.defaultAdapter.discovering = checked;
                }
            }
        }

        ListView {
            id: devicesList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.constants.spacing / 2
            clip: true

            model: Bluetooth.devices

            delegate: Rectangle {
                required property var modelData

                width: devicesList.width
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
                        text: modelData.name || modelData.deviceName || 'Unknown device'
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        color: Config.colors.foreground
                    }

                    Text {
                        visible: modelData.connected && modelData.batteryAvailable
                        text: root.batteryText(modelData.battery)
                        font.pixelSize: 12
                        color: Config.colors.secondaryLight
                    }

                    ShrinkButton {
                        Layout.alignment: Qt.AlignVCenter
                        width: 70
                        height: 24
                        onClicked: {
                            if (modelData.connected)
                                modelData.disconnect();
                            else if (modelData.pairing)
                                modelData.cancelPair();
                            else
                                modelData.connect();
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: Config.colors.secondaryDark

                            Text {
                                anchors.centerIn: parent
                                text: modelData.connected
                                    ? 'Disconnect'
                                    : modelData.pairing ? 'Cancel' : 'Connect'
                                font.pixelSize: 12
                                color: Config.colors.foreground
                            }
                        }
                    }

                    ShrinkButton {
                        Layout.alignment: Qt.AlignVCenter
                        width: 24
                        height: 24
                        onClicked: modelData.forget()

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: Config.colors.secondaryDark

                            Text {
                                anchors.centerIn: parent
                                text: 'x'
                                font.pixelSize: 12
                                font.bold: true
                                color: Config.colors.secondaryLight
                            }
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: Bluetooth.devices.count === 0
        text: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
            ? 'No devices'
            : 'Bluetooth off'
        font.pixelSize: 13
        color: Config.colors.secondaryLight
    }
}

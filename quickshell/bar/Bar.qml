pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import "../singleton"

Variants {
    model: Quickshell.screens

    delegate: Component {

        PanelWindow {
            id: bar

            property var modelData
            screen: modelData

            color: 'transparent'
            mask: {}

            exclusiveZone: 35

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 35

            margins {
                top: 5
                left: 5
                right: 5
            }

            Rectangle {
                id: workspaces

                implicitHeight: 35
                implicitWidth: row.implicitWidth + 20

                clip: true

                color: '#080808'

                radius: 10

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutSine
                    }
                }

                RowLayout {
                    id: row
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutSine
                        }
                    }

                    Repeater {
                        model: Hyprland.workspaces

                        Rectangle {
                            id: workspace

                            required property HyprlandWorkspace modelData

                            color: modelData.id === Hyprland.focusedWorkspace.id ? '#d8d8d8' : '#222222'

                            implicitWidth: modelData.id === Hyprland.focusedWorkspace.id ? 35 : 15
                            implicitHeight: 15

                            radius: 5

                            Behavior on implicitWidth {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.OutSine
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                    easing.type: Easing.OutSine
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: bluetooth

                readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
                readonly property bool connected: adapter.devices.values.some(device => device.connected)

                anchors.right: time.left
                anchors.rightMargin: 5

                color: "#080808"
                height: 35
                width: 35
                radius: 10

                Image {

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    source: bluetooth.connected ? 'root:/icons/bluetooth-connected.svg' : bluetooth.adapter.enabled ? 'root:/icons/bluetooth-on.svg' : 'root:/icons/bluetooth-off.svg'
                    sourceSize: "18x18"
                }

                Process {
                    id: btRunner
                    running: false
                    command: ['sh', '-c', 'blueman-manager']
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: () => {
                        btRunner.running = true;
                    }
                }
            }

            // Network status indicator
            Rectangle {
                id: network
                anchors.left: time.right
                anchors.leftMargin: 5
                height: 35
                width: 35
                radius: 10
                color: "#080808"

                property string networkStatusIcon: 'root:/icons/network-disconnected.svg'

                Timer {
                    interval: 5000
                    running: true
                    repeat: true
                    onTriggered: checkNetwork.running = true
                    triggeredOnStart: true
                }

                Process {
                    id: checkNetwork
                    running: false
                    command: ['sh', '-c', 'nmcli -t -f TYPE,STATE connection show --active | grep activated || echo ""']

                    stdout: StdioCollector {
                        onStreamFinished: {
                            var output = this.text.trim();
                            if (output.includes("802-3-ethernet:activated")) {
                                network.networkStatusIcon = 'root:/icons/network-wired.svg';
                            } else if (output.includes("802-11-wireless:activated")) {
                                network.networkStatusIcon = 'root:/icons/network-wifi.svg';
                            } else {
                                network.networkStatusIcon = "root:/icons/network-disconnected.svg";
                            }
                        }
                    }
                }

                Image {
                    anchors.centerIn: parent
                    sourceSize: "18x18"
                    source: network.networkStatusIcon
                }

                Process {
                    id: nmRunner
                    running: false
                    command: ['sh', '-c', 'nmgui']
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: () => {
                        nmRunner.running = true;
                    }
                }
            }

            // Hour marker in the center
            Rectangle {
                id: time
                anchors.centerIn: parent
                height: 35
                width: 60
                radius: 10
                color: "#080808"

                Text {
                    anchors.centerIn: parent
                    text: Time.time
                    font.bold: true
                    font.pixelSize: 16
                    color: "#d8d8d8"
                }
            }

            Rectangle {
                id: battery

                property bool isCharging: !UPower.onBattery

                anchors.right: parent.right

                height: 35
                implicitWidth: isCharging ? 75 : 55
                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 200
                    }
                }

                radius: 10

                color: "#080808"

                RowLayout {

                    anchors.fill: parent
                    spacing: 5

                    Rectangle {
                        color: "transparent"
                        clip: true

                        Layout.fillHeight: true
                        Layout.leftMargin: battery.isCharging ? 5 : 10

                        implicitWidth: battery.isCharging ? 15 : 0
                        scale: battery.isCharging ? 1 : 0
                        opacity: battery.isCharging ? 1 : 0

                        Behavior on implicitWidth {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                            }
                        }

                        Image {

                            anchors.centerIn: parent

                            source: "/home/andrw/.files/ags_new_old/icons/i-zap.svg"
                            sourceSize: "18x18"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: battery.isCharging ? -13 : -16
                        Behavior on Layout.leftMargin {
                            NumberAnimation {
                                duration: 200
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            font.bold: true
                            font.pixelSize: 16

                            color: "#d8d8d8"
                            text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                        }
                    }
                }
            }
        }
    }
}

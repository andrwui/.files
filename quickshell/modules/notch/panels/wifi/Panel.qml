pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
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

    readonly property var wifiDevice: {
        var devices = Networking.devices ? Networking.devices.values : [];
        for (var i = 0; i < devices.length; ++i) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    function signalIcon(strength) {
        if (strength > 0.66)
            return 'wifi/wifi-hi';
        if (strength > 0.33)
            return 'wifi/wifi-mid';
        return 'wifi/wifi-lo';
    }

    function needsPassword(network) {
        return network
            && network.security !== WifiSecurityType.Open
            && (network.security === WifiSecurityType.WpaPsk
                || network.security === WifiSecurityType.Wpa2Psk
                || network.security === WifiSecurityType.Sae);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.constants.spacing / 2

        RowLayout {
            Layout.fillWidth: true

            BackButton {
                text: 'Wifi'
                Layout.fillWidth: true
            }

            Text {
                text: 'Wifi'
                font.pixelSize: 13
                color: Config.colors.secondaryLight
            }

            CustomSwitch {
                checked: Networking.wifiEnabled
                onToggled: Networking.wifiEnabled = checked
            }

            Text {
                text: 'Scan'
                font.pixelSize: 13
                color: Config.colors.secondaryLight
            }

            CustomSwitch {
                checked: root.wifiDevice && root.wifiDevice.scannerEnabled
                onToggled: {
                    if (root.wifiDevice)
                        root.wifiDevice.scannerEnabled = checked;
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: 'VPN'
                font.pixelSize: 13
                color: Config.colors.secondaryLight
            }

            Item {
                Layout.fillWidth: true
            }

            Spinner {
                width: 16
                height: 16
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                visible: VpnState.isWaiting
            }

            CustomSwitch {
                id: vpnSwitch
                Component.onCompleted: vpnSwitch.checked = VpnState.active;
                onToggled: {
                    if (vpnSwitch.checked)
                        VpnState.connect();
                    else
                        VpnState.disconnect();
                }
            }
        }

        Connections {
            target: VpnState
            function onActiveChanged() {
                vpnSwitch.checked = VpnState.active;
            }
        }

        ListView {
            id: networksList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.constants.spacing / 2
            clip: true

            model: root.wifiDevice ? root.wifiDevice.networks : null

            delegate: Rectangle {
                required property var modelData
                property bool showPassword: false
                property string psk: ''

                readonly property bool passwordOpen: showPassword && !modelData.connected

                width: networksList.width
                height: passwordOpen ? 100 : 48
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
                        Layout.fillHeight: true
                        spacing: Config.constants.spacing / 2

                        CustomIcon {
                            Layout.alignment: Qt.AlignVCenter
                            iconName: root.signalIcon(modelData.signalStrength)
                            height: 24
                            width: 24
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: modelData.name || 'Unknown network'
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            color: Config.colors.foreground
                        }

                        Spinner {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            visible: modelData.stateChanging
                        }

                        ShrinkButton {
                            Layout.alignment: Qt.AlignVCenter
                            width: 70
                            height: 24
                            visible: !modelData.stateChanging
                            onClicked: {
                                if (modelData.connected)
                                    modelData.disconnect();
                                else if (root.needsPassword(modelData) && !modelData.known)
                                    showPassword = true;
                                else
                                    modelData.connect();
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: Config.colors.secondaryDark

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.connected ? 'Disconnect' : 'Connect'
                                    font.pixelSize: 12
                                    color: Config.colors.foreground
                                }
                            }
                        }

                        ShrinkButton {
                            Layout.alignment: Qt.AlignVCenter
                            width: 24
                            height: 24
                            visible: modelData.known
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

                    RowLayout {
                        Layout.fillWidth: true
                        visible: passwordOpen
                        spacing: Config.constants.spacing / 2

                        Text {
                            text: 'Password'
                            font.pixelSize: 12
                            color: Config.colors.secondaryLight
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 28
                            radius: 6
                            color: Config.colors.secondaryDark
                            border.color: Config.colors.secondaryDark
                            border.width: 1

                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                color: Config.colors.foreground
                                font.pixelSize: 14
                                text: psk
                                onTextChanged: psk = text
                            }
                        }

                        ShrinkButton {
                            width: 60
                            height: 28
                            onClicked: {
                                modelData.connectWithPsk(psk);
                                psk = '';
                                showPassword = false;
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: Config.colors.secondaryDark

                                Text {
                                    anchors.centerIn: parent
                                    text: 'Join'
                                    font.pixelSize: 12
                                    color: Config.colors.foreground
                                }
                            }
                        }
                    }
                }

                Connections {
                    target: modelData
                    function onConnectionFailed(reason) {
                        if (reason === ConnectionFailReason.NoSecrets)
                            showPassword = true;
                    }
                    function onConnectedChanged() {
                        if (modelData.connected)
                            showPassword = false;
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !root.wifiDevice || !Networking.wifiEnabled || root.wifiDevice.networks.count === 0
        text: !Networking.wifiEnabled || !root.wifiDevice
            ? 'Wifi off'
            : 'No networks'
        font.pixelSize: 13
        color: Config.colors.secondaryLight
    }
}

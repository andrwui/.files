import QtQuick
import Quickshell.Networking

Rectangle {
    id: root

    width: 300
    height: 185
    color: 'transparent'

    property var wifiDevice: Networking.devices.values.find(adapter => "Wifi" === DeviceType.toString(adapter.type))

    Component.onCompleted: {
        wifiDevice.scannerEnabled = true;
    }

    property var networks: wifiDevice.networks.values

    ListView {
        anchors.fill: parent
        model: root.networks

        delegate: Rectangle {
            width: ListView.view.width
            height: 40
            color: 'transparent'

            required property var modelData
            property WifiNetwork network: modelData

            Text {
                anchors.centerIn: parent
                text: network.name
                color: 'white'
                font.pixelSize: 20
                font.bold: true
            }
        }
    }
}

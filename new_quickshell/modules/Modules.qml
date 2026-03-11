pragma Singleton
import QtQuick
import qs.modules.power as Power
import qs.modules.bluetooth as Bluetooth
import qs.modules.wifi as Wifi
import qs.modules.other as Other

QtObject {
    property var items: [
        {
            notchItem: powerNotchItem,
            hoverComponent: powerHover,
            activeComponent: powerActive
        },
        {
            notchItem: bluetoothNotchItem,
            hoverComponent: bluetoothHover,
            activeComponent: bluetoothActive
        },
        {
            notchItem: wifiNotchItem,
            hoverComponent: wifiHover,
            activeComponent: wifiActive
        },
        {
            notchItem: otherNotchItem,
            hoverComponent: otherHover,
            activeComponent: otherActive
        }
    ]

    property Component powerActive: Power.Active {}
    property Component powerNotchItem: Power.NotchItem {}
    property Component powerHover: Power.Hover {}

    property Component bluetoothActive: Bluetooth.Active {}
    property Component bluetoothNotchItem: Bluetooth.NotchItem {}
    property Component bluetoothHover: Bluetooth.Hover {}

    property Component wifiActive: Wifi.Active {}
    property Component wifiNotchItem: Wifi.NotchItem {}
    property Component wifiHover: Wifi.Hover {}

    property Component otherActive: Other.Active {}
    property Component otherNotchItem: Other.NotchItem {}
    property Component otherHover: Other.Hover {}
}

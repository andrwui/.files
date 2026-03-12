pragma Singleton
import QtQuick
import qs.modules.power as Power
import qs.modules.bluetooth as Bluetooth
import qs.modules.wifi as Wifi
import qs.modules.other as Other
import qs.modules.time as Time

QtObject {
    id: root

    property list<NotchModule> items: [
        NotchModule {
            name: 'power'
            notchItem: root.powerNotchItem
            hoverComponent: root.powerHover
            activeComponent: root.powerActive
        },
        NotchModule {
            name: 'bluetooth'
            notchItem: root.bluetoothNotchItem
            hoverComponent: root.bluetoothHover
            activeComponent: root.bluetoothActive
        },
        NotchModule {
            name: 'time'
            notchItem: root.timeNotchItem
            hoverComponent: root.timeHover
            activeComponent: root.timeActive
        },
        NotchModule {
            name: 'wifi'
            notchItem: root.wifiNotchItem
            hoverComponent: root.wifiHover
            activeComponent: root.wifiActive
        },
        NotchModule {
            name: 'other'
            notchItem: root.otherNotchItem
            hoverComponent: root.otherHover
            activeComponent: root.otherActive
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

    property Component timeActive: Time.Active {}
    property Component timeNotchItem: Time.NotchItem {}
    property Component timeHover: Time.Hover {}
}

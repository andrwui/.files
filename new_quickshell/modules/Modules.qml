pragma Singleton
import QtQuick
import qs.models.notch
import qs.modules.notifications as Notifications
import qs.modules.bluetooth as Bluetooth
import qs.modules.wifi as Wifi
import qs.modules.other as Other
import qs.modules.time as Time
import qs.modules.tray as Tray
import qs.modules.servers as Servers

QtObject {
    id: root

    property list<NotchModuleModel> items: [
        NotchModuleModel {
            name: 'bluetooth'
            notchItem: root.bluetoothNotchItem
            hoverComponent: root.bluetoothHover
            activeComponent: root.bluetoothActive
        },
        NotchModuleModel {
            name: 'wifi'
            notchItem: root.wifiNotchItem
            hoverComponent: root.wifiHover
            activeComponent: root.wifiActive
        },
        NotchModuleModel {
            name: 'notifications'
            notchItem: root.notificationsNotchItem
            hoverComponent: root.notificationsHover
            activeComponent: root.notificationsActive
        },
        NotchModuleModel {
            name: 'time'
            notchItem: root.timeNotchItem
            hoverComponent: root.timeHover
            activeComponent: root.timeActive
        },
        NotchModuleModel {
            name: 'other'
            notchItem: root.otherNotchItem
            hoverComponent: root.otherHover
            activeComponent: root.otherActive
        },
        NotchModuleModel {
            name: 'servers'
            notchItem: root.serversNotchItem
            hoverComponent: root.serversHover
            activeComponent: root.serversActive
        },
        NotchModuleModel {
            name: 'tray'
            notchItem: root.trayNotchItem
            hoverComponent: root.trayHover
            activeComponent: root.trayActive
        }
    ]

    property Component bluetoothActive: Bluetooth.Active {}
    property Component bluetoothNotchItem: Bluetooth.NotchItem {}
    property Component bluetoothHover: Bluetooth.Hover {}

    property Component wifiActive: Wifi.Active {}
    property Component wifiNotchItem: Wifi.NotchItem {}
    property Component wifiHover: Wifi.Hover {}

    property Component notificationsActive: Notifications.Active {}
    property Component notificationsNotchItem: Notifications.NotchItem {}
    property Component notificationsHover: Notifications.Hover {}

    property Component timeActive: Time.Active {}
    property Component timeNotchItem: Time.NotchItem {}
    property Component timeHover: Time.Hover {}

    property Component otherActive: Other.Active {}
    property Component otherNotchItem: Other.NotchItem {}
    property Component otherHover: Other.Hover {}

    property Component serversActive: Servers.Active {}
    property Component serversNotchItem: Servers.NotchItem {}
    property Component serversHover: Servers.Hover {}

    property Component trayActive: Tray.Active {}
    property Component trayNotchItem: Tray.NotchItem {}
    property Component trayHover: Tray.Hover {}
}

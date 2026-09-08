pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import qs.models.notch
import qs.modules.notch.panels.time as Time
import qs.modules.notch.panels.servers as Servers
import qs.modules.notch.panels.notifications as Notifications
import qs.modules.notch.panels.emergent as Emergent
import qs.modules.notch.panels.bluetooth as BluetoothModule
import qs.modules.notch.panels.wifi as WifiModule
import qs.modules.notch.panels.sudo as SudoPanel
import qs.state
import qs.config

QtObject {
    id: root

    property list<NotchPanelModel> items: [
        NotchPanelModel {
            id: wifi
            name: 'wifi'
            width: 400
            height: 500
            radius: 40
            notchItem: WifiModule.NotchItem {}
            panel: WifiModule.Panel {
                width: wifi.width
                height: wifi.height
            }
        },
        NotchPanelModel {
            id: bluetooth
            name: 'bluetooth'
            width: 400
            height: 500
            radius: 40
            notchItem: BluetoothModule.NotchItem {}
            panel: BluetoothModule.Panel {
                width: bluetooth.width
                height: bluetooth.height
            }
        },
        NotchPanelModel {
            id: time
            name: 'time'
            width: 400
            height: 520
            radius: 40
            notchItem: Time.NotchItem {}
            panel: Time.Panel {
                width: time.width
                height: time.height
            }
        },
        NotchPanelModel {
            id: servers
            name: 'servers'
            width: 400
            height: 500
            radius: 40
            notchItem: Servers.NotchItem {}
            panel: Servers.Panel {
                width: servers.width
                height: servers.height
            }
        },
        NotchPanelModel {
            id: notifications
            name: 'notifications'
            width: 400
            height: 500
            radius: 40
            notchItem: Notifications.NotchItem {}
            panel: Notifications.Panel {
                width: notifications.width
                height: notifications.height
            }
        }
    ]

    property NotchPanelModel emergentNotification: NotchPanelModel {
        id: emergent
        name: 'emergent'
        width: Config.constants.notchHomeLayoutWidth + 80
        height: 80
        radius: 40
        panel: Emergent.Panel {
            width: emergent.width
            height: emergent.height
        }
    }

    property NotchPanelModel sudo: NotchPanelModel {
        id: sudoPanel
        name: 'sudo'
        width: 350
        height: 220
        radius: 40
        panel: SudoPanel.Panel {
            width: sudoPanel.width
            height: sudoPanel.height
        }
    }
}

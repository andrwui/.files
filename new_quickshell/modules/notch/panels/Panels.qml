pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import qs.models.notch
import qs.modules.notch.panels.time as Time
import qs.modules.notch.panels.servers as Servers
import qs.modules.notch.panels.notifications as Notifications
import qs.modules.notch.panels.emergent as Emergent
import qs.state
import qs.config

QtObject {
    id: root

    property list<NotchPanelModel> items: [
        NotchPanelModel {
            id: servers
            name: 'servers'
            width: 450
            height: Math.min(Math.max((SystemState.servers.count * (Config.constants.spacing * 3) + (Config.constants.spacing * 3)), 100), 300)
            radius: 30
            notchItem: Servers.NotchItem {}
            panel: Servers.Panel {
                width: servers.width
                height: servers.height
            }
        },
        NotchPanelModel {
            id: time
            name: 'time'
            width: 400
            height: 520
            radius: 30
            notchItem: Time.NotchItem {}
            panel: Time.Panel {
                width: time.width
                height: time.height
            }
        },
        NotchPanelModel {
            id: notifications
            name: 'notifications'
            width: 400
            height: 500
            radius: 200
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
}

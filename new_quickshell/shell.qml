import QtQuick
import Quickshell
import qs.notch
import qs.modules
import qs.modules.workspaces
import qs.state

Scope {

    Component.onCompleted: {
        CalendarState.init();
        SystemState.init();
    }

    PanelWindow {
        id: bar
        color: 'transparent'

        implicitHeight: 1080
        exclusiveZone: 35
        margins.left: 5
        margins.top: 5
        margins.right: 5

        mask: Region {
            regions: [notchRegion, trayRegion]
        }

        Region {
            id: notchRegion
            item: notch
        }

        Region {
            id: trayRegion
            item: tray
        }

        anchors {
            top: true
            left: true
            right: true
        }

        Workspaces {}

        Notch {
            id: notch
            items: Modules.items.map(item => item.notchItem)
        }

        NotchTray {
            id: tray
        }
    }
}

import QtQuick
import Quickshell
import qs.modules.notch
import qs.modules.workspaces
import qs.modules.notch.panels
import qs.state
import qs.config

Scope {

    Component.onCompleted: {
        CalendarState.init();
        SystemState.init();
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            screen: modelData

            color: 'transparent'

            implicitHeight: 1080
            exclusiveZone: 35
            margins.left: 5
            margins.top: 5
            margins.right: 5

            mask: Region {
                regions: [notchRegion]
            }

            Region {
                id: notchRegion
                item: notch
            }

            anchors {
                top: true
                left: true
                right: true
            }

            height: Config.constants.notchHeight

            Workspaces {
                anchors.left: parent.left
            }

            Notch {
                id: notch
                items: Panels.items.map(item => item.notchItem)
            }
        }
    }
}

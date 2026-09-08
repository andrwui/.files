import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.notch
import qs.modules.workspaces
import qs.modules.notch.panels
import qs.state
import qs.config
import qs.modules.battery
import qs.ocr
import qs.clipboard

Scope {

    Ocr {}
    Clipboard {}

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

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            implicitHeight: 1080
            exclusiveZone: 35
            margins.left: 5
            margins.top: 5
            margins.right: 5

            mask: Region {
                regions: [notchRegion, batteryRegion]
            }

            Region {
                id: notchRegion
                item: hoverZone
            }

            Region {
                id: batteryRegion
                item: batteryPill
            }

            anchors {
                top: true
                left: true
                right: true
            }

            Workspaces {
                anchors.left: parent.left
            }

            Notch {
                id: notch
                items: Panels.items.map(item => item.notchItem)
            }

            Rectangle {
                id: hoverZone
                width: notch.width + Config.constants.spacing
                height: notch.height + Config.constants.spacing
                color: 'transparent'
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: notch.verticalCenter

                HoverHandler {
                    onHoveredChanged: {
                        if (hovered) {
                            NotchState.enterNotch();
                        } else {
                            NotchState.exitNotch();
                        }
                    }
                }
            }

            Battery {
                id: batteryPill
            }
        }
    }
}

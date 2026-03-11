import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

Rectangle {
    id: workspaces
    implicitHeight: 35
    implicitWidth: row.implicitWidth + 20
    clip: true
    color: '#111111'
    radius: 10

    Behavior on implicitWidth {
        Anim {}
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutSine
            }
        }

        Repeater {
            model: Hyprland.workspaces
            Rectangle {
                id: workspace
                required property HyprlandWorkspace modelData
                color: modelData.id === Hyprland.focusedWorkspace.id ? Config.colors.foreground : Config.colors.secondary
                implicitWidth: modelData.id === Hyprland.focusedWorkspace.id ? 35 : 15
                implicitHeight: 15
                radius: 5

                Behavior on implicitWidth {
                    Anim {}
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                        easing.type: Easing.OutSine
                    }
                }
            }
        }
    }
}

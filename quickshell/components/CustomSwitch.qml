import QtQuick
import QtQuick.Controls
import qs.config
import qs.components

Switch {
    id: control

    indicator: Rectangle {
        width: 30
        height: 15
        radius: 10
        color: control.checked ? '#FFFFFF' : '#222222'

        x: control.leftPadding

        Behavior on color {
            ColorAnim {}
        }

        Rectangle {
            width: 13
            height: 13

            radius: 10
            color: control.checked ? Config.colors.base : Config.colors.foreground

            x: control.checked ? parent.width - (width + 2) : 2
            anchors.verticalCenter: parent.verticalCenter

            Behavior on x {
                Anim {}
            }

            Behavior on color {
                ColorAnim {}
            }
        }
    }
}

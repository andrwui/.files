import QtQuick
import qs.config
import qs.components

Rectangle {
    width: 300
    height: 85

    color: "transparent"
    BaseText {
        anchors.centerIn: parent
        text: 'You have clicked bitch: BLUETOOTH'
        color: Config.colors.foreground
    }
}

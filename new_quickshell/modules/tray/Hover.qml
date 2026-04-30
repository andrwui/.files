import QtQuick
import qs.components
import qs.config

Rectangle {
    width: 200
    height: 35
    color: "transparent"
    BaseText {
        anchors.centerIn: parent
        color: Config.colors.foreground
        text: 'Tray'
    }
}

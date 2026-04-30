import QtQuick
import qs.config
import qs.components

Rectangle {
    width: 200
    height: 35
    color: "transparent"
    BaseText {
        anchors.centerIn: parent
        text: 'Other'
        color: Config.colors.foreground
    }
}

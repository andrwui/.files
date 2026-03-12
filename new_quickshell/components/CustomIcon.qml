import QtQuick
import Quickshell.Widgets

Image {
    id: icon

    required property string iconName
    source: `root:/icons/${iconName}.svg`
    sourceSize: Qt.size(28, 28)
    fillMode: Image.PreserveAspectFit
    antialiasing: true
    smooth: true

    width: 18
    height: 18

    anchors.centerIn: parent
}

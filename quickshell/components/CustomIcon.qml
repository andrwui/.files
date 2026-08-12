import QtQuick
import Quickshell.Widgets

Image {
    id: icon

    required property string iconName
    source: `root:/icons/${iconName}.svg`
    sourceSize: Qt.size(24, 24)
    fillMode: Image.PreserveAspectFit
    antialiasing: true
    smooth: true

    width: 20
    height: 20
}

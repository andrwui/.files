import QtQuick.Layouts
import qs.config
import QtQuick

Image {
    id: icon

    required property string iconName
    source: `root:/icons/${iconName}.svg`
    sourceSize: Qt.size(24, 24)
    fillMode: Image.PreserveAspectFit
    antialiasing: true
    smooth: true

    width: Config.constants.iconSize
    height: Config.constants.iconSize
    Layout.preferredWidth: Config.constants.iconSize
    Layout.preferredHeight: Config.constants.iconSize
}

import QtQuick

Item {
    id: root

    property real pressedScale: 0.8

    signal clicked(var mouse)

    Item {
        id: content
        anchors.fill: parent
        scale: ma.pressed ? root.pressedScale : 1
        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: 120
            }
        }
    }

    default property alias data: content.data

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: false

        onClicked: root.clicked(mouse)
        cursorShape: Qt.PointingHandCursor
    }
}

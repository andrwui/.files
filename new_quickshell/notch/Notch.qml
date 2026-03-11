pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import qs.state
import qs.config

Rectangle {
    id: notch

    required property var items

    color: Config.colors.base
    width: Config.notchSize.width
    height: Config.notchSize.height

    radius: 10

    anchors.horizontalCenter: parent.horizontalCenter

    Rectangle {

        color: 'transparent'

        width: parent.width / 2
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        RowLayout {
            id: notchItemsRow
            anchors.fill: parent
            spacing: 10

            HoverHandler {
                id: notchMouseArea
                onHoveredChanged: () => {
                    NotchState.isNotchHovered = notchMouseArea.hovered;
                }
            }

            Repeater {
                model: notch.items

                delegate: Rectangle {
                    id: notchItem

                    required property int index

                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    width: 40

                    radius: 10

                    color: 'transparent'

                    MouseArea {
                        z: 5
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: () => {
                            NotchState.itemHovered = parent.index;
                            NotchState.itemAlignment = notchItem.mapToItem(notch, notchItem.width / 2, 0).x;
                        }

                        onClicked: NotchState.hasClicked = !NotchState.hasClicked
                    }

                    Loader {
                        id: notchItemLoader
                        anchors.fill: parent
                        sourceComponent: notch.items[parent.index]
                    }
                }
            }
        }
    }
}

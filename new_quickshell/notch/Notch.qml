import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import "../singleton"
import "../components"

Rectangle {
    id: notch

    color: '#111111'
    width: Constants.notchWidth
    height: Constants.notchHeight

    Component.onCompleted: {
        NotchState.notchGlobalPosition.left = notch.mapToGlobal(0, 0).x;
        NotchState.notchGlobalPosition.right = notch.mapToGlobal(0, 0).x + notch.width;
    }

    radius: 10

    anchors.horizontalCenter: parent.horizontalCenter

    HoverHandler {
        id: notchMouseArea
        onHoveredChanged: () => {
            NotchState.isHovered = notchMouseArea.hovered;
        }
    }

    RowLayout {
        id: notchItemsRow
        anchors.fill: parent
        spacing: 1

        Repeater {
            model: 3

            delegate: Rectangle {
                id: notchItem

                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: 10

                color: '#111111'

                MouseArea {
                    z: 5
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: () => {
                        console.log('entered', index);
                        NotchState.itemHovered = index;
                        NotchState.itemAlignment = notchItem.mapToItem(notch, notchItem.width / 2, 0).x;
                    }
                }

                Text {

                    text: index + 1
                    anchors.centerIn: parent
                    color: 'white'
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import qs.state
import qs.config
import qs.modules
import qs.components

Rectangle {
    id: notch

    required property var items

    width: Config.notchSize.width
    height: Config.notchSize.height

    color: Config.colors.base
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

            HoverHandler {
                id: notchMouseArea
                onHoveredChanged: () => {
                    if (notchMouseArea.hovered) {
                        NotchState.enterNotch();
                    } else {
                        NotchState.exitNotch();
                    }
                }
            }

            Repeater {
                model: notch.items

                delegate: Rectangle {
                    id: notchItem

                    color: 'transparent'

                    required property int index

                    Layout.fillHeight: true

                    Layout.alignment: Qt.AlignHCenter

                    width: Modules.items[index].name === 'time' ? 50 : 25

                    MouseArea {
                        id: itemMouseArea
                        z: 5
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: () => {
                            NotchState.itemHovered = Modules.items[parent.index];
                            NotchState.itemAlignment = notchItem.mapToItem(notch, notchItem.width / 2, 0).x;
                        }

                        onClicked: NotchState.hasClicked = !NotchState.hasClicked
                        cursorShape: Qt.PointingHandCursor
                    }

                    Loader {
                        id: notchItemLoader
                        opacity: NotchState.itemHovered === Modules.items[parent.index] && NotchState.isHovered ? 1 : itemMouseArea.containsMouse ? 1 : 0.7
                        asynchronous: true
                        anchors.fill: parent
                        sourceComponent: notch.items[parent.index]

                        Behavior on opacity {
                            Anim {}
                        }
                    }
                }
            }
        }
    }
}

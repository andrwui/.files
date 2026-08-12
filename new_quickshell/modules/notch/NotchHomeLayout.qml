pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import qs.state
import qs.config
import qs.modules.notch.panels
import qs.components

Rectangle {
    id: root

    property var items

    color: 'transparent'

    width: Config.constants.notchHomeLayoutWidth
    height: Config.constants.notchHomeLayoutHeight

    RowLayout {
        id: notchItemsRow
        anchors.fill: parent

        Repeater {
            model: root.items

            delegate: Rectangle {
                id: notchItem

                color: 'transparent'

                required property int index

                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                width: Panels.items[index].name === 'time' ? 50 : 15
                height: 15

                MouseArea {
                    id: notchMouseArea
                    cursorShape: Qt.PointingHandCursor
                    onClicked: () => {
                        NotchState.activePanel = Panels.items[parent.index];
                    }

                    anchors.fill: parent
                }

                Loader {
                    id: notchItemLoader
                    asynchronous: true
                    anchors.fill: parent
                    sourceComponent: root.items[parent.index]

                    Behavior on opacity {
                        Anim {}
                    }
                }
            }
        }
    }
}

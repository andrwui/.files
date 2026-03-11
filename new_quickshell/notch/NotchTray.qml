import QtQuick
import qs.components
import qs.state
import qs.modules

Item {
    id: notchTray

    // properties
    default property alias content: contentItem.data

    property bool hasChildren: contentItem.children.length > 0
    property bool childrenHasWidth: hasChildren && contentItem.children[0].implicitWidth > 0
    property bool childrenHasHeight: hasChildren && contentItem.children[0].implicitHeight > 0

    property real targetWidth: hasChildren && childrenHasWidth ? contentItem.children[0].implicitWidth : 0
    property real targetHeight: !NotchState.isHovered ? 0 : hasChildren && childrenHasHeight ? contentItem.children[0].implicitHeight : 0

    // dimensions
    implicitWidth: targetWidth
    implicitHeight: targetHeight

    onImplicitWidthChanged: NotchState.trayWidth = implicitWidth
    onImplicitHeightChanged: NotchState.trayWidth = implicitHeight

    z: -1

    clip: true

    anchors.top: parent.top
    anchors.topMargin: 35

    x: parent.width / 2 + NotchState.itemAlignment - targetWidth / 2 - 250

    // elements

    Popout {}

    Item {
        id: contentItem

        ViewTransitioner {
            anchors.fill: parent
            currentIndex: NotchState.itemHovered

            model: Modules.items.map(item => NotchState.hasClicked ? item.activeComponent : item.hoverComponent)
        }
    }

    HoverHandler {
        id: notchTrayMouseArea
        onHoveredChanged: () => {
            NotchState.isTrayHovered = notchTrayMouseArea.hovered;
        }
    }

    // animations

    Behavior on implicitHeight {
        Anim {}
    }

    Behavior on implicitWidth {
        Anim {}
    }

    Behavior on x {
        enabled: NotchState.isHovered
        Anim {}
    }
}

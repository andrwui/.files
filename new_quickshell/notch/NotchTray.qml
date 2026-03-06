import "../singleton"
import "../singleton"
import "../components"
import QtQuick

Rectangle {
    id: notchTray

    default property alias content: contentItem.data

    Item {
        id: contentItem
    }

    property bool hasChildren: contentItem.children.length > 0
    property bool childrenHasWidth: hasChildren && contentItem.children[0].implicitWidth > 0
    property bool childrenHasHeight: hasChildren && contentItem.children[0].implicitHeight > 0

    property real targetWidth: !NotchState.isHovered ? 0 : hasChildren && childrenHasWidth ? contentItem.children[0].implicitWidth : 0
    property real targetHeight: !NotchState.isHovered ? 0 : hasChildren && childrenHasHeight ? contentItem.children[0].implicitHeight : 0

    z: -1
    color: '#111111'
    clip: true
    implicitWidth: targetWidth
    implicitHeight: targetHeight

    onImplicitWidthChanged: NotchState.trayWidth = implicitWidth
    onImplicitHeightChanged: NotchState.trayWidth = implicitHeight

    onXChanged: {
        console.log('onX', x);
        NotchState.trayPosition.right = x + targetWidth;
        NotchState.trayPosition.left = x;
    }

    onChildrenChanged: {
        console.log(contentItem.childrenRect);
    }

    radius: 10

    anchors.top: parent.top
    anchors.topMargin: 25
    x: NotchState.isHovered ? parent.width / 2 + NotchState.itemAlignment - targetWidth / 2 - 100 : parent.width / 2

    HoverHandler {
        id: notchTrayMouseArea
        onHoveredChanged: () => {
            NotchState.isHovered = notchTrayMouseArea.hovered;
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuart
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuart
        }
    }

    Behavior on x {
        enabled: NotchState.isHovered
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}

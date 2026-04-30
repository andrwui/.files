import QtQuick
import QtQuick.Controls
import qs.components
import qs.state
import qs.config

Item {
    id: notchTray

    // properties

    property real targetWidth: stackView.currentItem.width
    property real targetHeight: NotchState.isHovered ? Math.max(stackView.currentItem.height, stackView.currentItem.implicitHeight) : 0

    // dimensions
    implicitWidth: targetWidth
    implicitHeight: targetHeight

    z: -1

    anchors.top: parent.top
    anchors.topMargin: 35

    clip: true

    x: parent.width / 2 + NotchState.itemAlignment - targetWidth / 2 - Config.notchSize.width / 2

    Popout {}

    Connections {
        target: NotchState
        function onItemHoveredChanged() {
            if (NotchState.hasClicked) {
                stackView.replace(NotchState.itemHovered.activeComponent);
            } else {
                stackView.replace(NotchState.itemHovered.hoverComponent);
            }
        }

        function onHasClickedChanged() {
            if (NotchState.hasClicked) {
                stackView.replace(NotchState.itemHovered.activeComponent);
            } else {
                stackView.replace(NotchState.itemHovered.hoverComponent);
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: NotchState.itemHovered.hoverComponent

        replaceEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                property: "scale"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        replaceExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
                easing.type: Easing.OutQuart
            }
            PropertyAnimation {
                property: "scale"
                from: 1
                to: 0
                duration: 200
                easing.type: Easing.OutQuart
            }
        }
    }

    HoverHandler {
        id: notchTrayMouseArea
        onHoveredChanged: () => {
            if (notchTrayMouseArea.hovered) {
                NotchState.enterTray();
            } else {
                NotchState.exitTray();
            }
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

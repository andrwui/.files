pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: notchState
    property int itemHovered: -1
    property bool isHovered: false
    property var itemAlignment
    property real trayTargetWidth: 0

    property QtObject trayPosition: QtObject {
        property real right: 0
        property real left: 0
    }

    property QtObject notchPosition: QtObject {
        property real left: 0
        property real right: 0
    }

    onIsHoveredChanged: {
        console.log(NotchState.isHovered);
    }
}

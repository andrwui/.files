pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: notchState
    property int itemHovered: -1
    property var itemAlignment

    property bool isTrayHovered: false
    property bool isNotchHovered: false

    readonly property bool isHovered: isTrayHovered || isNotchHovered

    property bool hasClicked: false
}

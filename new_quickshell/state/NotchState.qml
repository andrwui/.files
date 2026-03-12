pragma Singleton

import QtQuick
import Quickshell
import qs.modules

Singleton {
    id: notchState
    property NotchModule itemHovered: Modules.items[0]

    property var itemAlignment

    property bool isTrayHovered: false
    property bool isNotchHovered: false

    readonly property bool isHovered: isTrayHovered || isNotchHovered

    Timer {
        id: trayExitDelay
        interval: 1
        repeat: false
        onTriggered: notchState.isTrayHovered = false
    }

    Timer {
        id: notchExitDelay
        interval: 1
        repeat: false
        onTriggered: notchState.isNotchHovered = false
    }

    function enterTray() {
        trayExitDelay.stop();
        isTrayHovered = true;
    }
    function exitTray() {
        trayExitDelay.start();
    }

    function enterNotch() {
        notchExitDelay.stop();
        isNotchHovered = true;
    }

    function exitNotch() {
        notchExitDelay.start();
    }

    onIsHoveredChanged: {
        if (!isHovered) {
            hasClicked = false;
        }
    }

    property bool hasClicked: false
}

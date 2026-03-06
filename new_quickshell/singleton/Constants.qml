pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: constants

    property int notchWidth: 200
    property int notchHeight: 35

    property QtObject animations: QtObject {
        property int duration: 200
        property int easingType: Easing.InOutQuart
    }
}

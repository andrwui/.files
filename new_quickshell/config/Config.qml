pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property QtObject notchSize: QtObject {
        property int width: 550
        property int height: 35
    }

    property QtObject colors: QtObject {
        property string base: '#111111'
        property string foreground: '#ffffff'
        property string secondaryDark: '#222222'
        property string secondaryLight: '#444444'
    }

    property QtObject animations: QtObject {
        property int duration: 300
        property int easingType: Easing.OutQuart
    }
}

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property var notchSize: ({
            width: 500,
            height: 35
        })

    property var colors: ({
            base: '#111111',
            foreground: '#ffffff',
            secondary: '#222222'
        })

    property var animations: ({
            duration: 300,
            easingType: Easing.OutQuart
        })
}

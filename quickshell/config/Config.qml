pragma Singleton

import QtQuick
import Quickshell
import qs.models.config

Singleton {
    property ColorModel colors: ColorModel {
        base: '#080808'
        foreground: '#ffffff'
        secondaryDark: '#222222'
        secondaryLight: '#6a6a6a'
        error: '#ff5555'
    }

    property AnimationModel animations: AnimationModel {
        duration: 300
        easingType: Easing.OutQuad
        spring: 8.0
        damping: 0.6
    }

    property ConstantsModel constants: ConstantsModel {
        iconSize: 10

        notchHomeLayoutWidth: 300
        notchHomeLayoutHeight: 35

        popoutVMargin: 20

        fullRadius: 9999

        months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

        spacing: 20
    }
}

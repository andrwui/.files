pragma Singleton

import QtQuick
import Quickshell
import qs.models.config

Singleton {
    property ColorModel colors: ColorModel {
        property string base: '#111111'
        property string foreground: '#ffffff'
        property string secondaryDark: '#222222'
        property string secondaryLight: '#6a6a6a'
    }

    property AnimationModel animations: AnimationModel {
        property int duration: 300
        property int easingType: Easing.OutQuart
    }

    property ConstantsModel constants: ConstantsModel {
        property int notchWidth: 300
        property int notchHeight: 35

        property int popoutVMargin: 20
    }
}

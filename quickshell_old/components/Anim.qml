import QtQuick
import qs.config

NumberAnimation {
    duration: Config.animations.duration
    easing.type: Config.animations.easingType
}

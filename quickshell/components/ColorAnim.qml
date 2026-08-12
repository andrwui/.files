import QtQuick
import qs.config

ColorAnimation {
    duration: Config.animations.duration
    easing.type: Config.animations.easingType
}

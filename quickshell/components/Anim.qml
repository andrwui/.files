import QtQuick
import qs.config

SpringAnimation {
    spring: Config.animations.spring
    damping: Config.animations.damping
    epsilon: 0.01
}
